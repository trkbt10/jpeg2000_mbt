///|
// Unit tests for byte reading utilities

///|
test "read_u16_be reads big-endian 16-bit" {
  let data = Bytes::from_array([0x12, 0x34, 0x56, 0x78])
  inspect(read_u16_be(data, 0), content="4660") // 0x1234
  inspect(read_u16_be(data, 1), content="13398") // 0x3456
  inspect(read_u16_be(data, 2), content="22136") // 0x5678
}

///|
test "read_u16_be handles max value" {
  let data = Bytes::from_array([0xFF, 0xFF])
  inspect(read_u16_be(data, 0), content="65535")
}

///|
test "read_u16_be handles zero" {
  let data = Bytes::from_array([0x00, 0x00])
  inspect(read_u16_be(data, 0), content="0")
}

///|
test "read_u32_be reads big-endian 32-bit" {
  let data = Bytes::from_array([0x12, 0x34, 0x56, 0x78])
  inspect(read_u32_be(data, 0), content="305419896") // 0x12345678
}

///|
test "read_u32_be handles various values" {
  let data = Bytes::from_array([0x00, 0x00, 0x01, 0x00])
  inspect(read_u32_be(data, 0), content="256")
  let data2 = Bytes::from_array([0x00, 0x01, 0x00, 0x00])
  inspect(read_u32_be(data2, 0), content="65536")
}

///|
test "read_u16_be_arr reads from int array" {
  let data = [0x12, 0x34, 0x56]
  let result = read_u16_be_arr(data, 0)
  guard result is Ok(val) else { fail("expected Ok") }
  inspect(val, content="4660") // 0x1234
}

///|
test "read_u16_be_arr returns error on short array" {
  let data = [0x12]
  let result = read_u16_be_arr(data, 0)
  guard result is Err(msg) else { fail("expected Err") }
  inspect(msg, content="unexpected end while reading u16")
}

///|
test "read_u16_be_arr returns error on out of range byte" {
  let data = [0x12, 0x100] // 0x100 > 0xFF
  let result = read_u16_be_arr(data, 0)
  guard result is Err(msg) else { fail("expected Err") }
  inspect(msg, content="byte out of range")
}

///|
test "read_u32_be_arr reads from int array" {
  let data = [0x12, 0x34, 0x56, 0x78]
  let result = read_u32_be_arr(data, 0)
  guard result is Ok(val) else { fail("expected Ok") }
  inspect(val, content="305419896") // 0x12345678
}

///|
test "read_u32_be_arr returns error on short array" {
  let data = [0x12, 0x34, 0x56]
  let result = read_u32_be_arr(data, 0)
  guard result is Err(msg) else { fail("expected Err") }
  inspect(msg, content="unexpected end while reading u32")
}
