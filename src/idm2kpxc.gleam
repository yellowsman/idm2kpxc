import argv
import converter
import gleam/io
import gleam/result
import gleam/string
import simplifile

pub fn main() -> Nil {
  argv.load().arguments
  |> run()
}

pub fn run(arguments: List(String)) -> Nil {
  case arguments {
    [input_file_path, output_file_path]
    | ["-i", input_file_path, "-o", output_file_path]
    | ["--input", input_file_path, "--output", output_file_path] ->
      simplifile.read(input_file_path)
      // |> echo
      |> result.unwrap("")
      // |> echo
      // XMLテキストをCSVテキストに変換
      |> converter.convert()
      // |> reescape()
      |> echo
      // ファイル書き込み
      |> simplifile.write(output_file_path, _)
      |> result.unwrap(Nil)
    _ ->
      io.println("usage: ./program -i <input_file_path> -o <output_file_path>")
  }
}

fn reescape(raw_string: String) -> String {
  raw_string
  |> string.replace(each: "&", with: "&amp;")
  // 1. 必ず最初に単体の「&」を処理！
  |> string.replace(each: "<", with: "&lt;")
  // 2. あとは順不同
  |> string.replace(each: ">", with: "&gt;")
  // |> string.replace(each: "\"", with: "&quot;")
  |> string.replace(each: "'", with: "&apos;")
}
