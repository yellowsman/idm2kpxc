// todo モジュール名が idm_parser/idm_parserになっていて微妙だから直したい

pub type IDMPass {
  IDMItem(
    title: String,
    account: String,
    password: String,
    item1: #(String, String),
    item2: #(String, String),
    comment: String,
    url: String,
    serial_number: String,
    e_mail: String,
    file: String,
    issue_date: String,
    expiration_date: String,
    paste_type: String,
  )
  IDMFolder(title: String, children: List(IDMPass))
}

// 2. Erlangのブリッジ関数をバインド
@external(erlang, "xml_bridge", "parse_ordered")
pub fn parse_ordered(xml_string: String) -> List(IDMPass)

pub fn parse(xml_text: String) -> List(IDMPass) {
  // echo xml_text
  // []
  case xml_text {
    "" -> []
    _ -> parse_ordered(xml_text)
  }
}
