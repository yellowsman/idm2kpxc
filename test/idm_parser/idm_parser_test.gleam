import gleeunit
import idm_parser/idm_parser

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn xml_parse_test() {
  // 正常系テスト
  let body_xml =
    "<folder name=\"Dummy Folder\" open=\"true\" selected=\"false\">
        <item name=\"Dummy Service\" selected=\"false\">
            <account name=\"Account ID\">dummy_account</account>
            <password name=\"Password\">dummy_password</password>
            <item1 name=\"\">dummy_item1</item1>
            <item2 name=\"\"></item2>
            <serialNumber></serialNumber>
            <comment>item1: dummy_item1</comment>
            <url></url>
            <e-mail></e-mail>
            <file></file>
            <issueDate>09/07/2013</issueDate>
            <expirationDate>09/07/2014</expirationDate>
            <pasteType>0</pasteType>
        </item>
        </folder>"

  assert idm_parser.parse(build_xml(body_xml))
    == [
      build_idm_pass_folder("Dummy Folder", [
        build_idm_pass_item(
          "Dummy Service",
          "dummy_account",
          "dummy_password",
          #("", "dummy_item1"),
          #("", ""),
          "item1: dummy_item1",
          "",
        ),
      ]),
    ]
}

// このテストケースは必要？
pub fn empty_text_test() {
  // XMLテキストが空文字の場合は空のList(IDMPass)を返す
  assert idm_parser.parse("") == []
}

pub fn empty_item_test() {
  // アイテムが無い場合はフォルダだけのリストを返す

  let body_xml =
    "<folder name=\"Dummy Folder\" open=\"true\" selected=\"false\"></folder>"

  assert idm_parser.parse(build_xml(body_xml))
    == [build_idm_pass_folder("Dummy Folder", [])]
}

pub fn empty_item_and_folder_test() {
  // アイテムもフォルダも無い場合は空リストを返す
  assert idm_parser.parse(build_xml("")) == []
}

// このテストいる？
// データを整えてから来てくださいって感じがする
// ここまではしなくて良い気がするから一旦はスキップで
pub fn invalid_idmpass_mapping_test() {
  // Recordへのマッピングに失敗する場合(要素が無い、属性が無い)は、そのデータはスキップする

  let body_xml =
    "<folder name=\"Dummy Folder\" open=\"true\" selected=\"false\">
        <item name=\"Dummy Service1\" selected=\"false\">
            <account name=\"Account ID\">dummy_account</account>
            <password name=\"Password\">dummy_password</password>
            <item1 name=\"\">dummy_item1</item1>
            <item2 name=\"\"></item2>
            <serialNumber></serialNumber>
            <comment>item1: dummy_item1</comment>
            <url></url>
            <e-mail></e-mail>
            <file></file>
            <issueDate>09/07/2013</issueDate>
            <expirationDate>09/07/2014</expirationDate>
            <pasteType>0</pasteType>
        </item>
        <item name=\"Dummy Service2\" selected=\"false\">
            <item1 name=\"\">dummy_item1</item1>
            <item2 name=\"\"></item2>
            <serialNumber></serialNumber>
            <comment>item1: dummy_item1</comment>
            <url></url>
            <e-mail></e-mail>
            <file></file>
            <issueDate>09/07/2013</issueDate>
            <expirationDate>09/07/2014</expirationDate>
            <pasteType>0</pasteType>
        </item>
        </folder>"
  assert idm_parser.parse(build_xml(body_xml))
    == [
      build_idm_pass_folder("Dummy Folder", [
        build_idm_pass_item(
          "Dummy Service1",
          "dummy_account",
          "dummy_password",
          #("", "dummy_item1"),
          #("", ""),
          "item1: dummy_item1",
          "",
        ),
        build_idm_pass_item(
          "Dummy Service2",
          "dummy_account",
          "dummy_password",
          #("", "dummy_item1"),
          #("", ""),
          "item1: dummy_item1",
          "",
        ),
      ]),
    ]
}

fn build_idm_pass_folder(
  title: String,
  children: List(idm_parser.IDMPass),
) -> idm_parser.IDMPass {
  idm_parser.IDMFolder(title, children:)
}

fn build_idm_pass_item(
  title: String,
  account: String,
  password: String,
  item1: #(String, String),
  item2: #(String, String),
  comment: String,
  url: String,
) -> idm_parser.IDMPass {
  idm_parser.IDMItem(
    title,
    account,
    password,
    item1,
    item2,
    comment,
    url,
    "",
    "",
    "",
    "",
    "",
    "",
  )
}

fn build_xml(body: String) -> String {
  "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>
  <idmData>
      <familyName></familyName>
      <givenName></givenName>
      <familyNamePhonetic></familyNamePhonetic>
      <givenNamePhonetic></givenNamePhonetic>
      <familyNamePhonetic2></familyNamePhonetic2>
      <givenNamePhonetic2></givenNamePhonetic2>
      <e-mail1></e-mail1>
      <e-mail2></e-mail2>
      <e-mail3></e-mail3>
      <zip1></zip1>
      <prefecture1></prefecture1>
      <address1></address1>
      <zip2></zip2>
      <prefecture2></prefecture2>
      <address2></address2>
      <tel1></tel1>
      <tel2></tel2>
      <handlename1></handlename1>
      <handlename2></handlename2>
      <company></company>
      <defaultAccountName>Account ID</defaultAccountName>
      <defaultPasswordName>Password</defaultPasswordName>
      <defaultItem1Name></defaultItem1Name>
      <defaultItem2Name></defaultItem2Name>
      <pasteTypeList></pasteTypeList>" <> body <> "</idmData>"
}
