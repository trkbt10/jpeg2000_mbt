///|
// Tests for T.800-2015 B.5 subband dimension and coordinate functions

// =============================================================================
// T.800-2015 B.5 Eq. B-15: subband_ll_dims tests
// =============================================================================

///|
// T.800-2015 B.5: LL dimensions with zero origin (standard case)
// LL width = ceil(tcx1/2) - ceil(tcx0/2) = ceil(w/2) when tcx0=0
test "subband_ll_dims_zero_origin" {
  // 256x256 image, level 1: LL = 128x128
  let (w, h) = subband_ll_dims(256, 256, 1, tcx0=0, tcy0=0)
  assert_eq(w, 128)
  assert_eq(h, 128)

  // 256x256 image, level 2: LL = 64x64
  let (w2, h2) = subband_ll_dims(256, 256, 2, tcx0=0, tcy0=0)
  assert_eq(w2, 64)
  assert_eq(h2, 64)

  // Odd size: 7x7, level 1: LL = ceil(7/2) = 4
  let (w3, h3) = subband_ll_dims(7, 7, 1, tcx0=0, tcy0=0)
  assert_eq(w3, 4)
  assert_eq(h3, 4)
}

///|
// T.800-2015 B.5: LL dimensions with non-zero origin
// LL width = ceil(tcx1/2) - ceil(tcx0/2) where tcx1 = tcx0 + w
test "subband_ll_dims_nonzero_origin" {
  // tcx0=1, w=6: tcx1=7
  // LL width = ceil(7/2) - ceil(1/2) = 4 - 1 = 3
  let (w1, _) = subband_ll_dims(6, 6, 1, tcx0=1, tcy0=0)
  assert_eq(w1, 3)

  // tcx0=2, w=6: tcx1=8
  // LL width = ceil(8/2) - ceil(2/2) = 4 - 1 = 3
  let (w2, _) = subband_ll_dims(6, 6, 1, tcx0=2, tcy0=0)
  assert_eq(w2, 3)

  // tcx0=3, w=6: tcx1=9
  // LL width = ceil(9/2) - ceil(3/2) = 5 - 2 = 3
  let (w3, _) = subband_ll_dims(6, 6, 1, tcx0=3, tcy0=0)
  assert_eq(w3, 3)
}

///|
// T.800-2015 B.5: b1_mono tile 2 case (tcx0=3197, width=97, decomp=5)
// This is a real failing fixture - verify computed dimensions match spec
test "subband_ll_dims_b1_mono_tile2" {
  let width = 97
  let height = 83
  let tcx0 = 3197
  let tcy0 = 41

  // Level 1: LL width = ceil(3294/2) - ceil(3197/2) = 1647 - 1599 = 48
  let (w1, h1) = subband_ll_dims(width, height, 1, tcx0~, tcy0~)
  assert_eq(w1, 48)
  assert_eq(h1, 41) // ceil(124/2) - ceil(41/2) = 62 - 21 = 41

  // Level 2: origin becomes (1599, 21), size (48, 41)
  // LL width = ceil(1647/2) - ceil(1599/2) = 824 - 800 = 24
  let (w2, h2) = subband_ll_dims(width, height, 2, tcx0~, tcy0~)
  assert_eq(w2, 24)
  assert_eq(h2, 20)

  // Level 5 (deepest): should be 3x2
  let (w5, h5) = subband_ll_dims(width, height, 5, tcx0~, tcy0~)
  assert_eq(w5, 3)
  assert_eq(h5, 2)
}

///|
// T.800-2015 B.5: b1_mono tile 1 case (tcx0=3100, width=97)
// This tile decodes correctly - compare with tile 2
test "subband_ll_dims_b1_mono_tile1" {
  let width = 97
  let height = 83
  let tcx0 = 3100
  let tcy0 = 41

  // Level 1: LL width = ceil(3197/2) - ceil(3100/2) = 1599 - 1550 = 49
  let (w1, _) = subband_ll_dims(width, height, 1, tcx0~, tcy0~)
  assert_eq(w1, 49) // Note: tile 1 has 49, tile 2 has 48

  // Level 5 (deepest): should be 3x2
  let (w5, h5) = subband_ll_dims(width, height, 5, tcx0~, tcy0~)
  assert_eq(w5, 3)
  assert_eq(h5, 2)
}

// =============================================================================
// T.800-2015 B.5: resolution_origins tests
// =============================================================================

///|
// T.800-2015 B.5: resolution origins with zero origin
test "resolution_origins_zero_origin" {
  let origins = resolution_origins(0, 0, 3)
  // origins[0] = deepest LL origin (after 3 halvings)
  // origins[3] = full resolution origin (0, 0)
  assert_eq(origins.length(), 4)
  assert_eq(origins[3], (0, 0)) // Full res
  assert_eq(origins[2], (0, 0)) // After 1 halving
  assert_eq(origins[1], (0, 0)) // After 2 halvings
  assert_eq(origins[0], (0, 0)) // After 3 halvings
}

///|
// T.800-2015 B.5: resolution origins with non-zero origin
// origin at level r = ceil(origin at level r-1 / 2)
test "resolution_origins_nonzero_origin" {
  let origins = resolution_origins(100, 41, 3)
  assert_eq(origins.length(), 4)
  assert_eq(origins[3], (100, 41)) // Full res
  // Level 2: ceil(100/2)=50, ceil(41/2)=21
  assert_eq(origins[2], (50, 21))
  // Level 1: ceil(50/2)=25, ceil(21/2)=11
  assert_eq(origins[1], (25, 11))
  // Level 0: ceil(25/2)=13, ceil(11/2)=6
  assert_eq(origins[0], (13, 6))
}

///|
// T.800-2015 B.5: b1_mono tile 2 resolution origins (for CAS computation)
test "resolution_origins_b1_mono_tile2" {
  let origins = resolution_origins(3197, 41, 5)
  assert_eq(origins.length(), 6)
  // Full resolution
  assert_eq(origins[5], (3197, 41))
  // After 1 halving: ceil(3197/2)=1599, ceil(41/2)=21
  assert_eq(origins[4], (1599, 21))
  // After 2 halvings: ceil(1599/2)=800, ceil(21/2)=11
  assert_eq(origins[3], (800, 11))
  // After 3 halvings: ceil(800/2)=400, ceil(11/2)=6
  assert_eq(origins[2], (400, 6))
  // After 4 halvings: ceil(400/2)=200, ceil(6/2)=3
  assert_eq(origins[1], (200, 3))
  // After 5 halvings: ceil(200/2)=100, ceil(3/2)=2
  assert_eq(origins[0], (100, 2))

  // CAS at level 0 IDWT uses origins[1] = (200, 3)
  // cas_h = 200 % 2 = 0, cas_v = 3 % 2 = 1
  let (ox, oy) = origins[1]
  assert_eq(ox % 2, 0) // cas_h = 0
  assert_eq(oy % 2, 1) // cas_v = 1
}

// =============================================================================
// T.800-2015 B.5 Eq. B-15: subband_bounds tests
// =============================================================================

///|
// T.800-2015 B.5 Eq. B-15: LL subband bounds with zero origin
test "subband_bounds_ll_zero_origin" {
  // 256x256 image, nb=1 (decomp level 1)
  // LL: tbx0 = ceil(0/2) = 0, tbx1 = ceil(256/2) = 128
  let (tbx0, tby0, tbx1, tby1) = subband_bounds(0, 0, 256, 256, 1, 0)
  assert_eq(tbx0, 0)
  assert_eq(tby0, 0)
  assert_eq(tbx1, 128)
  assert_eq(tby1, 128)
}

///|
// T.800-2015 B.5 Eq. B-15: HL subband bounds
// HL: xob=1, yob=0
// tbx0 = ceil((tcx0 - 2^(nb-1)) / 2^nb)
test "subband_bounds_hl" {
  // 256x256 image at origin (0,0), nb=1
  // HL: tbx0 = ceil((0-1)/2) = ceil(-0.5) = 0
  //     tbx1 = ceil((256-1)/2) = ceil(127.5) = 128
  let (tbx0, tby0, tbx1, tby1) = subband_bounds(0, 0, 256, 256, 1, 1)
  assert_eq(tbx0, 0)
  assert_eq(tby0, 0)
  assert_eq(tbx1, 128)
  assert_eq(tby1, 128)
}

///|
// T.800-2015 B.5 Eq. B-15: subband bounds with non-zero origin
test "subband_bounds_nonzero_origin" {
  // tcx0=100, tcx1=200, nb=1
  // LL: tbx0 = ceil(100/2) = 50, tbx1 = ceil(200/2) = 100
  let (tbx0_ll, _, tbx1_ll, _) = subband_bounds(100, 0, 200, 100, 1, 0)
  assert_eq(tbx0_ll, 50)
  assert_eq(tbx1_ll, 100)

  // HL: tbx0 = ceil((100-1)/2) = ceil(49.5) = 50
  //     tbx1 = ceil((200-1)/2) = ceil(99.5) = 100
  let (tbx0_hl, _, tbx1_hl, _) = subband_bounds(100, 0, 200, 100, 1, 1)
  assert_eq(tbx0_hl, 50)
  assert_eq(tbx1_hl, 100)
}

// =============================================================================
// Tests for subband_origin function per T.800-2015 F.3

///|
// T.800-2015 F.3: Standard layout with non-zero LL dimensions
// The wavelet coefficient array has layout:
//   [LL | HL]
//   [LH | HH]
test "subband_origin_standard_layout" {
  // Standard case: LL is 4x3
  let ll_w = 4
  let ll_h = 3

  // HL should be at (ll_w, 0) = (4, 0) - top right
  let (hl_x, hl_y) = subband_origin(0, ll_w, ll_h)
  assert_eq(hl_x, 4)
  assert_eq(hl_y, 0)

  // LH should be at (0, ll_h) = (0, 3) - bottom left
  let (lh_x, lh_y) = subband_origin(1, ll_w, ll_h)
  assert_eq(lh_x, 0)
  assert_eq(lh_y, 3)

  // HH should be at (ll_w, ll_h) = (4, 3) - bottom right
  let (hh_x, hh_y) = subband_origin(2, ll_w, ll_h)
  assert_eq(hh_x, 4)
  assert_eq(hh_y, 3)
}

///|
// T.800-2015 F.3: Edge case with ll_width=0 (degenerate tile)
// When LL has zero width, the layout collapses:
//   HL occupies position (0, 0) - same as where LL would be
//   LH occupies position (0, ll_h)
//   HH occupies position (0, ll_h)
// This is a problem for IDWT which expects LL at (0, 0)
test "subband_origin_zero_ll_width" {
  let ll_w = 0 // Zero width LL (degenerate)
  let ll_h = 20

  // HL at (0, 0) - collides with LL area!
  let (hl_x, hl_y) = subband_origin(0, ll_w, ll_h)
  assert_eq(hl_x, 0)
  assert_eq(hl_y, 0)

  // LH at (0, 20)
  let (lh_x, lh_y) = subband_origin(1, ll_w, ll_h)
  assert_eq(lh_x, 0)
  assert_eq(lh_y, 20)

  // HH at (0, 20)
  let (hh_x, hh_y) = subband_origin(2, ll_w, ll_h)
  assert_eq(hh_x, 0)
  assert_eq(hh_y, 20)
}

///|
// T.800-2015 F.3: Edge case with ll_height=0 (degenerate tile)
test "subband_origin_zero_ll_height" {
  let ll_w = 10
  let ll_h = 0 // Zero height LL (degenerate)

  // HL at (10, 0)
  let (hl_x, hl_y) = subband_origin(0, ll_w, ll_h)
  assert_eq(hl_x, 10)
  assert_eq(hl_y, 0)

  // LH at (0, 0) - collides with LL area!
  let (lh_x, lh_y) = subband_origin(1, ll_w, ll_h)
  assert_eq(lh_x, 0)
  assert_eq(lh_y, 0)

  // HH at (10, 0)
  let (hh_x, hh_y) = subband_origin(2, ll_w, ll_h)
  assert_eq(hh_x, 10)
  assert_eq(hh_y, 0)
}
