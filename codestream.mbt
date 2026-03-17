///|
fn map_byte_result(
  result : Result[Array[Int], String],
) -> Result[Bytes, String] {
  match result {
    Ok(data) => Ok(@bytes.int_array_to_bytes(data))
    Err(msg) => Err(msg)
  }
}

///|
pub fn parse_codestream(data : Array[Int]) -> Result[Codestream, String] {
  @core.parse_codestream(@bytes.int_array_to_bytes(data))
}

///|
pub fn parse_codestream_bytes(data : Bytes) -> Result[Codestream, String] {
  @core.parse_codestream_bytes(data)
}

///|
pub fn parse_codestream_strict(data : Array[Int]) -> Result[Codestream, String] {
  @core.parse_codestream_strict(@bytes.int_array_to_bytes(data))
}

///|
pub fn parse_codestream_strict_bytes(
  data : Bytes,
) -> Result[Codestream, String] {
  @core.parse_codestream_strict(data)
}

///|
pub fn encode_codestream(stream : Codestream) -> Result[Array[Int], String] {
  @core.encode_codestream(stream)
}

///|
pub fn encode_codestream_bytes(stream : Codestream) -> Result[Bytes, String] {
  map_byte_result(@core.encode_codestream(stream))
}

///|
pub fn roundtrip_bytes(data : Array[Int]) -> Result[Array[Int], String] {
  @core.roundtrip_bytes(@bytes.int_array_to_bytes(data))
}

///|
pub fn roundtrip_codestream_bytes(data : Bytes) -> Result[Bytes, String] {
  map_byte_result(@core.roundtrip_bytes(data))
}
