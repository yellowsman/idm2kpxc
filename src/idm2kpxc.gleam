import argv
import converter
import gleam/io
import gleam/string
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
          error_message("File encoding is not UTF-8.")
        Error(_) -> error_message("Could not load the file")
        Ok("") -> error_message("File is empty.")
        Ok(read_text) -> {
          case converter.convert(read_text) {
            "" -> error_message("Convert process was unsuccessful.")
            convert_text -> {
              case simplifile.write(output_file_path, convert_text) {
                Error(simplifile.Enoent) ->
                  error_message("No such file or directory.")
                Error(_) -> error_message("Could not write the file")
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

fn error_message(message: String) -> Nil {
  io.println_error("[Error]" <> message)
}

fn help_message() -> Nil {
  [
    "Converts ID Manager export files into a KeePassXC importable format\n",
    "This program converts an ID Manager exported backup file into a format compatible with KeePassXC",
    "Backup file must be UTF-8 (convert from Shift-JIS before running)\n",
    "Usage: ./idm2kpxc <XML_FILE_PATH> <CSV_FILE_PATH>\n",
    "Arguments:",
    "  <XML_FILE_PATH>  ID Manager Backup file (XML format): must be UTF-8 (convert from Shift-JIS before running)",
    "  <CSV_FILE_PATH>  KeePassXC-importable file (CSV format) generated at the specified path\n",
    "Options:",
    "  -h, --help  Print help",
  ]
  |> string.join(with: "\n")
  |> io.println()
}
