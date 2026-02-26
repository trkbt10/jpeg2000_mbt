///|
// Public entrypoint functions for mooncakes consumers.
// Keep stable APIs here; internal implementations stay in focused files.
pub fn parse_codestream(data : Array[Int]) -> Result[Codestream, String] {
  parse_codestream_impl_default(data)
}

///|
pub fn parse_codestream_strict(data : Array[Int]) -> Result[Codestream, String] {
  parse_codestream_strict_impl(data)
}

///|
pub fn encode_codestream(stream : Codestream) -> Result[Array[Int], String] {
  encode_codestream_impl(stream)
}

///|
pub fn roundtrip_bytes(data : Array[Int]) -> Result[Array[Int], String] {
  roundtrip_bytes_impl(data)
}

///|
pub fn bytes_to_hex(data : Array[Int]) -> String {
  bytes_to_hex_impl(data)
}

///|
pub fn hex_to_bytes(hex : String) -> Result[Array[Int], String] {
  hex_to_bytes_impl(hex)
}

///|
pub fn sample_codestream_minimal() -> Array[Int] {
  sample_codestream_minimal_impl()
}

///|
pub fn sample_codestream_with_com() -> Array[Int] {
  sample_codestream_with_com_impl()
}

///|
pub fn sample_codestream_with_coc_qcc() -> Array[Int] {
  sample_codestream_with_coc_qcc_impl()
}

///|
pub fn sample_codestream_with_poc() -> Array[Int] {
  sample_codestream_with_poc_impl()
}

///|
pub fn sample_codestream_with_ppt_sop_eph() -> Array[Int] {
  sample_codestream_with_ppt_sop_eph_impl()
}

///|
pub fn sample_codestream_two_tileparts() -> Array[Int] {
  sample_codestream_two_tileparts_impl()
}

///|
pub fn sample_codestream_with_plm_plt() -> Array[Int] {
  sample_codestream_with_plm_plt_impl()
}

///|
pub fn sample_codestream_with_tlm() -> Array[Int] {
  sample_codestream_with_tlm_impl()
}

///|
pub fn sample_codestream_with_ppm() -> Array[Int] {
  sample_codestream_with_ppm_impl()
}

///|
pub fn sample_codestream_by_name(name : String) -> Array[Int]? {
  sample_codestream_by_name_impl(name)
}

///|
pub fn sample_codestream_names() -> Array[String] {
  sample_codestream_names_impl()
}

///|
pub fn classify_marker(code : Int) -> MarkerClass {
  classify_marker_impl(code)
}

///|
pub fn decode_tag_tree_inclusion_flags(
  data : Array[Int],
  width : Int,
  height : Int,
  threshold : Int,
) -> Result[(Array[Bool], Int), String] {
  decode_tag_tree_inclusion_flags_impl(data, width, height, threshold)
}

///|
pub fn decode_codeblock_segment_lengths_from_bits(
  data : Array[Int],
  initial_lblock : Int,
  added_passes : Array[Int],
) -> Result[(Array[Int], Int), String] {
  decode_codeblock_segment_lengths_from_bits_impl(
    data, initial_lblock, added_passes,
  )
}

///|
pub fn parse_packet_headers_single_codeblock(
  data : Array[Int],
) -> Result[Array[PacketHeaderMetadata], String] {
  parse_packet_headers_single_codeblock_impl(data)
}

///|
pub fn parse_packet_headers_with_code_blocks(
  data : Array[Int],
  code_block_count : Int,
) -> Result[Array[PacketHeaderMetadata], String] {
  parse_packet_headers_with_code_blocks_impl(data, code_block_count)
}

///|
pub fn parse_packet_header_single_packet_with_tag_tree(
  data : Array[Int],
  width : Int,
  height : Int,
  layer_index : Int,
) -> Result[PacketHeaderMetadata, String] {
  parse_packet_header_single_packet_with_tag_tree_impl(
    data, width, height, layer_index,
  )
}

///|
pub fn parse_packet_header_single_packet_with_tag_tree_and_pass_splits(
  data : Array[Int],
  width : Int,
  height : Int,
  layer_index : Int,
  added_passes_per_code_block : Array[Array[Int]],
) -> Result[PacketHeaderMetadata, String] {
  parse_packet_header_single_packet_with_tag_tree_and_pass_splits_impl(
    data, width, height, layer_index, added_passes_per_code_block,
  )
}

///|
pub fn parse_packet_headers_with_tag_tree_sequence(
  data : Array[Int],
  width : Int,
  height : Int,
  packet_count : Int,
) -> Result[Array[PacketHeaderMetadata], String] {
  parse_packet_headers_with_tag_tree_sequence_impl(
    data, width, height, packet_count,
  )
}

///|
pub fn parse_packet_headers_with_tag_tree_sequence_and_pass_splits(
  data : Array[Int],
  width : Int,
  height : Int,
  packet_count : Int,
  added_passes_per_packet_per_code_block : Array[Array[Array[Int]]],
) -> Result[Array[PacketHeaderMetadata], String] {
  parse_packet_headers_with_tag_tree_sequence_and_pass_splits_impl(
    data, width, height, packet_count, added_passes_per_packet_per_code_block,
  )
}
