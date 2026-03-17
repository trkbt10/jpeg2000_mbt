///|
// Tests for T.800-2015 F.3.7 PSEO (Periodic Symmetric Extension Operation)
// Using exact spec formula F-4:
// PSEO(i, i0, i1) = i0 + min(mod(i - i0, P), P - mod(i - i0, P))
// where P = 2*(i1 - i0) - 1
//
// This creates whole-sample symmetric extension where boundary elements
// are repeated at the reflection points.

///|
// T.800-2015 F.3.7 Eq. F-4: Basic PSEO with even i0
// Signal: [a, b, c] at indices [0, 3), P = 2*3 - 1 = 5
// Pattern: ... 2 1 [0 1 2] 2 1 0 1 2 2 ...
// Note: Boundary elements (0 and 2) are repeated at reflections
test "pseo_even_origin_basic" {
  // Signal from i0=0 to i1=3 (indices 0, 1, 2)
  // Period = 2*3 - 1 = 5, Pattern per period: [0 1 2 2 1]

  // Within bounds
  assert_eq(pseo(0, 0, 3), 0)
  assert_eq(pseo(1, 0, 3), 1)
  assert_eq(pseo(2, 0, 3), 2)

  // Right extension (whole-sample symmetric - boundary element 2 is repeated)
  // pos 3: min(3, 5-3) = min(3, 2) = 2
  // pos 4: min(4, 5-4) = min(4, 1) = 1
  // pos 5: min(0, 5-0) = min(0, 5) = 0 (new period)
  // pos 6: min(1, 5-1) = min(1, 4) = 1
  assert_eq(pseo(3, 0, 3), 2) // boundary repeated
  assert_eq(pseo(4, 0, 3), 1)
  assert_eq(pseo(5, 0, 3), 0) // new period
  assert_eq(pseo(6, 0, 3), 1)

  // Left extension
  // pos -1: mod(-1, 5) = 4, min(4, 1) = 1
  // pos -2: mod(-2, 5) = 3, min(3, 2) = 2
  // pos -3: mod(-3, 5) = 2, min(2, 3) = 2
  assert_eq(pseo(-1, 0, 3), 1)
  assert_eq(pseo(-2, 0, 3), 2)
  assert_eq(pseo(-3, 0, 3), 2)
}

///|
// T.800-2015 F.3.7: PSEO with odd i0
// Signal starts at odd index
test "pseo_odd_origin" {
  // Signal from i0=1 to i1=4 (indices 1, 2, 3), length 3
  // Period = 2*3 - 1 = 5, Pattern: [1 2 3 3 2] in absolute indices

  // Within bounds
  assert_eq(pseo(1, 1, 4), 1)
  assert_eq(pseo(2, 1, 4), 2)
  assert_eq(pseo(3, 1, 4), 3)

  // Right extension
  // pos 4: offset=3, min(3, 2) = 2, result = 1 + 2 = 3
  // pos 5: offset=4, min(4, 1) = 1, result = 1 + 1 = 2
  assert_eq(pseo(4, 1, 4), 3) // boundary repeated
  assert_eq(pseo(5, 1, 4), 2)

  // Left extension
  // pos 0: offset=-1, mod(-1, 5) = 4, min(4, 1) = 1, result = 1 + 1 = 2
  // pos -1: offset=-2, mod(-2, 5) = 3, min(3, 2) = 2, result = 1 + 2 = 3
  assert_eq(pseo(0, 1, 4), 2)
  assert_eq(pseo(-1, 1, 4), 3)
}

///|
// T.800-2015 F.3.7: PSEO with length 2 signal
test "pseo_length_2" {
  // Signal from i0=0 to i1=2 (indices 0, 1), length 2
  // Period = 2*2 - 1 = 3, Pattern: [0 1 1]

  assert_eq(pseo(0, 0, 2), 0)
  assert_eq(pseo(1, 0, 2), 1)
  // pos 2: offset=2, min(2, 1) = 1
  assert_eq(pseo(2, 0, 2), 1) // boundary repeated
  // pos 3: offset=3, mod(3, 3) = 0, min(0, 3) = 0
  assert_eq(pseo(3, 0, 2), 0) // new period
  // pos -1: mod(-1, 3) = 2, min(2, 1) = 1
  assert_eq(pseo(-1, 0, 2), 1)
}

///|
// T.800-2015 F.3.7: PSEO with length 1 signal
test "pseo_length_1" {
  // Signal from i0=0 to i1=1 (only index 0)
  // All accesses should return 0

  assert_eq(pseo(0, 0, 1), 0)
  assert_eq(pseo(1, 0, 1), 0)
  assert_eq(pseo(-1, 0, 1), 0)
  assert_eq(pseo(5, 0, 1), 0)
}

///|
// T.800-2015 F.3.7 Table F.2: Left extension for 5-3 filter
test "ileft_53_table_f2" {
  // i0 even: ileft = 1
  assert_eq(ileft_53(0), 1)
  assert_eq(ileft_53(2), 1)
  assert_eq(ileft_53(100), 1)

  // i0 odd: ileft = 2
  assert_eq(ileft_53(1), 2)
  assert_eq(ileft_53(3), 2)
  assert_eq(ileft_53(101), 2)
}

///|
// T.800-2015 F.3.7 Table F.3: Right extension for 5-3 filter
test "iright_53_table_f3" {
  // i1 odd: iright = 1
  assert_eq(iright_53(1), 1)
  assert_eq(iright_53(3), 1)
  assert_eq(iright_53(101), 1)

  // i1 even: iright = 2
  assert_eq(iright_53(0), 2)
  assert_eq(iright_53(2), 2)
  assert_eq(iright_53(100), 2)
}

///|
// T.800-2015 F.3.7: extend_signal function
test "extend_signal_basic" {
  let signal = [10, 20, 30]

  // Within bounds
  assert_eq(extend_signal(signal, 0, 0, 3), 10)
  assert_eq(extend_signal(signal, 1, 0, 3), 20)
  assert_eq(extend_signal(signal, 2, 0, 3), 30)

  // Extended (using PSEO with whole-sample symmetric)
  // pos 3: pseo(3,0,3) = 2, signal[2] = 30
  assert_eq(extend_signal(signal, 3, 0, 3), 30) // boundary repeated
  // pos -1: pseo(-1,0,3) = 1, signal[1] = 20
  assert_eq(extend_signal(signal, -1, 0, 3), 20)
}

///|
// Specific test for b1_mono tile 2 boundary scenario
// Tile 2: i0=3197 (odd), need to verify PSEO at this origin
test "pseo_b1mono_tile2_like" {
  // Simulate small signal with odd origin like tile 2
  // i0=5 (odd), length=4, i1=9
  // Period = 2*4 - 1 = 7, Pattern: [5 6 7 8 8 7 6]
  let i0 = 5
  let i1 = 9

  // Within bounds
  assert_eq(pseo(5, i0, i1), 5)
  assert_eq(pseo(6, i0, i1), 6)
  assert_eq(pseo(7, i0, i1), 7)
  assert_eq(pseo(8, i0, i1), 8)

  // Right extension (whole-sample symmetric)
  // pos 9: offset=4, min(4, 3) = 3, result = 5 + 3 = 8
  // pos 10: offset=5, min(5, 2) = 2, result = 5 + 2 = 7
  // pos 11: offset=6, min(6, 1) = 1, result = 5 + 1 = 6
  assert_eq(pseo(9, i0, i1), 8) // boundary repeated
  assert_eq(pseo(10, i0, i1), 7)
  assert_eq(pseo(11, i0, i1), 6)

  // Left extension
  // pos 4: offset=-1, mod(-1, 7) = 6, min(6, 1) = 1, result = 5 + 1 = 6
  // pos 3: offset=-2, mod(-2, 7) = 5, min(5, 2) = 2, result = 5 + 2 = 7
  // pos 2: offset=-3, mod(-3, 7) = 4, min(4, 3) = 3, result = 5 + 3 = 8
  assert_eq(pseo(4, i0, i1), 6)
  assert_eq(pseo(3, i0, i1), 7)
  assert_eq(pseo(2, i0, i1), 8)
}
