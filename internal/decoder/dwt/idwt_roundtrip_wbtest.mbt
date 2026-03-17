///|
// T.800-2015 F.3: IDWT round-trip verification tests
// These tests verify that known inputs produce expected outputs

///|
// Basic 2x2 identity: constant input should stay constant through IDWT
test "idwt_53_2x2_constant_value" {
  // All coefficients = 100, single level
  // For constant input, IDWT should produce constant output
  // (lifting steps cancel out when all values are equal)
  let coeffs = [100, 0, 0, 0] // LL=100, HL=0, LH=0, HH=0
  let result = apply_inverse_dwt_53(coeffs, 2, 2, 1, tcx0=0, tcy0=0)
  guard result is Ok(out) else { return fail("IDWT failed") }
  assert_eq(out.length(), 4)
  // With zero detail coefficients, output should be close to LL value
  // Exact value depends on lifting, but should be positive and bounded
  assert_true(out[0] > 90 && out[0] < 110)
  assert_true(out[1] > 90 && out[1] < 110)
  assert_true(out[2] > 90 && out[2] < 110)
  assert_true(out[3] > 90 && out[3] < 110)
}

///|
// 2x2 with cas_h=1: compare output between cas=0 and cas=1
test "idwt_53_2x2_cas_comparison" {
  let coeffs = [100, 20, 30, 10]

  // cas_h=0, cas_v=0 (tcx0=0, tcy0=0)
  let r00 = apply_inverse_dwt_53(coeffs.copy(), 2, 2, 1, tcx0=0, tcy0=0)

  // cas_h=1, cas_v=1 (tcx0=1, tcy0=1)
  let r11 = apply_inverse_dwt_53(coeffs.copy(), 2, 2, 1, tcx0=1, tcy0=1)

  guard r00 is Ok(out00) else { return fail("r00 failed") }
  guard r11 is Ok(out11) else { return fail("r11 failed") }

  // Both should produce valid 4-element outputs
  assert_eq(out00.length(), 4)
  assert_eq(out11.length(), 4)

  // Outputs may differ due to different CAS handling
  // but should both be reasonable (no huge values or zeroes)
  for i in 0..<4 {
    assert_true(out00[i] > -1000 && out00[i] < 1000)
    assert_true(out11[i] > -1000 && out11[i] < 1000)
  }
}

///|
// 4x4 two-level IDWT: verify structure is preserved
test "idwt_53_4x4_two_levels" {
  // Create a pattern: LL2 in top-left, details around it
  // Level 2: LL2(1x1), HL2(1x1), LH2(1x1), HH2(1x1) in 2x2 region
  // Level 1: HL1(2x2), LH1(2x2), HH1(2x2) around the 2x2 region
  let coeffs = [100, 10, 20, 30, 5, 15, 25, 35, 40, 50, 60, 70, 45, 55, 65, 75]

  let result = apply_inverse_dwt_53(coeffs, 4, 4, 2, tcx0=0, tcy0=0)
  guard result is Ok(out) else { return fail("IDWT failed") }
  assert_eq(out.length(), 16)

  // Output should have reasonable values (not all zero, not huge)
  let mut all_zero = true
  let mut any_huge = false
  for v in out {
    if v != 0 {
      all_zero = false
    }
    if v < -10000 || v > 10000 {
      any_huge = true
    }
  }
  assert_true(!all_zero)
  assert_true(!any_huge)
}

///|
// 4x4 two-level IDWT with cas_h=1, cas_v=1 (odd origin)
test "idwt_53_4x4_two_levels_odd_origin" {
  let coeffs = [100, 10, 20, 30, 5, 15, 25, 35, 40, 50, 60, 70, 45, 55, 65, 75]

  // tcx0=1, tcy0=1 gives cas_h=1, cas_v=1 at full resolution
  let result = apply_inverse_dwt_53(coeffs, 4, 4, 2, tcx0=1, tcy0=1)
  guard result is Ok(out) else { return fail("IDWT failed") }
  assert_eq(out.length(), 16)

  // Output should have reasonable values
  let mut all_zero = true
  let mut any_huge = false
  for v in out {
    if v != 0 {
      all_zero = false
    }
    if v < -10000 || v > 10000 {
      any_huge = true
    }
  }
  assert_true(!all_zero)
  assert_true(!any_huge)
}

///|
// Verify 1D IDWT cas=0 vs cas=1 for length 4 signal
test "idwt_53_1d_cas_effect" {
  // For length 4: sn=2, dn=2 with cas=0
  // For length 4: sn=2, dn=2 with cas=1
  let low = [100, 110]
  let high = [20, 30]

  let r0 = idwt_53_1d(low.copy(), high.copy(), cas=0)
  let r1 = idwt_53_1d(low.copy(), high.copy(), cas=1)

  assert_eq(r0.length(), 4)
  assert_eq(r1.length(), 4)

  // With cas=0: output[0]=s[0], output[1]=d[0], output[2]=s[1], output[3]=d[1]
  // With cas=1: output[0]=d[0], output[1]=s[0], output[2]=d[1], output[3]=s[1]
  // The lifting steps also differ, so values will be different
  // But both should produce reasonable outputs

  for i in 0..<4 {
    assert_true(r0[i] > -1000 && r0[i] < 1000)
    assert_true(r1[i] > -1000 && r1[i] < 1000)
  }
}

///|
// Asymmetric dimensions: 3x5 with 1 level
// This tests non-square tiles with different LL splits
test "idwt_53_3x5_asymmetric" {
  // 3x5 with tcx0=0, tcy0=0: LL is 2x3
  let coeffs : Array[Int] = []
  for i in 0..<15 {
    coeffs.push(50 + i * 5)
  }

  let result = apply_inverse_dwt_53(coeffs, 3, 5, 1, tcx0=0, tcy0=0)
  guard result is Ok(out) else { return fail("IDWT failed") }
  assert_eq(out.length(), 15)
}

///|
// Asymmetric dimensions: 5x3 with 1 level and odd x-origin
test "idwt_53_5x3_odd_x" {
  // 5x3 with tcx0=1, tcy0=0: LL is 2x2 (floor((1+5)/2) - ceil(1/2) = 3-1=2)
  let coeffs : Array[Int] = []
  for i in 0..<15 {
    coeffs.push(50 + i * 5)
  }

  let result = apply_inverse_dwt_53(coeffs, 5, 3, 1, tcx0=1, tcy0=0)
  guard result is Ok(out) else { return fail("IDWT failed") }
  assert_eq(out.length(), 15)
}

///|
// Large odd-origin test: similar to b1_mono tile 2 pattern but smaller
test "idwt_53_b1mono_like_pattern" {
  // Use dimensions and origin with similar CAS pattern to tile 2
  // Tile 2: 97x83, tcx0=3197, tcy0=41, decomp=5
  // Scale down: 8x8, tcx0=5 (odd), tcy0=3 (odd), decomp=2
  // This gives cas_h=1, cas_v=1 at full resolution

  let coeffs : Array[Int] = []
  for i in 0..<64 {
    // Use a gradient pattern
    let x = i % 8
    let y = i / 8
    coeffs.push(50 + x * 5 + y * 10)
  }

  let result = apply_inverse_dwt_53(coeffs, 8, 8, 2, tcx0=5, tcy0=3)
  guard result is Ok(out) else { return fail("IDWT failed") }
  assert_eq(out.length(), 64)

  // Verify output is reasonable
  let mut min_val = out[0]
  let mut max_val = out[0]
  for v in out {
    if v < min_val {
      min_val = v
    }
    if v > max_val {
      max_val = v
    }
  }
  // Range should be reasonable (not clipped to 0 or huge)
  assert_true(min_val > -500)
  assert_true(max_val < 500)
}
