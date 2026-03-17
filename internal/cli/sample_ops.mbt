///|
pub fn sample_bytes_by_name(name : String) -> Result[Array[Int], String] {
  guard @lib.sample_codestream_by_name(name) is Some(bytes) else {
    return Err("unknown sample name")
  }
  Ok(bytes)
}

///|
pub fn sample_hex_output(name : String) -> Result[String, String] {
  match sample_bytes_by_name(name) {
    Ok(bytes) => Ok(@lib.bytes_to_hex(bytes))
    Err(msg) => Err(msg)
  }
}

///|
pub fn parse_sample_by_name(name : String) -> Result[Unit, String] {
  match sample_bytes_by_name(name) {
    Ok(bytes) =>
      match @lib.parse_codestream(bytes) {
        Ok(_) => Ok(())
        Err(msg) => Err(msg)
      }
    Err(msg) => Err(msg)
  }
}

///|
pub fn roundtrip_hex_output(hex : String) -> Result[String, String] {
  match @lib.hex_to_bytes(hex) {
    Ok(bytes) =>
      match @lib.roundtrip_bytes(bytes) {
        Ok(out) => Ok(@lib.bytes_to_hex(out))
        Err(msg) => Err(msg)
      }
    Err(_) => Err("invalid input hex")
  }
}
