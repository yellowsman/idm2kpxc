import converter
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn convert_test() {
  let body_xml =
    "<folder name=\"Dummy Folder\" open=\"true\" selected=\"false\">
        <item name=\"Dummy Service\" selected=\"false\">
            <account name=\"Account ID\">dummy_account</account>
            <password name=\"Password\">dummy_password</password>
            <item1 name=\"\">dummy_item1</item1>
            <item2 name=\"\"></item2>
            <serialNumber></serialNumber>
            <comment>comment1</comment>
            <url></url>
            <e-mail></e-mail>
            <file></file>
            <issueDate>09/01/9999</issueDate>
            <expirationDate>09/01/9999</expirationDate>
            <pasteType>0</pasteType>
        </item>
        <item name=\"Dummy Service2\" selected=\"false\">
            <account name=\"Account ID\">dummy_account2</account>
            <password name=\"Password\">&gt;W7`5ui</password>
            <item1 name=\"\">ダミーアイテム2-1</item1>
            <item2 name=\"2番目のダミーアイテム\">ダミーアイテム2-2</item2>
            <serialNumber></serialNumber>
            <comment>コメント2</comment>
            <url></url>
            <e-mail></e-mail>
            <file></file>
            <issueDate>09/01/9999</issueDate>
            <expirationDate>09/01/9999</expirationDate>
            <pasteType>0</pasteType>
        </item>
        <folder name=\"Nested Dummy Folder\" open=\"true\" selected=\"false\">
            <item name=\"Nested Dummy Service\" selected=\"false\">
                <account name=\"Account ID\">Nested dummy_account</account>
                <password name=\"Password\">Nested dummy_password</password>
                <item1 name=\"first item\">Nested dummy_item1</item1>
                <item2 name=\"\"></item2>
                <serialNumber></serialNumber>
                <comment>Nested comment1</comment>
                <url></url>
                <e-mail></e-mail>
                <file></file>
                <issueDate>09/01/9999</issueDate>
                <expirationDate>09/01/9999</expirationDate>
                <pasteType>0</pasteType>
            </item>
        </folder>
    </folder>
    <folder name=\"Empty Folder\" open=\"true\" selected=\"false\">
    </folder>
    <item name=\"TopLevel Item\" selected=\"false\">
        <account name=\"Account ID\">TopLevel dummy_account</account>
        <password name=\"Password\">TopLevel dummy_password</password>
        <item1 name=\"top level item\">TopLevel dummy_item1</item1>
        <item2 name=\"\"></item2>
        <serialNumber></serialNumber>
        <comment>TopLevel comment1</comment>
        <url></url>
        <e-mail></e-mail>
        <file></file>
        <issueDate>09/01/9999</issueDate>
        <expirationDate>09/01/9999</expirationDate>
        <pasteType>0</pasteType>
    </item>"

  let item1 =
    "Dummy Folder,Dummy Service,dummy_account,dummy_password,,\"comment1\n\n[item1]\ndummy_item1\",,,,,\n"
  let include_japanese_special_character_password =
    "Dummy Folder,Dummy Service2,dummy_account2,&gt;W7`5ui,,\"コメント2\n\n[item1]\nダミーアイテム2-1\n\n[2番目のダミーアイテム]\nダミーアイテム2-2\",,,,,\n"
  let nested_item =
    "Dummy Folder/Nested Dummy Folder,Nested Dummy Service,Nested dummy_account,Nested dummy_password,,\"Nested comment1\n\n[first item]\nNested dummy_item1\",,,,,\n"
  // top_level_itemの先頭のカンマはグループの空欄を表現している
  let top_level_item =
    ",TopLevel Item,TopLevel dummy_account,TopLevel dummy_password,,\"TopLevel comment1\n\n[top level item]\nTopLevel dummy_item1\",,,,,\n"

  let expect_csv =
    header()
    <> item1
    <> include_japanese_special_character_password
    <> nested_item
    <> top_level_item
  assert converter.convert(build_xml(body_xml)) == expect_csv
}

pub fn empty_xml_test() {
  assert converter.convert("") == ""
}

pub fn empty_item_xml_test() {
  assert converter.convert(build_xml("")) == ""
}

fn header() -> String {
  "group,title,user_name,password,url,memo,tag,totp,icon,updated_at,created_at\n"
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
