import gleeunit
import xml_parser/xml_parser

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn parse_test() {
  assert xml_parser.parse("") == [build_dummy_idm_pass()]
}

fn build_dummy_idm_pass() -> xml_parser.IDMPass {
  xml_parser.IDMItem(
    "",
    "",
    "",
    #("", ""),
    #("", ""),
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
  )
}
