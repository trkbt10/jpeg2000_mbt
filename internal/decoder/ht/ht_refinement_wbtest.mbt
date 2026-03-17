///|
fn wb_bytes_to_int_array(data : Bytes) -> Array[Int] {
  let out : Array[Int] = []
  for b in data {
    out.push(b.to_int())
  }
  out
}

///|
fn ht_refinement_test_bytes(data : Array[Int]) -> Bytes {
  Bytes::from_iter(data.iter().map(fn(i) { i.to_byte() }))
}

///|
test "ht sigprop reader skips stuffed msb after ff" {
  let reader = ht_sigprop_init(ht_refinement_test_bytes([0xFF, 0x01]))
  let bits : Array[Int] = []
  for _ in 0..<15 {
    let bit_v = ht_sigprop_import_bit(reader)
    guard bit_v is Ok(bit) else { fail("sigprop import should not fail") }
    bits.push(bit)
  }
  assert_eq(bits, [1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0])
}

///|
test "ht refinement sigprop propagates through scan-causal r neighbors" {
  let refined_v = htj2k_apply_refinement_segment(
    [8, 0, 0],
    [true, false, false],
    ht_refinement_test_bytes([0x0B]),
    3,
    1,
    3,
    2,
    0,
  )
  guard refined_v is Ok(refined) else {
    fail("sigprop refinement should decode")
  }
  assert_eq(refined, [8, 6, -6])
}

///|
test "ht refinement causal style masks south neighbor at stripe boundary" {
  let noncausal_v = htj2k_apply_refinement_segment(
    [0, 0, 0, 0, 8],
    [false, false, false, false, true],
    ht_refinement_test_bytes([0x01]),
    1,
    5,
    3,
    2,
    0x40,
  )
  let causal_v = htj2k_apply_refinement_segment(
    [0, 0, 0, 0, 8],
    [false, false, false, false, true],
    ht_refinement_test_bytes([0x01]),
    1,
    5,
    3,
    2,
    0x48,
  )
  guard noncausal_v is Ok(noncausal) else {
    fail("non-causal sigprop refinement should decode")
  }
  guard causal_v is Ok(causal) else {
    fail("causal sigprop refinement should decode")
  }
  assert_eq(noncausal, [0, 0, 0, 6, 8])
  assert_eq(causal, [0, 0, 0, 0, 8])
}

///|
test "ht refinement lets prior-column lower-row significance affect later candidates" {
  let refined_v = htj2k_apply_refinement_segment(
    [0, 0, 0, 0, 0, 0, 8, 0],
    [false, false, false, false, false, false, true, false],
    ht_refinement_test_bytes([0x03]),
    2,
    4,
    3,
    2,
    0x48,
  )
  guard refined_v is Ok(refined) else {
    fail("causal sigprop refinement should decode")
  }
  assert_eq(refined, [0, 0, 0, 6, 6, 0, 8, 0])
}

///|
test "ht refinement magref updates cleanup-significant samples only" {
  let refined_v = htj2k_apply_refinement_segment(
    [8, -8],
    [true, true],
    ht_refinement_test_bytes([0x01]),
    2,
    1,
    3,
    3,
    0,
  )
  guard refined_v is Ok(refined) else {
    fail("magref refinement should decode")
  }
  assert_eq(refined, [10, -6])
}

///|
test "ht refinement selects trailing HT set after full earlier set" {
  let selected_v = htj2k_select_active_set(
    ht_refinement_test_bytes([
      0xE3, 0x00, 0x07, 0x74, 0x00, 0x00, 0xE3, 0x00, 0x07, 0x74, 0x00,
    ]),
    [5, 1, 5],
    [1, 2, 1],
    4,
  )
  guard selected_v is Ok(selected) else {
    fail("multi-set HT selection should succeed")
  }
  assert_eq(selected.skipped_ht_sets, 1)
  assert_eq(wb_bytes_to_int_array(selected.cleanup_segment), [
    0xE3, 0x00, 0x07, 0x74, 0x00,
  ])
  assert_eq(wb_bytes_to_int_array(selected.refinement_segment), [])
  assert_eq(selected.z_blk, 1)
}

///|
test "ht refinement counts placeholder HT sets before active cleanup" {
  let selected_v = htj2k_select_active_set(
    ht_refinement_test_bytes([0xE3, 0x00, 0x07, 0x74, 0x00]),
    [5],
    [1],
    4,
  )
  guard selected_v is Ok(selected) else {
    fail("placeholder HT selection should succeed")
  }
  assert_eq(selected.skipped_ht_sets, 1)
  assert_eq(wb_bytes_to_int_array(selected.cleanup_segment), [
    0xE3, 0x00, 0x07, 0x74, 0x00,
  ])
  assert_eq(selected.z_blk, 1)
}

///|
test "ht refinement counts zero-length HT set before active cleanup" {
  let selected_v = htj2k_select_active_set(
    ht_refinement_test_bytes([0xE3, 0x00, 0x07, 0x74, 0x00]),
    [0, 0, 5],
    [1, 2, 1],
    4,
  )
  guard selected_v is Ok(selected) else {
    fail("zero-length HT set selection should succeed")
  }
  assert_eq(selected.skipped_ht_sets, 1)
  assert_eq(wb_bytes_to_int_array(selected.cleanup_segment), [
    0xE3, 0x00, 0x07, 0x74, 0x00,
  ])
  assert_eq(wb_bytes_to_int_array(selected.refinement_segment), [])
  assert_eq(selected.z_blk, 1)
}

///|
test "ht refinement keeps z_blk one for zero-length refinement segment" {
  let selected_v = htj2k_select_active_set(
    ht_refinement_test_bytes([0xE3, 0x00, 0x07, 0x74, 0x00]),
    [5, 0],
    [1, 1],
    2,
  )
  guard selected_v is Ok(selected) else {
    fail("empty refinement HT selection should succeed")
  }
  assert_eq(selected.skipped_ht_sets, 0)
  assert_eq(wb_bytes_to_int_array(selected.cleanup_segment), [
    0xE3, 0x00, 0x07, 0x74, 0x00,
  ])
  assert_eq(wb_bytes_to_int_array(selected.refinement_segment), [])
  assert_eq(selected.z_blk, 1)
}

///|
test "ht refinement selects trailing cleanup after earlier empty refinement set" {
  let selected_v = htj2k_select_active_set(
    ht_refinement_test_bytes([
      0xE3, 0x00, 0x07, 0x74, 0x00, 0xE3, 0x00, 0x07, 0x74, 0x00,
    ]),
    [5, 0, 5],
    [1, 1, 1],
    3,
  )
  guard selected_v is Ok(selected) else {
    fail("trailing cleanup after empty refinement should succeed")
  }
  assert_eq(selected.skipped_ht_sets, 1)
  assert_eq(wb_bytes_to_int_array(selected.cleanup_segment), [
    0xE3, 0x00, 0x07, 0x74, 0x00,
  ])
  assert_eq(wb_bytes_to_int_array(selected.refinement_segment), [])
  assert_eq(selected.z_blk, 1)
}
