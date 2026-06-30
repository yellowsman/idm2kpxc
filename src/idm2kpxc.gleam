import argv
import converter
import gleam/io
import simplifile

pub fn main() -> Nil {
  argv.load().arguments
  |> run()
}

pub fn run(arguments: List(String)) -> Nil {
  case arguments {
    [input_file_path, output_file_path]
    | ["-i", input_file_path, "-o", output_file_path]
    | ["--input", input_file_path, "--output", output_file_path] -> {
      case simplifile.read(input_file_path) {
        Error(simplifile.NotUtf8) ->
          error_message("File encoding is not UTF-8.")
        Error(_) ->
          error_message(
            "Could not load the file, input_file_path: " <> input_file_path,
          )
        Ok("") -> error_message("Error: file empty.")
        Ok(read_text) -> {
          case converter.convert(read_text) {
            "" -> error_message("Convert process was unsuccessful.")
            convert_text -> {
              case simplifile.write(output_file_path, convert_text) {
                Error(_) ->
                  error_message(
                    "Could not write the file, output_file_path: "
                    <> output_file_path,
                  )
                Ok(_) -> {
                  io.println("Export success!")
                  io.println("Output to " <> output_file_path)
                }
              }
            }
          }
        }
      }
    }
    _ ->
      io.println("usage: ./program -i <input_file_path> -o <output_file_path>")
  }

  io.println("Finish idm2kpxc.")
}

fn error_message(message: String) -> Nil {
  io.println_error("[Error]" <> message)
}
