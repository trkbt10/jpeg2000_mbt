///|
fn minimal_codestream_bytes() -> Array[Int] {
  @jpeg2000.sample_codestream_minimal()
}

///|
fn valid_siz_payload() -> Array[Int] {
  [
    0x00, 0x00, // Rsiz
     0x00, 0x00, 0x00, 0x10, // Xsiz
     0x00, 0x00, 0x00, 0x10, // Ysiz
     0x00, 0x00, 0x00, 0x00, // XOsiz
     0x00, 0x00, 0x00, 0x00, // YOsiz
     0x00, 0x00, 0x00, 0x10, // XTsiz
     0x00, 0x00, 0x00, 0x10, // YTsiz
     0x00, 0x00, 0x00, 0x00, // XTOsiz
     0x00, 0x00, 0x00, 0x00, // YTOsiz
     0x00, 0x01, // Csiz = 1
     0x07, 0x01, 0x01, // Ssiz/XRsiz/YRsiz for component 0
  ]
}

///|
fn valid_cod_payload() -> Array[Int] {
  [
    0x00, // Scod
     0x00, // Progression order (LRCP)
     0x00, 0x01, // Number of layers
     0x00, // Multiple component transform
     0x00, // Number of decomposition levels
     0x00, // Code-block width exponent minus 2
     0x00, // Code-block height exponent minus 2
     0x00, // Code-block style
     0x00,
  ] // Transformation
}

///|
fn valid_cod_payload_decomp2() -> Array[Int] {
  [
    0x00, // Scod
     0x00, // Progression order (LRCP)
     0x00, 0x01, // Number of layers
     0x00, // Multiple component transform
     0x02, // Number of decomposition levels
     0x00, // Code-block width exponent minus 2
     0x00, // Code-block height exponent minus 2
     0x00, // Code-block style
     0x00,
  ] // Transformation
}

///|
fn valid_cod_payload_decomp2_precincts_layers3() -> Array[Int] {
  [
    0x01, // Scod (precincts present)
     0x00, // Progression order (LRCP)
     0x00, 0x03, // Number of layers
     0x00, // Multiple component transform
     0x02, // Number of decomposition levels
     0x00, // Code-block width exponent minus 2
     0x00, // Code-block height exponent minus 2
     0x00, // Code-block style
     0x00, // Transformation
     0x44, 0x33, 0x22,
  ] // precinct exponents per resolution
}

///|
fn valid_siz_payload_tile_2x2() -> Array[Int] {
  [
    0x00, 0x00, // Rsiz
     0x00, 0x00, 0x00, 0x10, // Xsiz
     0x00, 0x00, 0x00, 0x10, // Ysiz
     0x00, 0x00, 0x00, 0x00, // XOsiz
     0x00, 0x00, 0x00, 0x00, // YOsiz
     0x00, 0x00, 0x00, 0x08, // XTsiz
     0x00, 0x00, 0x00, 0x08, // YTsiz
     0x00, 0x00, 0x00, 0x00, // XTOsiz
     0x00, 0x00, 0x00, 0x00, // YTOsiz
     0x00, 0x01, // Csiz = 1
     0x07, 0x01, 0x01, // Ssiz/XRsiz/YRsiz
  ]
}

///|
fn valid_siz_payload_sampling_2() -> Array[Int] {
  [
    0x00, 0x00, // Rsiz
     0x00, 0x00, 0x00, 0x10, // Xsiz
     0x00, 0x00, 0x00, 0x10, // Ysiz
     0x00, 0x00, 0x00, 0x00, // XOsiz
     0x00, 0x00, 0x00, 0x00, // YOsiz
     0x00, 0x00, 0x00, 0x10, // XTsiz
     0x00, 0x00, 0x00, 0x10, // YTsiz
     0x00, 0x00, 0x00, 0x00, // XTOsiz
     0x00, 0x00, 0x00, 0x00, // YTOsiz
     0x00, 0x01, // Csiz = 1
     0x07, 0x02, 0x02, // Ssiz/XRsiz/YRsiz
  ]
}

///|
fn valid_cod_payload_decomp2_precincts_layers3_with_order(
  progression_order : Int,
) -> Array[Int] {
  [
    0x01, // Scod (precincts present)
     progression_order, // Progression order
     0x00, 0x03, // Number of layers
     0x00, // Multiple component transform
     0x02, // Number of decomposition levels
     0x00, // Code-block width exponent minus 2
     0x00, // Code-block height exponent minus 2
     0x00, // Code-block style
     0x00, // Transformation
     0x44, 0x33, 0x22,
  ] // precinct exponents per resolution
}

///|
fn bits_to_bytes(bits : String) -> Array[Int] {
  let bytes : Array[Int] = []
  let mut current = 0
  let mut count = 0
  for c in bits {
    if c != '0' && c != '1' {
      continue
    }
    current = (current << 1) + (if c == '1' { 1 } else { 0 })
    count += 1
    if count == 8 {
      bytes.push(current)
      current = 0
      count = 0
    }
  }
  if count > 0 {
    current = current << (8 - count)
    bytes.push(current)
  }
  bytes
}

///|
fn coding_pass_codeword_bits(coding_passes : Int) -> String {
  if coding_passes == 1 {
    return "0"
  }
  if coding_passes == 2 {
    return "10"
  }
  if coding_passes == 3 {
    return "1100"
  }
  if coding_passes == 4 {
    return "1101"
  }
  if coding_passes == 5 {
    return "1110"
  }
  if coding_passes >= 6 && coding_passes <= 36 {
    let mid = coding_passes - 6
    let b4 = if (mid & 0x10) != 0 { "1" } else { "0" }
    let b3 = if (mid & 0x08) != 0 { "1" } else { "0" }
    let b2 = if (mid & 0x04) != 0 { "1" } else { "0" }
    let b1 = if (mid & 0x02) != 0 { "1" } else { "0" }
    let b0 = if (mid & 0x01) != 0 { "1" } else { "0" }
    return "1111" + b4 + b3 + b2 + b1 + b0
  }
  if coding_passes >= 37 && coding_passes <= 164 {
    let tail = coding_passes - 37
    let b6 = if (tail & 0x40) != 0 { "1" } else { "0" }
    let b5 = if (tail & 0x20) != 0 { "1" } else { "0" }
    let b4 = if (tail & 0x10) != 0 { "1" } else { "0" }
    let b3 = if (tail & 0x08) != 0 { "1" } else { "0" }
    let b2 = if (tail & 0x04) != 0 { "1" } else { "0" }
    let b1 = if (tail & 0x02) != 0 { "1" } else { "0" }
    let b0 = if (tail & 0x01) != 0 { "1" } else { "0" }
    return "111111111" + b6 + b5 + b4 + b3 + b2 + b1 + b0
  }
  ""
}

///|
fn floor_log2_positive_for_test(v : Int) -> Int {
  let mut x = v
  let mut k = 0
  while x > 1 {
    x = x >> 1
    k += 1
  }
  k
}

///|
fn fixed_width_bits(value : Int, width : Int) -> String {
  let mut out = ""
  let mut i = width - 1
  while i >= 0 {
    let bit = if ((value >> i) & 1) == 1 { "1" } else { "0" }
    out = out + bit
    i -= 1
  }
  out
}

///|
fn single_codeblock_header_bits(
  coding_passes : Int,
  lblock_increment : Int,
  length : Int,
) -> String {
  let mut prefix = "111"
  prefix = prefix + coding_pass_codeword_bits(coding_passes)
  for _ in 0..<lblock_increment {
    prefix = prefix + "1"
  }
  prefix = prefix + "0"
  let width = 3 + lblock_increment + floor_log2_positive_for_test(coding_passes)
  prefix + fixed_width_bits(length, width)
}

///|
test "sample builder produces parsable stream" {
  let bytes = @jpeg2000.sample_codestream_minimal()
  let parsed = @jpeg2000.parse_codestream(bytes)
  assert_true(parsed is Ok(_))
}

///|
test "hex conversion and roundtrip bytes" {
  let bytes = @jpeg2000.sample_codestream_minimal()
  let hex = @jpeg2000.bytes_to_hex(bytes)
  let decoded = @jpeg2000.hex_to_bytes(hex)
  guard decoded is Ok(back) else { fail("hex decode failed") }
  assert_eq(back, bytes)

  let rt = @jpeg2000.roundtrip_bytes(back)
  guard rt is Ok(out) else { fail("roundtrip failed") }
  assert_eq(out, bytes)
}

///|
test "all sample codestreams parse and roundtrip" {
  for name in @jpeg2000.sample_codestream_names() {
    let sample = @jpeg2000.sample_codestream_by_name(name)
    guard sample is Some(bytes) else { fail("missing sample by name") }
    let parsed = @jpeg2000.parse_codestream(bytes)
    guard parsed is Ok(_) else { fail("sample should parse") }
    let rt = @jpeg2000.roundtrip_bytes(bytes)
    guard rt is Ok(out) else { fail("sample should roundtrip") }
    assert_eq(out, bytes)
  }
}

///|
test "packet payload after SOD is preserved in roundtrip" {
  let sample = @jpeg2000.sample_codestream_with_ppt_sop_eph()
  let parsed = @jpeg2000.parse_codestream(sample)
  guard parsed is Ok(stream) else { fail("sample should parse") }
  let mut sod_payload_len = 0
  for seg in stream.segments {
    if seg.code == 0xFF93 {
      sod_payload_len = seg.payload.length()
    }
  }
  assert_true(sod_payload_len > 0)

  let rt = @jpeg2000.roundtrip_bytes(sample)
  guard rt is Ok(out) else { fail("roundtrip failed") }
  assert_eq(out, sample)
}

///|
test "two tile-parts keep packet payload boundaries" {
  let sample = @jpeg2000.sample_codestream_two_tileparts()
  let parsed = @jpeg2000.parse_codestream(sample)
  guard parsed is Ok(stream) else { fail("sample should parse") }

  let sod_payload_sizes : Array[Int] = []
  for seg in stream.segments {
    if seg.code == 0xFF93 {
      sod_payload_sizes.push(seg.payload.length())
    }
  }
  assert_eq(sod_payload_sizes, [4, 3])

  let rt = @jpeg2000.roundtrip_bytes(sample)
  guard rt is Ok(out) else { fail("roundtrip failed") }
  assert_eq(out, sample)
}

///|
test "failure case: invalid packet bit stuffing sequence" {
  let broken = @jpeg2000.sample_codestream_with_ppt_sop_eph()
  guard marker_index_nth(broken, 0xFF, 0x91, 0) is Some(sop_at) else {
    fail("SOP marker should exist")
  }
  // SOP marker length must be 0x0004; break it.
  broken[sop_at + 3] = 0x03
  let parsed = @jpeg2000.parse_codestream(broken)
  guard parsed is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid packet data")
}

///|
test "failure case: invalid Psot in SOT" {
  let broken = @jpeg2000.sample_codestream_two_tileparts()
  guard marker_index(broken, 0xFF, 0x90) is Some(sot_at) else {
    fail("SOT marker should exist")
  }
  broken[sot_at + 6] = 0x00
  broken[sot_at + 7] = 0x00
  broken[sot_at + 8] = 0x00
  broken[sot_at + 9] = 0x05
  let parsed = @jpeg2000.parse_codestream(broken)
  guard parsed is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid Psot in SOT")
}

///|
test "failure case: invalid TPsot and TNsot relation" {
  let broken = @jpeg2000.sample_codestream_two_tileparts()
  guard marker_index_nth(broken, 0xFF, 0x90, 0) is Some(sot_at) else {
    fail("SOT marker should exist")
  }
  // TPsot (byte 6 in payload) = 2, TNsot (byte 7) = 2 => invalid (TPsot >= TNsot)
  broken[sot_at + 10] = 0x02
  broken[sot_at + 11] = 0x02
  let parsed = @jpeg2000.parse_codestream(broken)
  guard parsed is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid TPsot/TNsot relation")
}

///|
test "tile-part interleaving across tiles preserves per-tile order" {
  let siz_payload = valid_siz_payload_tile_2x2()
  let cod_payload = valid_cod_payload()
  let stream = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x52, 0x00, 0x0C, ..cod_payload,
    0xFF, 0x5C, 0x00, 0x04, 0, 0,
    // tile 0, part 0
     0xFF, 0x90, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0F, 0x00, 0x02, 0xFF,
    0x93, 0x11,
    // tile 1, part 0
     0xFF, 0x90, 0x00, 0x0A, 0x00, 0x01, 0x00, 0x00, 0x00, 0x0F, 0x00, 0x02, 0xFF,
    0x93, 0x22,
    // tile 0, part 1
     0xFF, 0x90, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0F, 0x01, 0x02, 0xFF,
    0x93, 0x33,
    // tile 1, part 1
     0xFF, 0x90, 0x00, 0x0A, 0x00, 0x01, 0x00, 0x00, 0x00, 0x0F, 0x01, 0x02, 0xFF,
    0x93, 0x44, 0xFF, 0xD9,
  ]
  let parsed = @jpeg2000.parse_codestream(stream)
  assert_true(parsed is Ok(_))
}

///|
test "failure case: tile-part interleaving breaks per-tile sequence" {
  let siz_payload = valid_siz_payload_tile_2x2()
  let cod_payload = valid_cod_payload()
  let broken = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x52, 0x00, 0x0C, ..cod_payload,
    0xFF, 0x5C, 0x00, 0x04, 0, 0,
    // tile 0, part 0
     0xFF, 0x90, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0F, 0x00, 0x02, 0xFF,
    0x93, 0x11,
    // tile 1, part 0
     0xFF, 0x90, 0x00, 0x0A, 0x00, 0x01, 0x00, 0x00, 0x00, 0x0F, 0x00, 0x02, 0xFF,
    0x93, 0x22,
    // tile 0, part 1 should be TPsot=1, but set 0
     0xFF, 0x90, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0F, 0x00, 0x02, 0xFF,
    0x93, 0x33, 0xFF, 0xD9,
  ]
  let parsed = @jpeg2000.parse_codestream(broken)
  guard parsed is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid tile-part index sequence")
}

///|
test "failure case: invalid tile-part index sequence" {
  let broken = @jpeg2000.sample_codestream_two_tileparts()
  guard marker_index_nth(broken, 0xFF, 0x90, 1) is Some(sot2_at) else {
    fail("second SOT marker should exist")
  }
  // second tile-part TPsot must be 1, set to 0 to break sequence.
  broken[sot2_at + 10] = 0x00
  let parsed = @jpeg2000.parse_codestream(broken)
  guard parsed is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid tile-part index sequence")
}

///|
test "failure case: Isot out of range" {
  let broken = @jpeg2000.sample_codestream_two_tileparts()
  guard marker_index_nth(broken, 0xFF, 0x90, 0) is Some(sot_at) else {
    fail("SOT marker should exist")
  }
  // For the sample, tile count is 1, so Isot=1 is out of range.
  broken[sot_at + 4] = 0x00
  broken[sot_at + 5] = 0x01
  let parsed = @jpeg2000.parse_codestream(broken)
  guard parsed is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="Isot out of range")
}

///|
test "failure case: SIZ component sampling must be positive" {
  let broken = @jpeg2000.sample_codestream_minimal()
  guard marker_index_nth(broken, 0xFF, 0x51, 0) is Some(siz_at) else {
    fail("SIZ marker should exist")
  }
  // SIZ payload start = siz_at + 4, then XRsiz at offset 35.
  broken[siz_at + 4 + 35] = 0x00
  let parsed = @jpeg2000.parse_codestream(broken)
  guard parsed is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}

///|
test "failure case: PLM marker segment length too short" {
  let siz_payload = valid_siz_payload()
  let cod_payload = valid_cod_payload()
  let broken = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x52, 0x00, 0x0C, ..cod_payload,
    0xFF, 0x5C, 0x00, 0x04, 0x00, 0x00, 0xFF, 0x57, 0x00, 0x03, 0x00, // PLM with too short length
     0xFF, 0x90, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x01, 0xFF,
    0x93, 0xFF, 0xD9,
  ]
  let parsed = @jpeg2000.parse_codestream(broken)
  guard parsed is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}

///|
test "failure case: invalid PLM chunk size mismatch" {
  let siz_payload = valid_siz_payload()
  let cod_payload = valid_cod_payload()
  let broken = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x52, 0x00, 0x0C, ..cod_payload,
    0xFF, 0x5C, 0x00, 0x04, 0x00, 0x00, 0xFF, 0x57, 0x00, 0x05, 0x00, 0x02, 0x01, // Nplm=2, but only 1 Iplm byte
     0xFF, 0x90, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x01, 0xFF,
    0x93, 0xFF, 0xD9,
  ]
  let parsed = @jpeg2000.parse_codestream(broken)
  guard parsed is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}

///|
test "failure case: invalid Zplm sequence" {
  let siz_payload = valid_siz_payload()
  let cod_payload = valid_cod_payload()
  let broken = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x52, 0x00, 0x0C, ..cod_payload,
    0xFF, 0x5C, 0x00, 0x04, 0x00, 0x00, 0xFF, 0x57, 0x00, 0x04, 0x00, 0x01, // PLM z=0
     0xFF, 0x57, 0x00, 0x04, 0x02, 0x01, // PLM z=2 (should be 1)
     0xFF, 0x90, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x01, 0xFF,
    0x93, 0xFF, 0xD9,
  ]
  let parsed = @jpeg2000.parse_codestream(broken)
  guard parsed is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}

///|
test "failure case: invalid Zppt sequence" {
  let siz_payload = valid_siz_payload()
  let cod_payload = valid_cod_payload()
  let broken = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x52, 0x00, 0x0C, ..cod_payload,
    0xFF, 0x5C, 0x00, 0x04, 0x00, 0x00,
    // Psot=0 to allow marker-scan fallback for this synthetic case.
     0xFF, 0x90, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF,
    0x61, 0x00, 0x04, 0x00, 0x00, // PPT z=0
     0xFF, 0x61, 0x00, 0x04, 0x02, 0x00, // PPT z=2 (should be 1)
     0xFF, 0x93, 0xFF, 0xD9,
  ]
  let parsed = @jpeg2000.parse_codestream(broken)
  guard parsed is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid Zppt sequence")
}

///|
fn marker_index(bytes : Array[Int], marker_hi : Int, marker_lo : Int) -> Int? {
  for i in 0..<(bytes.length() - 1) {
    if bytes[i] == marker_hi && bytes[i + 1] == marker_lo {
      return Some(i)
    }
  }
  None
}

///|
fn marker_index_nth(
  bytes : Array[Int],
  marker_hi : Int,
  marker_lo : Int,
  nth : Int,
) -> Int? {
  let mut count = 0
  for i in 0..<(bytes.length() - 1) {
    if bytes[i] == marker_hi && bytes[i + 1] == marker_lo {
      if count == nth {
        return Some(i)
      }
      count += 1
    }
  }
  None
}

///|
fn insert_bytes_at(
  data : Array[Int],
  at : Int,
  extra : Array[Int],
) -> Array[Int] {
  let out : Array[Int] = []
  for i in 0..<at {
    out.push(data[i])
  }
  for b in extra {
    out.push(b)
  }
  for i in at..<data.length() {
    out.push(data[i])
  }
  out
}

///|
test "default parser accepts reserved marker between COM and SOT" {
  let base = @jpeg2000.sample_codestream_with_com()
  guard marker_index(base, 0xFF, 0x90) is Some(sot_at) else {
    fail("SOT marker should exist")
  }
  let injected = insert_bytes_at(base, sot_at, [0xFF, 0x30])

  let strict_result = @jpeg2000.parse_codestream_strict(injected)
  guard strict_result is Err(msg) else { fail("strict parser should fail") }
  inspect(msg, content="invalid marker placement")

  let result = @jpeg2000.parse_codestream(injected)
  guard result is Ok(_) else { fail("default parser should accept") }

  let rt = @jpeg2000.roundtrip_bytes(injected)
  guard rt is Ok(out) else { fail("roundtrip should accept compat stream") }
  assert_eq(out, injected)
}

///|
test "strict parser accepts POC CEpoc zero as open upper bound" {
  let broken = @jpeg2000.sample_codestream_with_poc()
  guard marker_index_nth(broken, 0xFF, 0x5F, 0) is Some(poc_at) else {
    fail("POC marker should exist")
  }
  // CEpoc byte in 1-component form set to 0 (allowed by Table A.32).
  broken[poc_at + 9] = 0x00
  let strict_result = @jpeg2000.parse_codestream_strict(broken)
  guard strict_result is Ok(_) else {
    fail("strict parser should accept CEpoc=0")
  }
}

///|
test "strict parser accepts POC CEpoc 255 for Csiz<257" {
  let broken = @jpeg2000.sample_codestream_with_poc()
  guard marker_index_nth(broken, 0xFF, 0x5F, 0) is Some(poc_at) else {
    fail("POC marker should exist")
  }
  broken[poc_at + 9] = 0xFF
  let strict_result = @jpeg2000.parse_codestream_strict(broken)
  guard strict_result is Ok(_) else {
    fail("strict parser should accept CEpoc=255")
  }
}

///|
test "default parser tolerates malformed PPM packet headers" {
  let broken = @jpeg2000.sample_codestream_with_ppm()
  guard marker_index_nth(broken, 0xFF, 0x60, 0) is Some(ppm_at) else {
    fail("PPM marker should exist")
  }
  broken[ppm_at + 9] = 0xFF

  let strict_result = @jpeg2000.parse_codestream_strict(broken)
  guard strict_result is Err(msg) else {
    fail("strict parser should fail on malformed PPM packet headers")
  }
  inspect(msg, content="failed to parse packet headers in PPM")

  let parsed = @jpeg2000.parse_codestream(broken)
  guard parsed is Ok(_) else {
    fail("default parser should tolerate malformed PPM packet headers")
  }

  let rt = @jpeg2000.roundtrip_bytes(broken)
  guard rt is Ok(out) else { fail("roundtrip should succeed") }
  assert_eq(out, broken)
}

///|
test "parse minimal codestream skeleton" {
  let result = @jpeg2000.parse_codestream(minimal_codestream_bytes())
  guard result is Ok(stream) else { fail("expected parser success") }
  inspect(stream.segments.length(), content="7")
  assert_eq(stream.segments[0].code, 0xFF4F)
  assert_eq(stream.segments[1].code, 0xFF51)
  assert_eq(stream.segments[2].code, 0xFF52)
  assert_eq(stream.segments[3].code, 0xFF5C)
  assert_eq(stream.segments[4].code, 0xFF90)
  assert_eq(stream.segments[5].code, 0xFF93)
  assert_eq(stream.segments[6].code, 0xFFD9)
}

///|
test "parse minimal SIZ metadata" {
  let result = @jpeg2000.parse_codestream(minimal_codestream_bytes())
  guard result is Ok(stream) else { fail("expected parser success") }
  guard stream.metadata.siz is Some(siz) else { fail("expected SIZ metadata") }
  assert_eq(siz.xsiz, 16)
  assert_eq(siz.ysiz, 16)
  assert_eq(siz.xtsiz, 16)
  assert_eq(siz.ytsiz, 16)
  assert_eq(siz.csiz, 1)
  assert_eq(siz.tile_count, 1)
  assert_eq(siz.components.length(), 1)
  assert_eq(siz.components[0].precision_bits, 8)
  assert_eq(siz.components[0].xrsiz, 1)
  assert_eq(siz.components[0].yrsiz, 1)
}

///|
test "parse minimal COD and QCD metadata" {
  let result = @jpeg2000.parse_codestream(minimal_codestream_bytes())
  guard result is Ok(stream) else { fail("expected parser success") }
  guard stream.metadata.cod is Some(cod) else { fail("expected COD metadata") }
  guard stream.metadata.qcd is Some(qcd) else { fail("expected QCD metadata") }
  assert_eq(cod.progression_order, 0)
  assert_eq(cod.layers, 1)
  assert_eq(cod.multiple_component_transform, 0)
  assert_eq(cod.decomposition_levels, 0)
  assert_eq(cod.code_block_width_exponent, 2)
  assert_eq(cod.code_block_height_exponent, 2)
  assert_eq(qcd.guard_bits, 0)
  assert_eq(qcd.quantization_style, 0)
}

///|
test "parse COC/QCC metadata from sample" {
  let result = @jpeg2000.parse_codestream(
    @jpeg2000.sample_codestream_with_coc_qcc(),
  )
  guard result is Ok(stream) else { fail("expected parser success") }
  assert_eq(stream.metadata.coc.length(), 1)
  assert_eq(stream.metadata.qcc.length(), 1)
  assert_eq(stream.metadata.coc[0].component, 0)
  assert_eq(stream.metadata.qcc[0].component, 0)
}

///|
test "parse POC metadata from sample" {
  let result = @jpeg2000.parse_codestream(
    @jpeg2000.sample_codestream_with_poc(),
  )
  guard result is Ok(stream) else { fail("expected parser success") }
  assert_eq(stream.metadata.poc.length(), 1)
  assert_eq(stream.metadata.poc[0].cspoc, 0)
  assert_eq(stream.metadata.poc[0].cepoc, 1)
  assert_eq(stream.metadata.poc[0].ppoc, 0)
}

///|
test "parse PLM/PLT metadata from sample" {
  let result = @jpeg2000.parse_codestream(
    @jpeg2000.sample_codestream_with_plm_plt(),
  )
  guard result is Ok(stream) else { fail("expected parser success") }
  assert_eq(stream.metadata.plm.length(), 1)
  assert_eq(stream.metadata.plm[0].zplm, 0)
  assert_eq(stream.metadata.plm[0].chunks.length(), 1)
  assert_eq(stream.metadata.plm[0].chunks[0].packet_lengths, [1])
  assert_eq(stream.metadata.plt.length(), 1)
  assert_eq(stream.metadata.plt[0].zplt, 0)
  assert_eq(stream.metadata.plt[0].packet_lengths, [1])
}

///|
test "parse PPM/PPT metadata from samples" {
  let with_ppm = @jpeg2000.parse_codestream(
    @jpeg2000.sample_codestream_with_ppm(),
  )
  guard with_ppm is Ok(ppm_stream) else { fail("expected parser success") }
  assert_eq(ppm_stream.metadata.ppm.length(), 1)
  assert_eq(ppm_stream.metadata.ppm[0].zppm, 0)
  assert_eq(ppm_stream.metadata.ppm[0].chunks.length(), 1)
  assert_eq(ppm_stream.metadata.ppm[0].chunks[0].nppm, 1)
  assert_eq(ppm_stream.metadata.ppm[0].chunks[0].ippm, [0])
  assert_eq(ppm_stream.metadata.packet_headers_ppm.length(), 1)
  assert_eq(ppm_stream.metadata.packet_headers_ppm[0].zero_length, true)

  let with_ppt = @jpeg2000.parse_codestream(
    @jpeg2000.sample_codestream_with_ppt_sop_eph(),
  )
  guard with_ppt is Ok(ppt_stream) else { fail("expected parser success") }
  assert_eq(ppt_stream.metadata.ppt.length(), 1)
  assert_eq(ppt_stream.metadata.ppt[0].zppt, 0)
  assert_eq(ppt_stream.metadata.ppt[0].data, [0])
  assert_eq(ppt_stream.metadata.packet_headers_ppt.length(), 1)
  assert_eq(ppt_stream.metadata.packet_headers_ppt[0].zero_length, true)
}

///|
test "packet header single-codeblock decode: non-empty packet" {
  // non-zero, include-first-time, zero-bit-planes=3, coding-passes=3, Lblock+0, length=10
  let bytes = bits_to_bytes("110001110001010")
  let result = @jpeg2000.parse_packet_headers_single_codeblock(bytes)
  guard result is Ok(headers) else {
    fail("expected packet header parse success")
  }
  assert_eq(headers.length(), 1)
  assert_eq(headers[0].zero_length, false)
  assert_eq(headers[0].code_blocks.length(), 1)
  assert_eq(headers[0].code_blocks[0].included, true)
  assert_eq(headers[0].code_blocks[0].first_inclusion, true)
  assert_eq(headers[0].code_blocks[0].zero_bit_planes, Some(3))
  assert_eq(headers[0].code_blocks[0].coding_passes, Some(3))
  assert_eq(headers[0].code_blocks[0].segment_lengths, [10])
}

///|
test "packet header single-codeblock decode: zero-length packet" {
  let result = @jpeg2000.parse_packet_headers_single_codeblock([0x00])
  guard result is Ok(headers) else {
    fail("expected packet header parse success")
  }
  assert_eq(headers.length(), 1)
  assert_eq(headers[0].zero_length, true)
  assert_eq(headers[0].code_blocks[0].included, false)
}

///|
test "packet header multi-codeblock decode with state carryover" {
  // Packet#1: both CBs first included.
  // Packet#2: CB0 omitted, CB1 included again.
  let bytes = bits_to_bytes("111000111001101000100000101110000111")
  let result = @jpeg2000.parse_packet_headers_with_code_blocks(bytes, 2)
  guard result is Ok(headers) else {
    fail("expected packet header parse success")
  }
  assert_eq(headers.length(), 2)

  assert_eq(headers[0].zero_length, false)
  assert_eq(headers[0].code_blocks.length(), 2)
  assert_eq(headers[0].code_blocks[0].included, true)
  assert_eq(headers[0].code_blocks[0].first_inclusion, true)
  assert_eq(headers[0].code_blocks[0].zero_bit_planes, Some(0))
  assert_eq(headers[0].code_blocks[0].coding_passes, Some(1))
  assert_eq(headers[0].code_blocks[0].segment_lengths, [3])
  assert_eq(headers[0].code_blocks[1].included, true)
  assert_eq(headers[0].code_blocks[1].first_inclusion, true)
  assert_eq(headers[0].code_blocks[1].zero_bit_planes, Some(2))
  assert_eq(headers[0].code_blocks[1].coding_passes, Some(2))
  assert_eq(headers[0].code_blocks[1].segment_lengths, [4])

  assert_eq(headers[1].zero_length, false)
  assert_eq(headers[1].code_blocks[0].included, false)
  assert_eq(headers[1].code_blocks[1].included, true)
  assert_eq(headers[1].code_blocks[1].first_inclusion, false)
  assert_eq(headers[1].code_blocks[1].coding_passes, Some(3))
  assert_eq(headers[1].code_blocks[1].segment_lengths, [14])
}

///|
test "failure case: invalid packet header coding passes sequence" {
  // non-zero + include + first-inclusion + zero-bit-plane code without terminating 1
  let broken = bits_to_bytes("110000000")
  let result = @jpeg2000.parse_packet_headers_single_codeblock(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="unterminated zero bit-plane code")
}

///|
test "failure case: invalid packet header code-block count" {
  let result = @jpeg2000.parse_packet_headers_with_code_blocks([0x00], 0)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="code_block_count must be positive")
}

///|
test "packet header decode: coding pass codeword boundaries" {
  let cases = [6, 36, 37, 164]
  for passes in cases {
    let bits = single_codeblock_header_bits(passes, 0, 1)
    let bytes = bits_to_bytes(bits)
    let result = @jpeg2000.parse_packet_headers_single_codeblock(bytes)
    guard result is Ok(headers) else {
      fail("expected packet header parse success")
    }
    assert_eq(headers.length(), 1)
    assert_eq(headers[0].code_blocks.length(), 1)
    assert_eq(headers[0].code_blocks[0].coding_passes, Some(passes))
    assert_eq(headers[0].code_blocks[0].segment_lengths, [1])
  }
}

///|
test "failure case: truncated packet header length bits" {
  // valid prefix for passes=3 then truncate length field
  let broken = bits_to_bytes("1111000")
  let result = @jpeg2000.parse_packet_headers_single_codeblock(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="failed to decode code-block segment length")
}

///|
test "decode codeblock segment lengths helper: single segment" {
  // increment=0, length=10 on width=3 bits
  let bits = bits_to_bytes("0010")
  let result = @jpeg2000.decode_codeblock_segment_lengths_from_bits(bits, 3, [1])
  guard result is Ok((lengths, consumed)) else {
    fail("expected decode success")
  }
  assert_eq(lengths, [2])
  assert_eq(consumed, 4)
}

///|
test "decode codeblock segment lengths helper: multiple segments (B.10.7.2)" {
  // segment1: passes=1, inc=0, width=3, len=6  => 0 110
  // segment2: passes=2, inc=1, width=5, len=17 => 10 10001
  // segment3: passes=1, inc=0, width=4, len=9  => 0 1001
  let bits = bits_to_bytes("0110101000101001")
  let result = @jpeg2000.decode_codeblock_segment_lengths_from_bits(bits, 3, [
    1, 2, 1,
  ])
  guard result is Ok((lengths, consumed)) else {
    fail("expected decode success")
  }
  assert_eq(lengths, [6, 17, 9])
  assert_eq(consumed, 16)
}

///|
test "failure case: decode codeblock segment lengths helper truncated" {
  let result = @jpeg2000.decode_codeblock_segment_lengths_from_bits([], 3, [1])
  guard result is Err(msg) else { fail("expected decode failure") }
  inspect(msg, content="unterminated Lblock increment code")
}

///|
test "tag-tree inclusion decode: non-degenerate 2x2 sharing root state" {
  // root=1(known at 0), then leaf bits for raster leaves: 1,0,1,0
  let data = bits_to_bytes("11010")
  let result = @jpeg2000.decode_tag_tree_inclusion_flags(data, 2, 2, 1)
  guard result is Ok((flags, consumed)) else {
    fail("expected tag-tree decode success")
  }
  assert_eq(flags, [true, false, true, false])
  assert_eq(consumed, 5)
}

///|
test "failure case: tag-tree inclusion decode truncated" {
  let result = @jpeg2000.decode_tag_tree_inclusion_flags([], 2, 2, 1)
  guard result is Err(msg) else { fail("expected tag-tree decode failure") }
  inspect(msg, content="tag-tree bitstream truncated")
}

///|
test "failure case: tag-tree inclusion decode invalid threshold" {
  let result = @jpeg2000.decode_tag_tree_inclusion_flags([0x00], 2, 2, 0)
  guard result is Err(msg) else { fail("expected tag-tree decode failure") }
  inspect(msg, content="tag-tree threshold must be positive")
}

///|
test "packet header single packet with tag-tree inclusion" {
  // non-zero packet + inclusion tag-tree bits(2x2) + per-included block payload
  // inclusion flags become [true, false, true, false]
  let bits = bits_to_bytes("111010100011011000101")
  let result = @jpeg2000.parse_packet_header_single_packet_with_tag_tree(
    bits, 2, 2, 0,
  )
  guard result is Ok(header) else {
    fail("expected packet header parse success")
  }
  assert_eq(header.zero_length, false)
  assert_eq(header.code_blocks.length(), 4)
  assert_eq(header.code_blocks[0].included, true)
  assert_eq(header.code_blocks[0].first_inclusion, true)
  assert_eq(header.code_blocks[0].zero_bit_planes, Some(0))
  assert_eq(header.code_blocks[0].coding_passes, Some(1))
  assert_eq(header.code_blocks[0].segment_lengths, [3])
  assert_eq(header.code_blocks[1].included, false)
  assert_eq(header.code_blocks[2].included, true)
  assert_eq(header.code_blocks[2].first_inclusion, true)
  assert_eq(header.code_blocks[2].zero_bit_planes, Some(1))
  assert_eq(header.code_blocks[2].coding_passes, Some(2))
  assert_eq(header.code_blocks[2].segment_lengths, [5])
  assert_eq(header.code_blocks[3].included, false)
}

///|
test "failure case: packet header with tag-tree inclusion truncated" {
  let result = @jpeg2000.parse_packet_header_single_packet_with_tag_tree(
    [],
    2,
    2,
    0,
  )
  guard result is Err(msg) else { fail("expected packet header parse failure") }
  inspect(msg, content="packet header bitstream truncated")
}

///|
test "packet header with tag-tree inclusion and pass splits" {
  // non-zero + inclusion(1x1) + zbp(0) + passes(3) + lengths for [1,2]: 2 and 5
  let bits = bits_to_bytes("111110000101000101")
  let result = @jpeg2000.parse_packet_header_single_packet_with_tag_tree_and_pass_splits(
    bits,
    1,
    1,
    0,
    [[1, 2]],
  )
  guard result is Ok(header) else {
    guard result is Err(msg) else {
      fail("expected packet header parse success")
    }
    fail(msg)
  }
  assert_eq(header.code_blocks.length(), 1)
  assert_eq(header.code_blocks[0].coding_passes, Some(3))
  assert_eq(header.code_blocks[0].segment_lengths, [2, 5])
}

///|
test "failure case: tag-tree pass splits mismatch coding passes" {
  let bits = bits_to_bytes("111110000101000101")
  let result = @jpeg2000.parse_packet_header_single_packet_with_tag_tree_and_pass_splits(
    bits,
    1,
    1,
    0,
    [[1, 1]],
  )
  guard result is Err(msg) else { fail("expected packet header parse failure") }
  inspect(msg, content="failed to decode code-block segment length")
}

///|
test "packet header with tag-tree pass splits on 2x2 code-blocks" {
  // non-zero + inclusion(tag-tree 2x2 => [T,F,T,F]) +
  // cb0: zbp=0, passes=3, split [1,2], lengths [2,5]
  // cb2: zbp=1, passes=1, length [3]
  let bits = bits_to_bytes("111010111000010001010100011")
  let result = @jpeg2000.parse_packet_header_single_packet_with_tag_tree_and_pass_splits(
    bits,
    2,
    2,
    0,
    [[1, 2], [], [1], []],
  )
  guard result is Ok(header) else {
    guard result is Err(msg) else {
      fail("expected packet header parse success")
    }
    fail(msg)
  }
  assert_eq(header.code_blocks.length(), 4)
  assert_eq(header.code_blocks[0].included, true)
  assert_eq(header.code_blocks[0].segment_lengths, [2, 5])
  assert_eq(header.code_blocks[1].included, false)
  assert_eq(header.code_blocks[2].included, true)
  assert_eq(header.code_blocks[2].zero_bit_planes, Some(1))
  assert_eq(header.code_blocks[2].segment_lengths, [3])
  assert_eq(header.code_blocks[3].included, false)
}

///|
test "packet headers tag-tree sequence: carry state across packets" {
  // packet1 (1x1): include first time, zbp=2, passes=1, length=3
  // packet2 (1x1): same block included again via 1-bit inclusion, passes=2, length=5
  let bits = bits_to_bytes("1100100011000000111000101")
  let result = @jpeg2000.parse_packet_headers_with_tag_tree_sequence(
    bits, 1, 1, 2,
  )
  guard result is Ok(headers) else {
    fail("expected packet header sequence parse success")
  }
  assert_eq(headers.length(), 2)
  assert_eq(headers[0].code_blocks.length(), 1)
  assert_eq(headers[0].code_blocks[0].included, true)
  assert_eq(headers[0].code_blocks[0].first_inclusion, true)
  assert_eq(headers[0].code_blocks[0].zero_bit_planes, Some(2))
  assert_eq(headers[0].code_blocks[0].coding_passes, Some(1))
  assert_eq(headers[0].code_blocks[0].segment_lengths, [3])
  assert_eq(headers[1].code_blocks.length(), 1)
  assert_eq(headers[1].code_blocks[0].included, true)
  assert_eq(headers[1].code_blocks[0].first_inclusion, false)
  assert_eq(headers[1].code_blocks[0].zero_bit_planes, None)
  assert_eq(headers[1].code_blocks[0].coding_passes, Some(2))
  assert_eq(headers[1].code_blocks[0].segment_lengths, [5])
}

///|
test "failure case: packet headers tag-tree sequence invalid packet count" {
  let result = @jpeg2000.parse_packet_headers_with_tag_tree_sequence(
    [0x00],
    1,
    1,
    0,
  )
  guard result is Err(msg) else { fail("expected packet header parse failure") }
  inspect(msg, content="packet_count must be positive")
}

///|
test "packet headers tag-tree sequence with pass splits on second layer" {
  // packet1(1x1): include first time, zbp=2, passes=1, len=3
  // packet2(1x1): included again, passes=3 split as [1,2], lengths [2,5]
  let bits = bits_to_bytes("1100100011000000111100001000101")
  let result = @jpeg2000.parse_packet_headers_with_tag_tree_sequence_and_pass_splits(
    bits,
    1,
    1,
    2,
    [[], [[1, 2]]],
  )
  guard result is Ok(headers) else {
    guard result is Err(msg) else { fail("expected sequence parse success") }
    fail(msg)
  }
  assert_eq(headers.length(), 2)
  assert_eq(headers[0].code_blocks[0].coding_passes, Some(1))
  assert_eq(headers[0].code_blocks[0].segment_lengths, [3])
  assert_eq(headers[1].code_blocks[0].coding_passes, Some(3))
  assert_eq(headers[1].code_blocks[0].segment_lengths, [2, 5])
}

///|
test "failure case: sequence pass splits mismatch coding passes" {
  let bits = bits_to_bytes("1100100011000000111100001000101")
  let result = @jpeg2000.parse_packet_headers_with_tag_tree_sequence_and_pass_splits(
    bits,
    1,
    1,
    2,
    [[], [[1, 1]]],
  )
  guard result is Err(msg) else { fail("expected sequence parse failure") }
  inspect(msg, content="failed to decode code-block segment length")
}

///|
test "packet headers tag-tree sequence: zero-length then first inclusion" {
  // packet1: zero length (bit 0), packet2 starts at next byte boundary
  // packet2(1x1): non-zero(1), inclusion@layer2 bits(01), zbp=0(1), passes=1(0), Lblock+0(0), len=2(010)
  let data = [0x00, 0xB1, 0x00]
  let result = @jpeg2000.parse_packet_headers_with_tag_tree_sequence(
    data, 1, 1, 2,
  )
  guard result is Ok(headers) else {
    fail("expected packet header sequence parse success")
  }
  assert_eq(headers.length(), 2)
  assert_eq(headers[0].zero_length, true)
  assert_eq(headers[0].code_blocks[0].included, false)
  assert_eq(headers[1].zero_length, false)
  assert_eq(headers[1].code_blocks[0].included, true)
  assert_eq(headers[1].code_blocks[0].first_inclusion, true)
  assert_eq(headers[1].code_blocks[0].zero_bit_planes, Some(0))
  assert_eq(headers[1].code_blocks[0].coding_passes, Some(1))
  assert_eq(headers[1].code_blocks[0].segment_lengths, [2])
}

///|
test "parse TLM metadata from sample" {
  let result = @jpeg2000.parse_codestream(
    @jpeg2000.sample_codestream_with_tlm(),
  )
  guard result is Ok(stream) else { fail("expected parser success") }
  assert_eq(stream.metadata.tlm.length(), 1)
  assert_eq(stream.metadata.tlm[0].ztlm, 0)
  assert_eq(stream.metadata.tlm[0].stlm, 0)
  assert_eq(stream.metadata.tlm[0].entries.length(), 1)
  assert_true(stream.metadata.tlm[0].entries[0].tile is None)
  assert_eq(stream.metadata.tlm[0].entries[0].length, 14)
}

///|
test "parse SOP/EPH metadata from sample" {
  let result = @jpeg2000.parse_codestream(
    @jpeg2000.sample_codestream_with_ppt_sop_eph(),
  )
  guard result is Ok(stream) else { fail("expected parser success") }
  assert_eq(stream.metadata.sop.length(), 1)
  assert_eq(stream.metadata.sop[0].nsop, 0)
  assert_eq(stream.metadata.eph_positions.length(), 1)
}

///|
test "parse COM metadata from sample" {
  let result = @jpeg2000.parse_codestream(
    @jpeg2000.sample_codestream_with_com(),
  )
  guard result is Ok(stream) else { fail("expected parser success") }
  assert_eq(stream.metadata.com.length(), 1)
  assert_eq(stream.metadata.com[0].rcom, 1)
}

///|
test "parse CRG metadata from stream" {
  let siz_payload = valid_siz_payload()
  let cod_payload = valid_cod_payload()
  let stream = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x63, 0x00, 0x06, 0x00,
    0x01, 0x00, 0x02, // Xcrg=1, Ycrg=2
     0xFF, 0x52, 0x00, 0x0C, ..cod_payload, 0xFF, 0x5C, 0x00, 0x04, 0, 0, 0xFF, 0x90,
    0x00, 0x0A, 0, 0, 0, 0, 0, 0x0E, 0, 0, 0xFF, 0x93, 0xFF, 0xD9,
  ]
  let result = @jpeg2000.parse_codestream(stream)
  guard result is Ok(parsed) else {
    guard result is Err(msg) else { fail("expected parser success") }
    fail(msg)
  }
  guard parsed.metadata.crg is Some(crg) else { fail("expected CRG metadata") }
  assert_eq(crg.components.length(), 1)
  assert_eq(crg.components[0].xcrg, 1)
  assert_eq(crg.components[0].ycrg, 2)
}

///|
test "parse ordering metadata from minimal sample" {
  let result = @jpeg2000.parse_codestream(@jpeg2000.sample_codestream_minimal())
  guard result is Ok(stream) else { fail("expected parser success") }
  guard stream.metadata.ordering is Some(o) else {
    fail("expected ordering metadata")
  }
  assert_eq(o.reference_grid.x0, 0)
  assert_eq(o.reference_grid.y0, 0)
  assert_eq(o.reference_grid.x1, 16)
  assert_eq(o.reference_grid.y1, 16)
  assert_eq(o.tiles_x, 1)
  assert_eq(o.tiles_y, 1)
  assert_eq(o.components.length(), 1)
  assert_eq(o.components[0].width, 16)
  assert_eq(o.components[0].height, 16)
  assert_eq(o.tiles.length(), 1)
  assert_eq(o.tile_components.length(), 1)
  assert_eq(o.tile_components[0].width, 16)
  assert_eq(o.tile_components[0].height, 16)
  assert_eq(o.tiles[0].x0, 0)
  assert_eq(o.tiles[0].y0, 0)
  assert_eq(o.tiles[0].x1, 16)
  assert_eq(o.tiles[0].y1, 16)
}

///|
test "ordering metadata: 2x2 tile partition" {
  let siz_payload = valid_siz_payload_tile_2x2()
  let cod_payload = valid_cod_payload()
  let stream = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x52, 0x00, 0x0C, ..cod_payload,
    0xFF, 0x5C, 0x00, 0x04, 0, 0, 0xFF, 0x90, 0x00, 0x0A, 0, 0, 0, 0, 0, 0x0E, 0,
    0, 0xFF, 0x93, 0xFF, 0xD9,
  ]
  let result = @jpeg2000.parse_codestream(stream)
  guard result is Ok(parsed) else { fail("expected parser success") }
  guard parsed.metadata.ordering is Some(o) else {
    fail("expected ordering metadata")
  }
  assert_eq(o.tiles_x, 2)
  assert_eq(o.tiles_y, 2)
  assert_eq(o.tiles.length(), 4)
  assert_eq(o.tile_components.length(), 4)
  assert_eq(o.tile_components[0].width, 8)
  assert_eq(o.tile_components[0].height, 8)
  assert_eq(o.tiles[0].x1, 8)
  assert_eq(o.tiles[0].y1, 8)
  assert_eq(o.tiles[3].x0, 8)
  assert_eq(o.tiles[3].y0, 8)
}

///|
test "ordering metadata: component mapping by sampling factors" {
  let siz_payload = valid_siz_payload_sampling_2()
  let cod_payload = valid_cod_payload()
  let stream = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x52, 0x00, 0x0C, ..cod_payload,
    0xFF, 0x5C, 0x00, 0x04, 0, 0, 0xFF, 0x90, 0x00, 0x0A, 0, 0, 0, 0, 0, 0x0E, 0,
    0, 0xFF, 0x93, 0xFF, 0xD9,
  ]
  let result = @jpeg2000.parse_codestream(stream)
  guard result is Ok(parsed) else { fail("expected parser success") }
  guard parsed.metadata.ordering is Some(o) else {
    fail("expected ordering metadata")
  }
  assert_eq(o.components.length(), 1)
  assert_eq(o.components[0].xrsiz, 2)
  assert_eq(o.components[0].yrsiz, 2)
  assert_eq(o.components[0].width, 8)
  assert_eq(o.components[0].height, 8)
  assert_eq(o.tile_components.length(), 1)
  assert_eq(o.tile_components[0].width, 8)
  assert_eq(o.tile_components[0].height, 8)
}

///|
test "ordering coding metadata from COD decomposition levels" {
  let siz_payload = valid_siz_payload()
  let cod_payload = valid_cod_payload_decomp2()
  let stream = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x52, 0x00, 0x0C, ..cod_payload,
    0xFF, 0x5C, 0x00, 0x04, 0, 0, 0xFF, 0x90, 0x00, 0x0A, 0, 0, 0, 0, 0, 0x0E, 0,
    0, 0xFF, 0x93, 0xFF, 0xD9,
  ]
  let result = @jpeg2000.parse_codestream(stream)
  guard result is Ok(parsed) else { fail("expected parser success") }
  guard parsed.metadata.ordering_coding is Some(o) else {
    fail("expected ordering coding metadata")
  }
  assert_eq(o.decomposition_levels, 2)
  assert_eq(o.resolution_count, 3)
  assert_eq(o.subbands_per_resolution, [1, 3, 3])
  assert_eq(o.precincts.length(), 3)
  assert_eq(o.precincts[0].ppx, 15)
  assert_eq(o.precincts[0].ppy, 15)
  assert_eq(o.code_blocks.length(), 3)
  assert_eq(o.code_blocks[0].nominal_width, 4)
  assert_eq(o.code_blocks[0].nominal_height, 4)
  assert_eq(o.packets.length(), 3)
  assert_eq(o.packets[0].layers, 1)
}

///|
test "ordering progression metadata from minimal sample" {
  let result = @jpeg2000.parse_codestream(@jpeg2000.sample_codestream_minimal())
  guard result is Ok(parsed) else { fail("expected parser success") }
  guard parsed.metadata.progression is Some(p) else {
    fail("expected progression metadata")
  }
  assert_eq(p.order_code, 0)
  assert_eq(p.volumes.length(), 1)
  assert_eq(p.volumes[0].source_poc_index, -1)
  assert_eq(p.steps.length(), 1)
  assert_eq(p.steps[0].order_index, 0)
  assert_eq(p.steps[0].layer, 0)
  assert_eq(p.steps[0].resolution, 0)
  assert_eq(p.steps[0].component, 0)
  assert_eq(p.total_packets, 1)
}

///|
test "ordering coding metadata: precincts and packets" {
  let siz_payload = valid_siz_payload()
  let cod_payload = valid_cod_payload_decomp2_precincts_layers3()
  let stream = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x52, 0x00, 0x0F, ..cod_payload,
    0xFF, 0x5C, 0x00, 0x04, 0, 0, 0xFF, 0x90, 0x00, 0x0A, 0, 0, 0, 0, 0, 0x0E, 0,
    0, 0xFF, 0x93, 0xFF, 0xD9,
  ]
  let result = @jpeg2000.parse_codestream(stream)
  guard result is Ok(parsed) else { fail("expected parser success") }
  guard parsed.metadata.ordering_coding is Some(o) else {
    fail("expected ordering coding metadata")
  }
  assert_eq(o.precincts.length(), 3)
  assert_eq(o.precincts[0].ppx, 4)
  assert_eq(o.precincts[0].ppy, 4)
  assert_eq(o.precincts[1].ppx, 3)
  assert_eq(o.precincts[1].ppy, 3)
  assert_eq(o.precincts[2].ppx, 2)
  assert_eq(o.precincts[2].ppy, 2)
  assert_eq(o.packets.length(), 3)
  assert_eq(o.packets[0].tile_index, 0)
  assert_eq(o.packets[0].layers, 3)
  assert_true(o.packets[0].packets_per_layer > 0)
  assert_eq(o.packets[0].packets_total, o.packets[0].packets_per_layer * 3)
}

///|
test "ordering coding metadata: packets scale with tiles" {
  let siz_payload = valid_siz_payload_tile_2x2()
  let cod_payload = valid_cod_payload_decomp2()
  let stream = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x52, 0x00, 0x0C, ..cod_payload,
    0xFF, 0x5C, 0x00, 0x04, 0, 0, 0xFF, 0x90, 0x00, 0x0A, 0, 0, 0, 0, 0, 0x0E, 0,
    0, 0xFF, 0x93, 0xFF, 0xD9,
  ]
  let result = @jpeg2000.parse_codestream(stream)
  guard result is Ok(parsed) else { fail("expected parser success") }
  guard parsed.metadata.ordering_coding is Some(o) else {
    fail("expected ordering coding metadata")
  }
  // 4 tiles x 1 component x 3 resolutions
  assert_eq(o.packets.length(), 12)
  assert_eq(o.packets[0].tile_index, 0)
  assert_eq(o.packets[3].tile_index, 1)
  assert_eq(o.packets[6].tile_index, 2)
  assert_eq(o.packets[9].tile_index, 3)
}

///|
test "ordering progression metadata: LRCP layering sequence" {
  let siz_payload = valid_siz_payload()
  let cod_payload = valid_cod_payload_decomp2_precincts_layers3()
  let stream = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x52, 0x00, 0x0F, ..cod_payload,
    0xFF, 0x5C, 0x00, 0x04, 0, 0, 0xFF, 0x90, 0x00, 0x0A, 0, 0, 0, 0, 0, 0x0E, 0,
    0, 0xFF, 0x93, 0xFF, 0xD9,
  ]
  let result = @jpeg2000.parse_codestream(stream)
  guard result is Ok(parsed) else { fail("expected parser success") }
  guard parsed.metadata.progression is Some(p) else {
    fail("expected progression metadata")
  }
  // layers(3) * resolutions(3) * components(1)
  assert_eq(p.steps.length(), 9)
  assert_eq(p.steps[0].order_index, 0)
  assert_eq(p.steps[8].order_index, 8)
  assert_eq(p.steps[0].layer, 0)
  assert_eq(p.steps[0].resolution, 0)
  assert_eq(p.steps[3].layer, 1)
  assert_eq(p.steps[6].layer, 2)
  assert_true(p.total_packets > 0)
}

///|
test "ordering progression metadata: supports all progression orders" {
  let siz_payload = valid_siz_payload()
  let orders = [0, 1, 2, 3, 4]
  let expected_step1_layer = [0, 1, 1, 1, 0]
  let expected_step1_resolution = [1, 0, 0, 0, 1]
  let expected_step3_layer = [1, 0, 0, 0, 1]
  let expected_step3_resolution = [0, 1, 1, 1, 0]
  for idx in 0..<orders.length() {
    let order = orders[idx]
    let cod_payload = valid_cod_payload_decomp2_precincts_layers3_with_order(
      order,
    )
    let stream = [
      0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x52, 0x00, 0x0F,
      ..cod_payload, 0xFF, 0x5C, 0x00, 0x04, 0, 0, 0xFF, 0x90, 0x00, 0x0A, 0, 0,
      0, 0, 0, 0x0E, 0, 0, 0xFF, 0x93, 0xFF, 0xD9,
    ]
    let result = @jpeg2000.parse_codestream(stream)
    guard result is Ok(parsed) else { fail("expected parser success") }
    guard parsed.metadata.progression is Some(p) else {
      fail("expected progression metadata")
    }
    assert_eq(p.order_code, order)
    assert_eq(p.steps.length(), 9)
    assert_eq(p.steps[0].order_index, 0)
    assert_eq(p.steps[1].layer, expected_step1_layer[idx])
    assert_eq(p.steps[1].resolution, expected_step1_resolution[idx])
    assert_eq(p.steps[3].layer, expected_step3_layer[idx])
    assert_eq(p.steps[3].resolution, expected_step3_resolution[idx])
  }
}

///|
test "ordering progression metadata: POC overrides progression order volume" {
  let siz_payload = valid_siz_payload()
  let cod_payload = valid_cod_payload_decomp2_precincts_layers3_with_order(0)
  let stream = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x52, 0x00, 0x0F, ..cod_payload,
    0xFF, 0x5C, 0x00, 0x04, 0, 0, 0xFF, 0x5F, // POC
     0x00, 0x09, // Lpoc = 2 + 7
     0x00, // RSpoc
     0x00, // CSpoc
     0x00, 0x03, // LYEpoc
     0x03, // REpoc
     0x01, // CEpoc
     0x04, // Ppoc = CPRL
     0xFF, 0x90, 0x00, 0x0A, 0, 0, 0, 0, 0, 0x0E, 0, 0, 0xFF, 0x93, 0xFF, 0xD9,
  ]
  let result = @jpeg2000.parse_codestream(stream)
  guard result is Ok(parsed) else { fail("expected parser success") }
  guard parsed.metadata.progression is Some(p) else {
    fail("expected progression metadata")
  }
  assert_eq(p.order_code, 0)
  assert_eq(p.volumes.length(), 1)
  assert_eq(p.volumes[0].source_poc_index, 0)
  assert_eq(p.volumes[0].order_code, 4)
  // CPRL with single component: layer-major then resolution
  assert_eq(p.steps[0].layer, 0)
  assert_eq(p.steps[0].resolution, 0)
  assert_eq(p.steps[1].layer, 0)
  assert_eq(p.steps[1].resolution, 1)
  assert_eq(p.steps[3].layer, 1)
  assert_eq(p.steps[3].resolution, 0)
}

///|
test "round-trip codestream markers" {
  let parsed = @jpeg2000.parse_codestream(minimal_codestream_bytes())
  guard parsed is Ok(stream) else { fail("expected parser success") }
  let encoded = @jpeg2000.encode_codestream(stream)
  guard encoded is Ok(bytes) else { fail("expected encoder success") }
  assert_eq(bytes, minimal_codestream_bytes())
}

///|
test "marker classes for Annex A groups" {
  assert_true(@jpeg2000.classify_marker(0xFF4F) is Delimiting)
  assert_true(@jpeg2000.classify_marker(0xFF51) is FixedInformation)
  assert_true(@jpeg2000.classify_marker(0xFF52) is Functional)
  assert_true(@jpeg2000.classify_marker(0xFF55) is Pointer)
  assert_true(@jpeg2000.classify_marker(0xFF91) is InBitStream)
  assert_true(@jpeg2000.classify_marker(0xFF64) is Informational)
}

///|
test "failure case: missing SOC" {
  let broken = [0xFF, 0x90, 0x00, 0x02, 0xFF, 0xD9]
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="SOC must appear at codestream start")
}

///|
test "failure case: reserved marker range" {
  let broken = [
    0xFF, 0x4F, // SOC
     0xFF, 0x30, // reserved JPEG marker range
     0x00, 0x02, 0xFF, 0xD9,
  ]
  let result = @jpeg2000.parse_codestream_strict(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker placement")
}

///|
test "failure case: all reserved marker codes are rejected" {
  for lo in 0x30..<=0x3F {
    let broken = [
      0xFF, 0x4F, // SOC
       0xFF, lo, // reserved JPEG marker range
       0x00, 0x02, 0xFF, 0xD9,
    ]
    let result = @jpeg2000.parse_codestream_strict(broken)
    guard result is Err(msg) else { fail("expected parser failure") }
    inspect(msg, content="invalid marker placement")
  }
}

///|
test "failure case: SIZ must be second marker segment" {
  let broken = [
    0xFF, 0x4F, // SOC
     0xFF, 0x52, // COD
     0x00, 0x0C, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xFF, 0xD9,
  ]
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="SIZ must be the second marker segment")
}

///|
test "failure case: missing COD is rejected" {
  let broken = @jpeg2000.sample_codestream_minimal()
  guard marker_index_nth(broken, 0xFF, 0x52, 0) is Some(cod_at) else {
    fail("COD marker should exist")
  }
  broken[cod_at + 1] = 0x64 // COM
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="missing required main header markers")
}

///|
test "failure case: missing QCD is rejected" {
  let broken = @jpeg2000.sample_codestream_minimal()
  guard marker_index_nth(broken, 0xFF, 0x5C, 0) is Some(qcd_at) else {
    fail("QCD marker should exist")
  }
  broken[qcd_at + 1] = 0x64 // COM
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="missing required main header markers")
}

///|
test "failure case: missing SOT/SOD pair is rejected" {
  let siz_payload = valid_siz_payload()
  let cod_payload = valid_cod_payload()
  let broken = [
    0xFF, 0x4F, // SOC
     0xFF, 0x51, 0x00, 0x29, ..siz_payload, // SIZ
     0xFF, 0x52, 0x00, 0x0C, ..cod_payload, // COD
     0xFF, 0x5C, 0x00, 0x04, 0x00, 0x00, // QCD
     0xFF, 0xD9, // EOC
  ]
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="at least one SOT/SOD pair is required")
}

///|
test "failure case: invalid marker placement in main header" {
  let siz_payload = valid_siz_payload()
  let broken = [
    0xFF, 0x4F, // SOC
     0xFF, 0x51, // SIZ
     0x00, 0x29, ..siz_payload, 0xFF, 0x58, // PLT (tile-part header only)
     0x00, 0x03, 0x00, 0xFF, 0xD9,
  ]
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker placement")
}

///|
test "failure case: SOD before SOT is invalid placement" {
  let siz_payload = valid_siz_payload()
  let cod_payload = valid_cod_payload()
  let broken = [
    0xFF, 0x4F, // SOC
     0xFF, 0x51, // SIZ
     0x00, 0x29, ..siz_payload, 0xFF, 0x52, // COD
     0x00, 0x0C, ..cod_payload, 0xFF, 0x5C, // QCD
     0x00, 0x04, 0x00, 0x00, 0xFF, 0x93, // SOD appears before SOT
     0xFF, 0xD9,
  ]
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker placement")
}

///|
test "failure case: PPT in main header is invalid placement" {
  let siz_payload = valid_siz_payload()
  let cod_payload = valid_cod_payload()
  let broken = [
    0xFF, 0x4F, // SOC
     0xFF, 0x51, // SIZ
     0x00, 0x29, ..siz_payload, 0xFF, 0x52, // COD
     0x00, 0x0C, ..cod_payload, 0xFF, 0x5C, // QCD
     0x00, 0x04, 0x00, 0x00, 0xFF, 0x61, // PPT (tile-part header only)
     0x00, 0x04, 0x00, 0x00, 0xFF, 0x90, // SOT
     0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x01, 0xFF, 0x93, // SOD
     0xFF, 0xD9,
  ]
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker placement")
}

///|
test "failure case: PPM in tile-part header is invalid placement" {
  let siz_payload = valid_siz_payload()
  let cod_payload = valid_cod_payload()
  let broken = [
    0xFF, 0x4F, // SOC
     0xFF, 0x51, // SIZ
     0x00, 0x29, ..siz_payload, 0xFF, 0x52, // COD
     0x00, 0x0C, ..cod_payload, 0xFF, 0x5C, // QCD
     0x00, 0x04, 0x00, 0x00, 0xFF, 0x90, // SOT
     0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, // Psot=0 fallback
     0xFF, 0x60, // PPM (main header only)
     0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0xFF, 0x93, // SOD
     0xFF, 0xD9,
  ]
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker placement")
}

///|
test "failure case: SOT length must be 10" {
  let broken = minimal_codestream_bytes()
  guard marker_index(broken, 0xFF, 0x90) is Some(sot_at) else {
    fail("SOT marker should exist")
  }
  broken[sot_at + 2] = 0x00
  broken[sot_at + 3] = 0x08
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}

///|
test "failure case: COD progression order out of range" {
  let broken = @jpeg2000.sample_codestream_minimal()
  guard marker_index_nth(broken, 0xFF, 0x52, 0) is Some(cod_at) else {
    fail("COD marker should exist")
  }
  // COD payload starts at cod_at + 4, SGcod progression order at +1.
  broken[cod_at + 5] = 0x05
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}

///|
test "failure case: COD layers must be positive" {
  let broken = @jpeg2000.sample_codestream_minimal()
  guard marker_index_nth(broken, 0xFF, 0x52, 0) is Some(cod_at) else {
    fail("COD marker should exist")
  }
  // number of layers (2 bytes) at payload offsets 2..3.
  broken[cod_at + 6] = 0x00
  broken[cod_at + 7] = 0x00
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}

///|
test "failure case: COD code-block size exponents invalid" {
  let broken = @jpeg2000.sample_codestream_minimal()
  guard marker_index_nth(broken, 0xFF, 0x52, 0) is Some(cod_at) else {
    fail("COD marker should exist")
  }
  // SPcod cblk width/height exponents minus 2.
  broken[cod_at + 10] = 0x08
  broken[cod_at + 11] = 0x08
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}

///|
test "failure case: COD precinct length inconsistency" {
  let broken = @jpeg2000.sample_codestream_minimal()
  guard marker_index_nth(broken, 0xFF, 0x52, 0) is Some(cod_at) else {
    fail("COD marker should exist")
  }
  // Enable precincts in Scod without adding precinct bytes.
  broken[cod_at + 4] = 0x01
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}

///|
test "failure case: QCD quantization style invalid" {
  let broken = @jpeg2000.sample_codestream_minimal()
  guard marker_index_nth(broken, 0xFF, 0x5C, 0) is Some(qcd_at) else {
    fail("QCD marker should exist")
  }
  // SQcd lower bits encode quantization style.
  broken[qcd_at + 4] = 0x03
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}

///|
test "failure case: QCD derived style requires even parameter bytes" {
  let broken = @jpeg2000.sample_codestream_minimal()
  guard marker_index_nth(broken, 0xFF, 0x5C, 0) is Some(qcd_at) else {
    fail("QCD marker should exist")
  }
  // Keep minimal length but switch to scalar-derived style (requires 2-byte steps).
  broken[qcd_at + 4] = 0x01
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}

///|
test "failure case: duplicate COC in same header" {
  let siz_payload = valid_siz_payload()
  let cod_payload = valid_cod_payload()
  let coc_payload = [0x00, 0x00, 0x00] // Ccoc, Scoc, SPcoc(minimal)
  let broken = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x52, 0x00, 0x0C, ..cod_payload,
    0xFF, 0x5C, 0x00, 0x04, 0x00, 0x00, 0xFF, 0x53, 0x00, 0x05, ..coc_payload, 0xFF,
    0x53, 0x00, 0x05, ..coc_payload, 0xFF, 0x90, 0x00, 0x0A, 0, 0, 0, 0x0A, 0, 0,
    0, 1, 0xFF, 0x93, 0xFF, 0xD9,
  ]
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}

///|
test "failure case: PPM and PPT mixed" {
  let siz_payload = valid_siz_payload()
  let cod_payload = valid_cod_payload()
  let broken = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x52, 0x00, 0x0C, ..cod_payload,
    0xFF, 0x5C, 0x00, 0x04, 0, 0, 0xFF, 0x60, 0x00, 0x03, 0x00, // PPM
     0xFF, 0x90, 0x00, 0x0A, 0, 0, 0, 0x0A, 0, 0, 0, 1, 0xFF, 0x61, 0x00, 0x03, 0x00, // PPT
     0xFF, 0x93, 0xFF, 0xD9,
  ]
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}

///|
test "failure case: CRG length mismatch to components" {
  let siz_payload = valid_siz_payload()
  let cod_payload = valid_cod_payload()
  let broken = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x63, 0x00, 0x06, 0x00,
    0x00, 0x00, 0x00, // should be 0x0006 for Csiz=1? with L includes 2+4=6 yes valid
     0xFF, 0x63, 0x00, 0x06, 0x00, 0x00, 0x00, 0x00, // second CRG forbidden
     0xFF, 0x52, 0x00, 0x0C, ..cod_payload, 0xFF, 0x5C, 0x00, 0x04, 0, 0, 0xFF, 0x90,
    0x00, 0x0A, 0, 0, 0, 0x0A, 0, 0, 0, 1, 0xFF, 0x93, 0xFF, 0xD9,
  ]
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}

///|
test "failure case: CRG length mismatch with Csiz=2" {
  let siz_payload = [
    0x00, 0x00, // Rsiz
     0x00, 0x00, 0x00, 0x10, // Xsiz
     0x00, 0x00, 0x00, 0x10, // Ysiz
     0x00, 0x00, 0x00, 0x00, // XOsiz
     0x00, 0x00, 0x00, 0x00, // YOsiz
     0x00, 0x00, 0x00, 0x10, // XTsiz
     0x00, 0x00, 0x00, 0x10, // YTsiz
     0x00, 0x00, 0x00, 0x00, // XTOsiz
     0x00, 0x00, 0x00, 0x00, // YTOsiz
     0x00, 0x02, // Csiz = 2
     0x07, 0x01, 0x01, // component 0
     0x07, 0x01, 0x01, // component 1
  ]
  let cod_payload = valid_cod_payload()
  let broken = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x2C, ..siz_payload, 0xFF, 0x63, 0x00, 0x06, 0x00,
    0x00, 0x00, 0x00, // invalid for Csiz=2 (should be Lcrg=10)
     0xFF, 0x52, 0x00, 0x0C, ..cod_payload, 0xFF, 0x5C, 0x00, 0x04, 0, 0, 0xFF, 0x90,
    0x00, 0x0A, 0, 0, 0, 0x0A, 0, 0, 0, 1, 0xFF, 0x93, 0xFF, 0xD9,
  ]
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}

///|
test "failure case: RGN style invalid" {
  let siz_payload = valid_siz_payload()
  let cod_payload = valid_cod_payload()
  let broken = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x52, 0x00, 0x0C, ..cod_payload,
    0xFF, 0x5E, 0x00, 0x05, 0x00, 0x01, 0x00, // Crgn=0, Srgn=1(invalid), SPrgn
     0xFF, 0x5C, 0x00, 0x04, 0, 0, 0xFF, 0x90, 0x00, 0x0A, 0, 0, 0, 0x0A, 0, 0, 0,
    1, 0xFF, 0x93, 0xFF, 0xD9,
  ]
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}

///|
test "failure case: POC progression order out of range" {
  let broken = @jpeg2000.sample_codestream_with_poc()
  guard marker_index_nth(broken, 0xFF, 0x5F, 0) is Some(poc_at) else {
    fail("POC marker should exist")
  }
  // Ppoc byte in 1-component form.
  broken[poc_at + 10] = 0x05
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}

///|
test "failure case: POC CSpoc out of range" {
  let broken = @jpeg2000.sample_codestream_with_poc()
  guard marker_index_nth(broken, 0xFF, 0x5F, 0) is Some(poc_at) else {
    fail("POC marker should exist")
  }
  // CSpoc byte in 1-component form; set beyond Csiz.
  broken[poc_at + 5] = 0xFF
  let result = @jpeg2000.parse_codestream(broken)
  guard result is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}

///|
test "failure case: invalid PLT packet length sequence" {
  let broken = @jpeg2000.sample_codestream_with_plm_plt()
  guard marker_index_nth(broken, 0xFF, 0x58, 0) is Some(plt_at) else {
    fail("PLT marker should exist")
  }
  // Lplt=4, payload=[Zplt, Iplt]. Make Iplt unterminated (0x80).
  broken[plt_at + 5] = 0x80
  let parsed = @jpeg2000.parse_codestream(broken)
  guard parsed is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}

///|
test "failure case: invalid Zppm sequence" {
  let siz_payload = valid_siz_payload()
  let cod_payload = valid_cod_payload()
  let broken = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x52, 0x00, 0x0C, ..cod_payload,
    0xFF, 0x5C, 0x00, 0x04, 0x00, 0x00, 0xFF, 0x60, 0x00, 0x08, 0x00, 0x00, 0x00,
    0x00, 0x01, 0x00, // PPM z=0
     0xFF, 0x60, 0x00, 0x08, 0x02, 0x00, 0x00, 0x00, 0x01, 0x00, // PPM z=2 (should be 1)
     0xFF, 0x90, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x01, 0xFF,
    0x93, 0xFF, 0xD9,
  ]
  let parsed = @jpeg2000.parse_codestream(broken)
  guard parsed is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid Zppm sequence")
}

///|
test "failure case: invalid PPM chunk size mismatch" {
  let siz_payload = valid_siz_payload()
  let cod_payload = valid_cod_payload()
  let broken = [
    0xFF, 0x4F, 0xFF, 0x51, 0x00, 0x29, ..siz_payload, 0xFF, 0x52, 0x00, 0x0C, ..cod_payload,
    0xFF, 0x5C, 0x00, 0x04, 0x00, 0x00, 0xFF, 0x60, 0x00, 0x07, 0x00, 0x00, 0x00,
    0x00, 0x02, // Nppm=2, no Ippm bytes
     0xFF, 0x90, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x01, 0xFF,
    0x93, 0xFF, 0xD9,
  ]
  let parsed = @jpeg2000.parse_codestream(broken)
  guard parsed is Err(msg) else { fail("expected parser failure") }
  inspect(msg, content="invalid marker payload")
}
