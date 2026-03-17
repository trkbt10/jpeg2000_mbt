///|
fn usage() -> Unit {
  println("usage:")
  println("  moon run src/cmd/wasm -- list-samples")
  println("  moon run src/cmd/wasm -- parse-sample [name]")
  println("  moon run src/cmd/wasm -- sample-hex [name]")
  println("  moon run src/cmd/wasm -- roundtrip-hex <hex>")
  println("  moon run src/cmd/wasm -- decode <base64-bytes>")
}

///|
fn main {
  let args = @env.args()
  if @cli.dispatch_shared_commands(args) {
    return
  }
  if @cli.find_arg_index(args, "decode") is Some(i) {
    if i + 1 >= args.length() {
      usage()
      return
    }
    let input = @base64.decode(args[i + 1]) catch {
      _ => {
        println("error: invalid base64 input")
        return
      }
    }
    let result = try { @lib.decode(input) } catch {
      e => {
        println("error: \{e}")
        return
      }
    }
    println(
      "ok: w=\{result.width} h=\{result.height} comps=\{result.num_components} bits=\{result.bits_per_component} signed=\{result.is_signed} bytes=\{result.data.length()}",
    )
    return
  }
  usage()
}
