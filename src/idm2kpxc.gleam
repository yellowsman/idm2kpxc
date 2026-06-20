import argv
import converter
import gleam/io
import gleam/result
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
      // ファイル読み込み
      simplifile.read(input_file_path)
      |> result.unwrap("")
      // XMLテキストをCSVテキストに変換
      |> converter.convert()
      // ファイル書き込み
      |> simplifile.write(output_file_path, _)
      |> result.unwrap(Nil)

    _ ->
      io.println("usage: ./program -i <input_file_path> -o <output_file_path>")
  }
}
