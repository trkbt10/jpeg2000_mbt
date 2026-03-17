///|
// Unit tests for input helper functions (Annex I)

///|
test "@bytes.read_u16_be basic" {
  let data = Bytes::from_array([b'\x01', b'\x02', b'\x03'])
  inspect(@bytes.read_u16_be(data, 0), content="258") // 0x0102
  inspect(@bytes.read_u16_be(data, 1), content="515") // 0x0203
}

///|
test "@bytes.read_u32_be basic" {
  let data = Bytes::from_array([b'\x01', b'\x02', b'\x03', b'\x04', b'\x05'])
  inspect(@bytes.read_u32_be(data, 0), content="16909060") // 0x01020304
  inspect(@bytes.read_u32_be(data, 1), content="33752069") // 0x02030405
}

///|
test "is_soc_at detects SOC marker" {
  let data_with_soc = Bytes::from_array([b'\xFF', b'\x4F', b'\x00'])
  inspect(is_soc_at(data_with_soc, 0), content="true")
  inspect(is_soc_at(data_with_soc, 1), content="false")
}

///|
test "is_soc_at returns false for non-SOC" {
  let data_no_soc = Bytes::from_array([b'\xFF', b'\x51', b'\x00'])
  inspect(is_soc_at(data_no_soc, 0), content="false")
}

///|
test "is_soc_at handles short data" {
  let short_data = Bytes::from_array([b'\xFF'])
  inspect(is_soc_at(short_data, 0), content="false")
}

///|
test "@math.ceil_div_checked basic" {
  inspect(@math.ceil_div_checked(10, 3), content="Ok(4)")
  inspect(@math.ceil_div_checked(9, 3), content="Ok(3)")
  inspect(@math.ceil_div_checked(0, 3), content="Ok(0)")
}

///|
test "@math.ceil_div_checked error on zero divisor" {
  let result = @math.ceil_div_checked(10, 0)
  guard result is Err(msg) else { fail("expected error") }
  inspect(msg.contains("invalid"), content="true")
}

///|
test "make_zero_sample_bytes creates zeros" {
  let result = make_zero_sample_bytes(4, 8)
  guard result is Ok(bytes) else { fail("unexpected error") }
  inspect(bytes.length(), content="4")
  inspect(bytes[0], content="b'\\x00'")
  inspect(bytes[3], content="b'\\x00'")
}

///|
test "make_zero_sample_bytes 16-bit samples" {
  let result = make_zero_sample_bytes(3, 16)
  guard result is Ok(bytes) else { fail("unexpected error") }
  inspect(bytes.length(), content="6") // 3 samples * 2 bytes
}

///|
test "make_zero_sample_bytes error on invalid bits" {
  let result = make_zero_sample_bytes(1, 0)
  guard result is Err(_) else { fail("expected error") }
}

///|
test "make_single_sample_bytes_le 8-bit" {
  let result = make_single_sample_bytes_le(255, 8)
  guard result is Ok(bytes) else { fail("unexpected error") }
  inspect(bytes.length(), content="1")
  inspect(bytes[0], content="b'\\xFF'")
}

///|
test "make_single_sample_bytes_le 16-bit little-endian" {
  let result = make_single_sample_bytes_le(0x1234, 16)
  guard result is Ok(bytes) else { fail("unexpected error") }
  inspect(bytes.length(), content="2")
  inspect(bytes[0], content="b'\\x34'") // low byte first
  inspect(bytes[1], content="b'\\x12'") // high byte second
}

///|
test "make_sample_array_bytes_le basic" {
  let result = make_sample_array_bytes_le([100, 200, 50], 8)
  guard result is Ok(bytes) else { fail("unexpected error") }
  inspect(bytes.length(), content="3")
  inspect(bytes[0], content="b'\\x64'") // 100
  inspect(bytes[1], content="b'\\xC8'") // 200
  inspect(bytes[2], content="b'\\x32'") // 50
}

///|
test "make_sample_array_bytes_le error on empty" {
  let result = make_sample_array_bytes_le([], 8)
  guard result is Err(_) else { fail("expected error") }
}

///|
test "collect_sod_payloads from minimal sample" {
  let data = @bytes.int_array_to_bytes(@core.sample_codestream_minimal())
  let cs = @core.parse_codestream(data)
  guard cs is Ok(codestream) else { fail("parse failed") }
  let payloads = collect_sod_payloads(codestream)
  // Minimal sample has 1 SOD with empty payload
  inspect(payloads.length(), content="1")
}

///|
test "collect_ppt_payloads_by_tile flushes per tile-part in Zppt order" {
  let src = @core.sample_codestream_minimal()
  let mut sot_pos = -1
  let mut sod_pos = -1
  for i in 0..<(src.length() - 1) {
    if sot_pos < 0 && src[i] == 0xFF && src[i + 1] == 0x90 {
      sot_pos = i
    }
    if sod_pos < 0 && src[i] == 0xFF && src[i + 1] == 0x93 {
      sod_pos = i
    }
  }
  guard sot_pos >= 0 && sod_pos >= 0 else { fail("failed to locate SOT/SOD") }
  let data : Array[Int] = []
  for i in 0..<sod_pos {
    data.push(src[i])
  }
  // Make Psot=0 so inserted PPT marker bytes remain valid for parser.
  data[sot_pos + 6] = 0
  data[sot_pos + 7] = 0
  data[sot_pos + 8] = 0
  data[sot_pos + 9] = 0
  // Insert out-of-order PPT chunks: Zppt=1 then Zppt=0.
  data.push(0xFF)
  data.push(0x61)
  data.push(0x00)
  data.push(0x05)
  data.push(0x01)
  data.push(0x11)
  data.push(0x12)
  data.push(0xFF)
  data.push(0x61)
  data.push(0x00)
  data.push(0x04)
  data.push(0x00)
  data.push(0x01)
  // SOD + EOC
  data.push(0xFF)
  data.push(0x93)
  data.push(0xFF)
  data.push(0xD9)

  let parsed_v = @core.parse_codestream(@bytes.int_array_to_bytes(data))
  guard parsed_v is Ok(stream) else { fail("parse failed") }
  guard collect_ppt_payloads_by_tile(stream) is Some(grouped) else {
    fail("expected Some")
  }
  inspect(grouped.length(), content="1")
  let (tile_idx, ippt) = grouped[0]
  inspect(tile_idx, content="0")
  inspect(ippt, content="b\"\\x01\\x11\\x12\"")
}

///|
test "collect_ppt_payloads_by_tile returns None without PPT markers" {
  let parsed_v = @core.parse_codestream(
    @bytes.int_array_to_bytes(@core.sample_codestream_minimal()),
  )
  guard parsed_v is Ok(stream) else { fail("parse failed") }
  guard collect_ppt_payloads_by_tile(stream) is None else {
    fail("expected None")
  }
}

///|
test "collect_ppm_payload_bytes returns ippm bytes from sample" {
  let parsed_v = @core.parse_codestream(
    @bytes.int_array_to_bytes(@core.sample_codestream_with_ppm()),
  )
  guard parsed_v is Ok(stream) else { fail("parse failed") }
  guard collect_ppm_payload_bytes(stream) is Some(ppm) else {
    fail("expected Some")
  }
  inspect(ppm, content="b\"\\x00\"")
}

///|
fn wb_sample_codestream_with_split_ppm_continuation() -> Array[Int] {
  let src = @core.sample_codestream_with_ppm()
  let mut ppm_pos = -1
  let mut sot_pos = -1
  for i in 0..<(src.length() - 1) {
    if ppm_pos < 0 && src[i] == 0xFF && src[i + 1] == 0x60 {
      ppm_pos = i
    }
    if sot_pos < 0 && src[i] == 0xFF && src[i + 1] == 0x90 {
      sot_pos = i
    }
  }
  if ppm_pos < 0 || sot_pos < 0 {
    return src
  }
  let data : Array[Int] = []
  for i in 0..<ppm_pos {
    data.push(src[i])
  }
  // Split a single Ippm chunk (Nppm=3, data=[1,2,3]) across two PPM markers
  // with the same Zppm, forcing continuation handling.
  data.push(0xFF)
  data.push(0x60)
  data.push(0x00)
  data.push(0x08)
  data.push(0x00)
  data.push(0x00)
  data.push(0x00)
  data.push(0x00)
  data.push(0x03)
  data.push(0x01)
  data.push(0xFF)
  data.push(0x60)
  data.push(0x00)
  data.push(0x05)
  data.push(0x00)
  data.push(0x02)
  data.push(0x03)
  for i in sot_pos..<src.length() {
    data.push(src[i])
  }
  data
}

///|
test "collect_ppm_payload_bytes reconstructs split continuation" {
  let parsed_v = @core.parse_codestream(
    @bytes.int_array_to_bytes(
      wb_sample_codestream_with_split_ppm_continuation(),
    ),
  )
  guard parsed_v is Ok(stream) else { fail("parse failed") }
  guard collect_ppm_payload_bytes(stream) is Some(ppm) else {
    fail("expected Some")
  }
  inspect(ppm, content="b\"\\x01\\x02\\x03\"")
}

///|
test "collect_ppm_payload_bytes returns None without PPM markers" {
  let parsed_v = @core.parse_codestream(
    @bytes.int_array_to_bytes(@core.sample_codestream_minimal()),
  )
  guard parsed_v is Ok(stream) else { fail("parse failed") }
  guard collect_ppm_payload_bytes(stream) is None else { fail("expected None") }
}

///|
test "collect_ppm_payloads_by_tile maps PPM chunk to tile 0 on sample" {
  let parsed_v = @core.parse_codestream(
    @bytes.int_array_to_bytes(@core.sample_codestream_with_ppm()),
  )
  guard parsed_v is Ok(stream) else { fail("parse failed") }
  guard collect_ppm_payloads_by_tile(stream) is Some(grouped) else {
    fail("expected Some")
  }
  inspect(grouped.length(), content="1")
  let (tile_idx, ippm) = grouped[0]
  inspect(tile_idx, content="0")
  inspect(ippm, content="b\"\\x00\"")
}

///|
test "collect_ppm_payloads_by_tile reconstructs split continuation on sample" {
  let parsed_v = @core.parse_codestream(
    @bytes.int_array_to_bytes(
      wb_sample_codestream_with_split_ppm_continuation(),
    ),
  )
  guard parsed_v is Ok(stream) else { fail("parse failed") }
  guard collect_ppm_payloads_by_tile(stream) is Some(grouped) else {
    fail("expected Some")
  }
  inspect(grouped.length(), content="1")
  let (tile_idx, ippm) = grouped[0]
  inspect(tile_idx, content="0")
  inspect(ippm, content="b\"\\x01\\x02\\x03\"")
}

///|
test "collect_ppm_payloads_by_tile returns None without PPM markers" {
  let parsed_v = @core.parse_codestream(
    @bytes.int_array_to_bytes(@core.sample_codestream_minimal()),
  )
  guard parsed_v is Ok(stream) else { fail("parse failed") }
  guard collect_ppm_payloads_by_tile(stream) is None else {
    fail("expected None")
  }
}

///|
test "collect_ppm_payload_bytes rejoins continuation across multiple zppm markers" {
  let src = @core.sample_codestream_with_ppm()
  let mut ppm_pos = -1
  let mut sot_pos = -1
  for i in 0..<(src.length() - 1) {
    if ppm_pos < 0 && src[i] == 0xFF && src[i + 1] == 0x60 {
      ppm_pos = i
    }
    if sot_pos < 0 && src[i] == 0xFF && src[i + 1] == 0x90 {
      sot_pos = i
    }
  }
  guard ppm_pos >= 0 && sot_pos >= 0 else { fail("failed to locate PPM/SOT") }
  let data : Array[Int] = []
  for i in 0..<ppm_pos {
    data.push(src[i])
  }
  // Zppm=1 continuation bytes appear before Zppm=0 in codestream order.
  data.push(0xFF)
  data.push(0x60)
  data.push(0x00)
  data.push(0x06)
  data.push(0x01)
  data.push(0x0C)
  data.push(0x0D)
  data.push(0x0E)
  data.push(0xFF)
  data.push(0x60)
  data.push(0x00)
  data.push(0x09)
  data.push(0x00)
  data.push(0x00)
  data.push(0x00)
  data.push(0x00)
  data.push(0x05)
  data.push(0x0A)
  data.push(0x0B)
  for i in sot_pos..<src.length() {
    data.push(src[i])
  }

  let parsed_v = @core.parse_codestream(@bytes.int_array_to_bytes(data))
  guard parsed_v is Ok(stream) else { fail("parse failed") }
  guard collect_ppm_payload_bytes(stream) is Some(ppm) else {
    fail("expected Some")
  }
  inspect(ppm, content="b\"\\x0a\\x0b\\x0c\\x0d\\x0e\"")
  guard collect_ppm_payloads_by_tile(stream) is Some(grouped) else {
    fail("expected tile mapping")
  }
  inspect(grouped.length(), content="1")
  let (tile_idx, ippm) = grouped[0]
  inspect(tile_idx, content="0")
  inspect(ippm, content="b\"\\x0a\\x0b\\x0c\\x0d\\x0e\"")
}

///|
fn wb_codestream_nonzero_origin_subsampled() -> Array[Int] {
  let siz_payload = [
    0x00, 0x00, // Rsiz
     0x00, 0x00, 0x05, 0xEF, // Xsiz = 1519
     0x00, 0x00, 0x02, 0xB9, // Ysiz = 697
     0x00, 0x00, 0x00, 0x01, // XOsiz = 1
     0x00, 0x00, 0x00, 0xA0, // YOsiz = 160
     0x00, 0x00, 0x01, 0x7B, // XTsiz = 379
     0x00, 0x00, 0x00, 0xA1, // YTsiz = 161
     0x00, 0x00, 0x00, 0x00, // XTOsiz = 0
     0x00, 0x00, 0x00, 0x00, // YTOsiz = 0
     0x00, 0x01, // Csiz = 1
     0x07, 0x05, 0x03, // 8-bit unsigned, XRsiz=5, YRsiz=3
  ]
  let cod_payload = [
    0x00, // Scod
     0x00, // Progression order (LRCP)
     0x00, 0x01, // Number of layers
     0x00, // Multiple component transform
     0x00, // Number of decomposition levels
     0x00, // Code-block width exponent minus 2
     0x00, // Code-block height exponent minus 2
     0x00, // Code-block style
     0x00, // Transformation
  ]
  let stream = [
    0xFF, 0x4F, // SOC
     0xFF, 0x51, 0x00, 0x29, ..siz_payload, // SIZ
     0xFF, 0x52, 0x00, 0x0C, ..cod_payload, // COD
     0xFF, 0x5C, 0x00, 0x04, 0x00, 0x00, // QCD
     0xFF, 0x90, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x00, // SOT
     0xFF, 0x93, // SOD
     0xFF, 0xD9, // EOC
  ]
  stream
}

///|
test "component_dimensions_from_siz uses ceil bounds for non-zero origin subsampling" {
  let parsed_v = @core.parse_codestream(
    @bytes.int_array_to_bytes(wb_codestream_nonzero_origin_subsampled()),
  )
  guard parsed_v is Ok(parsed) else { fail("parse failed") }
  guard parsed.metadata.siz is Some(siz) else { fail("missing SIZ metadata") }
  let dims_v = component_dimensions_from_siz(siz, 0)
  guard dims_v is Ok((width, height)) else { fail("dimension compute failed") }
  inspect(width, content="303")
  inspect(height, content="179")
}

///|
test "codestream_payload_is_empty on minimal sample" {
  let data = @bytes.int_array_to_bytes(@core.sample_codestream_minimal())
  let cs = @core.parse_codestream(data)
  guard cs is Ok(codestream) else { fail("parse failed") }
  inspect(codestream_payload_is_empty(codestream), content="true")
}

///|
test "extract_decode_input_codestream passes through raw codestream" {
  let data = @core.sample_codestream_minimal()
  let bytes = @bytes.int_array_to_bytes(data)
  let result = extract_decode_input_codestream(bytes)
  guard result is Ok(extracted) else { fail("extraction failed") }
  // Should return the same bytes for raw codestream (starts with SOC)
  inspect(extracted.length() == bytes.length(), content="true")
}

///|
fn wb_wrap_codestream_in_jph(data : Bytes) -> Bytes {
  let out : Array[Byte] = []
  // Signature box
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x0C')
  out.push(b'j')
  out.push(b'P')
  out.push(b' ')
  out.push(b' ')
  out.push(b'\x0D')
  out.push(b'\x0A')
  out.push(b'\x87')
  out.push(b'\x0A')
  // File Type box: ftyp / brand jph / compat jph
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x14')
  out.push(b'f')
  out.push(b't')
  out.push(b'y')
  out.push(b'p')
  out.push(b'j')
  out.push(b'p')
  out.push(b'h')
  out.push(b' ')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'j')
  out.push(b'p')
  out.push(b'h')
  out.push(b' ')
  // Contiguous codestream box
  let box_size = data.length() + 8
  out.push(((box_size >> 24) & 0xFF).to_byte())
  out.push(((box_size >> 16) & 0xFF).to_byte())
  out.push(((box_size >> 8) & 0xFF).to_byte())
  out.push((box_size & 0xFF).to_byte())
  out.push(b'j')
  out.push(b'p')
  out.push(b'2')
  out.push(b'c')
  for b in data {
    out.push(b)
  }
  Bytes::from_iter(out.iter())
}

///|
test "extract_decode_input_codestream extracts jp2c from JPH wrapper" {
  let codestream = Bytes::from_iter(
    @core.sample_codestream_minimal().iter().map(fn(i) { i.to_byte() }),
  )
  let wrapped = wb_wrap_codestream_in_jph(codestream)
  let result = extract_decode_input_codestream(wrapped)
  guard result is Ok(extracted) else { fail("wrapped extraction failed") }
  assert_eq(extracted, codestream)
}

///|
test "parse_decode_input_codestream parses JPH wrapper" {
  let codestream = Bytes::from_iter(
    @core.sample_codestream_minimal().iter().map(fn(i) { i.to_byte() }),
  )
  let wrapped = wb_wrap_codestream_in_jph(codestream)
  let result = parse_decode_input_codestream(wrapped)
  guard result is Ok(stream) else { fail("wrapped parse failed") }
  assert_eq(stream.segments[0].code, 0xFF4F)
}

///|
test "roundtrip_decode_input_bytes preserves wrapped input bytes" {
  let codestream = Bytes::from_iter(
    @core.sample_codestream_minimal().iter().map(fn(i) { i.to_byte() }),
  )
  let wrapped = wb_wrap_codestream_in_jph(codestream)
  let result = roundtrip_decode_input_bytes(wrapped)
  guard result is Ok(roundtripped) else { fail("wrapped roundtrip failed") }
  assert_eq(roundtripped, wrapped)
}
