///|
test "package_name matches module name" {
  assert_eq(@jpeg2000.package_name(), "trkbt10/jpeg2000")
}

///|
test "bytes-first codestream facade roundtrips minimal sample" {
  guard @jpeg2000.sample_codestream_bytes_by_name("minimal") is Some(sample) else {
    fail("missing minimal sample")
  }
  let parsed = @jpeg2000.parse_codestream_bytes(sample)
  guard parsed is Ok(stream) else { fail("parse_codestream_bytes failed") }
  let strict_parsed = @jpeg2000.parse_codestream_strict_bytes(sample)
  guard strict_parsed is Ok(_) else {
    fail("parse_codestream_strict_bytes failed")
  }
  let encoded = @jpeg2000.encode_codestream_bytes(stream)
  guard encoded is Ok(roundtripped) else {
    fail("encode_codestream_bytes failed")
  }
  assert_eq(roundtripped, sample)
}

///|
test "roundtrip_codestream_bytes preserves minimal sample" {
  guard @jpeg2000.sample_codestream_bytes_by_name("minimal") is Some(sample) else {
    fail("missing minimal sample")
  }
  let result = @jpeg2000.roundtrip_codestream_bytes(sample)
  guard result is Ok(roundtripped) else {
    fail("roundtrip_codestream_bytes failed")
  }
  assert_eq(roundtripped, sample)
}
