///|
pub fn decode_tag_tree_inclusion_flags(
  data : Array[Int],
  width : Int,
  height : Int,
  threshold : Int,
) -> Result[(Array[Bool], Int), String] {
  @core.decode_tag_tree_inclusion_flags(
    @bytes.int_array_to_bytes(data), width, height, threshold,
  )
}

///|
pub fn decode_codeblock_segment_lengths_from_bits(
  data : Array[Int],
  initial_lblock : Int,
  added_passes : Array[Int],
) -> Result[(Array[Int], Int), String] {
  @core.decode_codeblock_segment_lengths_from_bits(
    @bytes.int_array_to_bytes(data), initial_lblock, added_passes,
  )
}

///|
pub fn parse_packet_headers_single_codeblock(
  data : Array[Int],
) -> Result[Array[PacketHeaderMetadata], String] {
  @core.parse_packet_headers_single_codeblock(@bytes.int_array_to_bytes(data))
}

///|
pub fn parse_packet_headers_with_code_blocks(
  data : Array[Int],
  code_block_count : Int,
) -> Result[Array[PacketHeaderMetadata], String] {
  @core.parse_packet_headers_with_code_blocks(
    @bytes.int_array_to_bytes(data), code_block_count,
  )
}

///|
pub fn parse_packet_headers_with_code_blocks_and_style(
  data : Array[Int],
  code_block_count : Int,
  code_block_style : Int,
) -> Result[Array[PacketHeaderMetadata], String] {
  @core.parse_packet_headers_with_code_blocks_and_style(
    @bytes.int_array_to_bytes(data), code_block_count, code_block_style,
  )
}

///|
pub fn parse_packet_header_first_packet_with_code_blocks_and_style(
  data : Array[Int],
  code_block_count : Int,
  code_block_style : Int,
) -> Result[PacketHeaderMetadata, String] {
  @core.parse_packet_header_first_packet_with_code_blocks_and_style(
    @bytes.int_array_to_bytes(data), code_block_count, code_block_style,
  )
}

///|
pub fn parse_packet_header_single_packet_with_tag_tree(
  data : Array[Int],
  width : Int,
  height : Int,
  layer_index : Int,
) -> Result[PacketHeaderMetadata, String] {
  @core.parse_packet_header_single_packet_with_tag_tree(
    @bytes.int_array_to_bytes(data), width, height, layer_index,
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
    @bytes.int_array_to_bytes(data), width, height, layer_index,
    added_passes_per_code_block,
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
    @bytes.int_array_to_bytes(data), width, height, packet_count,
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
    @bytes.int_array_to_bytes(data), width, height, packet_count,
    added_passes_per_packet_per_code_block,
  )
}
