///|
// Unit tests for hex codec functions

///|
test "bytes_to_hex converts empty array" {
  let result = bytes_to_hex([])
  inspect(result, content="")
}

///|
test "bytes_to_hex converts single byte" {
  inspect(bytes_to_hex([0x00]), content="00")
  inspect(bytes_to_hex([0xFF]), content="ff")
  inspect(bytes_to_hex([0xAB]), content="ab")
}

///|
test "bytes_to_hex converts multiple bytes" {
  inspect(bytes_to_hex([0xFF, 0x4F]), content="ff4f")
  inspect(bytes_to_hex([0x00, 0x01, 0x02]), content="000102")
}

///|
test "hex_to_bytes parses empty string" {
  let result = hex_to_bytes("")
  guard result is Ok(bytes) else { fail("expected success") }
  inspect(bytes.length(), content="0")
}

///|
test "hex_to_bytes parses lowercase hex" {
  let result = hex_to_bytes("ff4f")
  guard result is Ok(bytes) else { fail("expected success") }
  inspect(bytes, content="[255, 79]")
}

///|
test "hex_to_bytes parses uppercase hex" {
  let result = hex_to_bytes("FF4F")
  guard result is Ok(bytes) else { fail("expected success") }
  inspect(bytes, content="[255, 79]")
}

///|
test "hex_to_bytes parses mixed case hex" {
  let result = hex_to_bytes("Ff4F")
  guard result is Ok(bytes) else { fail("expected success") }
  inspect(bytes, content="[255, 79]")
}

///|
test "hex_to_bytes ignores whitespace" {
  let result = hex_to_bytes("ff 4f")
  guard result is Ok(bytes) else { fail("expected success") }
  inspect(bytes, content="[255, 79]")
}

///|
test "hex_to_bytes ignores newlines and tabs" {
  let result = hex_to_bytes("ff\n4f\t00")
  guard result is Ok(bytes) else { fail("expected success") }
  inspect(bytes, content="[255, 79, 0]")
}

///|
test "hex_to_bytes rejects invalid characters" {
  let result = hex_to_bytes("gg")
  guard result is Err(msg) else { fail("expected error") }
  inspect(msg, content="invalid hex character")
}

///|
test "hex_to_bytes rejects odd length" {
  let result = hex_to_bytes("fff")
  guard result is Err(msg) else { fail("expected error") }
  inspect(msg, content="hex string has odd length")
}

///|
test "hex roundtrip preserves data" {
  let original = [0x00, 0x7F, 0x80, 0xFF, 0x12, 0x34]
  let hex = bytes_to_hex(original)
  let result = hex_to_bytes(hex)
  guard result is Ok(bytes) else { fail("roundtrip failed") }
  inspect(bytes, content="[0, 127, 128, 255, 18, 52]")
}
