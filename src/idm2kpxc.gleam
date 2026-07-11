import argv
import converter
import gleam/io
import gleam/string
import gleam_community/ansi
import gleave
import simplifile

pub fn main() -> Nil {
  argv.load().arguments
  |> run()
}

pub fn run(arguments: List(String)) -> Nil {
  case arguments {
    [input_file_path, output_file_path] -> {
      case simplifile.read(input_file_path) {
        Error(simplifile.NotUtf8) ->
          error_response("File encoding is not UTF-8.")
        Error(_) -> error_response("Could not load the file")
        Ok("") -> error_response("File is empty.")
        Ok(read_text) -> {
          case converter.convert(read_text) {
            "" -> error_response("Convert process was unsuccessful.")
            convert_text -> {
              case simplifile.write(output_file_path, convert_text) {
                Error(simplifile.Enoent) ->
                  error_response("No such file or directory.")
                Error(_) -> error_response("Could not write the file")
                Ok(_) -> io.println("Convert success!")
              }
            }
          }
        }
      }
    }
    _ -> help_message()
  }
}

fn error_response(message: String) -> Nil {
  io.println_error("[Error]" <> message)
  // エラー時はステータスコードを1(失敗)にする
  gleave.exit(1)
}

fn help_message() -> Nil {
  [
    "Converts ID Manager backup files into a KeePassXC importable format.\n",
    "This program converts an ID Manager exported backup file into a format compatible with KeePassXC.",
    "Backup file must be UTF-8 (convert from Shift-JIS before running).\n",
    string.concat([
      text_yellow("Usage:"),
      " ",
      text_green("./idm2kpxc"),
      " ",
      "<XML_FILE_PATH> <CSV_FILE_PATH>\n",
    ]),
    text_yellow("Arguments:"),
    "  <XML_FILE_PATH>  ID Manager backup file (XML format): must be UTF-8 (convert from Shift-JIS before running).",
    "  <CSV_FILE_PATH>  KeePassXC-importable file (CSV format) generated at the specified path.\n",
    text_yellow("Options:"),
    string.concat([text_green("  -h, --help"), "  Print help."]),
  ]
  |> string.join(with: "\n")
  |> io.println()
}

fn text_yellow(text: String) -> String {
  ansi.yellow(text)
}

fn text_green(text: String) -> String {
  ansi.green(text)
}
