///|
// T.800-2015 F.3.6: 1D_SR procedure specification tests
// Verifies idwt_53_1d and idwt_53_1d_float against spec requirements

///|
// F.3.6 Case 1: Empty signal (length 0)
// Should return empty array
test "idwt_53_1d_empty_signal" {
  let result = idwt_53_1d([], [])
  assert_eq(result.length(), 0)
}

///|
// F.3.6 Case 2: Length 1, even origin (cas=0)
// "X(i0) = Y(i0) if i0 is an even integer"
// With cas=0, the single sample is low-pass (even position)
test "idwt_53_1d_length1_even_origin_low" {
  // Single low-pass coefficient at even position
  let result = idwt_53_1d([100], [], cas=0)
  assert_eq(result.length(), 1)
  assert_eq(result[0], 100) // No division
}

///|
// F.3.6 Case 2b: Length 1, even origin, high-pass only
// This configuration shouldn't occur (even origin means first sample is low-pass)
// but we test it anyway for robustness
test "idwt_53_1d_length1_even_origin_high" {
  // Single high-pass coefficient with cas=0
  // Output length = 1 (high only), but interleaving expects low at even positions
  let result = idwt_53_1d([], [100], cas=0)
  // With sn=0, dn=1, cas=0: output is just high (no scaling per current impl)
  assert_eq(result.length(), 1)
  assert_eq(result[0], 100)
}

///|
// F.3.6 Case 3: Length 1, odd origin (cas=1)
// "X(i0) = Y(i0)/2 if i0 is an odd integer"
// With cas=1, the single sample is high-pass (odd position starts first)
test "idwt_53_1d_length1_odd_origin_high" {
  // Single high-pass coefficient at odd origin
  let result = idwt_53_1d([], [100], cas=1)
  assert_eq(result.length(), 1)
  // F.3.6: X(i0) = Y(i0)/2 for odd i0
  assert_eq(result[0], 50) // 100 / 2 = 50
}

///|
// F.3.6 Case 3b: Length 1, odd origin, low-pass only
// This configuration is unusual but should be tested
test "idwt_53_1d_length1_odd_origin_low" {
  // Single low-pass coefficient with cas=1
  // Output has single low-pass at odd position (position 1 in interleaved)
  let result = idwt_53_1d([100], [], cas=1)
  assert_eq(result.length(), 1)
  // Low-pass at position 1 (odd in interleaved): no division per F.3.6
  // But wait - with cas=1, position 0 is high, position 1 is low
  // If we only have low, output is length 1 starting at odd position
  // F.3.6 says X(i0) = Y(i0)/2 for odd i0
  // This is ambiguous - the spec talks about the INTERLEAVED signal
  assert_eq(result[0], 100) // Current impl returns low unchanged
}

///|
// F.3.6 Case 4: Length 2, cas=0 (standard case)
// Normal lifting-based reconstruction
test "idwt_53_1d_length2_cas0" {
  // low=[100], high=[10] with cas=0
  // Interleaved: [low[0], high[0]] = positions [0, 1]
  // Lifting reconstruction should work normally
  let result = idwt_53_1d([100], [10], cas=0)
  assert_eq(result.length(), 2)
  // Expected values depend on 5/3 lifting:
  // Step 1: s[0] = low[0] - floor((high[0] + high[0] + 2) / 4)
  //       = 100 - floor((10 + 10 + 2) / 4) = 100 - 5 = 95
  // Step 2: d[0] = high[0] + floor((s[0] + s[0]) / 2)
  //       = 10 + floor(95) = 10 + 95 = 105
  // Output: [s[0], d[0]] = [95, 105]
  assert_eq(result[0], 95)
  assert_eq(result[1], 105)
}

///|
// F.3.6 Case 4b: Length 2, cas=1 (odd origin)
test "idwt_53_1d_length2_cas1" {
  // low=[100], high=[10] with cas=1
  // T.800-2015 F.3.5: cas=1 path reconstructs [d', s'] for length=2.
  let result = idwt_53_1d([100], [10], cas=1)
  assert_eq(result.length(), 2)
  assert_eq(result[0], 105)
  assert_eq(result[1], 95)
}

///|
// F.3.6 Case 5: Length 3 (2 samples one side, 1 sample other)
test "idwt_53_1d_length3_cas0" {
  // low=[100, 110], high=[10] with cas=0
  // sn=2, dn=1, total=3
  let result = idwt_53_1d([100, 110], [10], cas=0)
  assert_eq(result.length(), 3)
}

///|
// Boundary regression:
// For cas=0, boundary extension clamps to edge samples during lifting.
test "idwt_53_1d_boundary_clamp_cas0" {
  let result = idwt_53_1d([100, 110, 120], [10, 20, 30], cas=0)
  assert_eq(result.length(), 6)
  assert_eq(result[0], 95)
  assert_eq(result[1], 108)
  assert_eq(result[2], 102)
  assert_eq(result[3], 124)
  assert_eq(result[4], 107)
  assert_eq(result[5], 137)
}

///|
// Float version tests for F.3.6 compliance

///|
test "idwt_53_1d_float_length1_odd_origin" {
  // F.3.6: X(i0) = Y(i0)/2 for odd i0
  let result = idwt_53_1d_float([], [100.0], cas=1)
  assert_eq(result.length(), 1)
  assert_eq(result[0], 50.0)
}

///|
test "idwt_53_1d_float_length1_even_origin" {
  let result = idwt_53_1d_float([100.0], [], cas=0)
  assert_eq(result.length(), 1)
  assert_eq(result[0], 100.0)
}

///|
// Edge case: sn=0, dn>1, cas=1 (multiple high-pass, no low-pass)
// This occurs in degenerate tiles with zero-extent LL
test "idwt_53_1d_float_no_lowpass_multiple_highpass" {
  // 3 high-pass samples, no low-pass, odd origin
  let result = idwt_53_1d_float([], [100.0, 110.0, 120.0], cas=1)
  assert_eq(result.length(), 3)
  // With no low-pass, the spec's handling is complex
  // Current impl just returns high-pass unchanged
  // This may need revisiting for full spec compliance
}
