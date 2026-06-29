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
  io.println("Run idm2kpxc.")

  case arguments {
    [input_file_path, output_file_path]
    | ["-i", input_file_path, "-o", output_file_path]
    | ["--input", input_file_path, "--output", output_file_path] -> {
      let read_text =
        simplifile.read(input_file_path)
        |> result.unwrap("")

      case read_text {
        "" -> {
          io.println_error("Could not load the file or file empty.")
        }
        _ -> {
          let convert_text = converter.convert(read_text)

          case convert_text {
            "" -> io.println_error("Convert process was unsuccessful.")
            _ -> {
              let _ = simplifile.write(output_file_path, convert_text)

              io.println("Export success!")
              io.println("Output to " <> output_file_path)
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
