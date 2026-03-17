///|
// Unit tests for ROI helper functions (Annex H)

///|
fn roi_test_minimal_cod_payload() -> Array[Int] {
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
fn roi_test_siz_payload(csiz : Int) -> Array[Int] {
  let payload = [
    0x00,
    0x00, // Rsiz
    0x00,
    0x00,
    0x00,
    0x10, // Xsiz
    0x00,
    0x00,
    0x00,
    0x10, // Ysiz
    0x00,
    0x00,
    0x00,
    0x00, // XOsiz
    0x00,
    0x00,
    0x00,
    0x00, // YOsiz
    0x00,
    0x00,
    0x00,
    0x10, // XTsiz
    0x00,
    0x00,
    0x00,
    0x10, // YTsiz
    0x00,
    0x00,
    0x00,
    0x00, // XTOsiz
    0x00,
    0x00,
    0x00,
    0x00, // YTOsiz
    (csiz >> 8) & 0xFF,
    csiz & 0xFF,
  ]
  for _ in 0..<csiz {
    payload.push(0x07)
    payload.push(0x01)
    payload.push(0x01)
  }
  payload
}

///|
fn roi_test_append_marker(
  out : Array[Int],
  code : Int,
  payload : Array[Int],
) -> Unit {
  let length = payload.length() + 2
  out.push((code >> 8) & 0xFF)
  out.push(code & 0xFF)
  out.push((length >> 8) & 0xFF)
  out.push(length & 0xFF)
  for b in payload {
    out.push(b)
  }
}

///|
fn roi_test_codestream_with_main_header_rgn(shift : Int) -> Array[Int] {
  let out : Array[Int] = [0xFF, 0x4F]
  roi_test_append_marker(out, 0xFF51, roi_test_siz_payload(4))
  roi_test_append_marker(out, 0xFF52, roi_test_minimal_cod_payload())
  roi_test_append_marker(out, 0xFF5C, [0x00, 0x00])
  roi_test_append_marker(out, 0xFF5E, [0x00, 0x00, shift])
  out.push(0xFF)
  out.push(0x90)
  for b in [0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x01] {
    out.push(b)
  }
  out.push(0xFF)
  out.push(0x93)
  out.push(0xFF)
  out.push(0xD9)
  out
}

///|
fn roi_test_codestream_with_main_and_tile_rgn(
  main_shift : Int,
  tile_shift : Int,
) -> Array[Int] {
  let out : Array[Int] = [0xFF, 0x4F]
  roi_test_append_marker(out, 0xFF51, roi_test_siz_payload(1))
  roi_test_append_marker(out, 0xFF52, roi_test_minimal_cod_payload())
  roi_test_append_marker(out, 0xFF5C, [0x00, 0x00])
  roi_test_append_marker(out, 0xFF5E, [0x00, 0x00, main_shift])
  out.push(0xFF)
  out.push(0x90)
  for b in [0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x15, 0x00, 0x01] {
    out.push(b)
  }
  roi_test_append_marker(out, 0xFF5E, [0x00, 0x00, tile_shift])
  out.push(0xFF)
  out.push(0x93)
  out.push(0xFF)
  out.push(0xD9)
  out
}

///|
fn roi_test_codestream_with_tile_part_rgn_2byte_component() -> Array[Int] {
  let out : Array[Int] = [0xFF, 0x4F]
  roi_test_append_marker(out, 0xFF51, roi_test_siz_payload(258))
  roi_test_append_marker(out, 0xFF52, roi_test_minimal_cod_payload())
  roi_test_append_marker(out, 0xFF5C, [0x00, 0x00])
  out.push(0xFF)
  out.push(0x90)
  for b in [0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x16, 0x00, 0x01] {
    out.push(b)
  }
  roi_test_append_marker(out, 0xFF5E, [0x01, 0x01, 0x00, 0x07])
  out.push(0xFF)
  out.push(0x93)
  out.push(0xFF)
  out.push(0xD9)
  out
}

///|
test "extract_roi_shift_per_tile_component with no RGN markers" {
  // Parse minimal sample which has no RGN markers
  let data = @bytes.int_array_to_bytes(@core.sample_codestream_minimal())
  let cs = @core.parse_codestream(data)
  guard cs is Ok(codestream) else { fail("parse failed") }
  let roi_map = extract_roi_shift_per_tile_component(codestream)
  inspect(roi_map.length(), content="0")
}

///|
test "get_roi_shift returns 0 for empty map" {
  let roi_map : Map[Int, Map[Int, Int]] = {}
  let shift = get_roi_shift(roi_map, 0, 0)
  inspect(shift, content="0")
}

///|
test "get_roi_shift returns tile-specific value" {
  let roi_map : Map[Int, Map[Int, Int]] = {}
  let tile_map : Map[Int, Int] = {}
  tile_map[0] = 5
  roi_map[0] = tile_map
  let shift = get_roi_shift(roi_map, 0, 0)
  inspect(shift, content="5")
}

///|
test "get_roi_shift returns main-header value as fallback" {
  let roi_map : Map[Int, Map[Int, Int]] = {}
  let main_map : Map[Int, Int] = {}
  main_map[0] = 3
  roi_map[-1] = main_map
  // Tile 0 has no entry, should fall back to main header
  let shift = get_roi_shift(roi_map, 0, 0)
  inspect(shift, content="3")
}

///|
test "get_roi_shift prefers tile-specific over main-header" {
  let roi_map : Map[Int, Map[Int, Int]] = {}
  let main_map : Map[Int, Int] = {}
  main_map[0] = 3
  roi_map[-1] = main_map
  let tile_map : Map[Int, Int] = {}
  tile_map[0] = 7
  roi_map[0] = tile_map
  // Tile 0 has entry, should use tile-specific value
  let shift = get_roi_shift(roi_map, 0, 0)
  inspect(shift, content="7")
}

///|
test "get_roi_shift returns 0 for missing component" {
  let roi_map : Map[Int, Map[Int, Int]] = {}
  let tile_map : Map[Int, Int] = {}
  tile_map[0] = 5
  roi_map[0] = tile_map
  // Component 1 not in map
  let shift = get_roi_shift(roi_map, 0, 1)
  inspect(shift, content="0")
}

///|
test "extract_roi_shift_per_tile_component reads main-header RGN" {
  let data = @bytes.int_array_to_bytes(
    roi_test_codestream_with_main_header_rgn(11),
  )
  let parsed = @core.parse_codestream(data)
  guard parsed is Ok(stream) else { fail("parse failed") }
  inspect(stream.metadata.rgn.length(), content="1")
  inspect(stream.metadata.rgn[0].component, content="0")
  inspect(stream.metadata.rgn[0].shift, content="11")
  let roi_map = extract_roi_shift_per_tile_component(stream)
  inspect(get_roi_shift(roi_map, 0, 0), content="11")
  inspect(get_roi_shift(roi_map, 0, 1), content="0")
}

///|
test "extract_roi_shift_per_tile_component prefers tile-part RGN over main-header RGN" {
  let parsed = @core.parse_codestream(
    @bytes.int_array_to_bytes(
      roi_test_codestream_with_main_and_tile_rgn(11, 9),
    ),
  )
  guard parsed is Ok(stream) else { fail("parse failed") }
  let roi_map = extract_roi_shift_per_tile_component(stream)
  inspect(get_roi_shift(roi_map, 0, 0), content="9")
}

///|
test "extract_roi_shift_per_tile_component parses tile-part RGN with 2-byte component index" {
  let parsed = @core.parse_codestream(
    @bytes.int_array_to_bytes(
      roi_test_codestream_with_tile_part_rgn_2byte_component(),
    ),
  )
  guard parsed is Ok(stream) else { fail("parse failed") }
  let roi_map = extract_roi_shift_per_tile_component(stream)
  inspect(get_roi_shift(roi_map, 0, 257), content="7")
}
