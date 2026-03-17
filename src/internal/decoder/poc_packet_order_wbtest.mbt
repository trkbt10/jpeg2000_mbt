///|
test "build_packet_order_with_poc keeps p0_13 post-128 CPRL volume in component-major order" {
  let num_components = 257
  let comp_num_resolutions : Array[Int] = []
  let comp_decomp_levels : Array[Int] = []
  let comp_res_num_precincts : Array[Array[(Int, Int)]] = []
  let comp_res_bounds : Array[Array[(Int, Int, Int, Int)]] = []
  let comp_precinct_size_bytes : Array[Array[Int]] = []
  let comp_xrsiz : Array[Int] = []
  let comp_yrsiz : Array[Int] = []
  for _ in 0..<num_components {
    comp_num_resolutions.push(2)
    comp_decomp_levels.push(1)
    comp_res_num_precincts.push([(1, 1), (1, 1)])
    comp_res_bounds.push([(0, 0, 1, 1), (0, 0, 1, 1)])
    comp_precinct_size_bytes.push([])
    comp_xrsiz.push(1)
    comp_yrsiz.push(1)
  }
  let packet_order = @precinct.build_packet_order_with_poc(
    1,
    1,
    2,
    num_components,
    comp_num_resolutions,
    comp_decomp_levels,
    comp_res_num_precincts,
    comp_res_bounds,
    comp_precinct_size_bytes,
    0,
    0,
    [(0, 0, 1, 33, 128, 1), (0, 128, 1, 33, 257, 4)],
    comp_xrsiz~,
    comp_yrsiz~,
  )
  assert_eq(packet_order.length(), 514)
  assert_eq(packet_order[0], (0, 0, 0, 0))
  assert_eq(packet_order[127], (0, 0, 127, 0))
  assert_eq(packet_order[128], (1, 0, 0, 0))
  assert_eq(packet_order[255], (1, 0, 127, 0))
  assert_eq(packet_order[256], (0, 0, 128, 0))
  assert_eq(packet_order[257], (1, 0, 128, 0))
  assert_eq(packet_order[258], (0, 0, 129, 0))
  assert_eq(packet_order[259], (1, 0, 129, 0))
  assert_eq(packet_order[512], (0, 0, 256, 0))
  assert_eq(packet_order[513], (1, 0, 256, 0))
}
