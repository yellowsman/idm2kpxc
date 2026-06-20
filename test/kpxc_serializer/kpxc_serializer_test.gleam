import gleeunit
import kpxc_serializer/kpxc_serializer

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn kpxc_serialize_test() {
  let kpxc =
    build_kpxc("group1", "title1", "user_name1", "password1", "url1", "memo1")
  let expect_csv_text =
    header() <> "group1,title1,user_name1,password1,url1,memo1,,,,,\n"
  assert kpxc_serializer.to_csv([kpxc]) == expect_csv_text
}

pub fn empty_list_input_test() {
  assert kpxc_serializer.to_csv([]) == ""
}

fn header() -> String {
  "group,title,user_name,password,url,memo,tag,totp,icon,updated_at,created_at\n"
}

fn build_kpxc(
  group: String,
  title: String,
  user_name: String,
  password: String,
  url: String,
  memo: String,
) -> kpxc_serializer.KPXC {
  kpxc_serializer.KPXC(
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
