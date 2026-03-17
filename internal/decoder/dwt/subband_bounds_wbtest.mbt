///|
// Tests for @subband.subband_bounds function per T.800-2015 B.5 Eq. B-15

///|
// T.800-2015 B.5 Eq. B-15: LL subband bounds (xob=0, yob=0)
// tbx0 = ceil(tcx0 / 2^nb), tby0 = ceil(tcy0 / 2^nb)
// tbx1 = ceil(tcx1 / 2^nb), tby1 = ceil(tcy1 / 2^nb)
test "@subband.subband_bounds_ll_basic" {
  // Tile at origin, 64x64, nb=2
  // tcx0=0, tcy0=0, tcx1=64, tcy1=64, nb=2
  // tbx0 = ceil(0/4) = 0, tbx1 = ceil(64/4) = 16
  let (tbx0, tby0, tbx1, tby1) = @subband.subband_bounds(0, 0, 64, 64, 2, 0)
  assert_eq(tbx0, 0)
  assert_eq(tby0, 0)
  assert_eq(tbx1, 16)
  assert_eq(tby1, 16)
}

///|
// T.800-2015 B.5 Eq. B-15: HL subband bounds (xob=1, yob=0)
// tbx0 = ceil((tcx0 - 2^(nb-1)) / 2^nb)
test "@subband.subband_bounds_hl_basic" {
  // Tile at origin, 64x64, nb=2
  // tcx0=0, xob=1: tbx0 = ceil((0 - 2) / 4) = ceil(-0.5) = 0
  // tcx1=64, xob=1: tbx1 = ceil((64 - 2) / 4) = ceil(15.5) = 16
  let (tbx0, tby0, tbx1, tby1) = @subband.subband_bounds(0, 0, 64, 64, 2, 1)
  assert_eq(tbx0, 0)
  assert_eq(tby0, 0)
  assert_eq(tbx1, 16)
  assert_eq(tby1, 16)
}

///|
// T.800-2015 B.5 Eq. B-15: Non-zero tile origin
// b1_mono tile (0,0): tcx0=3097, tcy0=41, tcx1=3100, tcy1=124
test "@subband.subband_bounds_b1_mono_tile00_ll" {
  // LL at nb=5: ceil(tcx0/32), ceil(tcy0/32), ceil(tcx1/32), ceil(tcy1/32)
  // = ceil(3097/32), ceil(41/32), ceil(3100/32), ceil(124/32)
  // = 97, 2, 97, 4 → width=0, height=2
  let (tbx0, tby0, tbx1, tby1) = @subband.subband_bounds(
    3097, 41, 3100, 124, 5, 0,
  )
  assert_eq(tbx0, 97)
  assert_eq(tby0, 2)
  assert_eq(tbx1, 97)
  assert_eq(tby1, 4)
  assert_eq(tbx1 - tbx0, 0) // Zero width!
  assert_eq(tby1 - tby0, 2)
}

///|
// T.800-2015 B.5 Eq. B-15: HL subband for b1_mono tile (0,0) at nb=5
// tbx0 = ceil((3097 - 16) / 32) = ceil(3081/32) = 97
// tbx1 = ceil((3100 - 16) / 32) = ceil(3084/32) = 97
// Zero width HL as well
test "@subband.subband_bounds_b1_mono_tile00_hl_nb5" {
  let (tbx0, tby0, tbx1, tby1) = @subband.subband_bounds(
    3097, 41, 3100, 124, 5, 1,
  )
  assert_eq(tbx1 - tbx0, 0) // Zero width
}

///|
// T.800-2015 B.5 Eq. B-15: HL subband for b1_mono tile (0,0) at nb=1
// This is the highest detail level, should have non-zero width
test "@subband.subband_bounds_b1_mono_tile00_hl_nb1" {
  // HL at nb=1: xob=1
  // tbx0 = ceil((3097 - 1) / 2) = ceil(3096/2) = 1548
  // tbx1 = ceil((3100 - 1) / 2) = ceil(3099/2) = 1550
  // Width = 2
  let (tbx0, tby0, tbx1, tby1) = @subband.subband_bounds(
    3097, 41, 3100, 124, 1, 1,
  )
  assert_eq(tbx0, 1548)
  assert_eq(tbx1, 1550)
  assert_eq(tbx1 - tbx0, 2) // Non-zero width
}

///|
// Verify that LL bounds at nb=N match resolution bounds at r=0 (deepest level)
// per T.800-2015 B.5 relationship between Eq. B-14 and B-15
test "@subband.subband_bounds_ll_matches_resolution" {
  // For LL (xob=0, yob=0), the formula becomes:
  // tbx0 = ceil(tcx0 / 2^nb), same as trx0 from Eq. B-14
  let tcx0 = 100
  let tcy0 = 50
  let tcx1 = 200
  let tcy1 = 150
  let nb = 3

  let (ll_x0, ll_y0, ll_x1, ll_y1) = @subband.subband_bounds(
    tcx0, tcy0, tcx1, tcy1, nb, 0,
  )

  // Manually compute B-14: trx0 = ceil(tcx0 / 2^nb)
  let divisor = 1 << nb // 8
  let trx0 = (tcx0 + divisor - 1) / divisor // ceil(100/8) = 13
  let try0 = (tcy0 + divisor - 1) / divisor // ceil(50/8) = 7
  let trx1 = (tcx1 + divisor - 1) / divisor // ceil(200/8) = 25
  let try1 = (tcy1 + divisor - 1) / divisor // ceil(150/8) = 19

  assert_eq(ll_x0, trx0)
  assert_eq(ll_y0, try0)
  assert_eq(ll_x1, trx1)
  assert_eq(ll_y1, try1)
}
