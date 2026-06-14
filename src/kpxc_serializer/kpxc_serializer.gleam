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

pub fn to_csv(_input: List(KPXC)) -> String {
  ""
}
