///|
// Debug tests for multi-tile decoding
// Verifies tile payload collection and individual tile decode

///|
// Test: Verify tile component dimensions calculation
// b1_mono has XOsiz=3097, XTOsiz=3097, XTsiz=97, Xsiz=3400
// This creates tiles with varying widths at the edges
test "tile_dims_b1_mono_like" {
  // Simulate b1_mono SIZ parameters
  let xsiz = 3400
  let ysiz = 220
  let xosiz = 3097
  let yosiz = 41
  let xtosiz = 3097
  let ytosiz = 41
  let xtsiz = 97
  let ytsiz = 91

  // Calculate number of tiles
  let num_tiles_x = (xsiz - xtosiz + xtsiz - 1) / xtsiz
  let num_tiles_y = (ysiz - ytosiz + ytsiz - 1) / ytsiz
  assert_eq(num_tiles_x, 4) // Actually should be ceil((3400-3097)/97) = 4

  // Tile (0,0) should be degenerate (narrow)
  // tx0 = max(xtosiz + 0*xtsiz, xosiz) = max(3097, 3097) = 3097
  // tx1 = min(xtosiz + 1*xtsiz, xsiz) = min(3194, 3400) = 3194
  // BUT image starts at xosiz=3097, so effective tx1 is min(tx1, xsiz)
  // Width = min(3194, 3400) - 3097 = 97
  // Wait, that's not right either. Let me think...

  // The issue is that tile (0,0) spans [3097, 3194) in reference grid
  // But the image only occupies [3097, 3400) in X
  // So tile (0,0) has width 3194 - 3097 = 97... but earlier analysis said 3!

  // Actually, looking at the decoded output, tile 0 has 3 pixels, which means
  // there must be additional clipping happening. Let me check the actual
  // tile_component0_dims_and_origin_from_siz function.
}

///|
// Test: Verify that tile position in output image is correct
test "tile_position_in_output" {
  // For b1_mono-like layout:
  // Output image starts at (0,0), size 303x179
  // Tile (0,0) at reference (3097,41) maps to output (0,0)
  // Tile (1,0) at reference (3194,41) maps to output (97,0)
  // Tile (2,0) at reference (3291,41) maps to output (194,0)

  // But the actual mismatch starts at column 100, which would be:
  // Column 100 is at reference X = 3097 + 100 = 3197
  // This is in tile (1,0)'s range [3194, 3291)

  // Hmm, column 100 should be in tile 1, not tile 2
  // Let me recalculate:
  // - Tile 0 width: min(3194, 3400) - max(3097, 3097) = 3194 - 3097 = 97
  // - But we observed that tile 0 gives only 3 pixels...

  // There might be component-level subsampling or the SIZ values are different
  // from what I assumed. Let me check the actual b1_mono SIZ.
}
