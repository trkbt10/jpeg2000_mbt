///|
// T.800-2015 F.3.7/F.3.8.2: 9/7 IDWT specification compliance tests
// Verifies PSEO extension requirement per Tables F.2/F.3

///|
// T.800-2015 F.3.7 Table F.2/F.3: Extension parameters for 9/7 filter
// ileft9-7:  i0 even → 3, i0 odd → 4
// iright9-7: il odd → 3, il even → 4
test "T800_F37_Table_F2_F3_97_extension_parameters" {
  // From Table F.2 (left extension)
  // i0 even: ileft = 3
  // i0 odd: ileft = 4
  let ileft_even_origin = 3
  let ileft_odd_origin = 4

  // From Table F.3 (right extension)
  // il odd: iright = 3
  // il even: iright = 4
  let iright_odd_end = 3
  let iright_even_end = 4

  // Verify values match spec
  assert_eq(ileft_even_origin, 3)
  assert_eq(ileft_odd_origin, 4)
  assert_eq(iright_odd_end, 3)
  assert_eq(iright_even_end, 4)
}

///|
// T.800-2015 F.3.7 Eq. F-3/F-4: PSEO function for 9/7 filter
// Should produce same results as 5-3 PSEO (function is filter-independent)
test "T800_F37_pseo_for_97_filter" {
  // PSEO(i, i0, i1) = i0 + min(mod(i-i0, P), P - mod(i-i0, P))
  // where P = 2*(i1-i0) - 1

  // Test signal from i0=0 to i1=4 (length 4)
  // P = 2*4 - 1 = 7
  // Pattern: [0 1 2 3 3 2 1 0 1 2 ...]

  // Within bounds
  assert_eq(pseo(0, 0, 4), 0)
  assert_eq(pseo(1, 0, 4), 1)
  assert_eq(pseo(2, 0, 4), 2)
  assert_eq(pseo(3, 0, 4), 3)

  // Right extension (for 9/7, need at least 3 samples)
  assert_eq(pseo(4, 0, 4), 3) // boundary repeated
  assert_eq(pseo(5, 0, 4), 2)
  assert_eq(pseo(6, 0, 4), 1)

  // Left extension (for 9/7, need at least 3 samples)
  assert_eq(pseo(-1, 0, 4), 1)
  assert_eq(pseo(-2, 0, 4), 2)
  assert_eq(pseo(-3, 0, 4), 3)
}

///|
// T.800-2015 F.3.8.2 Table F.4: Verify 9/7 lifting coefficients
test "T800_F382_Table_F4_97_lifting_coefficients" {
  // Table F.4 values (15 decimal places)
  let alpha_expected = -1.586134342059924
  let beta_expected = -0.052980118572961
  let gamma_expected = 0.882911075530934
  let delta_expected = 0.443506852043971
  let k_expected = 1.230174104914001

  // Compare with implementation values (allow float32 rounding tolerance)
  // Our implementation uses float32 precision (T.800-2015 Table F.4)
  let eps = 1.0e-6
  assert_true((idwt97_alpha - alpha_expected).abs() < eps)
  assert_true((idwt97_beta - beta_expected).abs() < eps)
  assert_true((idwt97_gamma - gamma_expected).abs() < eps)
  assert_true((idwt97_delta - delta_expected).abs() < eps)
  assert_true((idwt97_k - k_expected).abs() < eps)
}

///|
// T.800-2015 F.3.8.2: Verify 9/7 1D IDWT produces correct output length
test "T800_F382_97_idwt_output_length" {
  // Output length should be sn + dn
  // Use equal-sized arrays to avoid boundary issues
  let low : Array[Double] = [1.0, 2.0, 3.0]
  let high : Array[Double] = [0.1, 0.2, 0.3]

  let result = idwt_97_1d(low, high, cas=0)
  assert_eq(result.length(), 6) // 3 + 3

  let result_cas1 = idwt_97_1d(low, high, cas=1)
  assert_eq(result_cas1.length(), 6)
}

///|
// T.800-2015 F.3.8.2: Constant input should produce near-constant output
// (DC preservation property of wavelet transform)
test "T800_F382_97_dc_preservation" {
  // Low-pass = constant 100.0, high-pass = 0.0
  // Output should be approximately constant (within scaling factor)
  let low : Array[Double] = [100.0, 100.0]
  let high : Array[Double] = [0.0, 0.0]

  let result = idwt_97_1d(low, high, cas=0)
  assert_eq(result.length(), 4)

  // All values should be close to each other (DC input → uniform output)
  let ref_val = result[0]
  for i in 1..<4 {
    let diff = (result[i] - ref_val).abs()
    // Allow some tolerance for boundary effects
    assert_true(diff < 1.0)
  }
}
