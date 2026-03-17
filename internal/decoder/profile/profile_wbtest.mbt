///|
fn profile_tile_htj2k_codestream(tile_qcd? : Bool = false) -> Array[Int] {
  let data = @core.sample_codestream_minimal()
  guard wb_marker_index(data, 0xFF, 0x90) is Some(sot_at) else { panic() }
  guard wb_marker_index(data, 0xFF, 0x93) is Some(sod_at) else { panic() }
  let tile_cod = [
    0xFF, 0x52, 0x00, 0x0C, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x40,
    0x00,
  ]
  let tile_qcd_bytes = if tile_qcd {
    [0xFF, 0x5C, 0x00, 0x04, 0x00, 0x00]
  } else {
    []
  }
  let extra : Array[Int] = []
  for b in tile_cod {
    extra.push(b)
  }
  for b in tile_qcd_bytes {
    extra.push(b)
  }
  wb_patch_u32_be(data, sot_at + 6, 14 + extra.length())
  wb_insert_bytes_at(data, sod_at, extra)
}

///|
fn profile_main_header_override_codestream(extra : Array[Int]) -> Array[Int] {
  let data = @core.sample_codestream_minimal()
  guard wb_marker_index(data, 0xFF, 0x90) is Some(sot_at) else { panic() }
  wb_insert_bytes_at(data, sot_at, extra)
}

///|
fn profile_tile_header_override_codestream(extra : Array[Int]) -> Array[Int] {
  let data = @core.sample_codestream_minimal()
  guard wb_marker_index(data, 0xFF, 0x90) is Some(sot_at) else { panic() }
  guard wb_marker_index(data, 0xFF, 0x93) is Some(sod_at) else { panic() }
  wb_patch_u32_be(data, sot_at + 6, 14 + extra.length())
  wb_insert_bytes_at(data, sod_at, extra)
}

///|
fn profile_main_header_coc_ht_codestream() -> Array[Int] {
  profile_main_header_override_codestream([
    0xFF, 0x53, 0x00, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00,
  ])
}

///|
fn profile_tile_header_coc_ht_codestream() -> Array[Int] {
  profile_tile_header_override_codestream([
    0xFF, 0x53, 0x00, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00,
  ])
}

///|
fn profile_tile_header_coc_qcc_ht_codestream() -> Array[Int] {
  profile_tile_header_override_codestream([
    0xFF, 0x53, 0x00, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0xFF, 0x5D,
    0x00, 0x05, 0x00, 0x01, 0x00,
  ])
}

///|
test "htj2k_signalled detects main-header HT style bit" {
  let data = @core.sample_codestream_minimal()
  let parsed_original = @core.parse_codestream(@bytes.int_array_to_bytes(data))
  guard parsed_original is Ok(base) else { fail("base parse failed") }
  let cod_pos = base.segments[2].position
  data[cod_pos + 12] = 0x40

  let parsed = @core.parse_codestream(@bytes.int_array_to_bytes(data))
  guard parsed is Ok(stream) else { fail("mutated parse failed") }
  assert_true(htj2k_signalled(stream))
  assert_true(
    htj2k_not_supported_reason(stream).contains(
      "DS-UNSUPPORTED-HTJ2K:cap_present_no_ht_decoder",
    ),
  )
  assert_true(htj2k_cleanup_only_subset_enabled(stream))
}

///|
test "htj2k_cleanup_only_subset_enabled accepts main-header COC HT style bit" {
  let parsed = @core.parse_codestream(@bytes.int_array_to_bytes(profile_main_header_coc_ht_codestream()))
  guard parsed is Ok(stream) else { fail("main-header COC parse failed") }
  assert_true(htj2k_signalled(stream))
  assert_true(htj2k_cleanup_only_subset_enabled(stream))
}

///|
test "htj2k_cleanup_only_subset_enabled accepts tile-part COC HT style bit" {
  let parsed = @core.parse_codestream(@bytes.int_array_to_bytes(profile_tile_header_coc_ht_codestream()))
  guard parsed is Ok(stream) else { fail("tile-header COC parse failed") }
  assert_true(htj2k_signalled(stream))
  assert_true(htj2k_cleanup_only_subset_enabled(stream))
}

///|
test "htj2k_cleanup_only_subset_enabled accepts tile-part HT qcc with derived quantization" {
  let parsed = @core.parse_codestream(
    @bytes.int_array_to_bytes(profile_tile_header_coc_qcc_ht_codestream()),
  )
  guard parsed is Ok(stream) else { fail("tile-header COC/QCC parse failed") }
  guard stream.metadata.cod is Some(cod) else { fail("missing COD") }
  let (_, _, _, style, transformation, component_qcd_opt) = @geometry.get_component_decode_context(
    stream,
    0,
    cod,
    fallback_qcd=stream.metadata.qcd,
    tile_index=0,
  )
  assert_true(htj2k_signalled(stream))
  assert_eq(style, 0x40)
  assert_eq(transformation, 0)
  guard component_qcd_opt is Some(component_qcd) else {
    fail("missing effective component qcd")
  }
  assert_eq(component_qcd.quantization_style, 1)
  assert_true(htj2k_cleanup_only_subset_enabled(stream))
  assert_true(tier1_minimal_reversible_subset_enabled(stream))
}

///|
test "htj2k_cleanup_only_subset_enabled accepts tile COD HT override" {
  let parsed = @core.parse_codestream(@bytes.int_array_to_bytes(profile_tile_htj2k_codestream()))
  guard parsed is Ok(stream) else { fail("tile HT parse failed") }
  assert_true(htj2k_signalled(stream))
  assert_true(htj2k_cleanup_only_subset_enabled(stream))
}

///|
test "htj2k_cleanup_only_subset_enabled accepts tile QCD override" {
  let parsed = @core.parse_codestream(
    @bytes.int_array_to_bytes(profile_tile_htj2k_codestream(tile_qcd=true)),
  )
  guard parsed is Ok(stream) else { fail("tile HT + QCD parse failed") }
  assert_true(htj2k_signalled(stream))
  assert_true(htj2k_cleanup_only_subset_enabled(stream))
}

///|
test "htj2k_cleanup_only_subset_enabled accepts multi-layer HT stream" {
  let data = @core.sample_codestream_minimal()
  let parsed_original = @core.parse_codestream(@bytes.int_array_to_bytes(data))
  guard parsed_original is Ok(base) else { fail("base parse failed") }
  let cod_pos = base.segments[2].position
  data[cod_pos + 6] = 0x00
  data[cod_pos + 7] = 0x02
  data[cod_pos + 12] = 0x40

  let parsed = @core.parse_codestream(@bytes.int_array_to_bytes(data))
  guard parsed is Ok(stream) else { fail("mutated parse failed") }
  assert_true(htj2k_signalled(stream))
  assert_true(htj2k_cleanup_only_subset_enabled(stream))
}
