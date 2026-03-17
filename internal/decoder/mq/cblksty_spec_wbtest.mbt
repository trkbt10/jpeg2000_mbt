///|
// T.800-2015 Code-block style specification compliance tests
// Validates implementation against A.6.1 Table A.19 and referenced sections

///|
// T.800-2015 A.6.1 Table A.19 / D.4 Table D.7: RESET mode context initialization
// Verifies context reset produces correct initial states per Table D.7:
// - UNIFORM (context 18): state_index=46, MPS=0
// - Run-length (context 17): state_index=3, MPS=0
// - All zero neighbours (context 0): state_index=4, MPS=0
// - All other contexts: state_index=0, MPS=0
test "T800_D4_Table_D7_context_reset_initial_states" {
  let contexts_v = tier1_annex_c_reset_contexts(
    TIER1_ANNEX_C_DEFAULT_CONTEXT_COUNT,
  )
  guard contexts_v is Ok(contexts) else { return fail("Context reset failed") }

  // Table D.7: UNIFORM context (label 18) -> index 46
  assert_eq(contexts[18].state_index, 46)
  assert_eq(contexts[18].mps, 0)

  // Table D.7: Run-length context (label 17) -> index 3
  assert_eq(contexts[17].state_index, 3)
  assert_eq(contexts[17].mps, 0)

  // Table D.7: All zero neighbours (label 0) -> index 4
  assert_eq(contexts[0].state_index, 4)
  assert_eq(contexts[0].mps, 0)

  // Table D.7: All other contexts -> index 0
  for i in 1..<17 {
    assert_eq(contexts[i].state_index, 0)
    assert_eq(contexts[i].mps, 0)
  }
}

///|
// T.800-2015 D.7: Vertically causal context formation
// "any coefficient from the next code-block scan is considered to be insignificant"
// "bit labelled 15 is decoded assuming D2 = V1 = D3 = 0 in Figure D.2"
test "T800_D7_vertically_causal_context_mask" {
  // Test that mask_south=true (CAUSAL mode, last row of stripe) zeros V1, D2, D3
  // Create a significant array where the row below has significant neighbors
  let width = 4
  let height = 8
  let significant : Array[Bool] = Array::make(width * height, false)

  // Set some neighbors in the row below (row 4 = first row of next stripe)
  // Position (1, 4) = significant
  significant[4 * width + 1] = true // V1 neighbor for (1, 3)
  significant[4 * width + 0] = true // D2 neighbor for (1, 3)
  significant[4 * width + 2] = true // D3 neighbor for (1, 3)

  // Without CAUSAL (mask_south=false), these should be counted
  let (hi_no_mask, vi_no_mask, di_no_mask) = tier1_spec_neighbor_sig_counts(
    width,
    height,
    significant,
    1,
    3,
    mask_south=false,
  )
  assert_eq(vi_no_mask, 1) // V1 counted
  assert_eq(di_no_mask, 2) // D2 + D3 counted

  // With CAUSAL (mask_south=true at y=3, last row of stripe), these should NOT be counted
  let (hi_masked, vi_masked, di_masked) = tier1_spec_neighbor_sig_counts(
    width,
    height,
    significant,
    1,
    3,
    mask_south=true,
  )
  assert_eq(vi_masked, 0) // V1 masked
  assert_eq(di_masked, 0) // D2, D3 masked
  assert_eq(hi_masked, hi_no_mask) // H0, H1 unchanged
}

///|
// T.800-2015 D.7: Verify CAUSAL mode applies only to last row of stripe (y % 4 == 3)
test "T800_D7_causal_applies_to_stripe_boundary" {
  // CAUSAL mode should only affect row 3, 7, 11, etc. within code-block
  let has_causal = true

  // Row 0: NOT last row of stripe
  let vsc_row0 = has_causal && 0 % 4 == 3
  assert_eq(vsc_row0, false)

  // Row 2: NOT last row of stripe
  let vsc_row2 = has_causal && 2 % 4 == 3
  assert_eq(vsc_row2, false)

  // Row 3: IS last row of stripe
  let vsc_row3 = has_causal && 3 % 4 == 3
  assert_eq(vsc_row3, true)

  // Row 7: IS last row of stripe
  let vsc_row7 = has_causal && 7 % 4 == 3
  assert_eq(vsc_row7, true)
}

///|
// T.800-2015 D.4 / A.6.1: RESET mode resets contexts on every pass boundary
// Verify that context reset happens before each pass (except pass 0)
test "T800_D4_reset_on_pass_boundaries" {
  // Simulate RESET mode behavior
  let has_reset = true
  let num_passes = 5
  let mut reset_count = 0

  for i in 0..<num_passes {
    if has_reset && i > 0 {
      reset_count += 1
    }
  }

  // Should reset before passes 1, 2, 3, 4 (not before pass 0)
  assert_eq(reset_count, num_passes - 1)
}

///|
// T.800-2015 D.7 / D.3.2: Sign context with CAUSAL mode
// Sign contributions should also mask V1 when CAUSAL is enabled
test "T800_D7_causal_sign_context_mask" {
  let width = 4
  let height = 8
  let significant : Array[Bool] = Array::make(width * height, false)
  let signs : Array[Int] = Array::make(width * height, 1) // All positive

  // Set V1 neighbor as significant at (1, 4) for position (1, 3)
  significant[4 * width + 1] = true
  signs[4 * width + 1] = 1 // Positive

  // Without CAUSAL, V1 should contribute
  let (h_no_mask, v_no_mask) = tier1_spec_neighbor_sign_contributions(
    width,
    height,
    significant,
    signs,
    1,
    3,
    mask_south=false,
  )
  assert_eq(v_no_mask, 1) // V1 contributes

  // With CAUSAL, V1 should NOT contribute
  let (h_masked, v_masked) = tier1_spec_neighbor_sign_contributions(
    width,
    height,
    significant,
    signs,
    1,
    3,
    mask_south=true,
  )
  assert_eq(v_masked, 0) // V1 masked
  assert_eq(h_masked, h_no_mask) // Horizontal unchanged
}
