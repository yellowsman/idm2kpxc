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
            <issueDate>09/07/2013</issueDate>
            <expirationDate>09/07/2014</expirationDate>
            <pasteType>0</pasteType>
        </item>
        </folder>"
  let expect_csv =
    header()
    <> "Dummy Folder,Dummy Service,dummy_account,dummy_password,,\"comment1\n\n[item1]\ndummy_item1\",,,,,\n"
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
