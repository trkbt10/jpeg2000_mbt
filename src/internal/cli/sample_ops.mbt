///|
pub fn sample_bytes_by_name(name : String) -> Result[Array[Int], String] {
  guard @core.sample_codestream_by_name(name) is Some(bytes) else {
    return Err("unknown sample name")
  }
  Ok(bytes)
}

///|
pub fn sample_hex_output(name : String) -> Result[String, String] {
  match sample_bytes_by_name(name) {
    Ok(bytes) => Ok(@core.bytes_to_hex(bytes))
    Err(msg) => Err(msg)
  }
}

///|
pub fn parse_sample_by_name(name : String) -> Result[Unit, String] {
  match sample_bytes_by_name(name) {
    Ok(bytes) =>
      match @core.parse_codestream(@bytes.int_array_to_bytes(bytes)) {
        Ok(_) => Ok(())
        Err(msg) => Err(msg)
      }
    Err(msg) => Err(msg)
  }
}

///|
pub fn roundtrip_hex_output(hex : String) -> Result[String, String] {
  match @core.hex_to_bytes(hex) {
    Ok(bytes) =>
      match @core.roundtrip_bytes(@bytes.int_array_to_bytes(bytes)) {
        Ok(out) => Ok(@core.bytes_to_hex(out))
        Err(msg) => Err(msg)
      }
    Err(_) => Err("invalid input hex")
  }
}
