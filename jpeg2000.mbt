///|
// Public facade package:
// - jpeg2000_types.mbt (re-exported public types)
// - jpeg2000.mbt (public function entrypoint)
//
// Internal implementation package:
// - internal/core/*.mbt

///|
pub fn parse_codestream(data : Array[Int]) -> Result[Codestream, String] {
  @core.parse_codestream(data)
}

///|
pub fn parse_codestream_strict(data : Array[Int]) -> Result[Codestream, String] {
  @core.parse_codestream_strict(data)
}

///|
pub fn encode_codestream(stream : Codestream) -> Result[Array[Int], String] {
  @core.encode_codestream(stream)
}

///|
pub fn roundtrip_bytes(data : Array[Int]) -> Result[Array[Int], String] {
  @core.roundtrip_bytes(data)
}

///|
pub fn bytes_to_hex(data : Array[Int]) -> String {
  @core.bytes_to_hex(data)
}

///|
pub fn hex_to_bytes(hex : String) -> Result[Array[Int], String] {
  @core.hex_to_bytes(hex)
}

///|
pub fn sample_codestream_minimal() -> Array[Int] {
  @core.sample_codestream_minimal()
}

///|
pub fn sample_codestream_with_com() -> Array[Int] {
  @core.sample_codestream_with_com()
}

///|
pub fn sample_codestream_with_coc_qcc() -> Array[Int] {
  @core.sample_codestream_with_coc_qcc()
}

///|
pub fn sample_codestream_with_poc() -> Array[Int] {
  @core.sample_codestream_with_poc()
}

///|
pub fn sample_codestream_with_ppt_sop_eph() -> Array[Int] {
  @core.sample_codestream_with_ppt_sop_eph()
}

///|
pub fn sample_codestream_two_tileparts() -> Array[Int] {
  @core.sample_codestream_two_tileparts()
}

///|
pub fn sample_codestream_with_plm_plt() -> Array[Int] {
  @core.sample_codestream_with_plm_plt()
}

///|
pub fn sample_codestream_with_tlm() -> Array[Int] {
  @core.sample_codestream_with_tlm()
}

///|
pub fn sample_codestream_with_ppm() -> Array[Int] {
  @core.sample_codestream_with_ppm()
}

///|
pub fn sample_codestream_by_name(name : String) -> Array[Int]? {
  @core.sample_codestream_by_name(name)
}

///|
pub fn sample_codestream_names() -> Array[String] {
  @core.sample_codestream_names()
}

///|
pub fn classify_marker(code : Int) -> MarkerClass {
  @core.classify_marker(code)
}

///|
pub fn decode_tag_tree_inclusion_flags(
  data : Array[Int],
  width : Int,
  height : Int,
  threshold : Int,
) -> Result[(Array[Bool], Int), String] {
  @core.decode_tag_tree_inclusion_flags(data, width, height, threshold)
}

///|
pub fn decode_codeblock_segment_lengths_from_bits(
  data : Array[Int],
  initial_lblock : Int,
  added_passes : Array[Int],
) -> Result[(Array[Int], Int), String] {
  @core.decode_codeblock_segment_lengths_from_bits(
    data, initial_lblock, added_passes,
  )
}

///|
pub fn parse_packet_headers_single_codeblock(
  data : Array[Int],
) -> Result[Array[PacketHeaderMetadata], String] {
  @core.parse_packet_headers_single_codeblock(data)
}

///|
pub fn parse_packet_headers_with_code_blocks(
  data : Array[Int],
  code_block_count : Int,
) -> Result[Array[PacketHeaderMetadata], String] {
  @core.parse_packet_headers_with_code_blocks(data, code_block_count)
}

///|
pub fn parse_packet_header_single_packet_with_tag_tree(
  data : Array[Int],
  width : Int,
  height : Int,
  layer_index : Int,
) -> Result[PacketHeaderMetadata, String] {
  @core.parse_packet_header_single_packet_with_tag_tree(
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
  @core.parse_packet_header_single_packet_with_tag_tree_and_pass_splits(
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
  @core.parse_packet_headers_with_tag_tree_sequence(
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
  @core.parse_packet_headers_with_tag_tree_sequence_and_pass_splits(
    data, width, height, packet_count, added_passes_per_packet_per_code_block,
  )
}
