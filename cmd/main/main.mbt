///|
fn usage() -> Unit {
  println("usage:")
  println("  moon run cmd/main -- list-samples")
  println("  moon run cmd/main -- sample-hex [name]")
  println("  moon run cmd/main -- parse-sample [name]")
  println("  moon run cmd/main -- roundtrip-hex <hex>")
  println("  moon run cmd/main -- parse-file <path>")
  println("  moon run cmd/main -- parse-file-strict <path>")
  println("  moon run cmd/main -- roundtrip-file <path>")
  println("  moon run cmd/main -- roundtrip-file-verify <path>")
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
fn read_file_bytes(path : String) -> Result[Array[Int], String] {
  let bytes_result = Ok(@fs.read_file_to_bytes(path)) catch {
    e => Err(e.to_string())
  }
  guard bytes_result is Ok(content) else {
    return Err("failed to read file: \{path}")
  }
  let out : Array[Int] = []
  for b in content.iter() {
    out.push(b.to_int())
  }
  Ok(out)
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
  if find_arg_index(args, "parse-file") is Some(i) {
    if i + 1 >= args.length() {
      usage()
      return
    }
    let loaded = read_file_bytes(args[i + 1])
    guard loaded is Ok(bytes) else {
      println("error: failed to read file")
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
  if find_arg_index(args, "parse-file-strict") is Some(i) {
    if i + 1 >= args.length() {
      usage()
      return
    }
    let loaded = read_file_bytes(args[i + 1])
    guard loaded is Ok(bytes) else {
      println("error: failed to read file")
      return
    }
    let parsed = @lib.parse_codestream_strict(bytes)
    if parsed is Ok(_) {
      println("ok")
    } else if parsed is Err(msg) {
      println("error: \{msg}")
    }
    return
  }
  if find_arg_index(args, "roundtrip-file") is Some(i) {
    if i + 1 >= args.length() {
      usage()
      return
    }
    let loaded = read_file_bytes(args[i + 1])
    guard loaded is Ok(bytes) else {
      println("error: failed to read file")
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
  if find_arg_index(args, "roundtrip-file-verify") is Some(i) {
    if i + 1 >= args.length() {
      usage()
      return
    }
    let loaded = read_file_bytes(args[i + 1])
    guard loaded is Ok(bytes) else {
      println("error: failed to read file")
      return
    }
    let rt = @lib.roundtrip_bytes(bytes)
    if rt is Ok(out) {
      if out == bytes {
        println("ok")
      } else {
        println("error: roundtrip mismatch")
      }
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
