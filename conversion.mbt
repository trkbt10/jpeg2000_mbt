///|
pub fn bytes_to_hex(data : Array[Int]) -> String {
  @core.bytes_to_hex(data)
}

///|
pub fn hex_to_bytes(hex : String) -> Result[Array[Int], String] {
  @core.hex_to_bytes(hex)
}
