///|
fn usage() -> Unit {
  println("usage:")
  println("  moon run cmd/wasm -- list-samples")
  println("  moon run cmd/wasm -- parse-sample [name]")
  println("  moon run cmd/wasm -- sample-hex [name]")
  println("  moon run cmd/wasm -- roundtrip-hex <hex>")
}

///|
fn main {
  let args = @env.args()
  if @cli.dispatch_shared_commands(args) {
    return
  }
  usage()
}
