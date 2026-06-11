// todo モジュール名が xml_parser/xml_parserになっていて微妙だから直したい

pub type IDMPass {
  IDMItem(
    title: String,
    account: String,
    password: String,
    item1: #(String, String),
    item2: #(String, String),
    serial_number: String,
    comment: String,
    url: String,
    e_mail: String,
    file: String,
    issue_date: String,
    expiration_date: String,
    paste_type: String,
  )
  IDMFolder(title: String, children: List(IDMPass))
}

pub fn parse(_xml_text: String) -> List(IDMPass) {
  []
}
