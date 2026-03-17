///|
// Unit tests for DWT subband helper functions
// These test the T.800-2015 B.5 subband dimension calculations

///|
test "@subband.subband_ll_dims level 0 returns original dimensions" {
  let (w, h) = @subband.subband_ll_dims(128, 128, 0)
  inspect(w, content="128")
  inspect(h, content="128")
}

///|
test "@subband.subband_ll_dims level 1 halves dimensions" {
  let (w, h) = @subband.subband_ll_dims(128, 128, 1)
  inspect(w, content="64")
  inspect(h, content="64")
}

///|
test "@subband.subband_ll_dims level 3 reduces to 1/8" {
  let (w, h) = @subband.subband_ll_dims(128, 128, 3)
  inspect(w, content="16")
  inspect(h, content="16")
}

///|
test "@subband.subband_ll_dims handles odd dimensions" {
  let (w, h) = @subband.subband_ll_dims(127, 125, 1)
  inspect(w, content="64")
  inspect(h, content="63")
}

///|
test "@subband.subband_ll_dims handles non-zero origin" {
  // T.800-2015 B.5: LL width = ceil(tcx1/2) - ceil(tcx0/2)
  // For tcx0=1, w=128: tcx1=129, ceil(129/2)=65, ceil(1/2)=1, width=64
  let (w, h) = @subband.subband_ll_dims(128, 128, 1, tcx0=1, tcy0=1)
  inspect(w, content="64")
  inspect(h, content="64")
}

///|
test "@subband.subband_detail_dims computes HL/LH/HH dimensions" {
  let (hl_w, hl_h, lh_w, lh_h, hh_w, hh_h) = @subband.subband_detail_dims(
    128, 128,
  )
  // For 128x128: LL=64x64, HL=64x64, LH=64x64, HH=64x64
  inspect(hl_w, content="64") // HL width
  inspect(hl_h, content="64") // HL height (same as LL height)
  inspect(lh_w, content="64") // LH width (same as LL width)
  inspect(lh_h, content="64") // LH height
  inspect(hh_w, content="64") // HH width
  inspect(hh_h, content="64") // HH height
}

///|
test "@subband.subband_detail_dims handles odd dimensions" {
  // For 127x125: LL = ceil(127/2) x ceil(125/2) = 64x63
  // HL = 127-64=63 x 63, LH = 64 x 125-63=62, HH = 63 x 62
  let (hl_w, hl_h, lh_w, lh_h, hh_w, hh_h) = @subband.subband_detail_dims(
    127, 125,
  )
  inspect(hl_w, content="63") // HL width = parent_w - ll_w
  inspect(hl_h, content="63") // HL height = ll_h
  inspect(lh_w, content="64") // LH width = ll_w
  inspect(lh_h, content="62") // LH height = parent_h - ll_h
  inspect(hh_w, content="63") // HH width = hl_w
  inspect(hh_h, content="62") // HH height = lh_h
}

///|
test "@subband.resolution_origins returns correct origin sequence" {
  let origins = @subband.resolution_origins(0, 0, 3)
  // For decomp=3: origins at resolutions 0,1,2,3
  // res0 (deepest LL): (0,0) after 3 halvings
  // res3 (full): (0,0)
  inspect(origins.length(), content="4")
  inspect(origins[0], content="(0, 0)") // deepest LL
  inspect(origins[3], content="(0, 0)") // full resolution
}

///|
test "@subband.resolution_origins handles non-zero origin" {
  let origins = @subband.resolution_origins(4, 4, 2)
  // tcx0=4, tcy0=4, decomp=2
  // Full: (4, 4)
  // After 1 halving: ceil(4/2)=2, (2, 2)
  // After 2 halvings: ceil(2/2)=1, (1, 1)
  // Reversed order: [(1,1), (2,2), (4,4)]
  inspect(origins.length(), content="3")
  inspect(origins[0], content="(1, 1)") // deepest LL
  inspect(origins[1], content="(2, 2)")
  inspect(origins[2], content="(4, 4)") // full resolution
}
