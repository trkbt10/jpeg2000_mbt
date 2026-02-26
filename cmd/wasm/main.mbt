///|
fn usage() -> Unit {
  println("usage:")
  println("  moon run cmd/wasm -- list-samples")
  println("  moon run cmd/wasm -- parse-sample [name]")
  println("  moon run cmd/wasm -- sample-hex [name]")
  println("  moon run cmd/wasm -- roundtrip-hex <hex>")
}

///|
fn find_arg_index(args : Array[String], value : String) -> Int? {
  for i, arg in args {
    if arg == value {
      return Some(i)
    }
  }
  None
}

///|
fn main {
  let args = @env.args()
  if find_arg_index(args, "list-samples") is Some(_) {
    for name in @lib.sample_codestream_names() {
      println(name)
    }
    return
  }
  if find_arg_index(args, "parse-sample") is Some(i) {
    let sample_name = if i + 1 < args.length() {
      args[i + 1]
    } else {
      "minimal"
    }
    let sample = @lib.sample_codestream_by_name(sample_name)
    guard sample is Some(bytes) else {
      println("error: unknown sample name")
      return
    }
    let parsed = @lib.parse_codestream(bytes)
    if parsed is Ok(_) {
      println("ok")
    } else if parsed is Err(msg) {
      println("error: \{msg}")
    }
    return
  }
  if find_arg_index(args, "sample-hex") is Some(i) {
    let sample_name = if i + 1 < args.length() {
      args[i + 1]
    } else {
      "minimal"
    }
    let sample = @lib.sample_codestream_by_name(sample_name)
    guard sample is Some(bytes) else {
      println("error: unknown sample name")
      return
    }
    println(@lib.bytes_to_hex(bytes))
    return
  }
  if find_arg_index(args, "roundtrip-hex") is Some(i) {
    if i + 1 >= args.length() {
      usage()
      return
    }
    let decoded = @lib.hex_to_bytes(args[i + 1])
    guard decoded is Ok(bytes) else {
      println("error: invalid input hex")
      return
    }
    let rt = @lib.roundtrip_bytes(bytes)
    if rt is Ok(out) {
      println(@lib.bytes_to_hex(out))
      return
    }
    if rt is Err(msg) {
      println("error: \{msg}")
      return
    }
    println("error: roundtrip failed")
    return
  }
  usage()
}
