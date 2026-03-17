test "sample builder produces parsable stream" {
  let bytes = sample_codestream_minimal()
  let parsed = parse_codestream(bytes)
  assert_true(parsed is Ok(_))
}

///|
test "hex conversion and roundtrip bytes" {
  let bytes = sample_codestream_minimal()
  let hex = bytes_to_hex(bytes)
  let decoded = hex_to_bytes(hex)
  guard decoded is Ok(back) else { fail("hex decode failed") }
  assert_eq(back, bytes)

  let rt = roundtrip_bytes(back)
  guard rt is Ok(out) else { fail("roundtrip failed") }
  assert_eq(out, bytes)
}

///|
test "all sample codestreams parse and roundtrip" {
  for name in sample_codestream_names() {
    let sample = sample_codestream_by_name(name)
    guard sample is Some(bytes) else { fail("missing sample by name") }
    let parsed = parse_codestream(bytes)
    guard parsed is Ok(_) else { fail("sample should parse") }
    let rt = roundtrip_bytes(bytes)
    guard rt is Ok(out) else { fail("sample should roundtrip") }
    assert_eq(out, bytes)
  }
}

///|
test "packet payload after SOD is preserved in roundtrip" {
  let sample = sample_codestream_with_ppt_sop_eph()
  let parsed = parse_codestream(sample)
  guard parsed is Ok(stream) else { fail("sample should parse") }
  let mut sod_payload_len = 0
  for seg in stream.segments {
    if seg.code == 0xFF93 {
      sod_payload_len = seg.payload.length()
    }
  }
  assert_true(sod_payload_len > 0)

  let rt = roundtrip_bytes(sample)
  guard rt is Ok(out) else { fail("roundtrip failed") }
  assert_eq(out, sample)
}

///|
test "two tile-parts keep packet payload boundaries" {
  let sample = sample_codestream_two_tileparts()
  let parsed = parse_codestream(sample)
  guard parsed is Ok(stream) else { fail("sample should parse") }

  let sod_payload_sizes : Array[Int] = []
  for seg in stream.segments {
    if seg.code == 0xFF93 {
      sod_payload_sizes.push(seg.payload.length())
    }
  }
  assert_eq(sod_payload_sizes, [4, 3])

  let rt = roundtrip_bytes(sample)
  guard rt is Ok(out) else { fail("roundtrip failed") }
  assert_eq(out, sample)
}

///|

///|
test "round-trip codestream markers" {
  let parsed = parse_codestream(minimal_codestream_bytes())
  guard parsed is Ok(stream) else { fail("expected parser success") }
  let encoded = encode_codestream(stream)
  guard encoded is Ok(bytes) else { fail("expected encoder success") }
  assert_eq(bytes, minimal_codestream_bytes())
}
