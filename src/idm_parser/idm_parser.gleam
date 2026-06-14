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

pub fn parse(_xml_text: String) -> List(IDMPass) {
  []
}
