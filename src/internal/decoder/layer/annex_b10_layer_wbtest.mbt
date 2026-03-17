///|
// Packet-order tests for T.800-2015 B.12 position-based progression.

///|
test "packet_order_pcrl_reference_grid_across_resolutions" {
  // One component, NL=2, one scanline; precinct grids differ by resolution.
  // Expected PCRL order follows (y, x, c, r) in reference-grid coordinates.
  let packet_order = @precinct.build_packet_order(
    3, // PCRL
    1, // layers
    3, // num_resolutions (Nmax+1)
    1, // num_components
    [3], // per-component num resolutions
    [2], // per-component decomposition levels (NL)
    [[(1, 1), (2, 1), (4, 1)]], // precinct grids per resolution
    [
      [
        (1, 0, 2, 1), // r=0
        (1, 0, 5, 1), // r=1
        (1, 0, 9, 1),
      ],
    ], // r=2
    [[0x00, 0x00, 0x00]], // PPx=PPy=0 for all resolutions
    1, // tcx0
    0, // tcy0
  )
  let expected : Array[(Int, Int, Int, Int)] = [
    (2, 0, 0, 0), // x=1
    (1, 0, 0, 0), // x=2
    (2, 0, 0, 1), // x=2
    (2, 0, 0, 2), // x=3
    (0, 0, 0, 0), // x=4
    (1, 0, 0, 1), // x=4
    (2, 0, 0, 3), // x=4
  ]
  assert_eq(packet_order.length(), expected.length())
  for i in 0..<expected.length() {
    assert_eq(packet_order[i], expected[i])
  }
}

///|
test "packet_order_cprl_component_outermost" {
  let packet_order = @precinct.build_packet_order(
    4, // CPRL
    1,
    2,
    2,
    [2, 2],
    [1, 1],
    [[(1, 1), (1, 1)], [(1, 1), (1, 1)]],
    [[(0, 0, 1, 1), (0, 0, 2, 1)], [(0, 0, 1, 1), (0, 0, 2, 1)]],
    [[0x00, 0x00], [0x00, 0x00]],
    0,
    0,
  )
  let expected : Array[(Int, Int, Int, Int)] = [
    (0, 0, 0, 0),
    (1, 0, 0, 0),
    (0, 0, 1, 0),
    (1, 0, 1, 0),
  ]
  assert_eq(packet_order.length(), expected.length())
  for i in 0..<expected.length() {
    assert_eq(packet_order[i], expected[i])
  }
}

///|
test "packet_order_with_poc_overrides_cod_progression" {
  // COD says PCRL, but POC requests LRCP over the full packet space.
  let poc_entries : Array[(Int, Int, Int, Int, Int, Int)] = [(0, 0, 1, 2, 1, 0)]
  let packet_order = @precinct.build_packet_order_with_poc(
    3, // COD progression: PCRL
    1,
    2,
    1,
    [2],
    [1],
    [[(1, 1), (1, 1)]],
    [[(4, 0, 5, 1), (0, 0, 1, 1)]],
    [[0x00, 0x00]],
    0,
    0,
    poc_entries,
  )
  let expected : Array[(Int, Int, Int, Int)] = [(0, 0, 0, 0), (1, 0, 0, 0)]
  assert_eq(packet_order.length(), expected.length())
  for i in 0..<expected.length() {
    assert_eq(packet_order[i], expected[i])
  }
}

///|
test "packet_order_with_poc_tracks_next_layer_across_volumes" {
  // Volume 1 emits up to layer 0; volume 2 extends to layer 2.
  // Decoder must continue from the next layer and never repeat packets.
  let poc_entries : Array[(Int, Int, Int, Int, Int, Int)] = [
    (0, 0, 1, 1, 1, 0),
    (0, 0, 3, 1, 1, 1),
  ]
  let packet_order = @precinct.build_packet_order_with_poc(
    0,
    3,
    1,
    1,
    [1],
    [0],
    [[(1, 1)]],
    [[(0, 0, 1, 1)]],
    [[0x00]],
    0,
    0,
    poc_entries,
  )
  let expected : Array[(Int, Int, Int, Int)] = [
    (0, 0, 0, 0),
    (0, 1, 0, 0),
    (0, 2, 0, 0),
  ]
  assert_eq(packet_order.length(), expected.length())
  for i in 0..<expected.length() {
    assert_eq(packet_order[i], expected[i])
  }
}

///|
test "packet_order_with_poc_pcrl_matches main iterator on misaligned tile origin" {
  let poc_entries : Array[(Int, Int, Int, Int, Int, Int)] = [(0, 0, 1, 6, 1, 3)]
  let packet_order = @precinct.build_packet_order_with_poc(
    0,
    1,
    1,
    1,
    [1],
    [0],
    [[(3, 4)]],
    [[(80, 1, 159, 102)]],
    [[0x55]],
    80,
    1,
    poc_entries,
  )
  // The first intersecting precinct at a non-zero tile origin is still local
  // precinct 0. The previous anchor-based POC path started from precinct 1.
  assert_true(packet_order.length() > 0)
  assert_eq(packet_order[0], (0, 0, 0, 0))
}

///|
test "packet_order_rpcl_p1_07_geometry_packet_count" {
  let packet_order = @precinct.build_packet_order(
    2, // RPCL
    1, // layers
    2, // num_resolutions
    2, // num_components
    [2, 2],
    [1, 1],
    [[(1, 6), (2, 6)], [(2, 3), (2, 3)]],
    [[(1, 0, 2, 6), (1, 0, 3, 12)], [(2, 0, 6, 6), (4, 0, 12, 12)]],
    [[0x00, 0x11], [0x11, 0x22]],
    1, // tcx0 for component0
    0, // tcy0 for component0
    comp_xrsiz=[4, 1], // XRsiz
    comp_yrsiz=[1, 1], // YRsiz
  )
  // p1_07 codestream has 30 SOP markers -> 30 packets per layer.
  assert_eq(packet_order.length(), 30)
}

///|
test "packet_order_rpcl_deduplicates_precinct_hits" {
  // T.800-2015 B.12: RPCL iterator uses a deduplication bitmap so repeated (x,y) hits
  // on the same precinct are emitted only once per layer.
  let packet_order = @precinct.build_packet_order(
    2, // RPCL
    1, // layers
    1, // decode only resolution 0 in this test
    1, // components
    [2], // component has 2 resolutions (so level shift at r=0 is 1)
    [1], // decomposition levels
    [[(2, 1), (2, 1)]],
    [[(1, 0, 3, 1), (1, 0, 5, 1)]],
    [[0x00, 0x11]],
    1,
    0,
    comp_xrsiz=[1],
    comp_yrsiz=[1],
  )
  let expected : Array[(Int, Int, Int, Int)] = [(0, 0, 0, 0), (0, 0, 0, 1)]
  assert_eq(packet_order.length(), expected.length())
  for i in 0..<expected.length() {
    assert_eq(packet_order[i], expected[i])
  }
}

///|
test "packet_order_with_poc_cprl_handles p0_13 style second component range" {
  let num_components = 257
  let comp_num_resolutions : Array[Int] = []
  let comp_decomp_levels : Array[Int] = []
  let comp_res_num_precincts : Array[Array[(Int, Int)]] = []
  let comp_res_bounds : Array[Array[(Int, Int, Int, Int)]] = []
  let comp_precinct_size_bytes : Array[Array[Int]] = []
  for _ in 0..<num_components {
    comp_num_resolutions.push(2)
    comp_decomp_levels.push(1)
    comp_res_num_precincts.push([(1, 1), (1, 1)])
    comp_res_bounds.push([(0, 0, 1, 1), (0, 0, 1, 1)])
    comp_precinct_size_bytes.push([0x00, 0x00])
  }
  let poc_entries : Array[(Int, Int, Int, Int, Int, Int)] = [
    (0, 0, 1, 33, 128, 1),
    (0, 128, 1, 33, 257, 4),
  ]
  let packet_order = @precinct.build_packet_order_with_poc(
    1, 1, 2, num_components, comp_num_resolutions, comp_decomp_levels, comp_res_num_precincts,
    comp_res_bounds, comp_precinct_size_bytes, 0, 0, poc_entries,
  )
  assert_eq(packet_order.length(), 514)
  assert_eq(packet_order[0], (0, 0, 0, 0))
  assert_eq(packet_order[255], (1, 0, 127, 0))
  assert_eq(packet_order[256], (0, 0, 128, 0))
  assert_eq(packet_order[257], (1, 0, 128, 0))
  assert_eq(packet_order[258], (0, 0, 129, 0))
  assert_eq(packet_order[259], (1, 0, 129, 0))
  assert_eq(packet_order[512], (0, 0, 256, 0))
  assert_eq(packet_order[513], (1, 0, 256, 0))
}

///|
test "multi-layer accumulation consumes empty zero-codeblock packets before later components" {
  let payload_arr = wb_single_codeblock_packet_header(true, 0, 1, [1], [1]) +
    [0x11] +
    [0x00] +
    wb_single_codeblock_packet_header(true, 0, 1, [1], [1]) +
    [0x22] +
    [0x00] +
    wb_single_codeblock_packet_header(true, 0, 1, [1], [1]) +
    [0x33] +
    [0x00]
  let accum_v = split_sod_accumulate_multi_layer(
    wb_int_array_to_bytes(payload_arr),
    1,
    1,
    1,
    3,
    1,
    4,
    0,
    comp_widths=[1, 1, 1],
    comp_heights=[1, 1, 1],
    comp_decomp_levels=[1, 1, 1],
    comp_precinct_size_bytes=[[0x00, 0x00], [0x00, 0x00], [0x00, 0x00]],
    precinct_size_bytes=[0x00, 0x00],
  )
  guard accum_v is Ok((all_comp_accum, _)) else {
    if accum_v is Err(msg) {
      fail("expected zero-codeblock packet accumulation success: \{msg}")
    }
    fail("expected zero-codeblock packet accumulation success")
  }
  assert_eq(all_comp_accum.length(), 3)
  assert_eq(all_comp_accum[0][0].length(), 1)
  assert_eq(all_comp_accum[1][0].length(), 1)
  assert_eq(all_comp_accum[2][0].length(), 1)
  assert_eq(
    wb_bytes_to_int_array(
      Bytes::from_iter(all_comp_accum[0][0][0].codeword.iter()),
    ),
    [0x11],
  )
  assert_eq(
    wb_bytes_to_int_array(
      Bytes::from_iter(all_comp_accum[1][0][0].codeword.iter()),
    ),
    [0x22],
  )
  assert_eq(
    wb_bytes_to_int_array(
      Bytes::from_iter(all_comp_accum[2][0][0].codeword.iter()),
    ),
    [0x33],
  )
}
