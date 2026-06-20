import gleam/list
import gleam/string
import idm_parser/idm_parser
import kpxc_serializer/kpxc_serializer

pub fn convert(xml_text: String) -> String {
  // 1. XMLテキストをパースしてList(IDMPASS)を得る
  idm_parser.parse(xml_text)
  // 2. List(IDMPASS)をList(KPXC)に変換する
  |> flatten()
  |> list.reverse()
  // 3. List(KPXC)をCSVテキストに変換して返却する
  |> kpxc_serializer.to_csv()
}

fn flatten(data: List(idm_parser.IDMPass)) -> List(kpxc_serializer.KPXC) {
  do_flatten("", data, [])
}

fn do_flatten(
  group: String,
  data: List(idm_parser.IDMPass),
  result: List(kpxc_serializer.KPXC),
) -> List(kpxc_serializer.KPXC) {
  case data {
    [] -> result
    [idm_parser.IDMItem(..) as idm_item, ..tail] ->
      do_flatten(group, tail, [
        kpxc_serializer.build_kpxc(
          group,
          idm_item.title,
          idm_item.account,
          idm_item.password,
          idm_item.url,
          build_comment(idm_item),
        ),
        ..result
      ])
    [idm_parser.IDMFolder(title, children), ..tail] -> {
      // 子要素
      // gruopを引き継ぐのでjoinして先頭の余計なスラッシュを取り除く
      let children_data =
        do_flatten(
          string.concat([group, "/", title]) |> string.remove_prefix("/"),
          children,
          result,
        )

      // 次の要素
      // list.appendを使わず最後にlist.reverseできるように子要素の結果を受け継いで並びを揃える
      do_flatten(group, tail, children_data)
    }
  }
}

fn build_comment(idm_item: idm_parser.IDMPass) -> String {
  case idm_item {
    idm_parser.IDMItem(
      item1: #(item1_key, item1_value),
      item2: #(item2_key, item2_value),
      comment:,
      ..,
    ) -> {
      case item1_value, item2_value {
        // どちらも空文字ならcommentをそのまま返す
        "", "" -> comment

        // item1だけ値が入っている
        _, "" -> {
          let i1key = case item1_key {
            "" -> "[item1]"
            _ -> string.concat(["[", item1_key, "]"])
          }
          append_item_to_comment(comment, i1key, item1_value)
        }

        // item2だけ値が入っている
        "", _ -> {
          let i2key = case item2_key {
            "" -> "[item2]"
            _ -> string.concat(["[", item2_key, "]"])
          }
          append_item_to_comment(comment, i2key, item2_value)
        }

        // 両方に値が入っている
        _, _ -> {
          let i1key = case item1_key {
            "" -> "[item1]"
            _ -> string.concat(["[", item1_key, "]"])
          }
          let i2key = case item2_key {
            "" -> "[item2]"
            _ -> string.concat(["[", item2_key, "]"])
          }
          append_item_to_comment(comment, i1key, item1_value)
          |> append_item_to_comment(i2key, item2_value)
        }
      }
    }
    _ -> ""
  }
}

fn append_item_to_comment(
  comment: String,
  key: String,
  value: String,
) -> String {
  string.concat([comment, "\n\n", key, "\n", value])
}
