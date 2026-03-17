///|
// Unit tests for MCT (Multi-Component Transform) functions (Annex G)

///|
test "inverse_rct_triplet identity case" {
  // When Db=Dr=0, the inverse RCT should return (Y, Y, Y)
  let (r, g, b) = tier1_annex_g_inverse_rct_triplet(128, 0, 0)
  inspect(r, content="128")
  inspect(g, content="128")
  inspect(b, content="128")
}

///|
test "inverse_rct_triplet with color difference" {
  // T.800-2015 G.2: G = Y - floor((Db + Dr)/4), R = Dr + G, B = Db + G
  // Y=100, Db=8, Dr=4 => G = 100 - floor(12/4) = 97
  // R = 4 + 97 = 101, B = 8 + 97 = 105
  let (r, g, b) = tier1_annex_g_inverse_rct_triplet(100, 8, 4)
  inspect(g, content="97")
  inspect(r, content="101")
  inspect(b, content="105")
}

///|
test "inverse_rct_triplet with negative differences" {
  // Y=128, Db=-16, Dr=-8 => G = 128 - floor(-24/4) = 128 - (-6) = 134
  // R = -8 + 134 = 126, B = -16 + 134 = 118
  let (r, g, b) = tier1_annex_g_inverse_rct_triplet(128, -16, -8)
  inspect(g, content="134")
  inspect(r, content="126")
  inspect(b, content="118")
}

///|
test "inverse_ict_triplet identity case" {
  // When Cb=Cr=0, the inverse ICT should return approximately (Y, Y, Y)
  let (r, g, b) = tier1_annex_g_inverse_ict_triplet(128, 0, 0)
  inspect(r, content="128")
  inspect(g, content="128")
  inspect(b, content="128")
}

///|
test "inverse_ict_triplet with chrominance" {
  // T.800-2015 G.3: R = Y + 1.402*Cr, G = Y - 0.34413*Cb - 0.71414*Cr, B = Y + 1.772*Cb
  // Using fixed-point: k=8192
  // R = Y + (11485 * Cr + 4096) / 8192
  // G = Y - (2819 * Cb + 5850 * Cr + 4096) / 8192
  // B = Y + (14516 * Cb + 4096) / 8192
  let (r, g, b) = tier1_annex_g_inverse_ict_triplet(128, 64, 64)
  // R = 128 + (11485*64 + 4096)/8192 = 128 + 90 = 218
  // G = 128 - (2819*64 + 5850*64 + 4096)/8192 = 128 - 68 = 60
  // B = 128 + (14516*64 + 4096)/8192 = 128 + 113 = 241
  inspect(r, content="218")
  inspect(g, content="60")
  inspect(b, content="241")
}

///|
test "inverse_rct_components basic" {
  let y = [100, 128, 150]
  let db = [0, 0, 0]
  let dr = [0, 0, 0]
  let result = tier1_annex_g_inverse_rct_components(y, db, dr)
  guard result is Ok((r, g, b)) else { fail("unexpected error") }
  inspect(r, content="[100, 128, 150]")
  inspect(g, content="[100, 128, 150]")
  inspect(b, content="[100, 128, 150]")
}

///|
test "inverse_rct_components mismatched lengths" {
  let y = [100, 128]
  let db = [0]
  let dr = [0, 0]
  let result = tier1_annex_g_inverse_rct_components(y, db, dr)
  guard result is Err(msg) else { fail("expected error") }
  inspect(msg.contains("equal"), content="true")
}

///|
test "inverse_ict_components basic" {
  let y = [100, 128, 150]
  let cb = [0, 0, 0]
  let cr = [0, 0, 0]
  let result = tier1_annex_g_inverse_ict_components(y, cb, cr)
  guard result is Ok((r, g, b)) else { fail("unexpected error") }
  inspect(r, content="[100, 128, 150]")
  inspect(g, content="[100, 128, 150]")
  inspect(b, content="[100, 128, 150]")
}

///|
test "inverse_ict_components mismatched lengths" {
  let y = [100]
  let cb = [0, 0]
  let cr = [0]
  let result = tier1_annex_g_inverse_ict_components(y, cb, cr)
  guard result is Err(msg) else { fail("expected error") }
  inspect(msg.contains("equal"), content="true")
}

///|
test "inverse_ict_components_float basic" {
  let y = [128.0]
  let cb = [64.0]
  let cr = [64.0]
  let result = tier1_annex_g_inverse_ict_components_float(y, cb, cr)
  guard result is Ok((r, g, b)) else { fail("unexpected error") }
  assert_true((r[0] - 217.728).abs() < 0.01)
  assert_true((g[0] - 60.27248).abs() < 0.01)
  assert_true((b[0] - 241.408).abs() < 0.01)
}

///|
test "inverse_ict_components_float mismatched lengths" {
  let y = [100.0]
  let cb = [0.0, 0.0]
  let cr = [0.0]
  let result = tier1_annex_g_inverse_ict_components_float(y, cb, cr)
  guard result is Err(msg) else { fail("expected error") }
  inspect(msg.contains("equal"), content="true")
}
