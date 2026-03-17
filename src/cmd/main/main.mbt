///|
fn usage() -> Unit {
  println("usage:")
  println("  moon run cmd/main -- list-samples")
  println("  moon run cmd/main -- sample-hex [name]")
  println("  moon run cmd/main -- parse-sample [name]")
  println("  moon run cmd/main -- decode-file <path>")
  println("  moon run cmd/main -- decode-file-dump <path>")
  println("  moon run cmd/main -- decode-file-all-components-dump <path>")
  println(
    "  moon run cmd/main -- decode-file-all-components-audit <path> [limit]",
  )
  println("  moon run cmd/main -- decode-file-audit <path> [ppt] [limit]")
  println("  moon run cmd/main -- roundtrip-hex <hex>")
  println("  moon run cmd/main -- parse-file <path>")
  println("  moon run cmd/main -- parse-file-strict <path>")
  println("  moon run cmd/main -- roundtrip-file <path>")
  println("  moon run cmd/main -- roundtrip-file-verify <path>")
  println("  moon run cmd/main -- decode-roundtrip-file-verify <path>")
}

///|
fn read_file_bytes(path : String) -> Result[Bytes, String] {
  let bytes_result = Ok(@fs.read_file_to_bytes(path)) catch {
    e => Err(e.to_string())
  }
  guard bytes_result is Ok(content) else {
    return Err("failed to read file: \{path}")
  }
  Ok(content)
}

///|
fn read_file_arg_bytes(args : Array[String], at : Int) -> Bytes? {
  if at + 1 >= args.length() {
    usage()
    return None
  }
  guard read_file_bytes(args[at + 1]) is Ok(bytes) else {
    println("error: failed to read file")
    return None
  }
  Some(bytes)
}

///|
fn print_decoded_result(
  decoded : Result[@orchestrate.DecodeSamplesResult, String],
  ok_prefix : String,
  include_samples_hex : Bool,
) -> Unit {
  match decoded {
    Ok(result) =>
      if include_samples_hex {
        let hex = @core.bytes_to_hex(@bytes.bytes_to_int_array(result.samples))
        println(
          "\{ok_prefix}: w=\{result.width} h=\{result.height} comps=\{result.num_components} bits=\{result.bits_per_component} signed=\{result.is_signed} layout=\{result.sample_layout} bytes=\{result.samples.length()} samples_hex=\{hex}",
        )
      } else {
        println(
          "\{ok_prefix}: w=\{result.width} h=\{result.height} comps=\{result.num_components} bits=\{result.bits_per_component} signed=\{result.is_signed} layout=\{result.sample_layout} bytes=\{result.samples.length()}",
        )
      }
    Err(msg) => println("error: \{msg}")
  }
}

///|
fn print_decode_samples_result(data : Bytes) -> Unit {
  print_decoded_result(@decoder.decode_samples(data), "ok", false)
}

///|
fn decode_samples_results_match(
  a : @orchestrate.DecodeSamplesResult,
  b : @orchestrate.DecodeSamplesResult,
) -> Bool {
  a.width == b.width &&
  a.height == b.height &&
  a.num_components == b.num_components &&
  a.bits_per_component == b.bits_per_component &&
  a.is_signed == b.is_signed &&
  a.sample_layout == b.sample_layout &&
  a.samples == b.samples
}

///|
fn print_decode_samples_dump_result(data : Bytes) -> Unit {
  print_decoded_result(@decoder.decode_samples(data), "ok-dump", true)
}

///|
fn print_decode_all_components_dump_result(data : Bytes) -> Unit {
  let decoded = @decoder.decode_samples_all_components_debug(data)
  match decoded {
    Ok(result) => {
      println(
        "ok-dump-all: comps=\{result.num_components} layout=\{result.sample_layout}",
      )
      for i in 0..<result.components.length() {
        let component = result.components[i]
        let hex = @core.bytes_to_hex(
          @bytes.bytes_to_int_array(component.samples),
        )
        println(
          "ok-dump-component: index=\{i} w=\{component.width} h=\{component.height} bits=\{component.bits_per_component} signed=\{component.is_signed} layout=\{component.sample_layout} bytes=\{component.samples.length()} samples_hex=\{hex}",
        )
      }
    }
    Err(msg) => println("error: \{msg}")
  }
}

///|
fn print_decode_all_components_audit_result(
  data : Bytes,
  packet_audit_limit : Int,
) -> Unit {
  let decoded = @decoder.decode_samples_all_components_audit(
    data,
    packet_audit_limit~,
  )
  match decoded {
    Ok(result) =>
      println(
        "ok-audit-all: comps=\{result.num_components} layout=\{result.sample_layout}",
      )
    Err(msg) => println("error: \{msg}")
  }
}

///|
fn print_decode_samples_audit_result(
  data : Bytes,
  packet_audit_limit : Int,
  force_relocated_ppt : Bool,
) -> Unit {
  print_decoded_result(
    @decoder.decode_samples_audit(data, packet_audit_limit~, force_relocated_ppt~),
    "ok-audit",
    true,
  )
}

///|
fn print_decode_roundtrip_verify_result(data : Bytes) -> Unit {
  let roundtripped_v = @core.roundtrip_bytes(data)
  guard roundtripped_v is Ok(roundtripped) else {
    if roundtripped_v is Err(msg) {
      println("error: \{msg}")
      return
    }
    println("error: roundtrip failed")
    return
  }
  let roundtripped_bytes = @bytes.int_array_to_bytes(roundtripped)
  let decoded_original_v = @decoder.decode_samples(data)
  guard decoded_original_v is Ok(decoded_original) else {
    if decoded_original_v is Err(msg) {
      println("error: decode original failed: \{msg}")
      return
    }
    println("error: decode original failed")
    return
  }
  let decoded_roundtrip_v = @decoder.decode_samples(roundtripped_bytes)
  guard decoded_roundtrip_v is Ok(decoded_roundtrip) else {
    if decoded_roundtrip_v is Err(msg) {
      println("error: decode roundtrip failed: \{msg}")
      return
    }
    println("error: decode roundtrip failed")
    return
  }
  if decode_samples_results_match(decoded_original, decoded_roundtrip) {
    println("ok")
  } else {
    println("error: decode roundtrip mismatch")
  }
}

///|
fn main {
  let args = @env.args()
  if @cli.dispatch_shared_commands(args) {
    return
  }
  if @cli.find_arg_index(args, "decode-file") is Some(i) {
    guard read_file_arg_bytes(args, i) is Some(bytes) else { return }
    print_decode_samples_result(bytes)
    return
  }
  if @cli.find_arg_index(args, "decode-file-dump") is Some(i) {
    guard read_file_arg_bytes(args, i) is Some(bytes) else { return }
    print_decode_samples_dump_result(bytes)
    return
  }
  if @cli.find_arg_index(args, "decode-file-all-components-dump") is Some(i) {
    guard read_file_arg_bytes(args, i) is Some(bytes) else { return }
    print_decode_all_components_dump_result(bytes)
    return
  }
  if @cli.find_arg_index(args, "decode-file-all-components-audit") is Some(i) {
    guard read_file_arg_bytes(args, i) is Some(bytes) else { return }
    let packet_audit_limit = if i + 2 < args.length() {
      let parsed = @strconv.parse_int(args[i + 2]) catch { _ => -1 }
      if parsed > 0 {
        parsed
      } else {
        300
      }
    } else {
      300
    }
    print_decode_all_components_audit_result(bytes, packet_audit_limit)
    return
  }
  if @cli.find_arg_index(args, "decode-file-audit") is Some(i) {
    guard read_file_arg_bytes(args, i) is Some(bytes) else { return }
    let force_relocated_ppt = if i + 2 < args.length() {
      args[i + 2] == "ppt" || args[i + 2] == "true" || args[i + 2] == "1"
    } else {
      false
    }
    let packet_audit_limit = if i + 3 < args.length() {
      let parsed = @strconv.parse_int(args[i + 3]) catch { _ => -1 }
      if parsed > 0 {
        parsed
      } else {
        300
      }
    } else {
      300
    }
    print_decode_samples_audit_result(
      bytes, packet_audit_limit, force_relocated_ppt,
    )
    return
  }
  if @cli.find_arg_index(args, "parse-file") is Some(i) {
    guard read_file_arg_bytes(args, i) is Some(bytes) else { return }
    let parsed = @input.parse_decode_input_codestream(bytes)
    if parsed is Ok(_) {
      println("ok")
    } else if parsed is Err(msg) {
      println("error: \{msg}")
    }
    return
  }
  if @cli.find_arg_index(args, "parse-file-strict") is Some(i) {
    guard read_file_arg_bytes(args, i) is Some(bytes) else { return }
    let parsed = @input.parse_decode_input_codestream_strict(bytes)
    if parsed is Ok(_) {
      println("ok")
    } else if parsed is Err(msg) {
      println("error: \{msg}")
    }
    return
  }
  if @cli.find_arg_index(args, "roundtrip-file") is Some(i) {
    guard read_file_arg_bytes(args, i) is Some(bytes) else { return }
    let rt = @input.roundtrip_decode_input_bytes(bytes)
    if rt is Ok(out) {
      println(@core.bytes_to_hex(@bytes.bytes_to_int_array(out)))
      return
    }
    if rt is Err(msg) {
      println("error: \{msg}")
      return
    }
    println("error: roundtrip failed")
    return
  }
  if @cli.find_arg_index(args, "roundtrip-file-verify") is Some(i) {
    guard read_file_arg_bytes(args, i) is Some(bytes) else { return }
    let rt = @input.roundtrip_decode_input_bytes(bytes)
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
  if @cli.find_arg_index(args, "decode-roundtrip-file-verify") is Some(i) {
    guard read_file_arg_bytes(args, i) is Some(bytes) else { return }
    print_decode_roundtrip_verify_result(bytes)
    return
  }
  usage()
}
