///|
// Unit tests for codestream parsing and encoding

///|
test "parse_codestream parses minimal sample" {
  let data = @bytes.int_array_to_bytes(sample_codestream_minimal())
  let result = parse_codestream(data)
  guard result is Ok(cs) else { fail("parse failed") }
  // Verify SIZ metadata exists
  guard cs.metadata.siz is Some(siz) else { fail("missing SIZ") }
  inspect(siz.csiz, content="1") // 1 component
}

///|
test "sample_codestream_minimal returns a fresh array" {
  let first = sample_codestream_minimal()
  let second = sample_codestream_minimal()
  first[0] = 0x00
  assert_eq(second[0], 0xFF)
}

///|
test "parse_codestream parses sample with COC/QCC" {
  let data = @bytes.int_array_to_bytes(sample_codestream_with_coc_qcc())
  let result = parse_codestream(data)
  guard result is Ok(cs) else { fail("parse failed") }
  // Verify COC and QCC metadata exist
  inspect(cs.metadata.coc.length() > 0, content="true")
  inspect(cs.metadata.qcc.length() > 0, content="true")
}

///|
test "parse_codestream parses sample with COM" {
  let data = @bytes.int_array_to_bytes(sample_codestream_with_com())
  let result = parse_codestream(data)
  guard result is Ok(cs) else { fail("parse failed") }
  inspect(cs.metadata.com.length() > 0, content="true")
}

///|
test "parse_codestream parses sample with POC" {
  let data = @bytes.int_array_to_bytes(sample_codestream_with_poc())
  let result = parse_codestream(data)
  guard result is Ok(cs) else { fail("parse failed") }
  inspect(cs.metadata.poc.length() > 0, content="true")
}

///|
test "parse_codestream parses sample with PPT/SOP/EPH" {
  let data = @bytes.int_array_to_bytes(sample_codestream_with_ppt_sop_eph())
  let result = parse_codestream(data)
  guard result is Ok(cs) else { fail("parse failed") }
  // Verify PPT exists
  inspect(cs.metadata.ppt.length() > 0, content="true")
  // Verify SOP markers were found
  inspect(cs.metadata.sop.length() > 0, content="true")
}

///|
test "parse_codestream parses sample with TLM" {
  let data = @bytes.int_array_to_bytes(sample_codestream_with_tlm())
  let result = parse_codestream(data)
  guard result is Ok(cs) else { fail("parse failed") }
  inspect(cs.metadata.tlm.length() > 0, content="true")
}

///|
test "parse_codestream parses two-tilepart sample" {
  let data = @bytes.int_array_to_bytes(sample_codestream_two_tileparts())
  let result = parse_codestream(data)
  guard result is Ok(cs) else { fail("parse failed") }
  // Verify we have multiple SOT segments
  let mut sot_count = 0
  for seg in cs.segments {
    if seg.code == 0xFF90 { // SOT marker
      sot_count += 1
    }
  }
  inspect(sot_count >= 2, content="true")
}

///|
test "parse_codestream rejects empty input" {
  let result = parse_codestream(Bytes::new(0))
  guard result is Err(msg) else { fail("expected error for empty input") }
  inspect(msg.contains("too short") || msg.contains("SOC"), content="true")
}

///|
test "parse_codestream rejects missing SOC" {
  let result = parse_codestream(Bytes::from_array([0x00, 0x00]))
  guard result is Err(_) else { fail("expected error for missing SOC") }
}

///|
test "roundtrip_bytes preserves minimal codestream" {
  let original_arr = sample_codestream_minimal()
  let original = @bytes.int_array_to_bytes(original_arr)
  let result = roundtrip_bytes(original)
  guard result is Ok(roundtripped) else { fail("roundtrip failed") }
  inspect(roundtripped.length(), content=original.length().to_string())
}

///|
test "roundtrip_bytes preserves trailing fill after EOC in compat mode" {
  let original_arr = sample_codestream_minimal()
  let with_fill_arr = [..original_arr, 0x00, 0x00]
  let with_fill = @bytes.int_array_to_bytes(with_fill_arr)
  let parsed = parse_codestream(with_fill)
  guard parsed is Ok(cs) else { fail("compat parse failed") }
  assert_eq(cs.trailing_bytes, Bytes::from_array([0x00, 0x00]))

  let result = roundtrip_bytes(with_fill)
  guard result is Ok(roundtripped) else { fail("roundtrip failed") }
  assert_eq(roundtripped, with_fill_arr)
}

///|
test "compat parser preserves missing EOC codestream" {
  let original_arr = sample_codestream_minimal()
  let truncated : Array[Int] = []
  let mut i = 0
  while i + 2 < original_arr.length() {
    truncated.push(original_arr[i])
    i += 1
  }

  let truncated_bytes = @bytes.int_array_to_bytes(truncated)
  let strict_result = parse_codestream_strict(truncated_bytes)
  guard strict_result is Err(msg) else {
    fail("strict parser should reject missing EOC")
  }
  inspect(msg, content="EOC marker missing")

  let parsed = parse_codestream(truncated_bytes)
  guard parsed is Ok(cs) else { fail("compat parse failed") }
  assert_eq(cs.trailing_bytes, Bytes::new(0))
  assert_eq(cs.segments.length(), 6)
  assert_eq(cs.segments[cs.segments.length() - 1].code, MARKER_SOD)
}

///|
test "roundtrip_bytes preserves missing EOC codestream bytes" {
  let original_arr = sample_codestream_minimal()
  let truncated : Array[Int] = []
  let mut i = 0
  while i + 2 < original_arr.length() {
    truncated.push(original_arr[i])
    i += 1
  }

  let result = roundtrip_bytes(@bytes.int_array_to_bytes(truncated))
  guard result is Ok(roundtripped) else { fail("roundtrip failed") }
  assert_eq(roundtripped, truncated)
}

///|
test "compat parser preserves undecodable suffix after valid SIZ" {
  let original_arr = sample_codestream_minimal()
  let original = @bytes.int_array_to_bytes(original_arr)
  let parsed_original = parse_codestream(original)
  guard parsed_original is Ok(base) else { fail("base parse failed") }
  let cod_pos = base.segments[2].position
  let broken : Array[Int] = []
  let mut i = 0
  while i < cod_pos {
    broken.push(original_arr[i])
    i += 1
  }
  broken.push(0xFF)
  broken.push(0xDE)
  broken.push(0xDE)
  broken.push(0xDE)
  broken.push(0xDE)

  let broken_bytes = @bytes.int_array_to_bytes(broken)
  let parsed = parse_codestream(broken_bytes)
  guard parsed is Ok(cs) else { fail("compat parse failed") }
  assert_eq(cs.segments.length(), 2)
  assert_eq(cs.segments[1].code, MARKER_SIZ)
  assert_eq(
    cs.trailing_bytes,
    Bytes::from_array([0xFF, 0xDE, 0xDE, 0xDE, 0xDE]),
  )

  let result = roundtrip_bytes(broken_bytes)
  guard result is Ok(roundtripped) else { fail("roundtrip failed") }
  assert_eq(roundtripped, broken)
}

///|
test "compat parser preserves malformed SIZ and remaining bytes" {
  let broken_arr = sample_codestream_minimal()
  // YTsiz = 0 -> invalid in strict mode, but compat parser should preserve raw bytes.
  broken_arr[28] = 0x00
  broken_arr[29] = 0x00
  broken_arr[30] = 0x00
  broken_arr[31] = 0x00

  let broken = @bytes.int_array_to_bytes(broken_arr)
  let strict_result = parse_codestream_strict(broken)
  guard strict_result is Err(msg) else {
    fail("strict parser should reject malformed SIZ")
  }
  inspect(msg, content="invalid marker payload: SIZ tile size must be positive")

  let parsed = parse_codestream(broken)
  guard parsed is Ok(cs) else { fail("compat parse failed") }
  assert_eq(cs.segments.length(), 2)
  assert_eq(cs.segments[1].code, MARKER_SIZ)
  assert_true(cs.metadata.siz is None)
  assert_true(cs.trailing_bytes.length() > 0)

  let result = roundtrip_bytes(broken)
  guard result is Ok(roundtripped) else { fail("roundtrip failed") }
  assert_eq(roundtripped, broken_arr)
}

///|
test "encode_codestream produces valid output" {
  let data = @bytes.int_array_to_bytes(sample_codestream_minimal())
  let parse_result = parse_codestream(data)
  guard parse_result is Ok(cs) else { fail("parse failed") }
  let encode_result = encode_codestream(cs)
  guard encode_result is Ok(encoded) else { fail("encode failed") }
  // Verify SOC marker at start
  inspect(encoded[0], content="255") // 0xFF
  inspect(encoded[1], content="79") // 0x4F (SOC)
}

///|
test "sample_codestream_names returns all sample names" {
  let names = sample_codestream_names()
  inspect(names.length() > 0, content="true")
  // Verify minimal is included
  let has_minimal = names.iter().any(fn(n) { n == "minimal" })
  inspect(has_minimal, content="true")
}

///|
test "sample_codestream_by_name returns expected samples" {
  let result = sample_codestream_by_name("minimal")
  guard result is Some(data) else { fail("minimal sample not found") }
  inspect(data.length() > 0, content="true")
  // Verify SOC marker
  inspect(data[0], content="255") // 0xFF
  inspect(data[1], content="79") // 0x4F
}

///|
test "sample_codestream_by_name returns None for unknown" {
  let result = sample_codestream_by_name("nonexistent")
  inspect(result is None, content="true")
}
