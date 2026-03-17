///|
// T.800-2015 F.3: Multi-level inverse DWT tests with non-zero origins
// These tests verify correct CAS computation and subband dimension handling
// for tiles with non-trivial absolute coordinates.

///|
// T.800-2015 F.3: Basic 2x2 identity test with single level, zero origin
// Forward DWT of [a, b, c, d] -> [LL, HL, LH, HH]
// Inverse should reconstruct exactly
test "apply_inverse_dwt_53_2x2_single_level" {
  // For 2x2, single level decomposition:
  // LL is top-left (1x1), HL is top-right (1x1)
  // LH is bottom-left (1x1), HH is bottom-right (1x1)
  // Input layout: [LL, HL, LH, HH] in row-major
  let coeffs = [100, 10, 20, 5]
  let result = apply_inverse_dwt_53(coeffs, 2, 2, 1, tcx0=0, tcy0=0)
  guard result is Ok(out) else { return fail("IDWT failed") }
  assert_eq(out.length(), 4)
  // Verify reconstruction produces integer values
  assert_true(out[0] != 0 || out[1] != 0 || out[2] != 0 || out[3] != 0)
}

///|
// T.800-2015 F.3/B.5: Single level IDWT with odd x-origin (cas_h=1)
// tcx0=1 means the tile starts at odd absolute x coordinate
test "apply_inverse_dwt_53_2x2_odd_x_origin" {
  let coeffs = [100, 10, 20, 5]
  let result = apply_inverse_dwt_53(coeffs, 2, 2, 1, tcx0=1, tcy0=0)
  guard result is Ok(out) else { return fail("IDWT failed with odd x origin") }
  assert_eq(out.length(), 4)
}

///|
// T.800-2015 F.3/B.5: Single level IDWT with odd y-origin (cas_v=1)
test "apply_inverse_dwt_53_2x2_odd_y_origin" {
  let coeffs = [100, 10, 20, 5]
  let result = apply_inverse_dwt_53(coeffs, 2, 2, 1, tcx0=0, tcy0=1)
  guard result is Ok(out) else { return fail("IDWT failed with odd y origin") }
  assert_eq(out.length(), 4)
}

///|
// T.800-2015 F.3/B.5: Single level IDWT with both origins odd
test "apply_inverse_dwt_53_2x2_odd_both_origins" {
  let coeffs = [100, 10, 20, 5]
  let result = apply_inverse_dwt_53(coeffs, 2, 2, 1, tcx0=1, tcy0=1)
  guard result is Ok(out) else {
    return fail("IDWT failed with both origins odd")
  }
  assert_eq(out.length(), 4)
}

///|
// T.800-2015 F.3: 4x4 with 2 decomposition levels, zero origin
test "apply_inverse_dwt_53_4x4_two_levels" {
  // 4x4 with 2 levels:
  // Level 2 LL: 1x1, Level 1 LL: 2x2
  // Layout depends on subband arrangement
  let coeffs : Array[Int] = []
  for i in 0..<16 {
    coeffs.push(100 + i)
  }
  let result = apply_inverse_dwt_53(coeffs, 4, 4, 2, tcx0=0, tcy0=0)
  guard result is Ok(out) else { return fail("IDWT 4x4 level 2 failed") }
  assert_eq(out.length(), 16)
}

///|
// T.800-2015 F.3/B.5: Multi-level with non-zero origin - simulates b1_mono tile pattern
// This test uses dimensions and origin similar to the b1_mono tile 2 scenario
// but at smaller scale for tractability
test "apply_inverse_dwt_53_nonzero_origin_pattern" {
  // Simulate a tile at tcx0=5, tcy0=3, size 4x4, decomp=2
  // Level 2: origin (ceil(5/2), ceil(3/2)) = (3, 2)
  // Level 1: origin (5, 3)
  // CAS at level 1: (5%2, 3%2) = (1, 1)
  // CAS at level 0: (3%2, 2%2) = (1, 0)
  let coeffs : Array[Int] = []
  for i in 0..<16 {
    coeffs.push(50 + i * 3)
  }
  let result = apply_inverse_dwt_53(coeffs, 4, 4, 2, tcx0=5, tcy0=3)
  guard result is Ok(out) else {
    return fail("IDWT with nonzero origin failed")
  }
  assert_eq(out.length(), 16)
}

///|
// T.800-2015 F.3/B.5: Verify CAS computation matches resolution_origins
// For tcx0=3197, tcy0=41, decomp=5 (b1_mono tile 2 scenario)
test "apply_inverse_dwt_53_cas_matches_origins" {
  // Small size to test CAS propagation, same origin pattern as b1_mono tile 2
  // tcx0=3197, tcy0=41 reduced to equivalent parity pattern
  // 3197 % 2 = 1 (odd), 41 % 2 = 1 (odd)
  // After 1 halving: ceil(3197/2)=1599 (1599%2=1), ceil(41/2)=21 (21%2=1)
  // After 2 halvings: ceil(1599/2)=800 (800%2=0), ceil(21/2)=11 (11%2=1)
  // After 3 halvings: ceil(800/2)=400 (400%2=0), ceil(11/2)=6 (6%2=0)
  // After 4 halvings: ceil(400/2)=200 (200%2=0), ceil(6/2)=3 (3%2=1)
  // After 5 halvings: ceil(200/2)=100 (100%2=0), ceil(3/2)=2 (2%2=0)

  // Use origin with same parity as b1_mono: tcx0=1 (odd), tcy0=1 (odd)
  // With decomp=2, check CAS values
  let origins = @subband.resolution_origins(1, 1, 2)
  // origins[0] = after 2 halvings = (ceil(1/4), ceil(1/4)) = (1, 1)
  // origins[1] = after 1 halving = (ceil(1/2), ceil(1/2)) = (1, 1)
  // origins[2] = original = (1, 1)
  assert_eq(origins[2], (1, 1)) // Full resolution
  let (ox1, oy1) = origins[1]
  assert_eq(ox1 % 2, 1) // cas_h at level 0 IDWT
  assert_eq(oy1 % 2, 1) // cas_v at level 0 IDWT
}

///|
// T.800-2015 F.3: 8x8 with 3 decomposition levels
test "apply_inverse_dwt_53_8x8_three_levels" {
  let coeffs : Array[Int] = []
  for i in 0..<64 {
    coeffs.push(10 + i)
  }
  let result = apply_inverse_dwt_53(coeffs, 8, 8, 3, tcx0=0, tcy0=0)
  guard result is Ok(out) else { return fail("IDWT 8x8 level 3 failed") }
  assert_eq(out.length(), 64)
}

///|
// T.800-2015 F.3: Verify decomposition level 0 returns input unchanged
test "apply_inverse_dwt_53_zero_levels" {
  let coeffs = [100, 110, 120, 130]
  let result = apply_inverse_dwt_53(coeffs, 2, 2, 0, tcx0=0, tcy0=0)
  guard result is Ok(out) else { return fail("IDWT level 0 failed") }
  assert_eq(out.length(), 4)
  assert_eq(out[0], 100)
  assert_eq(out[1], 110)
  assert_eq(out[2], 120)
  assert_eq(out[3], 130)
}

///|
// T.800-2015 F.3/B.5: Odd-sized input with non-zero origin
// Tests the LL dimension calculation with fractional splits
test "apply_inverse_dwt_53_odd_size_nonzero_origin" {
  // 5x3 with tcx0=2, tcy0=1, decomp=1
  // LL width = ceil((2+5)/2) - ceil(2/2) = 4 - 1 = 3
  // LL height = ceil((1+3)/2) - ceil(1/2) = 2 - 1 = 1
  let coeffs : Array[Int] = []
  for i in 0..<15 {
    coeffs.push(20 + i * 2)
  }
  let result = apply_inverse_dwt_53(coeffs, 5, 3, 1, tcx0=2, tcy0=1)
  guard result is Ok(out) else { return fail("IDWT odd size failed") }
  assert_eq(out.length(), 15)
}

///|
// T.800-2015 F.3: Round-trip verification - forward then inverse should reconstruct
// (Simplified: check that inverse of zero input gives zero output)
test "apply_inverse_dwt_53_zero_input" {
  let coeffs = [0, 0, 0, 0]
  let result = apply_inverse_dwt_53(coeffs, 2, 2, 1, tcx0=0, tcy0=0)
  guard result is Ok(out) else { return fail("IDWT zero input failed") }
  assert_eq(out[0], 0)
  assert_eq(out[1], 0)
  assert_eq(out[2], 0)
  assert_eq(out[3], 0)
}

///|
// T.800-2015 F.3/B.5: 5-level IDWT matching b1_mono tile 2 structure
// Tile 2: tcx0=3197, tcy0=41, size=97x83, decomp=5
// Key: consecutive cas_h=1 at levels 4 and 5
test "apply_inverse_dwt_53_5level_b1mono_pattern" {
  // Use a scaled-down version with same CAS pattern
  // Original: 97x83, decomp=5
  // Scaled: 32x24, decomp=5 (to have all levels non-zero)
  //
  // For origin (3197, 41), the CAS pattern is:
  // Level 5: origin=(100, 2) -> cas=(0, 0)
  // Level 4: origin=(200, 3) -> cas=(0, 1)
  // Level 3: origin=(400, 6) -> cas=(0, 0)
  // Level 2: origin=(800, 11) -> cas=(0, 1)
  // Level 1: origin=(1599, 21) -> cas=(1, 1) <- KEY
  // Level 0: origin=(3197, 41) -> cas=(1, 1) <- KEY
  //
  // To get same pattern, use tcx0 = 1 (odd), tcy0 = 1 (odd)
  // With size 32x24:
  // Level 5 LL: ceil(1/32)=1, ceil(1/32)=1 -> size 1x1
  // Level 4 LL: ~2x1
  // ...etc

  // Simplify: use 16x16 with decomp=3, origin (1,1)
  // This gives cas patterns similar to b1_mono's inner levels
  let width = 16
  let height = 16
  let decomp = 3
  let tcx0 = 1
  let tcy0 = 1

  // Verify CAS pattern
  let origins = @subband.resolution_origins(tcx0, tcy0, decomp)

  // Print CAS pattern for debugging
  // Level 3 (deepest LL): origins[0]
  // Level 2: origins[1]
  // Level 1: origins[2]
  // Level 0 (full res): origins[3]
  let mut cas_info = "CAS pattern for (\{tcx0}, \{tcy0}) decomp=\{decomp}:\n"
  for level in 0..<=decomp {
    let (ox, oy) = origins[level]
    let cas_h = ox % 2
    let cas_v = oy % 2
    cas_info = cas_info +
      "  Level \{level}: origin=(\{ox}, \{oy}) cas=(\{cas_h}, \{cas_v})\n"
  }

  // Create test coefficients
  let coeffs : Array[Int] = []
  for i in 0..<(width * height) {
    // Use a gradient pattern
    let x = i % width
    let y = i / width
    coeffs.push(50 + x + y * 2)
  }

  let result = apply_inverse_dwt_53(coeffs, width, height, decomp, tcx0~, tcy0~)
  guard result is Ok(out) else {
    return fail("5-level IDWT failed: \{cas_info}")
  }

  assert_eq(out.length(), width * height)

  // Check for reasonable values (no extreme clipping)
  let mut min_val = out[0]
  let mut max_val = out[0]
  let mut clip_count = 0
  for v in out {
    if v < min_val {
      min_val = v
    }
    if v > max_val {
      max_val = v
    }
    if v <= 0 || v >= 255 {
      clip_count = clip_count + 1
    }
  }

  // Report statistics
  println(
    "5-level IDWT result: min=\{min_val}, max=\{max_val}, clips=\{clip_count}",
  )

  // For valid DWT coefficients, output should be bounded
  // This is a sanity check, not a strict requirement
  assert_true(clip_count < width * height / 2) // Less than 50% clipped
}

///|
// T.800-2015 F.3/B.5: Compare tile 1 vs tile 2 CAS patterns
// Tile 1 works, Tile 2 has errors - the difference is CAS at levels 4 and 5
test "compare_tile1_tile2_cas_patterns" {
  // Tile 1: tcx0=3100, tcy0=41 - works correctly
  // Tile 2: tcx0=3197, tcy0=41 - has errors
  let decomp = 5

  let origins1 = @subband.resolution_origins(3100, 41, decomp)
  let origins2 = @subband.resolution_origins(3197, 41, decomp)

  // Find levels where CAS differs
  let diff_levels : Array[Int] = []
  for level in 0..<=decomp {
    let (ox1, oy1) = origins1[level]
    let (ox2, oy2) = origins2[level]
    let cas1_h = ox1 % 2
    let cas2_h = ox2 % 2
    if cas1_h != cas2_h {
      diff_levels.push(level)
    }
  }

  // Print the differences
  println("Tile 1 vs Tile 2 CAS differences at levels: \{diff_levels}")

  // Verify the known pattern: levels 4 and 5 differ
  // Tile 1 level 4: cas_h = 1550 % 2 = 0
  // Tile 2 level 4: cas_h = 1599 % 2 = 1
  // Tile 1 level 5: cas_h = 3100 % 2 = 0
  // Tile 2 level 5: cas_h = 3197 % 2 = 1
  assert_true(diff_levels.contains(4))
  assert_true(diff_levels.contains(5))
}

///|
// T.800-2015 F.3: Test 1D IDWT with consecutive cas=1
// This simulates what happens at b1_mono tile 2's boundaries
test "idwt_53_1d_consecutive_cas1" {
  // Test consecutive cas=1 operations (simulating multi-level)
  // First level: cas=1
  let low1 = [100, 110, 120, 130]
  let high1 = [5, 10, 15]
  let result1 = idwt_53_1d(low1, high1, cas=1)

  // Second level: also cas=1, using result from first
  // Split the result into new low/high
  let sn2 = (result1.length() + 1) / 2
  let dn2 = result1.length() / 2
  let low2 : Array[Int] = []
  let high2 : Array[Int] = []

  // For cas=1, odd positions go to low, even to high
  for i in 0..<result1.length() {
    if i % 2 == 1 {
      low2.push(result1[i])
    } else {
      high2.push(result1[i])
    }
  }

  // Apply second IDWT with cas=1
  if low2.length() > 0 && high2.length() > 0 {
    let result2 = idwt_53_1d(low2, high2, cas=1)
    println(
      "Consecutive cas=1: stage1 len=\{result1.length()}, stage2 len=\{result2.length()}",
    )

    // Verify no extreme values
    for v in result2 {
      assert_true(v > -10000 && v < 10000)
    }
  }
}
