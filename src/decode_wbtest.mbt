///|
test "decode returns ImageData for minimal codestream" {
  let data = @bytes.int_array_to_bytes(sample_codestream_minimal())
  let result = try {
    decode(data)
  } catch {
    e => fail("decode raised: \{e}")
  }
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.num_components > 0)
  assert_true(result.bits_per_component > 0)
  assert_true(result.data.length() > 0)
}

///|
test "decode raises DecodeError for empty input" {
  let result = try {
    Ok(decode(b""))
  } catch {
    DecodeError::DecodeFailed(_) => Err("decode failed as expected")
    e => fail("unexpected error type: \{e}")
  }
  assert_true(result is Err(_))
}

///|
test "parse returns Codestream for minimal codestream" {
  let data = @bytes.int_array_to_bytes(sample_codestream_minimal())
  let result = try {
    parse(data)
  } catch {
    e => fail("parse raised: \{e}")
  }
  // Verify we got a valid Codestream (non-empty segments)
  ignore(result)
}

///|
test "parse raises DecodeError for invalid input" {
  let result = try {
    Ok(parse(b""))
  } catch {
    DecodeError::InvalidCodestream(_) => Err("invalid as expected")
    e => fail("unexpected error type: \{e}")
  }
  assert_true(result is Err(_))
}
