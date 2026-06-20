import gleam/list
import gsv

pub type KPXC {
  KPXC(
    group: String,
    title: String,
    user_name: String,
    password: String,
    url: String,
    memo: String,
    tag: String,
    totp: String,
    icon: String,
    updated_at: String,
    created_at: String,
  )
}

pub fn build_kpxc(
  group: String,
  title: String,
  user_name: String,
  password: String,
  url: String,
  memo: String,
) -> KPXC {
  KPXC(
    group:,
    title:,
    user_name:,
    password:,
    url:,
    memo:,
    tag: "",
    totp: "",
    icon: "",
    updated_at: "",
    created_at: "",
  )
}

pub fn to_csv(input: List(KPXC)) -> String {
  case input {
    [] -> ""
    _ -> list.map(input, convert_list) |> convert_csv()
  }
}

fn header() -> List(String) {
  [
    "group",
    "title",
    "user_name",
    "password",
    "url",
    "memo",
    "tag",
    "totp",
    "icon",
    "updated_at",
    "created_at",
  ]
}

fn convert_list(data: KPXC) -> List(String) {
  list.new()
  |> list.append([
    data.group,
    data.title,
    data.user_name,
    data.password,
    data.url,
    data.memo,
    data.tag,
    data.totp,
    data.icon,
    data.updated_at,
    data.created_at,
  ])
}

fn convert_csv(data: List(List(String))) -> String {
  gsv.from_lists(
    list.append([header()], data),
    separator: ",",
    line_ending: gsv.Unix,
  )
}
