///|
fn wb_minimal_ht_single_codeblock_codestream(
  payload : Array[Int],
  layers : Int,
  code_block_style : Int,
) -> Bytes {
  let data = @core.sample_codestream_minimal()
  guard wb_marker_index(data, 0xFF, 0x51) is Some(siz_at) else { panic() }
  guard wb_marker_index(data, 0xFF, 0x52) is Some(cod_at) else { panic() }
  guard wb_marker_index(data, 0xFF, 0xD9) is Some(eoc_at) else { panic() }
  wb_patch_u32_be(data, siz_at + 6, 1)
  wb_patch_u32_be(data, siz_at + 10, 1)
  wb_patch_u32_be(data, siz_at + 22, 1)
  wb_patch_u32_be(data, siz_at + 26, 1)
  data[siz_at + 40] = 7
  data[cod_at + 6] = (layers >> 8) & 0xFF
  data[cod_at + 7] = layers & 0xFF
  data[cod_at + 10] = 4
  data[cod_at + 11] = 4
  data[cod_at + 12] = code_block_style
  let with_cap = wb_insert_bytes_at(data, cod_at, [
    0xFF, 0x50, 0x00, 0x08, 0x00, 0x02, 0x00, 0x00, 0x00, 0x05,
  ])
  guard wb_marker_index(with_cap, 0xFF, 0x90) is Some(with_cap_sot_at) else {
    panic()
  }
  wb_patch_u32_be(with_cap, with_cap_sot_at + 6, 14 + payload.length())
  let with_payload = wb_insert_bytes_at(with_cap, eoc_at + 10, payload)
  Bytes::from_iter(with_payload.iter().map(fn(i) { i.to_byte() }))
}

///|
fn wb_staged_ht_magref_payload() -> Array[Int] {
  wb_single_codeblock_packet_header(true, 6, 3, [5, 1], [1, 2]) +
  [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00]
}

///|
fn wb_trailing_ht_cleanup_payload() -> Array[Int] {
  wb_single_codeblock_packet_header(true, 6, 4, [5, 1, 5], [1, 2, 1]) +
  [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00, 0xE3, 0x00, 0x07, 0x74, 0x00]
}

///|
fn wb_trailing_ht_full_payload() -> Array[Int] {
  wb_single_codeblock_packet_header(true, 5, 6, [5, 1, 5, 1], [1, 2, 1, 2]) +
  [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00, 0xE3, 0x00, 0x07, 0x74, 0x00, 0x00]
}

///|
test "analyze_single_codeblock_first_packet parses one-byte segment" {
  // z=1, include=1, zero-bit-planes=0, coding-passes=1, lblock-inc=0, len=1
  let payload = wb_int_array_to_bytes([0xE1, 0x00])
  let parsed = @a8.parse_single_codeblock_first_packet_parts(payload)
  guard parsed is Ok(parts) else { fail("expected analysis success") }
  inspect(parts.segment_total, content="1")
}

///|
test "analyze_single_codeblock_first_packet detects truncated body" {
  // Header declares len=1 but payload has no body byte.
  let payload = wb_int_array_to_bytes([0xE1])
  let parsed = @a8.parse_single_codeblock_first_packet_parts(payload)
  guard parsed is Err(msg) else { fail("expected analysis failure") }
  inspect(msg, content="packet body truncated for declared segment lengths")
}

///|
test "extract_single_codeblock_first_packet_codeword returns declared bytes" {
  let payload = wb_int_array_to_bytes([0xE1, 0x7A])
  let parsed = @a8.parse_single_codeblock_first_packet_parts(payload)
  guard parsed is Ok(parts) else { fail("expected extraction success") }
  inspect(
    @core.bytes_to_hex(wb_bytes_to_int_array(parts.codeword)),
    content="7a",
  )
}

///|
test "extract_single_codeblock_first_packet_codeword keeps HT trailing-set metadata" {
  let payload = wb_int_array_to_bytes(wb_trailing_ht_cleanup_payload())
  let parsed = @a8.parse_single_codeblock_first_packet_parts_with_candidates(
    payload,
    0x40,
    [],
  )
  guard parsed is Ok(parts) else {
    if parsed is Err(msg) {
      fail("expected HT trailing-set extraction success: \{msg}")
    }
    fail("expected HT trailing-set extraction success")
  }
  assert_eq(parts.segment_lengths, [5, 1, 5])
  assert_eq(parts.segment_passes, [1, 2, 1])
  assert_eq(parts.zero_bit_planes, Some(6))
  assert_eq(parts.coding_passes, Some(4))
  assert_eq(
    @core.bytes_to_hex(wb_bytes_to_int_array(parts.codeword)),
    "e30007740000e300077400",
  )
}

///|
test "extract_single_codeblock_first_packet_codeword keeps HT full trailing-set metadata" {
  let payload = wb_int_array_to_bytes(wb_trailing_ht_full_payload())
  let parsed = @a8.parse_single_codeblock_first_packet_parts_with_candidates(
    payload,
    0x40,
    [],
  )
  guard parsed is Ok(parts) else {
    if parsed is Err(msg) {
      fail("expected HT full trailing-set extraction success: \{msg}")
    }
    fail("expected HT full trailing-set extraction success")
  }
  assert_eq(parts.segment_lengths, [5, 1, 5, 1])
  assert_eq(parts.segment_passes, [1, 2, 1, 2])
  assert_eq(parts.zero_bit_planes, Some(5))
  assert_eq(parts.coding_passes, Some(6))
  assert_eq(
    @core.bytes_to_hex(wb_bytes_to_int_array(parts.codeword)),
    "e30007740000e30007740000",
  )
}

///|
test "extract_single_codeblock_first_packet_codeword keeps staged HT MagRef metadata" {
  let payload = wb_int_array_to_bytes(wb_staged_ht_magref_payload())
  let parsed = @a8.parse_single_codeblock_first_packet_parts_with_candidates(
    payload,
    0x40,
    [],
  )
  guard parsed is Ok(parts) else {
    if parsed is Err(msg) {
      fail("expected staged HT extraction success: \{msg}")
    }
    fail("expected staged HT extraction success")
  }
  assert_eq(parts.segment_lengths, [5, 1])
  assert_eq(parts.segment_passes, [1, 2])
  assert_eq(parts.zero_bit_planes, Some(6))
  assert_eq(parts.coding_passes, Some(3))
  assert_eq(
    @core.bytes_to_hex(wb_bytes_to_int_array(parts.codeword)),
    "e30007740000",
  )
}

///|
test "split_sod_payload_single_codeblock_series keeps staged HT MagRef payload whole" {
  let payload = wb_int_array_to_bytes(wb_staged_ht_magref_payload())
  let split_v = @a8.split_sod_payload_single_codeblock_series(payload, 0x40)
  guard split_v is Ok(packets) else {
    if split_v is Err(msg) {
      fail("expected staged HT packet split success: \{msg}")
    }
    fail("expected staged HT packet split success")
  }
  assert_eq(packets.length(), 1)
  assert_eq(packets[0], payload)
}

///|
test "split_sod_payload_single_codeblock_series keeps trailing HT cleanup payload whole" {
  let payload = wb_int_array_to_bytes(wb_trailing_ht_cleanup_payload())
  let split_v = @a8.split_sod_payload_single_codeblock_series(payload, 0x40)
  guard split_v is Ok(packets) else {
    if split_v is Err(msg) {
      fail("expected trailing HT packet split success: \{msg}")
    }
    fail("expected trailing HT packet split success")
  }
  assert_eq(packets.length(), 1)
  assert_eq(packets[0], payload)
}

///|
test "split_sod_payload_single_codeblock_series keeps trailing full HT payload whole" {
  let payload = wb_int_array_to_bytes(wb_trailing_ht_full_payload())
  let split_v = @a8.split_sod_payload_single_codeblock_series(payload, 0x40)
  guard split_v is Ok(packets) else {
    if split_v is Err(msg) {
      fail("expected full trailing HT packet split success: \{msg}")
    }
    fail("expected full trailing HT packet split success")
  }
  assert_eq(packets.length(), 1)
  assert_eq(packets[0], payload)
}

///|
test "decode_samples internal staged HT MagRef codestream yields MagRef sample" {
  let codestream = wb_minimal_ht_single_codeblock_codestream(
    wb_staged_ht_magref_payload(),
    1,
    0x40,
  )
  let decoded = decode_samples(codestream)
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail("expected staged HT MagRef codestream decode success: \{msg}")
    }
    fail("expected staged HT MagRef codestream decode success")
  }
  assert_eq(wb_bytes_to_int_array(result.samples), [92])
}

///|
test "full codestream staged HT MagRef keeps segment metadata through extraction" {
  let codestream = wb_minimal_ht_single_codeblock_codestream(
    wb_staged_ht_magref_payload(),
    1,
    0x40,
  )
  let parsed_v = @core.parse_codestream(codestream)
  guard parsed_v is Ok(stream) else {
    fail("expected codestream parse success")
  }
  let payloads = @input.collect_sod_payloads(stream)
  let prepared_v = @a8.prepare_sod_payloads_for_simple_profile(payloads)
  guard prepared_v is Ok(simple_payloads) else {
    fail("expected simple payload prepare")
  }
  let extracted_v = @a8.extract_simple_profile_packet_parts(stream, simple_payloads)
  guard extracted_v is Ok(parts_list) else {
    if extracted_v is Err(msg) {
      fail("expected HT extraction success: \{msg}")
    }
    fail("expected HT extraction success")
  }
  assert_eq(parts_list.length(), 1)
  let parts = parts_list[0]
  assert_eq(parts.segment_lengths, [5, 1])
  assert_eq(parts.segment_passes, [1, 2])
  assert_eq(parts.zero_bit_planes, Some(6))
  assert_eq(parts.coding_passes, Some(3))
  assert_eq(
    @core.bytes_to_hex(wb_bytes_to_int_array(parts.codeword)),
    "e30007740000",
  )
}

///|
test "strip SOP/EPH markers for simple-profile packet analysis" {
  let payload = wb_int_array_to_bytes([0xFF, 0x91, 0x00, 0x04, 0x00, 0x00, 0xFF, 0x92])
  let stripped = @a8.strip_in_bitstream_markers_for_simple_profile(payload)
  guard stripped is Ok(cleaned) else { fail("expected marker strip success") }
  inspect(cleaned.length(), content="0")
}

///|
// Spec basis (T.800-2015 conformance regression):
// - tests pin Annex A/B/C/D derived staged behavior to detect
//   implementation drift.
fn wb_stream_with_ppt_relocated_header_and_body() -> Array[Int] {
  let siz_payload = [
    0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x10,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x07, 0x01, 0x01,
  ]
  let cod_payload = [0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
  [
    0xFF, 0x4F, // SOC
     0xFF, 0x51, 0x00, 0x29, ..siz_payload, // SIZ
     0xFF, 0x52, 0x00, 0x0C, ..cod_payload, // COD
     0xFF, 0x5C, 0x00, 0x04, 0x00, 0x00, // QCD
     0xFF, 0x90, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, // SOT (Psot=0)
     0xFF, 0x61, 0x00, 0x04, 0x00, 0xE1, // PPT (Zppt=0 + packet header bits)
     0xFF, 0x93, // SOD
     0xC0, // codeword body byte (chosen to break in-band packet-header parse)
     0xFF, 0xD9, // EOC
  ]
}

///|
test "extract_simple_profile_packet_parts uses relocated PPT header deterministically" {
  let parsed = @core.parse_codestream(
    @bytes.int_array_to_bytes(wb_stream_with_ppt_relocated_header_and_body()),
  )
  guard parsed is Ok(stream) else { fail("expected parser success") }

  let payloads = @input.collect_sod_payloads(stream)
  let prepared = @a8.prepare_sod_payloads_for_simple_profile(payloads)
  guard prepared is Ok(simple_payloads) else {
    fail("expected SOD payload prepare success")
  }
  let extracted = @a8.extract_simple_profile_packet_parts(stream, simple_payloads)
  guard extracted is Ok(parts_list) else {
    fail("expected relocated header extraction success")
  }
  inspect(parts_list.length(), content="1")
  inspect(parts_list[0].segment_total, content="1")
  inspect(parts_list[0].included, content="true")
  inspect(
    @core.bytes_to_hex(wb_bytes_to_int_array(parts_list[0].codeword)),
    content="c0",
  )
}

///|
test "annex-c context reset/save/restore roundtrip is deterministic" {
  let reset_v = @mq.tier1_annex_c_reset_contexts(3)
  guard reset_v is Ok(contexts) else { fail("expected reset success") }
  inspect(contexts.length(), content="3")
  inspect(
    contexts[0].state_index,
    content=(
      #|4
    ),
  )
  inspect(contexts[0].mps, content="0")

  let saved_v = @mq.tier1_annex_c_save_contexts(contexts)
  guard saved_v is Ok(snapshot) else { fail("expected save success") }
  inspect(
    snapshot,
    content=(
      #|[8, 0, 0]
    ),
  )

  let restored_v = @mq.tier1_annex_c_restore_contexts(snapshot)
  guard restored_v is Ok(restored) else { fail("expected restore success") }
  inspect(restored.length(), content="3")
  inspect(restored[2].state_index, content="0")
  inspect(restored[2].mps, content="0")
}

///|
test "annex-c one-decision probe is deterministic" {
  let codewords = [b"\x7A"]
  let boot_v = @mq.tier1_annex_c_bootstrap_from_codewords(codewords)
  guard boot_v is Ok(boot) else { fail("expected bootstrap success") }
  let contexts_v = @mq.tier1_annex_c_reset_contexts(1)
  guard contexts_v is Ok(contexts) else {
    fail("expected context reset success")
  }
  let probe_v = @mq.tier1_annex_c_probe_one_decision(boot, codewords, contexts)
  guard probe_v is Ok(probe) else { fail("expected probe success") }
  inspect(
    @mq.tier1_annex_c_probe_debug(probe),
    content=(
      #|probe:ctx=0,decision=0,kind=MPS
    ),
  )
}

///|
test "annex-c single-coeff pass decode trace is deterministic" {
  let codewords = [b"\x7A"]
  let boot_v = @mq.tier1_annex_c_bootstrap_from_codewords(codewords)
  guard boot_v is Ok(boot) else { fail("expected bootstrap success") }
  let contexts_v = @mq.tier1_annex_c_reset_contexts(5)
  guard contexts_v is Ok(contexts) else {
    fail("expected context reset success")
  }
  let trace_v = @mq.tier1_annex_c_decode_single_coeff_passes(
    boot, codewords, contexts, 1, false,
  )
  guard trace_v is Ok((ctxs, decisions, kinds)) else {
    fail("expected trace success")
  }
  inspect(
    @mq.tier1_annex_c_context_trace_debug(ctxs, decisions, kinds),
    content=(
      #|trace:contexts=[0],bits=[0],kinds=["MPS"]
    ),
  )
}

///|
test "annex-d staged pass trace is deterministic" {
  let trace_v = @t1.tier1_staged_pass_trace(4, 0)
  guard trace_v is Ok(trace) else { fail("expected pass trace success") }
  inspect(
    trace,
    content="tier1-pass-trace:n=4,seq=[\"cleanup@bp0\", \"sigprop@bp0\", \"magref@bp0\", \"cleanup@bp1\"]",
  )
}

///|
test "annex-c single-coeff staged policy consumes sigprop decision" {
  let codewords = [b"\x7A"]
  let boot_v = @mq.tier1_annex_c_bootstrap_from_codewords(codewords)
  guard boot_v is Ok(boot) else { fail("expected bootstrap success") }
  let contexts_v = @mq.tier1_annex_c_reset_contexts(5)
  guard contexts_v is Ok(contexts) else {
    fail("expected context reset success")
  }
  let trace_v = @mq.tier1_annex_c_decode_single_coeff_passes(
    boot, codewords, contexts, 2, true,
  )
  guard trace_v is Ok((ctxs, decisions, kinds)) else {
    fail("expected staged-policy decode success")
  }
  inspect(
    @mq.tier1_annex_c_context_trace_debug(ctxs, decisions, kinds),
    content=(
      #|trace:contexts=[0, 1],bits=[0, 0],kinds=["MPS", "MPS"]
    ),
  )
}

///|
test "annex-c mini-block pass decode uses neighbor-category contexts" {
  let codewords = [b"\x7A"]
  let boot_v = @mq.tier1_annex_c_bootstrap_from_codewords(codewords)
  guard boot_v is Ok(boot) else { fail("expected bootstrap success") }
  let contexts_v = @mq.tier1_annex_c_reset_contexts(19)
  guard contexts_v is Ok(contexts) else {
    fail("expected context reset success")
  }
  let trace_v = @mq.tier1_annex_c_decode_mini_block_passes(
    boot, codewords, contexts, 2, 2, 1, false,
  )
  guard trace_v is Ok((ctxs, decisions, kinds)) else {
    fail("expected mini-block decode success")
  }
  inspect(
    @mq.tier1_annex_c_context_trace_debug(ctxs, decisions, kinds),
    content=(
      #|trace:contexts=[0, 0, 0, 0],bits=[0, 0, 0, 0],kinds=["MPS", "MPS", "MPS", "MPS"]
    ),
  )
}

///|
test "annex-c sign-context profile differs between cleanup and sigprop" {
  let signs = [1, 0, 0, 0, 0, 0, 0, 0, 0]
  let cleanup_score = @mq.tier1_mq_mini_block_cleanup_sign_score(
    3, 3, signs, 1, 1,
  )
  let sigprop_score = @mq.tier1_mq_mini_block_sigprop_sign_score(
    3, 3, signs, 1, 1,
  )
  inspect(cleanup_score, content="1")
  inspect(sigprop_score, content="1")
  inspect(
    @mq.tier1_mq_mini_block_cleanup_sign_context(cleanup_score, 1),
    content="13",
  )
  inspect(
    @mq.tier1_mq_mini_block_sigprop_sign_context(sigprop_score, 1),
    content="17",
  )
}

///|
test "annex-c sign-context table adapts to neighbor and bias buckets" {
  inspect(@mq.tier1_mq_mini_block_neighbor_bucket(1), content="0")
  inspect(@mq.tier1_mq_mini_block_neighbor_bucket(4), content="2")
  inspect(@mq.tier1_mq_mini_block_bias_bucket(0), content="0")
  inspect(@mq.tier1_mq_mini_block_bias_bucket(1), content="1")
  inspect(@mq.tier1_mq_mini_block_bias_bucket(3), content="2")
  inspect(@mq.tier1_mq_sign_mode_table_cleanup(0, 2), content="1")
  inspect(@mq.tier1_mq_sign_mode_table_cleanup(2, 2), content="0")
  inspect(@mq.tier1_mq_sign_mode_table_sigprop(0, 1), content="1")
  inspect(@mq.tier1_mq_sign_mode_table_sigprop(2, 1), content="0")
  inspect(@mq.tier1_mq_sig_context_table_cleanup(0, 0), content="5")
  inspect(@mq.tier1_mq_sig_context_table_cleanup(1, 2), content="7")
  inspect(@mq.tier1_mq_sig_context_table_sigprop(0, 0), content="9")
  inspect(@mq.tier1_mq_sig_context_table_sigprop(2, 2), content="10")
  inspect(@mq.tier1_mq_mini_block_cleanup_sig_context(0, 0), content="5")
  inspect(@mq.tier1_mq_mini_block_cleanup_sig_context(4, 3), content="7")
  inspect(@mq.tier1_mq_mini_block_sigprop_sig_context(1, 0), content="9")
  inspect(@mq.tier1_mq_mini_block_sigprop_sig_context(4, 3), content="10")
  inspect(@mq.tier1_mq_mini_block_cleanup_sign_context(2, 1), content="14")
  inspect(@mq.tier1_mq_mini_block_cleanup_sign_context(2, 4), content="13")
  inspect(@mq.tier1_mq_mini_block_cleanup_sign_context(-2, 1), content="15")
  inspect(@mq.tier1_mq_mini_block_cleanup_sign_context(0, 1), content="13")
  inspect(@mq.tier1_mq_mini_block_sigprop_sign_context(2, 1), content="17")
  inspect(@mq.tier1_mq_mini_block_sigprop_sign_context(2, 4), content="17")
  inspect(@mq.tier1_mq_mini_block_sigprop_sign_context(-2, 1), content="18")
  inspect(@mq.tier1_mq_mini_block_sigprop_sign_context(0, 4), content="16")
}

///|
test "annex-c sign-context score honors directional weights" {
  // Center (1,1): one orthogonal + one diagonal positive neighbor
  let signs = [1, 0, 0, 1, 0, 0, 0, 0, 0]
  let cleanup_score = @mq.tier1_mq_mini_block_cleanup_sign_score(
    3, 3, signs, 1, 1,
  )
  let sigprop_score = @mq.tier1_mq_mini_block_sigprop_sign_score(
    3, 3, signs, 1, 1,
  )
  inspect(cleanup_score, content="3")
  inspect(sigprop_score, content="4")
}

///|
test "annex-d staged pass state is deterministic" {
  let state_v = @t1.tier1_staged_apply_passes(4, 0, [1, 0, 0, 1])
  guard state_v is Ok(state) else { fail("expected pass state success") }
  inspect(
    @t1.tier1_staged_pass_state_debug(state),
    content="tier1-pass-state:sig=true,sign=1,mag=2,consumed=5",
  )
}

///|
test "annex-d pass primitives update single-coeff state deterministically" {
  let s0 = @t1.Tier1StagedPassState::new(false, 1, 0, 0)
  let c0 = @t1.Tier1StagedBitCursor::new([1, 1, 1], 0)
  let p1 = @t1.tier1_apply_cleanup_pass_single(s0, c0)
  guard p1 is Ok((s1, c1)) else { fail("cleanup pass should succeed") }
  inspect(
    @t1.tier1_staged_pass_state_debug(s1),
    content="tier1-pass-state:sig=true,sign=-1,mag=1,consumed=2",
  )
  let p2 = @t1.tier1_apply_magref_pass_single(s1, c1)
  guard p2 is Ok((s2, _)) else { fail("magref pass should succeed") }
  inspect(
    @t1.tier1_staged_pass_state_debug(s2),
    content="tier1-pass-state:sig=true,sign=-1,mag=2,consumed=3",
  )
}

///|
test "annex-d normative preview differs on sigprop-without-neighbors" {
  let staged_v = @t1.tier1_staged_apply_passes(4, 0, [1, 0, 0, 1])
  guard staged_v is Ok(staged) else { fail("expected staged state success") }
  let norm_v = @t1.tier1_apply_passes_normative_preview_single_coeff(4, 0, [
    1, 0, 0, 1,
  ])
  guard norm_v is Ok(norm) else { fail("expected normative preview success") }
  inspect(
    @t1.tier1_staged_pass_state_debug(staged),
    content="tier1-pass-state:sig=true,sign=1,mag=2,consumed=5",
  )
  inspect(
    @t1.tier1_normative_preview_state_debug(norm),
    content="tier1-pass-norm-preview:sig=true,sign=1,mag=1,consumed=4",
  )
  inspect(
    @t1.tier1_normative_single_coeff_debug(norm),
    content="tier1-pass-coeff:value=1",
  )
  let values_v = @t1.tier1_normative_preview_sample_values(2, norm, [1, 0, 0, 1])
  guard values_v is Ok(values) else { fail("expected sample preview success") }
  inspect(
    @t1.tier1_normative_preview_sample_values_debug(values),
    content="tier1-pass-samples:[1, 1]",
  )
}

///|
test "annex-d integrated pass core switches on sigprop policy" {
  let staged_v = @t1.tier1_apply_passes_single_coeff_with_sigprop_policy(
    4,
    0,
    [1, 0, 0, 1],
    true,
  )
  guard staged_v is Ok(staged) else { fail("expected staged-policy success") }
  inspect(
    @t1.tier1_staged_pass_state_debug(staged),
    content="tier1-pass-state:sig=true,sign=1,mag=2,consumed=5",
  )
  let norm_v = @t1.tier1_apply_passes_single_coeff_with_sigprop_policy(
    4,
    0,
    [1, 0, 0, 1],
    false,
  )
  guard norm_v is Ok(norm) else { fail("expected normative-policy success") }
  inspect(
    @t1.tier1_normative_preview_state_debug(norm),
    content="tier1-pass-norm-preview:sig=true,sign=1,mag=1,consumed=4",
  )
}

///|
test "annex-d normative 2x2 preview applies cleanup/sigprop/magref" {
  let values_v = @t1.tier1_normative_preview_sample_values_mini_block(
    2,
    2,
    3,
    0,
    [1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1],
  )
  guard values_v is Ok((values, consumed_bits)) else {
    fail("expected 2x2 preview success")
  }
  // Spec basis (T.800-2015 D.3.4): magref uses (magnitude << 1) | bit
  inspect(
    values,
    content=(
      #|[3, 0, -1, 1]
    ),
  )
  inspect(
    consumed_bits,
    content=(
      #|11
    ),
  )
}

///|
test "annex-d normative 2x2 sigprop skips without significant neighbors" {
  let values_v = @t1.tier1_normative_preview_sample_values_mini_block(
    2,
    2,
    2,
    0,
    [0, 0, 0, 0, 1, 1],
  )
  guard values_v is Ok((values, consumed_bits)) else {
    fail("expected 2x2 preview success")
  }
  inspect(values, content="[0, 0, 0, 0]")
  inspect(consumed_bits, content="4")
}

///|
test "annex-d fixedpoint ignores bpno_plus_one below one" {
  let values_v = @t1.tier1_fixedpoint_sample_values_mini_block(
    2,
    2,
    4,
    0,
    [1, 0, 1, 1, 0, 1],
  )
  guard values_v is Ok((values, consumed_bits)) else {
    fail("expected fixedpoint preview success")
  }
  inspect(values, content="[0, 0, 0, 0]")
  inspect(consumed_bits, content="0")
}

///|
test "annex-d normative preview applies causal mask on stripe boundary" {
  let values_v = @t1.tier1_normative_preview_sample_values_mini_block(
    1,
    5,
    2,
    0,
    [0, 0, 0, 0, 1, 0, 1, 0],
    code_block_style=0x08,
  )
  guard values_v is Ok((values, consumed_bits)) else {
    fail("expected causal normative preview success")
  }
  inspect(values, content="[0, 0, 0, 0, 1]")
  inspect(consumed_bits, content="6")
}

///|
test "annex-d fixedpoint applies causal mask on stripe boundary" {
  let values_v = @t1.tier1_fixedpoint_sample_values_mini_block(
    1,
    5,
    2,
    1,
    [0, 0, 0, 0, 1, 0, 1, 0],
    code_block_style=0x08,
  )
  guard values_v is Ok((values, consumed_bits)) else {
    fail("expected causal fixedpoint preview success")
  }
  inspect(values, content="[0, 0, 0, 0, 3]")
  inspect(consumed_bits, content="6")
}

///|
test "annex-g inverse RCT triplet is deterministic" {
  let (r, g, b) = @mct.tier1_annex_g_inverse_rct_triplet(10, 4, -2)
  inspect(r, content="8")
  inspect(g, content="10")
  inspect(b, content="14")
}

///|
test "annex-g inverse ICT triplet keeps neutral chroma at Y" {
  let (r, g, b) = @mct.tier1_annex_g_inverse_ict_triplet(100, 0, 0)
  inspect(r, content="100")
  inspect(g, content="100")
  inspect(b, content="100")
}

///|
test "annex-g inverse RCT components validates length" {
  let out = @mct.tier1_annex_g_inverse_rct_components([1, 2], [0], [0, 0])
  guard out is Err(msg) else { fail("expected inverse RCT length error") }
  inspect(msg, content="inverse RCT requires equal component lengths")
}

///|
test "annex-g inverse ICT components validates length" {
  let out = @mct.tier1_annex_g_inverse_ict_components([1], [0, 1], [0])
  guard out is Err(msg) else { fail("expected inverse ICT length error") }
  inspect(msg, content="inverse ICT requires equal component lengths")
}

///|
test "lossy positioned bitplane count keeps qstyle1 extra plane" {
  inspect(@codeblock.tier1_lossy_positioned_bitplane_count(3, 1, 0, 8, 8), content="2")
  inspect(@codeblock.tier1_lossy_positioned_bitplane_count(6, 1, 0, 8, 8), content="3")
}

///|
test "lossy positioned bitplane count adds bypass magref plane for non-termall" {
  inspect(@codeblock.tier1_lossy_positioned_bitplane_count(3, 2, 0x01, 3, 5), content="2")
  inspect(@codeblock.tier1_lossy_positioned_bitplane_count(6, 2, 0x19, 8, 8), content="3")
}

///|
test "lossy positioned bitplane count leaves termall and base path unchanged" {
  inspect(@codeblock.tier1_lossy_positioned_bitplane_count(3, 2, 0x05, 3, 5), content="1")
  inspect(@codeblock.tier1_lossy_positioned_bitplane_count(5, 2, 0x00, 2, 3), content="2")
}

///|
test "htj2k split first set separates cleanup and refinement segments" {
  let split_v = @ht.htj2k_select_active_set(
    b"\xAA\xBB\xCC\xDD\xEE",
    [2, 3],
    [1, 2],
    3,
  )
  guard split_v is Ok(selected) else {
    fail("expected HT segment split success")
  }
  inspect(
    @core.bytes_to_hex(wb_bytes_to_int_array(selected.cleanup_segment)),
    content="aabb",
  )
  inspect(
    @core.bytes_to_hex(wb_bytes_to_int_array(selected.refinement_segment)),
    content="ccddee",
  )
  inspect(selected.z_blk, content="3")
}

///|
test "htj2k split selects trailing HT set" {
  let split_v = @ht.htj2k_select_active_set(
    b"\xAA\xBB\xCC\xDD\xEE\x11\x22",
    [2, 3, 2],
    [1, 2, 1],
    4,
  )
  guard split_v is Ok(selected) else {
    fail("expected trailing HT set extraction success")
  }
  inspect(
    @core.bytes_to_hex(wb_bytes_to_int_array(selected.cleanup_segment)),
    content="1122",
  )
  inspect(
    @core.bytes_to_hex(wb_bytes_to_int_array(selected.refinement_segment)),
    content="",
  )
  inspect(selected.z_blk, content="1")
}

///|
test "htj2k sigprop uses refinement bits inside a stripe" {
  let values = [8, 0, 0]
  let cleanup_significant = [true, false, false]
  let applied_v = @ht.htj2k_apply_refinement_segment(
    values, cleanup_significant, b"\x03", 1, 3, 3, 2, 0x40,
  )
  guard applied_v is Ok(applied) else {
    fail("expected HT sigprop decode success")
  }
  inspect(applied, content="[8, 6, 6]")
}

///|
test "htj2k causal sigprop masks south neighbor across stripe boundary" {
  let applied_v = @ht.htj2k_apply_refinement_segment(
    [0, 0, 0, 0, 8],
    [false, false, false, false, true],
    b"\x01",
    1,
    5,
    3,
    2,
    0x48,
  )
  guard applied_v is Ok(applied) else {
    fail("expected HT causal sigprop decode success")
  }
  inspect(applied, content="[0, 0, 0, 0, 8]")
}

///|
test "htj2k magref adjusts cleanup-significant coefficient from reverse stream" {
  let applied_v = @ht.htj2k_apply_refinement_segment(
    [8],
    [true],
    b"\x01",
    1,
    1,
    3,
    3,
    0x40,
  )
  guard applied_v is Ok(applied) else {
    fail("expected HT magref decode success")
  }
  inspect(applied, content="[10]")
}

///|
test "htj2k codeblock decode applies MagRef in staged path" {
  let cleanup_v = @codeblock.decode_single_codeblock_coefficients(
    b"\xE3\x00\x07\x74\x00", 1, 1, 1, 6, 8, 0x40,
  )
  let refined_v = @codeblock.decode_single_codeblock_coefficients(
    b"\xE3\x00\x07\x74\x00\x00",
    1,
    1,
    3,
    6,
    8,
    0x40,
    segment_lengths=[5, 1],
    per_segment_passes=[1, 2],
  )
  guard cleanup_v is Ok(cleanup) else {
    fail("cleanup-only HT codeblock should decode")
  }
  guard refined_v is Ok(refined) else {
    fail("HT MagRef codeblock should decode")
  }
  inspect(cleanup, content="[-37]")
  inspect(refined, content="[-36]")
}

///|
test "htj2k codeblock decode preserves cleanup value with ROI descaling" {
  let plain_v = @codeblock.decode_single_codeblock_coefficients(
    b"\xE3\x00\x07\x74\x00", 1, 1, 1, 6, 8, 0x40,
  )
  let roi_v = @codeblock.decode_single_codeblock_coefficients(
    b"\xE3\x00\x07\x74\x00",
    1,
    1,
    1,
    6,
    8,
    0x40,
    roishift=1,
  )
  guard plain_v is Ok(plain) else {
    fail("plain HT cleanup codeblock should decode")
  }
  guard roi_v is Ok(roi) else { fail("ROI HT cleanup codeblock should decode") }
  inspect(plain, content="[-37]")
  inspect(roi, content="[-37]")
}

///|
test "htj2k codeblock decode preserves staged value with ROI descaling" {
  let plain_v = @codeblock.decode_single_codeblock_coefficients(
    b"\xE3\x00\x07\x74\x00\x00",
    1,
    1,
    3,
    6,
    8,
    0x40,
    segment_lengths=[5, 1],
    per_segment_passes=[1, 2],
  )
  let roi_v = @codeblock.decode_single_codeblock_coefficients(
    b"\xE3\x00\x07\x74\x00\x00",
    1,
    1,
    3,
    6,
    8,
    0x40,
    segment_lengths=[5, 1],
    per_segment_passes=[1, 2],
    roishift=1,
  )
  guard plain_v is Ok(plain) else {
    fail("plain staged HT codeblock should decode")
  }
  guard roi_v is Ok(roi) else { fail("ROI staged HT codeblock should decode") }
  inspect(plain, content="[-36]")
  inspect(roi, content="[-36]")
}

///|
test "htj2k component helper keeps main-header COC override" {
  let parsed = @core.parse_codestream(@bytes.int_array_to_bytes(profile_main_header_coc_ht_codestream()))
  guard parsed is Ok(stream) else { fail("main-header COC parse failed") }
  assert_eq(@geometry.get_component_code_block_style(stream, 0), 0x40)
}

///|
test "htj2k component helper applies tile-part COC override for matching tile" {
  let parsed = @core.parse_codestream(
    @bytes.int_array_to_bytes(profile_tile_header_coc_qcc_ht_codestream()),
  )
  guard parsed is Ok(stream) else { fail("tile-header COC parse failed") }
  assert_eq(stream.metadata.coc[0].tile_index, 0)
  assert_eq(@geometry.get_component_code_block_style(stream, 0, tile_index=0), 0x40)
}

///|
test "htj2k component quantization helper applies tile-part QCC override" {
  let parsed = @core.parse_codestream(
    @bytes.int_array_to_bytes(profile_tile_header_coc_qcc_ht_codestream()),
  )
  guard parsed is Ok(stream) else { fail("tile-header QCC parse failed") }
  guard stream.metadata.qcd is Some(qcd) else { fail("missing QCD") }
  assert_eq(stream.metadata.qcc[0].tile_index, 0)
  let effective_qcd = @geometry.get_component_qcd_with_fallback(
    stream,
    0,
    qcd,
    tile_index=0,
  )
  assert_eq(effective_qcd.quantization_style, 1)
}

///|
test "htj2k codeblock decode selects trailing HT cleanup set" {
  let trailing_v = @codeblock.decode_single_codeblock_coefficients(
    b"\xE3\x00\x07\x74\x00\x00\xE3\x00\x07\x74\x00",
    1,
    1,
    4,
    6,
    8,
    0x40,
    segment_lengths=[5, 1, 5],
    per_segment_passes=[1, 2, 1],
  )
  let expected_v = @codeblock.decode_single_codeblock_coefficients(
    b"\xE3\x00\x07\x74\x00", 1, 1, 1, 7, 8, 0x40,
  )
  guard trailing_v is Ok(trailing) else {
    fail("HT multi-set codeblock should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("shifted cleanup HT codeblock should decode")
  }
  inspect(trailing, content="[-18]")
  inspect(expected, content="[-18]")
}

///|
test "htj2k codeblock decode selects trailing full HT set" {
  let trailing_v = @codeblock.decode_single_codeblock_coefficients(
    b"\xE3\x00\x07\x74\x00\x00\xE3\x00\x07\x74\x00\x00",
    1,
    1,
    6,
    5,
    8,
    0x40,
    segment_lengths=[5, 1, 5, 1],
    per_segment_passes=[1, 2, 1, 2],
  )
  let expected_v = @codeblock.decode_single_codeblock_coefficients(
    b"\xE3\x00\x07\x74\x00\x00",
    1,
    1,
    3,
    6,
    8,
    0x40,
    segment_lengths=[5, 1],
    per_segment_passes=[1, 2],
  )
  guard trailing_v is Ok(trailing) else {
    fail("HT full multi-set codeblock should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("shifted full HT codeblock should decode")
  }
  inspect(trailing, content="[-36]")
  inspect(expected, content="[-36]")
}

///|
test "multi-layer accumulator keeps trailing full HT single-codeblock metadata" {
  let payload_arr = wb_single_codeblock_packet_header(true, 5, 3, [5, 1], [1, 2]) +
    [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00] +
    wb_single_codeblock_packet_header(false, 0, 3, [5, 1], [1, 2]) +
    [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00]
  let accum_v = @layer.split_sod_accumulate_multi_layer(
    wb_int_array_to_bytes(payload_arr),
    1,
    1,
    0,
    1,
    2,
    0,
    0x40,
    cb_width=16,
    cb_height=16,
  )
  guard accum_v is Ok((all_comp_accum, _)) else {
    if accum_v is Err(msg) {
      fail("expected full HT accumulation success: \{msg}")
    }
    fail("expected full HT accumulation success")
  }
  assert_eq(all_comp_accum.length(), 1)
  assert_eq(all_comp_accum[0].length(), 1)
  assert_eq(all_comp_accum[0][0].length(), 1)
  let cb = all_comp_accum[0][0][0]
  assert_eq(cb.zero_bit_planes, 5)
  assert_eq(cb.total_coding_passes, 6)
  assert_eq(cb.all_segment_lengths, [5, 1, 5, 1])
  assert_eq(cb.per_segment_passes, [1, 2, 1, 2])
  assert_eq(wb_bytes_to_int_array(Bytes::from_iter(cb.codeword.iter())), [
    0xE3, 0x00, 0x07, 0x74, 0x00, 0x00, 0xE3, 0x00, 0x07, 0x74, 0x00, 0x00,
  ])
}

///|
test "layer packet header keeps HT full second contribution after first inclusion" {
  let sb_states = [
    @layer.init_subband_layer_state(1, 1, 16, 16, ncbx_override=1, ncby_override=1),
  ]
  let subbands = [(1, 1, 0)]
  let first_v = @layer.parse_layer_packet_header(
    wb_int_array_to_bytes(wb_single_codeblock_packet_header(true, 5, 3, [5, 1], [1, 2])),
    0,
    0x40,
    subbands,
    sb_states,
    16,
    16,
  )
  guard first_v is Ok((first_infos, _)) else {
    if first_v is Err(msg) {
      fail("expected first HT layer header parse success: \{msg}")
    }
    fail("expected first HT layer header parse success")
  }
  assert_eq(first_infos.length(), 1)
  assert_true(first_infos[0].included)
  assert_eq(first_infos[0].coding_passes, Some(3))
  assert_eq(first_infos[0].segment_lengths, [5, 1])
  assert_eq(first_infos[0].segment_passes, [1, 2])
  let second_v = @layer.parse_layer_packet_header(
    wb_int_array_to_bytes(wb_single_codeblock_packet_header(false, 0, 3, [5, 1], [1, 2])),
    1,
    0x40,
    subbands,
    sb_states,
    16,
    16,
  )
  guard second_v is Ok((second_infos, _)) else {
    if second_v is Err(msg) {
      fail("expected second HT layer header parse success: \{msg}")
    }
    fail("expected second HT layer header parse success")
  }
  assert_eq(second_infos.length(), 1)
  assert_true(second_infos[0].included)
  assert_eq(second_infos[0].zero_bit_planes, None)
  assert_eq(second_infos[0].coding_passes, Some(3))
  assert_eq(second_infos[0].segment_lengths, [5, 1])
  assert_eq(second_infos[0].segment_passes, [1, 2])
}

///|
test "htj2k codeblock decode applies placeholder HT set skip" {
  let placeholder_v = @codeblock.decode_single_codeblock_coefficients(
    b"\xE3\x00\x07\x74\x00",
    1,
    1,
    4,
    6,
    8,
    0x40,
    segment_lengths=[5],
    per_segment_passes=[1],
  )
  let expected_v = @codeblock.decode_single_codeblock_coefficients(
    b"\xE3\x00\x07\x74\x00", 1, 1, 1, 7, 8, 0x40,
  )
  guard placeholder_v is Ok(placeholder) else {
    fail("placeholder HT codeblock should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("shifted cleanup HT codeblock should decode")
  }
  inspect(placeholder, content="[-18]")
  inspect(expected, content="[-18]")
}

///|
test "htj2k codeblock decode skips zero-length HT set before active cleanup" {
  let zero_len_v = @codeblock.decode_single_codeblock_coefficients(
    b"\xE3\x00\x07\x74\x00",
    1,
    1,
    4,
    6,
    8,
    0x40,
    segment_lengths=[0, 0, 5],
    per_segment_passes=[1, 2, 1],
  )
  let expected_v = @codeblock.decode_single_codeblock_coefficients(
    b"\xE3\x00\x07\x74\x00", 1, 1, 1, 7, 8, 0x40,
  )
  guard zero_len_v is Ok(zero_len) else {
    fail("zero-length HT set codeblock should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("shifted cleanup HT codeblock should decode")
  }
  inspect(zero_len, content="[-18]")
  inspect(expected, content="[-18]")
}

///|
test "htj2k codeblock decode applies SigProp in staged path" {
  let cleanup_codeword = b"\xA1\xC4\xA8\x09\x81\x4A\x28\x07\x9E\x24\x9D\xAC\x62\xA6\x01\x2E\xCE\x72\x08\x42\x3F\xA5\x4B\xBB\x00"
  let refined_codeword = b"\xA1\xC4\xA8\x09\x81\x4A\x28\x07\x9E\x24\x9D\xAC\x62\xA6\x01\x2E\xCE\x72\x08\x42\x3F\xA5\x4B\xBB\x00\x01"
  let cleanup_v = @codeblock.decode_single_codeblock_coefficients(
    cleanup_codeword,
    5,
    5,
    1,
    9,
    8,
    0x40,
    subband_max_bit_planes=11,
    quantization_style=0,
  )
  let refined_v = @codeblock.decode_single_codeblock_coefficients(
    refined_codeword,
    5,
    5,
    2,
    9,
    8,
    0x40,
    segment_lengths=[25, 1],
    per_segment_passes=[1, 1],
    subband_max_bit_planes=11,
    quantization_style=0,
  )
  guard cleanup_v is Ok(cleanup) else {
    fail("cleanup-only HT codeblock should decode")
  }
  guard refined_v is Ok(refined) else {
    fail("HT SigProp codeblock should decode")
  }
  assert_eq(cleanup.length(), 25)
  assert_eq(refined.length(), 25)
  assert_eq(cleanup[0], 0)
  assert_eq(refined[0], 1)
}

///|
test "htj2k multi-codeblock path decodes staged SigProp block" {
  let refined_codeword = b"\xA1\xC4\xA8\x09\x81\x4A\x28\x07\x9E\x24\x9D\xAC\x62\xA6\x01\x2E\xCE\x72\x08\x42\x3F\xA5\x4B\xBB\x00\x01"
  let packet_parts : @a8.MultiCodeblockPacketParts = {
    non_zero_packet: true,
    code_block_count: 1,
    parts: [
      {
        segment_total: 26,
        segment_lengths: [25, 1],
        segment_passes: [1, 1],
        non_zero_packet: true,
        included: true,
        zero_bit_planes: Some(9),
        coding_passes: Some(2),
        codeword: refined_codeword,
      },
    ],
  }
  let coeffs_v = @codeblock.decode_multi_codeblock_coefficients(
    [packet_parts],
    1,
    1,
    64,
    64,
    5,
    5,
    8,
    0x40,
    subband_max_bit_planes=11,
    quantization_style=0,
  )
  guard coeffs_v is Ok(coeffs) else {
    fail("HT multi-codeblock path should decode staged SigProp block")
  }
  assert_eq(coeffs.length(), 25)
  assert_eq(coeffs[0], 1)
}

///|
test "htj2k multi-codeblock path preserves staged SigProp block with ROI descaling" {
  let refined_codeword = b"\xA1\xC4\xA8\x09\x81\x4A\x28\x07\x9E\x24\x9D\xAC\x62\xA6\x01\x2E\xCE\x72\x08\x42\x3F\xA5\x4B\xBB\x00\x01"
  let packet_parts : @a8.MultiCodeblockPacketParts = {
    non_zero_packet: true,
    code_block_count: 1,
    parts: [
      {
        segment_total: 26,
        segment_lengths: [25, 1],
        segment_passes: [1, 1],
        non_zero_packet: true,
        included: true,
        zero_bit_planes: Some(9),
        coding_passes: Some(2),
        codeword: refined_codeword,
      },
    ],
  }
  let plain_v = @codeblock.decode_multi_codeblock_coefficients(
    [packet_parts],
    1,
    1,
    64,
    64,
    5,
    5,
    8,
    0x40,
    subband_max_bit_planes=11,
    quantization_style=0,
  )
  let roi_v = @codeblock.decode_multi_codeblock_coefficients(
    [packet_parts],
    1,
    1,
    64,
    64,
    5,
    5,
    8,
    0x40,
    subband_max_bit_planes=11,
    quantization_style=0,
    roishift=1,
  )
  guard plain_v is Ok(plain) else {
    fail("plain HT multi-codeblock path should decode staged SigProp block")
  }
  guard roi_v is Ok(roi) else {
    fail("ROI HT multi-codeblock path should decode staged SigProp block")
  }
  assert_eq(roi, plain)
}

///|
test "htj2k multi-codeblock path decodes zero-length HT set block" {
  let packet_parts : @a8.MultiCodeblockPacketParts = {
    non_zero_packet: true,
    code_block_count: 2,
    parts: [
      {
        segment_total: 5,
        segment_lengths: [0, 0, 5],
        segment_passes: [1, 2, 1],
        non_zero_packet: true,
        included: true,
        zero_bit_planes: Some(6),
        coding_passes: Some(4),
        codeword: b"\xE3\x00\x07\x74\x00",
      },
      {
        segment_total: 0,
        segment_lengths: [],
        segment_passes: [],
        non_zero_packet: true,
        included: false,
        zero_bit_planes: None,
        coding_passes: None,
        codeword: b"",
      },
    ],
  }
  let coeffs_v = @codeblock.decode_multi_codeblock_coefficients(
    [packet_parts],
    2,
    1,
    1,
    1,
    2,
    1,
    8,
    0x40,
  )
  guard coeffs_v is Ok(coeffs) else {
    fail("HT multi-codeblock zero-length set should decode")
  }
  assert_eq(coeffs, [-18, 0])
}

///|
test "htj2k multi-codeblock path decodes trailing full HT set block" {
  let packet_parts : @a8.MultiCodeblockPacketParts = {
    non_zero_packet: true,
    code_block_count: 2,
    parts: [
      {
        segment_total: 12,
        segment_lengths: [5, 1, 5, 1],
        segment_passes: [1, 2, 1, 2],
        non_zero_packet: true,
        included: true,
        zero_bit_planes: Some(5),
        coding_passes: Some(6),
        codeword: b"\xE3\x00\x07\x74\x00\x00\xE3\x00\x07\x74\x00\x00",
      },
      {
        segment_total: 0,
        segment_lengths: [],
        segment_passes: [],
        non_zero_packet: true,
        included: false,
        zero_bit_planes: None,
        coding_passes: None,
        codeword: b"",
      },
    ],
  }
  let coeffs_v = @codeblock.decode_multi_codeblock_coefficients(
    [packet_parts],
    2,
    1,
    1,
    1,
    2,
    1,
    8,
    0x40,
  )
  guard coeffs_v is Ok(coeffs) else {
    fail("HT multi-codeblock trailing full set should decode")
  }
  assert_eq(coeffs, [-36, 0])
}

///|
test "htj2k multi-codeblock path accumulates staged MagRef contributions across packets" {
  let single_packet : @a8.MultiCodeblockPacketParts = {
    non_zero_packet: true,
    code_block_count: 2,
    parts: [
      {
        segment_total: 6,
        segment_lengths: [5, 1],
        segment_passes: [1, 2],
        non_zero_packet: true,
        included: true,
        zero_bit_planes: Some(6),
        coding_passes: Some(3),
        codeword: b"\xE3\x00\x07\x74\x00\x00",
      },
      {
        segment_total: 0,
        segment_lengths: [],
        segment_passes: [],
        non_zero_packet: true,
        included: false,
        zero_bit_planes: None,
        coding_passes: None,
        codeword: b"",
      },
    ],
  }
  let packet0 : @a8.MultiCodeblockPacketParts = {
    non_zero_packet: true,
    code_block_count: 2,
    parts: [
      {
        segment_total: 5,
        segment_lengths: [5],
        segment_passes: [1],
        non_zero_packet: true,
        included: true,
        zero_bit_planes: Some(6),
        coding_passes: Some(1),
        codeword: b"\xE3\x00\x07\x74\x00",
      },
      {
        segment_total: 5,
        segment_lengths: [5],
        segment_passes: [1],
        non_zero_packet: true,
        included: true,
        zero_bit_planes: Some(6),
        coding_passes: Some(1),
        codeword: b"\xE3\x00\x07\x74\x00",
      },
    ],
  }
  let packet1 : @a8.MultiCodeblockPacketParts = {
    non_zero_packet: true,
    code_block_count: 2,
    parts: [
      {
        segment_total: 1,
        segment_lengths: [1],
        segment_passes: [2],
        non_zero_packet: true,
        included: true,
        zero_bit_planes: None,
        coding_passes: Some(2),
        codeword: b"\x00",
      },
      {
        segment_total: 0,
        segment_lengths: [],
        segment_passes: [],
        non_zero_packet: true,
        included: false,
        zero_bit_planes: None,
        coding_passes: None,
        codeword: b"",
      },
    ],
  }
  let first_v = @codeblock.decode_multi_codeblock_coefficients(
    [single_packet],
    2,
    1,
    4,
    4,
    5,
    1,
    8,
    0x40,
  )
  let second_v = @codeblock.decode_multi_codeblock_coefficients(
    [packet0, packet1],
    2,
    1,
    4,
    4,
    5,
    1,
    8,
    0x40,
  )
  guard first_v is Ok(first) else {
    fail("single-packet HT multi-codeblock should decode")
  }
  guard second_v is Ok(second) else {
    fail("multi-packet HT multi-codeblock should decode")
  }
  assert_eq(first, [-36, 0, 0, 0, 0])
  assert_eq(second, [-36, 0, 0, 0, -37])
}
