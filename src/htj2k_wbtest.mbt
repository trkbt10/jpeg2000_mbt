///|
priv struct Htj2kTestCodeblockSpec {
  included : Bool
  zbp : Int
  passes : Int
  segment_lengths : Array[Int]
  segment_passes : Array[Int]
  codeword : Array[Int]
}

///|
priv struct Htj2kTestSingleCodeblockPacketSpec {
  first_inclusion : Bool
  zbp : Int
  passes : Int
  segment_lengths : Array[Int]
  segment_passes : Array[Int]
  codeword : Array[Int]
}

///|
fn htj2k_test_push_coding_pass_bits(bits : Array[Int], passes : Int) -> Unit {
  if passes == 1 {
    bits.push(0)
  } else if passes == 2 {
    bits.push(1)
    bits.push(0)
  } else if passes == 3 {
    push_bits(bits, 0b1100, 4)
  } else if passes == 4 {
    push_bits(bits, 0b1101, 4)
  } else if passes == 5 {
    push_bits(bits, 0b1110, 4)
  } else if passes <= 36 {
    push_bits(bits, 0b1111, 4)
    push_bits(bits, passes - 6, 5)
  } else if passes <= 164 {
    push_bits(bits, 0b1111, 4)
    push_bits(bits, 31, 5)
    push_bits(bits, passes - 37, 7)
  } else {
    panic()
  }
}

///|
fn htj2k_test_push_segment_length_bits_legacy(
  bits : Array[Int],
  segment_lengths : Array[Int],
  segment_passes : Array[Int],
) -> Unit {
  let count = if segment_lengths.length() < segment_passes.length() {
    segment_lengths.length()
  } else {
    segment_passes.length()
  }
  if count > 0 {
    // Retain the helper name, but encode B.10.7 with one Lblock prefix per contribution.
    bits.push(0)
  }
  for i in 0..<count {
    let width = 3 + @math.floor_log2(segment_passes[i])
    push_bits(bits, segment_lengths[i], width)
  }
}

///|
fn htj2k_test_single_codeblock_packet_header_bytes(
  packet : Htj2kTestSingleCodeblockPacketSpec,
) -> Array[Int] {
  let bits : Array[Int] = [1, 1]
  if packet.first_inclusion {
    for _ in 0..<packet.zbp {
      bits.push(0)
    }
    bits.push(1)
  }
  htj2k_test_push_coding_pass_bits(bits, packet.passes)
  htj2k_test_push_segment_length_bits_legacy(
    bits,
    packet.segment_lengths,
    packet.segment_passes,
  )
  pack_bits(bits)
}

///|
fn htj2k_like_minimal_single_codeblock_codestream(
  passes : Int,
  segment_lengths : Array[Int],
  segment_passes : Array[Int],
  codeword : Array[Int],
  width? : Int = 1,
  height? : Int = 1,
  zbp? : Int = 6,
  precision_bits? : Int = 8,
  code_block_style? : Int = 0x40,
) -> Bytes {
  htj2k_like_minimal_single_codeblock_multi_packet_codestream(
    [
      {
        first_inclusion: true,
        zbp,
        passes,
        segment_lengths,
        segment_passes,
        codeword,
      },
    ],
    width~,
    height~,
    precision_bits~,
    code_block_style~,
  )
}

///|
fn htj2k_like_minimal_single_codeblock_multi_packet_codestream(
  packets : Array[Htj2kTestSingleCodeblockPacketSpec],
  width? : Int = 1,
  height? : Int = 1,
  precision_bits? : Int = 8,
  code_block_style? : Int = 0x40,
) -> Bytes {
  guard packets.length() > 0 else { panic() }
  let data = sample_codestream_minimal()
  guard marker_index(data, 0xFF, 0x51) is Some(siz_at) else { panic() }
  guard marker_index(data, 0xFF, 0x52) is Some(cod_at) else { panic() }
  guard marker_index(data, 0xFF, 0xD9) is Some(eoc_at) else { panic() }
  patch_u32_be(data, siz_at + 6, width)
  patch_u32_be(data, siz_at + 10, height)
  patch_u32_be(data, siz_at + 22, width)
  patch_u32_be(data, siz_at + 26, height)
  data[siz_at + 40] = (precision_bits - 1) & 0x7F
  data[cod_at + 6] = (packets.length() >> 8) & 0xFF
  data[cod_at + 7] = packets.length() & 0xFF
  data[cod_at + 10] = 4
  data[cod_at + 11] = 4
  data[cod_at + 12] = code_block_style
  let with_cap = insert_bytes_at(data, cod_at, [
    0xFF, 0x50, 0x00, 0x08, 0x00, 0x02, 0x00, 0x00, 0x00, 0x05,
  ])
  let payload : Array[Int] = []
  for packet in packets {
    let header = htj2k_test_single_codeblock_packet_header_bytes(packet)
    for b in header {
      payload.push(b)
    }
    for b in packet.codeword {
      payload.push(b)
    }
  }
  guard marker_index(with_cap, 0xFF, 0x90) is Some(with_cap_sot_at) else {
    panic()
  }
  patch_u32_be(with_cap, with_cap_sot_at + 6, 14 + payload.length())
  let with_payload = insert_bytes_at(with_cap, eoc_at + 10, payload)
  @bytes.int_array_to_bytes(with_payload)
}

///|
fn baseline_like_minimal_single_codeblock_codestream(
  packet : Htj2kTestSingleCodeblockPacketSpec,
  width? : Int = 1,
  height? : Int = 1,
  precision_bits? : Int = 8,
  code_block_style? : Int = 0x00,
) -> Bytes {
  let data = sample_codestream_minimal()
  guard marker_index(data, 0xFF, 0x51) is Some(siz_at) else { panic() }
  guard marker_index(data, 0xFF, 0x52) is Some(cod_at) else { panic() }
  guard marker_index(data, 0xFF, 0x90) is Some(sot_at) else { panic() }
  guard marker_index(data, 0xFF, 0xD9) is Some(eoc_at) else { panic() }
  patch_u32_be(data, siz_at + 6, width)
  patch_u32_be(data, siz_at + 10, height)
  patch_u32_be(data, siz_at + 22, width)
  patch_u32_be(data, siz_at + 26, height)
  data[siz_at + 40] = (precision_bits - 1) & 0x7F
  data[cod_at + 6] = 0
  data[cod_at + 7] = 1
  data[cod_at + 10] = 4
  data[cod_at + 11] = 4
  data[cod_at + 12] = code_block_style
  let payload : Array[Int] = []
  let header = htj2k_test_single_codeblock_packet_header_bytes(packet)
  for b in header {
    payload.push(b)
  }
  for b in packet.codeword {
    payload.push(b)
  }
  patch_u32_be(data, sot_at + 6, 14 + payload.length())
  let with_payload = insert_bytes_at(data, eoc_at, payload)
  @bytes.int_array_to_bytes(with_payload)
}

///|
fn htj2k_like_minimal_two_tile_single_codeblock_codestream(
  tile0_packets : Array[Htj2kTestSingleCodeblockPacketSpec],
  tile1_packets : Array[Htj2kTestSingleCodeblockPacketSpec],
  precision_bits? : Int = 8,
  code_block_style? : Int = 0x40,
) -> Bytes {
  if tile0_packets.length() == 0 && tile1_packets.length() == 0 {
    panic()
  }
  let data = sample_codestream_minimal()
  guard marker_index(data, 0xFF, 0x51) is Some(siz_at) else { panic() }
  guard marker_index(data, 0xFF, 0x52) is Some(cod_at) else { panic() }
  patch_u32_be(data, siz_at + 6, 2)
  patch_u32_be(data, siz_at + 10, 1)
  patch_u32_be(data, siz_at + 22, 1)
  patch_u32_be(data, siz_at + 26, 1)
  data[siz_at + 40] = (precision_bits - 1) & 0x7F
  let layer_count = if tile0_packets.length() > tile1_packets.length() {
    tile0_packets.length()
  } else {
    tile1_packets.length()
  }
  data[cod_at + 6] = (layer_count >> 8) & 0xFF
  data[cod_at + 7] = layer_count & 0xFF
  data[cod_at + 10] = 4
  data[cod_at + 11] = 4
  data[cod_at + 12] = code_block_style
  let with_cap = insert_bytes_at(data, cod_at, [
    0xFF, 0x50, 0x00, 0x08, 0x00, 0x02, 0x00, 0x00, 0x00, 0x05,
  ])
  guard marker_index(with_cap, 0xFF, 0x90) is Some(with_cap_sot_at) else {
    panic()
  }
  let prefix : Array[Int] = []
  for i in 0..<with_cap_sot_at {
    prefix.push(with_cap[i])
  }
  let tile0_payload : Array[Int] = []
  for packet in tile0_packets {
    let header = htj2k_test_single_codeblock_packet_header_bytes(packet)
    for b in header {
      tile0_payload.push(b)
    }
    for b in packet.codeword {
      tile0_payload.push(b)
    }
  }
  let tile1_payload : Array[Int] = []
  for packet in tile1_packets {
    let header = htj2k_test_single_codeblock_packet_header_bytes(packet)
    for b in header {
      tile1_payload.push(b)
    }
    for b in packet.codeword {
      tile1_payload.push(b)
    }
  }
  let out = prefix
  let tile0_psot = 14 + tile0_payload.length()
  let tile1_psot = 14 + tile1_payload.length()
  let tile0_part = [
    0xFF,
    0x90,
    0x00,
    0x0A,
    0x00,
    0x00,
    (tile0_psot >> 24) & 0xFF,
    (tile0_psot >> 16) & 0xFF,
    (tile0_psot >> 8) & 0xFF,
    tile0_psot & 0xFF,
    0x00,
    0x01,
    0xFF,
    0x93,
  ]
  let tile1_part = [
    0xFF,
    0x90,
    0x00,
    0x0A,
    0x00,
    0x01,
    (tile1_psot >> 24) & 0xFF,
    (tile1_psot >> 16) & 0xFF,
    (tile1_psot >> 8) & 0xFF,
    tile1_psot & 0xFF,
    0x00,
    0x01,
    0xFF,
    0x93,
  ]
  for b in tile0_part {
    out.push(b)
  }
  for b in tile0_payload {
    out.push(b)
  }
  for b in tile1_part {
    out.push(b)
  }
  for b in tile1_payload {
    out.push(b)
  }
  out.push(0xFF)
  out.push(0xD9)
  @bytes.int_array_to_bytes(out)
}

///|
fn htj2k_test_multi_codeblock_packet_header_bytes(
  blocks : Array[Htj2kTestCodeblockSpec],
) -> Array[Int] {
  let bits : Array[Int] = [1]
  for block in blocks {
    if !block.included {
      bits.push(0)
      continue
    }
    bits.push(1)
    for _ in 0..<block.zbp {
      bits.push(0)
    }
    bits.push(1)
    htj2k_test_push_coding_pass_bits(bits, block.passes)
    htj2k_test_push_segment_length_bits_legacy(
      bits,
      block.segment_lengths,
      block.segment_passes,
    )
  }
  pack_bits(bits)
}

///|
fn htj2k_test_multi_codeblock_packet_header_bytes_legacy(
  blocks : Array[Htj2kTestCodeblockSpec],
) -> Array[Int] {
  let bits : Array[Int] = [1]
  for block in blocks {
    if !block.included {
      bits.push(0)
      continue
    }
    bits.push(1)
    for _ in 0..<block.zbp {
      bits.push(0)
    }
    bits.push(1)
    htj2k_test_push_coding_pass_bits(bits, block.passes)
    htj2k_test_push_segment_length_bits_legacy(
      bits,
      block.segment_lengths,
      block.segment_passes,
    )
  }
  pack_bits(bits)
}

///|
fn htj2k_test_multi_codeblock_followup_packet_header_bytes(
  blocks : Array[Htj2kTestCodeblockSpec],
) -> Array[Int] {
  let bits : Array[Int] = []
  let mut any_included = false
  for block in blocks {
    if block.included {
      any_included = true
      break
    }
  }
  bits.push(if any_included { 1 } else { 0 })
  if any_included {
    for block in blocks {
      bits.push(if block.included { 1 } else { 0 })
      if !block.included {
        continue
      }
      htj2k_test_push_coding_pass_bits(bits, block.passes)
      htj2k_test_push_segment_length_bits_legacy(
        bits,
        block.segment_lengths,
        block.segment_passes,
      )
    }
  }
  pack_bits(bits)
}

///|
fn htj2k_test_multi_codeblock_packet_payload(
  packets : Array[Array[Htj2kTestCodeblockSpec]],
) -> Array[Int] {
  let payload : Array[Int] = []
  for packet_idx in 0..<packets.length() {
    let packet = packets[packet_idx]
    let header = if packet_idx == 0 {
      htj2k_test_multi_codeblock_packet_header_bytes(packet)
    } else {
      htj2k_test_multi_codeblock_followup_packet_header_bytes(packet)
    }
    for b in header {
      payload.push(b)
    }
    for block in packet {
      if !block.included {
        continue
      }
      for b in block.codeword {
        payload.push(b)
      }
    }
  }
  payload
}

///|
fn htj2k_like_minimal_multi_codeblock_codestream(
  width : Int,
  height : Int,
  blocks : Array[Htj2kTestCodeblockSpec],
  precision_bits? : Int = 8,
  code_block_style? : Int = 0x40,
) -> Bytes {
  let data = sample_codestream_minimal()
  guard marker_index(data, 0xFF, 0x51) is Some(siz_at) else { panic() }
  guard marker_index(data, 0xFF, 0x52) is Some(cod_at) else { panic() }
  patch_u32_be(data, siz_at + 6, width)
  patch_u32_be(data, siz_at + 10, height)
  patch_u32_be(data, siz_at + 22, width)
  patch_u32_be(data, siz_at + 26, height)
  data[siz_at + 40] = (precision_bits - 1) & 0x7F
  data[cod_at + 10] = 0
  data[cod_at + 11] = 0
  data[cod_at + 12] = code_block_style
  let with_cap = insert_bytes_at(data, cod_at, [
    0xFF, 0x50, 0x00, 0x08, 0x00, 0x02, 0x00, 0x00, 0x00, 0x05,
  ])
  guard marker_index(with_cap, 0xFF, 0x90) is Some(sot_at) else { panic() }
  guard marker_index(with_cap, 0xFF, 0xD9) is Some(eoc_at) else { panic() }
  let header = htj2k_test_multi_codeblock_packet_header_bytes_legacy(blocks)
  let payload : Array[Int] = []
  for b in header {
    payload.push(b)
  }
  for block in blocks {
    if !block.included {
      continue
    }
    for b in block.codeword {
      payload.push(b)
    }
  }
  patch_u32_be(with_cap, sot_at + 6, 14 + payload.length())
  let with_payload = insert_bytes_at(with_cap, eoc_at, payload)
  @bytes.int_array_to_bytes(with_payload)
}

///|
fn htj2k_like_minimal_multi_codeblock_multi_packet_codestream(
  width : Int,
  height : Int,
  packets : Array[Array[Htj2kTestCodeblockSpec]],
  precision_bits? : Int = 8,
  code_block_style? : Int = 0x40,
) -> Bytes {
  guard packets.length() > 0 else { panic() }
  let data = sample_codestream_minimal()
  guard marker_index(data, 0xFF, 0x51) is Some(siz_at) else { panic() }
  guard marker_index(data, 0xFF, 0x52) is Some(cod_at) else { panic() }
  patch_u32_be(data, siz_at + 6, width)
  patch_u32_be(data, siz_at + 10, height)
  patch_u32_be(data, siz_at + 22, width)
  patch_u32_be(data, siz_at + 26, height)
  data[siz_at + 40] = (precision_bits - 1) & 0x7F
  data[cod_at + 6] = (packets.length() >> 8) & 0xFF
  data[cod_at + 7] = packets.length() & 0xFF
  data[cod_at + 10] = 0
  data[cod_at + 11] = 0
  data[cod_at + 12] = code_block_style
  let with_cap = insert_bytes_at(data, cod_at, [
    0xFF, 0x50, 0x00, 0x08, 0x00, 0x02, 0x00, 0x00, 0x00, 0x05,
  ])
  guard marker_index(with_cap, 0xFF, 0x90) is Some(sot_at) else { panic() }
  guard marker_index(with_cap, 0xFF, 0xD9) is Some(eoc_at) else { panic() }
  let payload = htj2k_test_multi_codeblock_packet_payload(packets)
  patch_u32_be(with_cap, sot_at + 6, 14 + payload.length())
  let with_payload = insert_bytes_at(with_cap, eoc_at, payload)
  @bytes.int_array_to_bytes(with_payload)
}

///|
fn htj2k_like_minimal_two_tile_multi_codeblock_multi_packet_codestream(
  tile_width : Int,
  height : Int,
  tile0_packets : Array[Array[Htj2kTestCodeblockSpec]],
  tile1_packets : Array[Array[Htj2kTestCodeblockSpec]],
  precision_bits? : Int = 8,
  code_block_style? : Int = 0x40,
) -> Bytes {
  if tile0_packets.length() == 0 && tile1_packets.length() == 0 {
    panic()
  }
  let data = sample_codestream_minimal()
  guard marker_index(data, 0xFF, 0x51) is Some(siz_at) else { panic() }
  guard marker_index(data, 0xFF, 0x52) is Some(cod_at) else { panic() }
  let total_width = tile_width * 2
  patch_u32_be(data, siz_at + 6, total_width)
  patch_u32_be(data, siz_at + 10, height)
  patch_u32_be(data, siz_at + 22, tile_width)
  patch_u32_be(data, siz_at + 26, height)
  data[siz_at + 40] = (precision_bits - 1) & 0x7F
  let layer_count = {
    let max_packets = if tile0_packets.length() > tile1_packets.length() {
      tile0_packets.length()
    } else {
      tile1_packets.length()
    }
    if max_packets > 0 {
      max_packets
    } else {
      1
    }
  }
  data[cod_at + 6] = (layer_count >> 8) & 0xFF
  data[cod_at + 7] = layer_count & 0xFF
  data[cod_at + 10] = 0
  data[cod_at + 11] = 0
  data[cod_at + 12] = code_block_style
  let with_cap = insert_bytes_at(data, cod_at, [
    0xFF, 0x50, 0x00, 0x08, 0x00, 0x02, 0x00, 0x00, 0x00, 0x05,
  ])
  guard marker_index(with_cap, 0xFF, 0x90) is Some(with_cap_sot_at) else {
    panic()
  }
  let prefix : Array[Int] = []
  for i in 0..<with_cap_sot_at {
    prefix.push(with_cap[i])
  }
  let tile0_payload = htj2k_test_multi_codeblock_packet_payload(tile0_packets)
  let tile1_payload = htj2k_test_multi_codeblock_packet_payload(tile1_packets)
  let out = prefix
  let tile0_psot = 14 + tile0_payload.length()
  let tile1_psot = 14 + tile1_payload.length()
  let tile0_part = [
    0xFF,
    0x90,
    0x00,
    0x0A,
    0x00,
    0x00,
    (tile0_psot >> 24) & 0xFF,
    (tile0_psot >> 16) & 0xFF,
    (tile0_psot >> 8) & 0xFF,
    tile0_psot & 0xFF,
    0x00,
    0x01,
    0xFF,
    0x93,
  ]
  let tile1_part = [
    0xFF,
    0x90,
    0x00,
    0x0A,
    0x00,
    0x01,
    (tile1_psot >> 24) & 0xFF,
    (tile1_psot >> 16) & 0xFF,
    (tile1_psot >> 8) & 0xFF,
    tile1_psot & 0xFF,
    0x00,
    0x01,
    0xFF,
    0x93,
  ]
  for b in tile0_part {
    out.push(b)
  }
  for b in tile0_payload {
    out.push(b)
  }
  for b in tile1_part {
    out.push(b)
  }
  for b in tile1_payload {
    out.push(b)
  }
  out.push(0xFF)
  out.push(0xD9)
  @bytes.int_array_to_bytes(out)
}

///|
fn htj2k_test_replace_marker_segment(
  data : Array[Int],
  marker_hi : Int,
  marker_lo : Int,
  replacement : Array[Int],
) -> Array[Int] {
  guard marker_index(data, marker_hi, marker_lo) is Some(at) else { panic() }
  let seg_len = (data[at + 2] << 8) | data[at + 3]
  let end = at + 2 + seg_len
  let out : Array[Int] = []
  for i in 0..<at {
    out.push(data[i])
  }
  for b in replacement {
    out.push(b)
  }
  for i in end..<data.length() {
    out.push(data[i])
  }
  out
}

///|
fn htj2k_with_main_header_coc_ht_override(data : Bytes) -> Bytes {
  let raw = @bytes.bytes_to_int_array(data)
  guard marker_index(raw, 0xFF, 0x52) is Some(cod_at) else { panic() }
  guard marker_index(raw, 0xFF, 0x90) is Some(sot_at) else { panic() }
  raw[cod_at + 12] = 0x00
  let extra : Array[Int] = [
    0xFF, 0x53, 0x00, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00,
  ]
  @bytes.int_array_to_bytes(insert_bytes_at(raw, sot_at, extra))
}

///|
fn htj2k_with_main_header_coc_qcc_ht_override(data : Bytes) -> Bytes {
  let raw = @bytes.bytes_to_int_array(data)
  guard marker_index(raw, 0xFF, 0x52) is Some(cod_at) else { panic() }
  raw[cod_at + 12] = 0x00
  let replaced_qcd = htj2k_test_replace_marker_segment(raw, 0xFF, 0x5C, [
    0xFF, 0x5C, 0x00, 0x05, 0x01, 0x38, 0x00,
  ])
  guard marker_index(replaced_qcd, 0xFF, 0x90) is Some(sot_at) else { panic() }
  @bytes.int_array_to_bytes(
    insert_bytes_at(replaced_qcd, sot_at, [
      0xFF, 0x53, 0x00, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0xFF, 0x5D,
      0x00, 0x05, 0x00, 0x00, 0x00,
    ]),
  )
}

///|
fn htj2k_with_main_header_rgn(data : Bytes, shift : Int) -> Bytes {
  let raw = @bytes.bytes_to_int_array(data)
  guard marker_index(raw, 0xFF, 0x90) is Some(sot_at) else { panic() }
  @bytes.int_array_to_bytes(
    insert_bytes_at(raw, sot_at, [0xFF, 0x5E, 0x00, 0x05, 0x00, 0x00, shift]),
  )
}

///|
fn htj2k_with_tile_header_rgn(data : Bytes, shift : Int) -> Bytes {
  htj2k_with_tile_header_rgn_at_tile_part(data, shift, 0)
}

///|
fn htj2k_with_tile_header_rgn_at_tile_part(
  data : Bytes,
  shift : Int,
  tile_part_ordinal : Int,
) -> Bytes {
  let raw = @bytes.bytes_to_int_array(data)
  guard marker_index_nth(raw, 0xFF, 0x90, tile_part_ordinal) is Some(sot_at) else {
    panic()
  }
  guard marker_index_nth(raw, 0xFF, 0x93, tile_part_ordinal) is Some(sod_at) else {
    panic()
  }
  let extra = [0xFF, 0x5E, 0x00, 0x05, 0x00, 0x00, shift]
  let current_psot = read_u32_be(raw, sot_at + 6)
  patch_u32_be(raw, sot_at + 6, current_psot + extra.length())
  @bytes.int_array_to_bytes(insert_bytes_at(raw, sod_at, extra))
}

///|
fn htj2k_with_tile_header_coc_qcc_ht_override(data : Bytes) -> Bytes {
  htj2k_with_tile_header_coc_qcc_ht_override_at_tile_part(data, 0)
}

///|
fn htj2k_with_tile_header_coc_qcc_ht_override_at_tile_part(
  data : Bytes,
  tile_part_ordinal : Int,
  replace_main_qcd? : Bool = true,
) -> Bytes {
  let raw = @bytes.bytes_to_int_array(data)
  guard marker_index(raw, 0xFF, 0x52) is Some(cod_at) else { panic() }
  raw[cod_at + 12] = 0x00
  let with_main_qcd = if replace_main_qcd {
    htj2k_test_replace_marker_segment(raw, 0xFF, 0x5C, [
      0xFF, 0x5C, 0x00, 0x05, 0x01, 0x38, 0x00,
    ])
  } else {
    raw
  }
  guard marker_index_nth(with_main_qcd, 0xFF, 0x90, tile_part_ordinal)
    is Some(sot_at) else {
    panic()
  }
  guard marker_index_nth(with_main_qcd, 0xFF, 0x93, tile_part_ordinal)
    is Some(sod_at) else {
    panic()
  }
  let extra = [
    0xFF, 0x53, 0x00, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0xFF, 0x5D,
    0x00, 0x05, 0x00, 0x00, 0x00,
  ]
  let current_psot = read_u32_be(with_main_qcd, sot_at + 6)
  patch_u32_be(with_main_qcd, sot_at + 6, current_psot + extra.length())
  @bytes.int_array_to_bytes(insert_bytes_at(with_main_qcd, sod_at, extra))
}

///|
fn htj2k_fixture_bytes(path : String) -> Bytes? {
  let loaded = Ok(@fs.read_file_to_bytes(path)) catch { _ => Err(()) }
  match loaded {
    Ok(bytes) => Some(bytes)
    Err(_) => None
  }
}

///|
fn htj2k_like_minimal_codestream() -> Bytes {
  let data = sample_codestream_minimal()
  guard marker_index(data, 0xFF, 0x52) is Some(cod_at) else { panic() }
  data[cod_at + 12] = 0x40
  let with_cap = insert_bytes_at(data, cod_at, [
    0xFF, 0x50, 0x00, 0x08, 0x00, 0x02, 0x00, 0x00, 0x00, 0x05,
  ])
  @bytes.int_array_to_bytes(with_cap)
}

///|
fn htj2k_like_minimal_tile_cleanup_codestream() -> Bytes {
  let data = sample_codestream_minimal()
  guard marker_index(data, 0xFF, 0x90) is Some(sot_at) else { panic() }
  guard marker_index(data, 0xFF, 0x93) is Some(sod_at) else { panic() }
  let tile_cod = [
    0xFF, 0x52, 0x00, 0x0C, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x40,
    0x00,
  ]
  patch_u32_be(data, sot_at + 6, 14 + tile_cod.length())
  let with_tile_cod = insert_bytes_at(data, sod_at, tile_cod)
  @bytes.int_array_to_bytes(with_tile_cod)
}

///|
test "decode_samples accepts empty-payload HTJ2K codestream via zero recon" {
  let decoded = decode_samples(htj2k_like_minimal_codestream())
  guard decoded is Ok(result) else {
    fail("empty-payload HTJ2K should use zero reconstruction")
  }
  assert_true(
    result.sample_layout.contains("DS-ZERO-PACKET-RECON:empty_sod_payload"),
  )
}

///|
test "decode_samples accepts tile-header HTJ2K codestream via zero recon" {
  let decoded = decode_samples(
    htj2k_like_minimal_tile_cleanup_codestream(),
  )
  guard decoded is Ok(result) else {
    fail("tile-header HTJ2K should use zero reconstruction")
  }
  assert_true(
    result.sample_layout.contains("DS-ZERO-PACKET-RECON:empty_sod_payload"),
  )
}

///|
test "decode_samples accepts synthetic single-codeblock HT cleanup codestream" {
  let decoded = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(1, [5], [1], [
      0xE3, 0x00, 0x07, 0x74, 0x00,
    ]),
  )
  guard decoded is Ok(result) else {
    fail("synthetic HT cleanup codestream should decode")
  }
  assert_eq(result.width, 1)
  assert_eq(result.height, 1)
  assert_eq(result.num_components, 1)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
  assert_eq(result.samples.length(), 1)
}

///|
test "decode_samples accepts synthetic single-codeblock HT cleanup codestream with main-header RGN" {
  let decoded = decode_samples(
    htj2k_with_main_header_rgn(
      htj2k_like_minimal_single_codeblock_codestream(1, [5], [1], [
        0xE3, 0x00, 0x07, 0x74, 0x00,
      ]),
      1,
    ),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(1, [5], [1], [
      0xE3, 0x00, 0x07, 0x74, 0x00,
    ]),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail("synthetic HT cleanup + RGN codestream should decode: \{msg}")
    }
    fail("synthetic HT cleanup + RGN codestream should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("baseline synthetic HT cleanup codestream should decode")
  }
  assert_eq(result.samples, expected.samples)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples accepts synthetic single-codeblock multi-layer HT codestream with main-header RGN" {
  let packets = [
    {
      first_inclusion: true,
      zbp: 6,
      passes: 1,
      segment_lengths: [5],
      segment_passes: [1],
      codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
    },
    {
      first_inclusion: false,
      zbp: 0,
      passes: 2,
      segment_lengths: [1],
      segment_passes: [2],
      codeword: [0x00],
    },
  ]
  let decoded = decode_samples(
    htj2k_with_main_header_rgn(
      htj2k_like_minimal_single_codeblock_multi_packet_codestream(packets),
      1,
    ),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_single_codeblock_multi_packet_codestream(packets),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail("synthetic multi-layer HT + RGN codestream should decode: \{msg}")
    }
    fail("synthetic multi-layer HT + RGN codestream should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("baseline synthetic multi-layer HT codestream should decode")
  }
  assert_eq(result.samples, expected.samples)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples accepts synthetic single-codeblock HT cleanup codestream with tile-header RGN" {
  let decoded = decode_samples(
    htj2k_with_tile_header_rgn(
      htj2k_like_minimal_single_codeblock_codestream(1, [5], [1], [
        0xE3, 0x00, 0x07, 0x74, 0x00,
      ]),
      1,
    ),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(1, [5], [1], [
      0xE3, 0x00, 0x07, 0x74, 0x00,
    ]),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail(
        "synthetic HT cleanup + tile-header RGN codestream should decode: \{msg}",
      )
    }
    fail("synthetic HT cleanup + tile-header RGN codestream should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("baseline synthetic HT cleanup codestream should decode")
  }
  assert_eq(result.samples, expected.samples)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples accepts synthetic single-codeblock multi-layer HT codestream with tile-header RGN" {
  let packets = [
    {
      first_inclusion: true,
      zbp: 6,
      passes: 1,
      segment_lengths: [5],
      segment_passes: [1],
      codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
    },
    {
      first_inclusion: false,
      zbp: 0,
      passes: 2,
      segment_lengths: [1],
      segment_passes: [2],
      codeword: [0x00],
    },
  ]
  let decoded = decode_samples(
    htj2k_with_tile_header_rgn(
      htj2k_like_minimal_single_codeblock_multi_packet_codestream(packets),
      1,
    ),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_single_codeblock_multi_packet_codestream(packets),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail(
        "synthetic multi-layer HT + tile-header RGN codestream should decode: \{msg}",
      )
    }
    fail("synthetic multi-layer HT + tile-header RGN codestream should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("baseline synthetic multi-layer HT codestream should decode")
  }
  assert_eq(result.samples, expected.samples)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples assembles synthetic no-dwt multi-tile HT cleanup codestream" {
  let decoded = decode_samples(
    htj2k_like_minimal_two_tile_single_codeblock_codestream(
      [
        {
          first_inclusion: true,
          zbp: 6,
          passes: 1,
          segment_lengths: [5],
          segment_passes: [1],
          codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
        },
      ],
      [
        {
          first_inclusion: true,
          zbp: 6,
          passes: 1,
          segment_lengths: [5],
          segment_passes: [1],
          codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
        },
      ],
    ),
  )
  let single_v = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(1, [5], [1], [
      0xE3, 0x00, 0x07, 0x74, 0x00,
    ]),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail("synthetic multi-tile HT cleanup codestream should decode: \{msg}")
    }
    fail("synthetic multi-tile HT cleanup codestream should decode")
  }
  guard single_v is Ok(single) else {
    fail("synthetic single-tile HT cleanup codestream should decode")
  }
  let expected : Array[Int] = []
  for b in single.samples {
    expected.push(b.to_int())
  }
  for b in single.samples {
    expected.push(b.to_int())
  }
  assert_eq(result.width, 2)
  assert_eq(result.height, 1)
  assert_eq(result.num_components, 1)
  let actual = @bytes.bytes_to_int_array(result.samples)
  if actual != expected {
    fail(
      "synthetic multi-tile HT cleanup mismatch: actual=\{actual} expected=\{expected} layout=\{result.sample_layout}",
    )
  }
  assert_true(
    result.sample_layout.contains("DS-TILE-SEQUENTIAL-DECODE:nodwt_seq_tiles2"),
  )
}

///|
test "decode_samples assembles synthetic no-dwt multi-tile multi-layer HT codestream" {
  let tile_packets = [
    {
      first_inclusion: true,
      zbp: 6,
      passes: 1,
      segment_lengths: [5],
      segment_passes: [1],
      codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
    },
    {
      first_inclusion: false,
      zbp: 0,
      passes: 2,
      segment_lengths: [1],
      segment_passes: [2],
      codeword: [0x00],
    },
  ]
  let decoded = decode_samples(
    htj2k_like_minimal_two_tile_single_codeblock_codestream(
      tile_packets, tile_packets,
    ),
  )
  let single_v = decode_samples(
    htj2k_like_minimal_single_codeblock_multi_packet_codestream(tile_packets),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail(
        "synthetic multi-tile multi-layer HT codestream should decode: \{msg}",
      )
    }
    fail("synthetic multi-tile multi-layer HT codestream should decode")
  }
  guard single_v is Ok(single) else {
    fail("synthetic single-tile multi-layer HT codestream should decode")
  }
  let expected : Array[Int] = []
  for b in single.samples {
    expected.push(b.to_int())
  }
  for b in single.samples {
    expected.push(b.to_int())
  }
  let actual = @bytes.bytes_to_int_array(result.samples)
  if actual != expected {
    fail(
      "synthetic multi-tile multi-layer HT mismatch: actual=\{actual} expected=\{expected} layout=\{result.sample_layout}",
    )
  }
  assert_eq(result.width, 2)
  assert_eq(result.height, 1)
  assert_eq(result.num_components, 1)
  assert_true(
    result.sample_layout.contains("DS-TILE-SEQUENTIAL-DECODE:nodwt_seq_tiles2"),
  )
}

///|
test "decode_samples assembles synthetic no-dwt multi-tile multi-layer HT codestream with tile1-header RGN" {
  let tile1_packets = [
    {
      first_inclusion: true,
      zbp: 6,
      passes: 1,
      segment_lengths: [5],
      segment_passes: [1],
      codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
    },
    {
      first_inclusion: false,
      zbp: 0,
      passes: 2,
      segment_lengths: [1],
      segment_passes: [2],
      codeword: [0x00],
    },
  ]
  let decoded = decode_samples(
    htj2k_with_tile_header_rgn_at_tile_part(
      htj2k_like_minimal_two_tile_single_codeblock_codestream([], tile1_packets),
      1,
      1,
    ),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_single_codeblock_multi_packet_codestream(tile1_packets),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail(
        "synthetic multi-tile multi-layer HT + tile1-header RGN codestream should decode: \{msg}",
      )
    }
    fail(
      "synthetic multi-tile multi-layer HT + tile1-header RGN codestream should decode",
    )
  }
  guard expected_v is Ok(expected) else {
    fail("single-tile multi-layer HT codestream should decode")
  }
  let expected_samples = [128, ..@bytes.bytes_to_int_array(expected.samples)]
  let actual = @bytes.bytes_to_int_array(result.samples)
  if actual != expected_samples {
    fail(
      "synthetic multi-tile multi-layer HT + tile1-header RGN mismatch: actual=\{actual} expected=\{expected_samples} layout=\{result.sample_layout}",
    )
  }
  assert_eq(result.width, 2)
  assert_eq(result.height, 1)
  assert_eq(result.num_components, 1)
  assert_true(
    result.sample_layout.contains("DS-TILE-SEQUENTIAL-DECODE:nodwt_seq_tiles2"),
  )
}

///|
test "decode_samples assembles synthetic mixed baseline and tile1-header HT codestream" {
  let tile0_packet = {
    first_inclusion: true,
    zbp: 0,
    passes: 1,
    segment_lengths: [1],
    segment_passes: [1],
    codeword: [0x7A],
  }
  let tile1_packets = [
    {
      first_inclusion: true,
      zbp: 6,
      passes: 1,
      segment_lengths: [5],
      segment_passes: [1],
      codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
    },
  ]
  let decoded = decode_samples(
    htj2k_with_tile_header_coc_qcc_ht_override_at_tile_part(
      htj2k_like_minimal_two_tile_single_codeblock_codestream(
        [tile0_packet],
        tile1_packets,
        code_block_style=0x00,
      ),
      1,
      replace_main_qcd=false,
    ),
  )
  let baseline_v = decode_samples(
    baseline_like_minimal_single_codeblock_codestream(tile0_packet),
  )
  let expected_ht_v = decode_samples(
    htj2k_with_tile_header_coc_qcc_ht_override_at_tile_part(
      htj2k_like_minimal_single_codeblock_codestream(
        1,
        [5],
        [1],
        [0xE3, 0x00, 0x07, 0x74, 0x00],
        code_block_style=0x00,
      ),
      0,
      replace_main_qcd=false,
    ),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail("synthetic mixed baseline/HT codestream should decode: \{msg}")
    }
    fail("synthetic mixed baseline/HT codestream should decode")
  }
  guard baseline_v is Ok(baseline) else {
    fail("synthetic baseline single-codeblock codestream should decode")
  }
  assert_true(
    baseline.sample_layout.contains("component0:raster:le:real_decode"),
  )
  guard expected_ht_v is Ok(expected_ht) else {
    fail("single-tile tile-header COC/QCC HT codestream should decode")
  }
  let expected_samples = [128, ..@bytes.bytes_to_int_array(expected_ht.samples)]
  let actual = @bytes.bytes_to_int_array(result.samples)
  if actual != expected_samples {
    fail(
      "synthetic mixed baseline/HT mismatch: actual=\{actual} expected=\{expected_samples} layout=\{result.sample_layout}",
    )
  }
  assert_eq(result.width, 2)
  assert_eq(result.height, 1)
  assert_eq(result.num_components, 1)
  assert_true(
    result.sample_layout.contains("DS-TILE-SEQUENTIAL-DECODE:nodwt_seq_tiles2"),
  )
}

///|
test "decode_samples assembles synthetic mixed baseline and tile1-header multi-layer HT codestream" {
  let tile0_packet = {
    first_inclusion: true,
    zbp: 0,
    passes: 1,
    segment_lengths: [1],
    segment_passes: [1],
    codeword: [0x7A],
  }
  let tile1_packets = [
    {
      first_inclusion: true,
      zbp: 6,
      passes: 1,
      segment_lengths: [5],
      segment_passes: [1],
      codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
    },
    {
      first_inclusion: false,
      zbp: 0,
      passes: 2,
      segment_lengths: [1],
      segment_passes: [2],
      codeword: [0x00],
    },
  ]
  let decoded = decode_samples(
    htj2k_with_tile_header_coc_qcc_ht_override_at_tile_part(
      htj2k_like_minimal_two_tile_single_codeblock_codestream(
        [tile0_packet],
        tile1_packets,
        code_block_style=0x00,
      ),
      1,
      replace_main_qcd=false,
    ),
  )
  let baseline_v = decode_samples(
    baseline_like_minimal_single_codeblock_codestream(tile0_packet),
  )
  let expected_ht_v = decode_samples(
    htj2k_with_tile_header_coc_qcc_ht_override_at_tile_part(
      htj2k_like_minimal_single_codeblock_multi_packet_codestream(
        tile1_packets,
        code_block_style=0x00,
      ),
      0,
      replace_main_qcd=false,
    ),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail(
        "synthetic mixed baseline/multi-layer HT codestream should decode: \{msg}",
      )
    }
    fail("synthetic mixed baseline/multi-layer HT codestream should decode")
  }
  guard baseline_v is Ok(baseline) else {
    fail("synthetic baseline single-codeblock codestream should decode")
  }
  assert_true(
    baseline.sample_layout.contains("component0:raster:le:real_decode"),
  )
  guard expected_ht_v is Ok(expected_ht) else {
    fail(
      "single-tile multi-layer tile-header COC/QCC HT codestream should decode",
    )
  }
  let expected_samples = [128, ..@bytes.bytes_to_int_array(expected_ht.samples)]
  let actual = @bytes.bytes_to_int_array(result.samples)
  if actual != expected_samples {
    fail(
      "synthetic mixed baseline/multi-layer HT mismatch: actual=\{actual} expected=\{expected_samples} layout=\{result.sample_layout}",
    )
  }
  assert_eq(result.width, 2)
  assert_eq(result.height, 1)
  assert_eq(result.num_components, 1)
  assert_true(
    result.sample_layout.contains("DS-TILE-SEQUENTIAL-DECODE:nodwt_seq_tiles2"),
  )
}

///|
test "decode_samples assembles synthetic no-dwt multi-tile HT via tile1-header COC/QCC override" {
  let decoded = decode_samples(
    htj2k_with_tile_header_coc_qcc_ht_override_at_tile_part(
      htj2k_like_minimal_two_tile_single_codeblock_codestream(
        [],
        [
          {
            first_inclusion: true,
            zbp: 6,
            passes: 1,
            segment_lengths: [5],
            segment_passes: [1],
            codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
          },
        ],
        code_block_style=0x00,
      ),
      1,
      replace_main_qcd=false,
    ),
  )
  let expected_v = decode_samples(
    htj2k_with_tile_header_coc_qcc_ht_override_at_tile_part(
      htj2k_like_minimal_single_codeblock_codestream(
        1,
        [5],
        [1],
        [0xE3, 0x00, 0x07, 0x74, 0x00],
        code_block_style=0x00,
      ),
      0,
      replace_main_qcd=false,
    ),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail(
        "synthetic multi-tile tile1-header COC/QCC HT codestream should decode: \{msg}",
      )
    }
    fail(
      "synthetic multi-tile tile1-header COC/QCC HT codestream should decode",
    )
  }
  guard expected_v is Ok(expected) else {
    fail("single-tile tile-header COC/QCC HT codestream should decode")
  }
  let expected_samples = [128, ..@bytes.bytes_to_int_array(expected.samples)]
  let actual = @bytes.bytes_to_int_array(result.samples)
  if actual != expected_samples {
    fail(
      "synthetic multi-tile tile1-header COC/QCC HT mismatch: actual=\{actual} expected=\{expected_samples} layout=\{result.sample_layout}",
    )
  }
  assert_eq(result.width, 2)
  assert_eq(result.height, 1)
  assert_eq(result.num_components, 1)
  assert_true(
    result.sample_layout.contains("DS-TILE-SEQUENTIAL-DECODE:nodwt_seq_tiles2"),
  )
}

///|
test "decode_samples assembles synthetic no-dwt multi-tile multi-layer HT via tile1-header COC/QCC override" {
  let tile1_packets = [
    {
      first_inclusion: true,
      zbp: 6,
      passes: 1,
      segment_lengths: [5],
      segment_passes: [1],
      codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
    },
    {
      first_inclusion: false,
      zbp: 0,
      passes: 2,
      segment_lengths: [1],
      segment_passes: [2],
      codeword: [0x00],
    },
  ]
  let decoded = decode_samples(
    htj2k_with_tile_header_coc_qcc_ht_override_at_tile_part(
      htj2k_like_minimal_two_tile_single_codeblock_codestream(
        [],
        tile1_packets,
        code_block_style=0x00,
      ),
      1,
      replace_main_qcd=false,
    ),
  )
  let expected_v = decode_samples(
    htj2k_with_tile_header_coc_qcc_ht_override_at_tile_part(
      htj2k_like_minimal_single_codeblock_multi_packet_codestream(
        tile1_packets,
        code_block_style=0x00,
      ),
      0,
      replace_main_qcd=false,
    ),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail(
        "synthetic multi-tile multi-layer tile1-header COC/QCC HT codestream should decode: \{msg}",
      )
    }
    fail(
      "synthetic multi-tile multi-layer tile1-header COC/QCC HT codestream should decode",
    )
  }
  guard expected_v is Ok(expected) else {
    fail(
      "single-tile multi-layer tile-header COC/QCC HT codestream should decode",
    )
  }
  let expected_samples = [128, ..@bytes.bytes_to_int_array(expected.samples)]
  let actual = @bytes.bytes_to_int_array(result.samples)
  if actual != expected_samples {
    fail(
      "synthetic multi-tile multi-layer tile1-header COC/QCC HT mismatch: actual=\{actual} expected=\{expected_samples} layout=\{result.sample_layout}",
    )
  }
  assert_eq(result.width, 2)
  assert_eq(result.height, 1)
  assert_eq(result.num_components, 1)
  assert_true(
    result.sample_layout.contains("DS-TILE-SEQUENTIAL-DECODE:nodwt_seq_tiles2"),
  )
}

///|
test "decode_samples assembles synthetic no-dwt multi-tile multi-codeblock HT via tile1-header COC/QCC override" {
  let tile1_packets = [
    [
      {
        included: true,
        zbp: 6,
        passes: 1,
        segment_lengths: [5],
        segment_passes: [1],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
      },
      {
        included: true,
        zbp: 6,
        passes: 1,
        segment_lengths: [5],
        segment_passes: [1],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
      },
    ],
  ]
  let decoded = decode_samples(
    htj2k_with_tile_header_coc_qcc_ht_override_at_tile_part(
      htj2k_like_minimal_two_tile_multi_codeblock_multi_packet_codestream(
        5,
        1,
        [],
        tile1_packets,
        code_block_style=0x00,
      ),
      1,
      replace_main_qcd=false,
    ),
  )
  let expected_v = decode_samples(
    htj2k_with_tile_header_coc_qcc_ht_override_at_tile_part(
      htj2k_like_minimal_multi_codeblock_multi_packet_codestream(
        5,
        1,
        tile1_packets,
        code_block_style=0x00,
      ),
      0,
      replace_main_qcd=false,
    ),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail(
        "synthetic multi-tile multi-codeblock tile1-header COC/QCC HT codestream should decode: \{msg}",
      )
    }
    fail(
      "synthetic multi-tile multi-codeblock tile1-header COC/QCC HT codestream should decode",
    )
  }
  guard expected_v is Ok(expected) else {
    fail(
      "single-tile multi-codeblock tile-header COC/QCC HT codestream should decode",
    )
  }
  let expected_samples = [
    128,
    128,
    128,
    128,
    128,
    ..@bytes.bytes_to_int_array(expected.samples),
  ]
  let actual = @bytes.bytes_to_int_array(result.samples)
  if actual != expected_samples {
    fail(
      "synthetic multi-tile multi-codeblock tile1-header COC/QCC HT mismatch: actual=\{actual} expected=\{expected_samples} layout=\{result.sample_layout}",
    )
  }
  assert_eq(result.width, 10)
  assert_eq(result.height, 1)
  assert_eq(result.num_components, 1)
  assert_true(
    result.sample_layout.contains("DS-TILE-SEQUENTIAL-DECODE:nodwt_seq_tiles2"),
  )
}

///|
test "decode_samples assembles synthetic no-dwt multi-tile multi-codeblock multi-layer HT via tile1-header COC/QCC override" {
  let tile1_packets = [
    [
      {
        included: true,
        zbp: 6,
        passes: 1,
        segment_lengths: [5],
        segment_passes: [1],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
      },
      {
        included: true,
        zbp: 6,
        passes: 1,
        segment_lengths: [5],
        segment_passes: [1],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
      },
    ],
    [
      {
        included: true,
        zbp: 0,
        passes: 2,
        segment_lengths: [1],
        segment_passes: [2],
        codeword: [0x00],
      },
      {
        included: false,
        zbp: 0,
        passes: 0,
        segment_lengths: [],
        segment_passes: [],
        codeword: [],
      },
    ],
  ]
  let decoded = decode_samples(
    htj2k_with_tile_header_coc_qcc_ht_override_at_tile_part(
      htj2k_like_minimal_two_tile_multi_codeblock_multi_packet_codestream(
        5,
        1,
        [],
        tile1_packets,
        code_block_style=0x00,
      ),
      1,
      replace_main_qcd=false,
    ),
  )
  let expected_v = decode_samples(
    htj2k_with_tile_header_coc_qcc_ht_override_at_tile_part(
      htj2k_like_minimal_multi_codeblock_multi_packet_codestream(
        5,
        1,
        tile1_packets,
        code_block_style=0x00,
      ),
      0,
      replace_main_qcd=false,
    ),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail(
        "synthetic multi-tile multi-codeblock multi-layer tile1-header COC/QCC HT codestream should decode: \{msg}",
      )
    }
    fail(
      "synthetic multi-tile multi-codeblock multi-layer tile1-header COC/QCC HT codestream should decode",
    )
  }
  guard expected_v is Ok(expected) else {
    fail(
      "single-tile multi-codeblock multi-layer tile-header COC/QCC HT codestream should decode",
    )
  }
  let expected_samples = [
    128,
    128,
    128,
    128,
    128,
    ..@bytes.bytes_to_int_array(expected.samples),
  ]
  let actual = @bytes.bytes_to_int_array(result.samples)
  if actual != expected_samples {
    fail(
      "synthetic multi-tile multi-codeblock multi-layer tile1-header COC/QCC HT mismatch: actual=\{actual} expected=\{expected_samples} layout=\{result.sample_layout}",
    )
  }
  assert_eq(result.width, 10)
  assert_eq(result.height, 1)
  assert_eq(result.num_components, 1)
  assert_true(
    result.sample_layout.contains("DS-TILE-SEQUENTIAL-DECODE:nodwt_seq_tiles2"),
  )
}

///|
test "decode_samples accepts synthetic single-codeblock HT cleanup via main-header COC override" {
  let decoded = decode_samples(
    htj2k_with_main_header_coc_ht_override(
      htj2k_like_minimal_single_codeblock_codestream(1, [5], [1], [
        0xE3, 0x00, 0x07, 0x74, 0x00,
      ]),
    ),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(1, [5], [1], [
      0xE3, 0x00, 0x07, 0x74, 0x00,
    ]),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail("synthetic main-header COC HT codestream should decode: \{msg}")
    }
    fail("synthetic main-header COC HT codestream should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("baseline synthetic HT cleanup codestream should decode")
  }
  assert_eq(result.samples, expected.samples)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples accepts synthetic single-codeblock multi-layer HT via main-header COC override" {
  let decoded = decode_samples(
    htj2k_with_main_header_coc_ht_override(
      htj2k_like_minimal_single_codeblock_multi_packet_codestream([
        {
          first_inclusion: true,
          zbp: 6,
          passes: 1,
          segment_lengths: [5],
          segment_passes: [1],
          codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
        },
        {
          first_inclusion: false,
          zbp: 0,
          passes: 2,
          segment_lengths: [1],
          segment_passes: [2],
          codeword: [0x00],
        },
      ]),
    ),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_single_codeblock_multi_packet_codestream([
      {
        first_inclusion: true,
        zbp: 6,
        passes: 1,
        segment_lengths: [5],
        segment_passes: [1],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
      },
      {
        first_inclusion: false,
        zbp: 0,
        passes: 2,
        segment_lengths: [1],
        segment_passes: [2],
        codeword: [0x00],
      },
    ]),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail(
        "synthetic main-header COC multi-layer HT codestream should decode: \{msg}",
      )
    }
    fail("synthetic main-header COC multi-layer HT codestream should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("baseline synthetic multi-layer HT codestream should decode")
  }
  assert_eq(result.samples, expected.samples)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples accepts synthetic single-codeblock HT cleanup via main-header COC/QCC override" {
  let decoded = decode_samples(
    htj2k_with_main_header_coc_qcc_ht_override(
      htj2k_like_minimal_single_codeblock_codestream(1, [5], [1], [
        0xE3, 0x00, 0x07, 0x74, 0x00,
      ]),
    ),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(1, [5], [1], [
      0xE3, 0x00, 0x07, 0x74, 0x00,
    ]),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail("synthetic main-header COC/QCC HT codestream should decode: \{msg}")
    }
    fail("synthetic main-header COC/QCC HT codestream should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("baseline synthetic HT cleanup codestream should decode")
  }
  assert_eq(result.samples, expected.samples)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples accepts synthetic single-codeblock HT cleanup via tile-header COC/QCC override" {
  let decoded = decode_samples(
    htj2k_with_tile_header_coc_qcc_ht_override(
      htj2k_like_minimal_single_codeblock_codestream(1, [5], [1], [
        0xE3, 0x00, 0x07, 0x74, 0x00,
      ]),
    ),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(1, [5], [1], [
      0xE3, 0x00, 0x07, 0x74, 0x00,
    ]),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail("synthetic tile-header COC/QCC HT codestream should decode: \{msg}")
    }
    fail("synthetic tile-header COC/QCC HT codestream should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("baseline synthetic HT cleanup codestream should decode")
  }
  assert_eq(result.samples, expected.samples)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples accepts synthetic single-codeblock multi-layer HT via tile-header COC/QCC override" {
  let decoded = decode_samples(
    htj2k_with_tile_header_coc_qcc_ht_override(
      htj2k_like_minimal_single_codeblock_multi_packet_codestream([
        {
          first_inclusion: true,
          zbp: 6,
          passes: 1,
          segment_lengths: [5],
          segment_passes: [1],
          codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
        },
        {
          first_inclusion: false,
          zbp: 0,
          passes: 2,
          segment_lengths: [1],
          segment_passes: [2],
          codeword: [0x00],
        },
      ]),
    ),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_single_codeblock_multi_packet_codestream([
      {
        first_inclusion: true,
        zbp: 6,
        passes: 1,
        segment_lengths: [5],
        segment_passes: [1],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
      },
      {
        first_inclusion: false,
        zbp: 0,
        passes: 2,
        segment_lengths: [1],
        segment_passes: [2],
        codeword: [0x00],
      },
    ]),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail(
        "synthetic tile-header COC/QCC multi-layer HT codestream should decode: \{msg}",
      )
    }
    fail(
      "synthetic tile-header COC/QCC multi-layer HT codestream should decode",
    )
  }
  guard expected_v is Ok(expected) else {
    fail("baseline synthetic multi-layer HT codestream should decode")
  }
  assert_eq(result.samples, expected.samples)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples accepts synthetic single-codeblock HT MagRef codestream" {
  let cleanup_v = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(1, [5], [1], [
      0xE3, 0x00, 0x07, 0x74, 0x00,
    ]),
  )
  let refined_v = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(3, [5, 1], [1, 2], [
      0xE3, 0x00, 0x07, 0x74, 0x00, 0x00,
    ]),
  )
  guard cleanup_v is Ok(cleanup) else {
    fail("synthetic cleanup codestream should decode")
  }
  guard refined_v is Ok(refined) else {
    fail("synthetic MagRef codestream should decode")
  }
  assert_eq(cleanup.samples.length(), 1)
  assert_eq(refined.samples.length(), 1)
  assert_true(
    refined.sample_layout.contains("component0:raster:le:real_decode"),
  )
}

///|
test "decode_samples accepts synthetic single-codeblock multi-layer HT MagRef codestream" {
  let decoded = decode_samples(
    htj2k_like_minimal_single_codeblock_multi_packet_codestream([
      {
        first_inclusion: true,
        zbp: 6,
        passes: 1,
        segment_lengths: [5],
        segment_passes: [1],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
      },
      {
        first_inclusion: false,
        zbp: 0,
        passes: 2,
        segment_lengths: [1],
        segment_passes: [2],
        codeword: [0x00],
      },
    ]),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(3, [5, 1], [1, 2], [
      0xE3, 0x00, 0x07, 0x74, 0x00, 0x00,
    ]),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail("synthetic multi-layer HT MagRef codestream should decode: \{msg}")
    }
    fail("synthetic multi-layer HT MagRef codestream should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("synthetic staged HT codestream should decode")
  }
  assert_eq(result.samples, expected.samples)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples accepts synthetic single-codeblock HT zero-length refinement segment" {
  let decoded = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(2, [5, 0], [1, 1], [
      0xE3, 0x00, 0x07, 0x74, 0x00,
    ]),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(1, [5], [1], [
      0xE3, 0x00, 0x07, 0x74, 0x00,
    ]),
  )
  guard decoded is Ok(result) else {
    fail("synthetic zero-length refinement codestream should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("synthetic cleanup codestream should decode")
  }
  assert_eq(result.samples, expected.samples)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples selects trailing synthetic HT set" {
  let decoded = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(4, [5, 1, 5], [1, 2, 1], [
      0xE3, 0x00, 0x07, 0x74, 0x00, 0x00, 0xE3, 0x00, 0x07, 0x74, 0x00,
    ]),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(
      1,
      [5],
      [1],
      [0xE3, 0x00, 0x07, 0x74, 0x00],
      zbp=7,
    ),
  )
  guard decoded is Ok(result) else {
    fail("synthetic multi-set HT codestream should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("shifted synthetic HT cleanup codestream should decode")
  }
  assert_eq(result.samples.length(), 1)
  assert_eq(result.samples, expected.samples)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples applies synthetic multi-packet HT placeholder skip" {
  let decoded = decode_samples(
    htj2k_like_minimal_single_codeblock_multi_packet_codestream([
      {
        first_inclusion: true,
        zbp: 6,
        passes: 3,
        segment_lengths: [0, 0],
        segment_passes: [1, 2],
        codeword: [],
      },
      {
        first_inclusion: false,
        zbp: 0,
        passes: 1,
        segment_lengths: [5],
        segment_passes: [1],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
      },
    ]),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(
      1,
      [5],
      [1],
      [0xE3, 0x00, 0x07, 0x74, 0x00],
      zbp=7,
    ),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail(
        "synthetic multi-packet HT placeholder codestream should decode: \{msg}",
      )
    }
    fail("synthetic multi-packet HT placeholder codestream should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("shifted synthetic HT cleanup codestream should decode")
  }
  let actual_samples = @bytes.bytes_to_int_array(result.samples)
  let expected_samples = @bytes.bytes_to_int_array(expected.samples)
  if actual_samples != expected_samples {
    fail(
      "multi-packet placeholder mismatch: actual=\{actual_samples} expected=\{expected_samples} layout=\{result.sample_layout}",
    )
  }
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples selects trailing synthetic full HT set" {
  let decoded = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(
      6,
      [5, 1, 5, 1],
      [1, 2, 1, 2],
      [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00, 0xE3, 0x00, 0x07, 0x74, 0x00, 0x00],
      zbp=5,
    ),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(
      3,
      [5, 1],
      [1, 2],
      [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00],
      zbp=6,
    ),
  )
  guard decoded is Ok(result) else {
    fail("synthetic full multi-set HT codestream should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("shifted synthetic full HT codestream should decode")
  }
  let actual_samples = @bytes.bytes_to_int_array(result.samples)
  let expected_samples = @bytes.bytes_to_int_array(expected.samples)
  if actual_samples != expected_samples {
    fail(
      "multi-packet full-set mismatch: actual=\{actual_samples} expected=\{expected_samples} layout=\{result.sample_layout}",
    )
  }
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples selects trailing synthetic multi-packet full HT set" {
  let decoded = decode_samples(
    htj2k_like_minimal_single_codeblock_multi_packet_codestream([
      {
        first_inclusion: true,
        zbp: 5,
        passes: 3,
        segment_lengths: [5, 1],
        segment_passes: [1, 2],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00],
      },
      {
        first_inclusion: false,
        zbp: 0,
        passes: 3,
        segment_lengths: [5, 1],
        segment_passes: [1, 2],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00],
      },
    ]),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(
      3,
      [5, 1],
      [1, 2],
      [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00],
      zbp=6,
    ),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail("synthetic multi-packet full HT codestream should decode: \{msg}")
    }
    fail("synthetic multi-packet full HT codestream should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("shifted synthetic full HT codestream should decode")
  }
  let actual_samples = @bytes.bytes_to_int_array(result.samples)
  let expected_samples = @bytes.bytes_to_int_array(expected.samples)
  if actual_samples != expected_samples {
    fail(
      "multi-packet full HT mismatch: actual=\{actual_samples} expected=\{expected_samples} layout=\{result.sample_layout}",
    )
  }
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples applies synthetic HT placeholder set skip" {
  let decoded = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(4, [0, 0, 5], [1, 2, 1], [
      0xE3, 0x00, 0x07, 0x74, 0x00,
    ]),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(
      1,
      [5],
      [1],
      [0xE3, 0x00, 0x07, 0x74, 0x00],
      zbp=7,
    ),
  )
  guard decoded is Ok(result) else {
    fail("synthetic HT placeholder codestream should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("shifted synthetic HT cleanup codestream should decode")
  }
  assert_eq(result.samples, expected.samples)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples applies synthetic single-codeblock HT SigProp codestream" {
  let cleanup_codeword = [
    0xA1, 0xC4, 0xA8, 0x09, 0x81, 0x4A, 0x28, 0x07, 0x9E, 0x24, 0x9D, 0xAC, 0x62,
    0xA6, 0x01, 0x2E, 0xCE, 0x72, 0x08, 0x42, 0x3F, 0xA5, 0x4B, 0xBB, 0x00,
  ]
  let refined_codeword = cleanup_codeword.copy()
  refined_codeword.push(0x01)
  let cleanup_v = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(
      1,
      [25],
      [1],
      cleanup_codeword,
      width=5,
      height=5,
      zbp=9,
      precision_bits=11,
    ),
  )
  let refined_v = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(
      2,
      [25, 1],
      [1, 1],
      refined_codeword,
      width=5,
      height=5,
      zbp=9,
      precision_bits=11,
    ),
  )
  guard cleanup_v is Ok(cleanup) else {
    if cleanup_v is Err(msg) {
      fail("synthetic cleanup 5x5 codestream should decode: \{msg}")
    }
    fail("synthetic cleanup 5x5 codestream should decode")
  }
  guard refined_v is Ok(refined) else {
    if refined_v is Err(msg) {
      fail("synthetic SigProp 5x5 codestream should decode: \{msg}")
    }
    fail("synthetic SigProp 5x5 codestream should decode")
  }
  let cleanup_samples = @bytes.bytes_to_int_array(cleanup.samples)
  let refined_samples = @bytes.bytes_to_int_array(refined.samples)
  assert_eq(cleanup.width, 5)
  assert_eq(cleanup.height, 5)
  assert_eq(refined.width, 5)
  assert_eq(refined.height, 5)
  assert_true(
    cleanup.sample_layout.contains("component0:raster:le:real_decode"),
  )
  assert_true(
    refined.sample_layout.contains("component0:raster:le:real_decode"),
  )
  assert_eq(cleanup_samples.length(), refined_samples.length())
  assert_eq(cleanup_samples.length(), 50)
}

///|
test "decode_samples accepts synthetic single-codeblock HT causal SigProp codestream" {
  let cleanup_codeword = [
    0xA1, 0xC4, 0xA8, 0x09, 0x81, 0x4A, 0x28, 0x07, 0x9E, 0x24, 0x9D, 0xAC, 0x62,
    0xA6, 0x01, 0x2E, 0xCE, 0x72, 0x08, 0x42, 0x3F, 0xA5, 0x4B, 0xBB, 0x00,
  ]
  let refined_codeword = cleanup_codeword.copy()
  refined_codeword.push(0x01)
  let decoded = decode_samples(
    htj2k_like_minimal_single_codeblock_codestream(
      2,
      [25, 1],
      [1, 1],
      refined_codeword,
      width=5,
      height=5,
      zbp=9,
      precision_bits=11,
      code_block_style=0x48,
    ),
  )
  guard decoded is Ok(result) else {
    fail("synthetic causal SigProp codestream should decode")
  }
  assert_eq(result.width, 5)
  assert_eq(result.height, 5)
  assert_eq(result.num_components, 1)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples accepts synthetic multi-codeblock HT cleanup codestream" {
  let decoded = decode_samples(
    htj2k_like_minimal_multi_codeblock_codestream(2, 1, [
      {
        included: true,
        zbp: 6,
        passes: 1,
        segment_lengths: [5],
        segment_passes: [1],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
      },
      {
        included: false,
        zbp: 0,
        passes: 0,
        segment_lengths: [],
        segment_passes: [],
        codeword: [],
      },
    ]),
  )
  guard decoded is Ok(result) else {
    fail("synthetic multi-codeblock HT cleanup codestream should decode")
  }
  assert_eq(result.width, 2)
  assert_eq(result.height, 1)
  assert_eq(result.num_components, 1)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples accepts synthetic multi-codeblock HT MagRef via main-header COC override" {
  let decoded = decode_samples(
    htj2k_with_main_header_coc_ht_override(
      htj2k_like_minimal_multi_codeblock_codestream(2, 1, [
        {
          included: true,
          zbp: 6,
          passes: 3,
          segment_lengths: [5, 1],
          segment_passes: [1, 2],
          codeword: [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00],
        },
        {
          included: false,
          zbp: 0,
          passes: 0,
          segment_lengths: [],
          segment_passes: [],
          codeword: [],
        },
      ]),
    ),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_multi_codeblock_codestream(2, 1, [
      {
        included: true,
        zbp: 6,
        passes: 3,
        segment_lengths: [5, 1],
        segment_passes: [1, 2],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00],
      },
      {
        included: false,
        zbp: 0,
        passes: 0,
        segment_lengths: [],
        segment_passes: [],
        codeword: [],
      },
    ]),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail(
        "synthetic main-header COC multi-codeblock HT codestream should decode: \{msg}",
      )
    }
    fail(
      "synthetic main-header COC multi-codeblock HT codestream should decode",
    )
  }
  guard expected_v is Ok(expected) else {
    fail("baseline synthetic multi-codeblock HT codestream should decode")
  }
  assert_eq(result.samples, expected.samples)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples accepts synthetic multi-codeblock HT MagRef via tile-header COC/QCC override" {
  let decoded = decode_samples(
    htj2k_with_tile_header_coc_qcc_ht_override(
      htj2k_like_minimal_multi_codeblock_codestream(2, 1, [
        {
          included: true,
          zbp: 6,
          passes: 3,
          segment_lengths: [5, 1],
          segment_passes: [1, 2],
          codeword: [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00],
        },
        {
          included: false,
          zbp: 0,
          passes: 0,
          segment_lengths: [],
          segment_passes: [],
          codeword: [],
        },
      ]),
    ),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_multi_codeblock_codestream(2, 1, [
      {
        included: true,
        zbp: 6,
        passes: 3,
        segment_lengths: [5, 1],
        segment_passes: [1, 2],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00],
      },
      {
        included: false,
        zbp: 0,
        passes: 0,
        segment_lengths: [],
        segment_passes: [],
        codeword: [],
      },
    ]),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail(
        "synthetic tile-header COC/QCC multi-codeblock HT codestream should decode: \{msg}",
      )
    }
    fail(
      "synthetic tile-header COC/QCC multi-codeblock HT codestream should decode",
    )
  }
  guard expected_v is Ok(expected) else {
    fail("baseline synthetic multi-codeblock HT codestream should decode")
  }
  assert_eq(result.samples, expected.samples)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples accepts synthetic multi-codeblock HT MagRef codestream" {
  let decoded = decode_samples(
    htj2k_like_minimal_multi_codeblock_codestream(5, 1, [
      {
        included: true,
        zbp: 6,
        passes: 3,
        segment_lengths: [5, 1],
        segment_passes: [1, 2],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00],
      },
      {
        included: false,
        zbp: 0,
        passes: 0,
        segment_lengths: [],
        segment_passes: [],
        codeword: [],
      },
    ]),
  )
  guard decoded is Ok(result) else {
    fail("synthetic multi-codeblock HT MagRef codestream should decode")
  }
  assert_eq(result.width, 5)
  assert_eq(result.height, 1)
  assert_eq(result.num_components, 1)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples accepts synthetic multi-codeblock multi-layer HT MagRef codestream" {
  let decoded = decode_samples(
    htj2k_like_minimal_multi_codeblock_multi_packet_codestream(5, 1, [
      [
        {
          included: true,
          zbp: 6,
          passes: 1,
          segment_lengths: [5],
          segment_passes: [1],
          codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
        },
        {
          included: true,
          zbp: 6,
          passes: 1,
          segment_lengths: [5],
          segment_passes: [1],
          codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
        },
      ],
      [
        {
          included: true,
          zbp: 0,
          passes: 2,
          segment_lengths: [1],
          segment_passes: [2],
          codeword: [0x00],
        },
        {
          included: false,
          zbp: 0,
          passes: 0,
          segment_lengths: [],
          segment_passes: [],
          codeword: [],
        },
      ],
    ]),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_multi_codeblock_codestream(5, 1, [
      {
        included: true,
        zbp: 6,
        passes: 3,
        segment_lengths: [5, 1],
        segment_passes: [1, 2],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00],
      },
      {
        included: true,
        zbp: 6,
        passes: 1,
        segment_lengths: [5],
        segment_passes: [1],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
      },
    ]),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail(
        "synthetic multi-codeblock multi-layer HT codestream should decode: \{msg}",
      )
    }
    fail("synthetic multi-codeblock multi-layer HT codestream should decode")
  }
  guard expected_v is Ok(expected) else {
    fail("synthetic staged multi-codeblock HT codestream should decode")
  }
  let actual_samples = @bytes.bytes_to_int_array(result.samples)
  let expected_samples = @bytes.bytes_to_int_array(expected.samples)
  if actual_samples != expected_samples {
    fail(
      "synthetic multi-codeblock multi-layer HT mismatch: actual=\{actual_samples} expected=\{expected_samples} layout=\{result.sample_layout}",
    )
  }
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples accepts synthetic multi-codeblock multi-layer HT codestream with main-header RGN" {
  let packets = [
    [
      {
        included: true,
        zbp: 6,
        passes: 1,
        segment_lengths: [5],
        segment_passes: [1],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
      },
      {
        included: true,
        zbp: 6,
        passes: 1,
        segment_lengths: [5],
        segment_passes: [1],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
      },
    ],
    [
      {
        included: true,
        zbp: 0,
        passes: 2,
        segment_lengths: [1],
        segment_passes: [2],
        codeword: [0x00],
      },
      {
        included: false,
        zbp: 0,
        passes: 0,
        segment_lengths: [],
        segment_passes: [],
        codeword: [],
      },
    ],
  ]
  let decoded = decode_samples(
    htj2k_with_main_header_rgn(
      htj2k_like_minimal_multi_codeblock_multi_packet_codestream(2, 1, packets),
      1,
    ),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_multi_codeblock_multi_packet_codestream(2, 1, packets),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail(
        "synthetic multi-codeblock multi-layer HT + RGN codestream should decode: \{msg}",
      )
    }
    fail(
      "synthetic multi-codeblock multi-layer HT + RGN codestream should decode",
    )
  }
  guard expected_v is Ok(expected) else {
    fail(
      "baseline synthetic multi-codeblock multi-layer HT codestream should decode",
    )
  }
  assert_eq(result.samples, expected.samples)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples accepts synthetic multi-codeblock multi-layer HT codestream with tile-header RGN" {
  let packets = [
    [
      {
        included: true,
        zbp: 6,
        passes: 1,
        segment_lengths: [5],
        segment_passes: [1],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
      },
      {
        included: true,
        zbp: 6,
        passes: 1,
        segment_lengths: [5],
        segment_passes: [1],
        codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
      },
    ],
    [
      {
        included: true,
        zbp: 0,
        passes: 2,
        segment_lengths: [1],
        segment_passes: [2],
        codeword: [0x00],
      },
      {
        included: false,
        zbp: 0,
        passes: 0,
        segment_lengths: [],
        segment_passes: [],
        codeword: [],
      },
    ],
  ]
  let decoded = decode_samples(
    htj2k_with_tile_header_rgn(
      htj2k_like_minimal_multi_codeblock_multi_packet_codestream(2, 1, packets),
      1,
    ),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_multi_codeblock_multi_packet_codestream(2, 1, packets),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail(
        "synthetic multi-codeblock multi-layer HT + tile-header RGN codestream should decode: \{msg}",
      )
    }
    fail(
      "synthetic multi-codeblock multi-layer HT + tile-header RGN codestream should decode",
    )
  }
  guard expected_v is Ok(expected) else {
    fail(
      "baseline synthetic multi-codeblock multi-layer HT codestream should decode",
    )
  }
  assert_eq(result.samples, expected.samples)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples accepts synthetic multi-codeblock multi-layer HT via tile-header COC/QCC override" {
  let decoded = decode_samples(
    htj2k_with_tile_header_coc_qcc_ht_override(
      htj2k_like_minimal_multi_codeblock_multi_packet_codestream(2, 1, [
        [
          {
            included: true,
            zbp: 6,
            passes: 1,
            segment_lengths: [5],
            segment_passes: [1],
            codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
          },
          {
            included: true,
            zbp: 6,
            passes: 1,
            segment_lengths: [5],
            segment_passes: [1],
            codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
          },
        ],
        [
          {
            included: true,
            zbp: 0,
            passes: 2,
            segment_lengths: [1],
            segment_passes: [2],
            codeword: [0x00],
          },
          {
            included: false,
            zbp: 0,
            passes: 0,
            segment_lengths: [],
            segment_passes: [],
            codeword: [],
          },
        ],
      ]),
    ),
  )
  let expected_v = decode_samples(
    htj2k_like_minimal_multi_codeblock_multi_packet_codestream(2, 1, [
      [
        {
          included: true,
          zbp: 6,
          passes: 1,
          segment_lengths: [5],
          segment_passes: [1],
          codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
        },
        {
          included: true,
          zbp: 6,
          passes: 1,
          segment_lengths: [5],
          segment_passes: [1],
          codeword: [0xE3, 0x00, 0x07, 0x74, 0x00],
        },
      ],
      [
        {
          included: true,
          zbp: 0,
          passes: 2,
          segment_lengths: [1],
          segment_passes: [2],
          codeword: [0x00],
        },
        {
          included: false,
          zbp: 0,
          passes: 0,
          segment_lengths: [],
          segment_passes: [],
          codeword: [],
        },
      ],
    ]),
  )
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail(
        "synthetic tile-header COC/QCC multi-layer HT codestream should decode: \{msg}",
      )
    }
    fail(
      "synthetic tile-header COC/QCC multi-layer HT codestream should decode",
    )
  }
  guard expected_v is Ok(expected) else {
    fail("baseline synthetic multi-layer HT codestream should decode")
  }
  assert_eq(result.samples, expected.samples)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples accepts synthetic multi-codeblock HT causal MagRef codestream" {
  let decoded = decode_samples(
    htj2k_like_minimal_multi_codeblock_codestream(
      2,
      1,
      [
        {
          included: true,
          zbp: 6,
          passes: 3,
          segment_lengths: [5, 1],
          segment_passes: [1, 2],
          codeword: [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00],
        },
        {
          included: false,
          zbp: 0,
          passes: 0,
          segment_lengths: [],
          segment_passes: [],
          codeword: [],
        },
      ],
      code_block_style=0x48,
    ),
  )
  guard decoded is Ok(result) else {
    fail("synthetic multi-codeblock HT causal MagRef codestream should decode")
  }
  assert_eq(result.width, 2)
  assert_eq(result.height, 1)
  assert_eq(result.num_components, 1)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
}

///|
test "decode_samples decodes Bretagne1_ht fixture when available" {
  let fixture = htj2k_fixture_bytes(
    "samples/corpus/Bretagne1_ht.j2k",
  )
  guard fixture is Some(bytes) else { return }
  let decoded = decode_samples(bytes)
  guard decoded is Ok(result) else {
    fail("Bretagne1_ht should decode in cleanup-only subset")
  }
  assert_eq(result.width, 640)
  assert_eq(result.height, 480)
  assert_eq(result.bits_per_component, 8)
  assert_eq(result.num_components, 3)
  assert_eq(result.samples.length(), 640 * 480)
}

///|
test "decode_samples decodes Bretagne1_ht_lossy fixture when available" {
  let fixture = htj2k_fixture_bytes(
    "samples/corpus/Bretagne1_ht_lossy.j2k",
  )
  guard fixture is Some(bytes) else { return }
  let decoded = decode_samples(bytes)
  guard decoded is Ok(result) else {
    fail("Bretagne1_ht_lossy should decode in cleanup-only subset")
  }
  assert_eq(result.width, 640)
  assert_eq(result.height, 480)
  assert_eq(result.bits_per_component, 8)
  assert_eq(result.num_components, 3)
  assert_eq(result.samples.length(), 640 * 480)
  assert_true(result.sample_layout.contains("component0:raster:le:real_decode"))
  let expected = [
    159, 160, 161, 160, 159, 162, 161, 160, 161, 162, 161, 160, 160, 159, 160, 160,
    160, 161, 162, 159, 160, 162, 161, 161, 161, 160, 162, 162, 162, 162, 161, 161,
    161, 160, 160, 160, 160, 163, 161, 162, 162, 161, 161, 159, 160, 160, 161, 162,
    162, 160, 161, 161, 163, 160, 162, 161, 161, 161, 162, 162, 161, 161, 161, 161,
  ]
  for i in 0..<expected.length() {
    assert_eq(result.samples[i].to_int(), expected[i])
  }
}

///|
test "decode_samples matches byte.jph component0 prefix when available" {
  let fixture = htj2k_fixture_bytes(
    "samples/corpus/byte.jph",
  )
  guard fixture is Some(bytes) else { return }
  let decoded = decode_samples(bytes)
  guard decoded is Ok(result) else {
    fail("byte.jph should decode in cleanup-only subset")
  }
  assert_eq(result.width, 20)
  assert_eq(result.height, 20)
  assert_eq(result.bits_per_component, 8)
  assert_eq(result.num_components, 1)
  let expected = [
    107, 123, 132, 115, 132, 132, 140, 132, 132, 132, 107, 132, 107, 132, 132, 107,
    123, 115, 156, 148, 115, 132, 107, 123, 148, 115, 165, 115, 140, 107, 123, 123,
    99, 132, 123, 132, 132, 132, 99, 156,
  ]
  for i in 0..<expected.length() {
    assert_eq(result.samples[i].to_int(), expected[i])
  }
}

///|
test "decode_samples matches byte_causal.jhc component0 prefix when available" {
  let fixture = htj2k_fixture_bytes(
    "samples/corpus/byte_causal.jhc",
  )
  guard fixture is Some(bytes) else { return }
  let decoded = decode_samples(bytes)
  guard decoded is Ok(result) else {
    fail("byte_causal.jhc should decode in cleanup-only subset")
  }
  assert_eq(result.width, 20)
  assert_eq(result.height, 20)
  assert_eq(result.bits_per_component, 8)
  assert_eq(result.num_components, 1)
  let expected = [
    107, 123, 132, 115, 132, 132, 140, 132, 132, 132, 107, 132, 107, 132, 132, 107,
    123, 115, 156, 148, 115, 132, 107, 123, 148, 115, 165, 115, 140, 107, 123, 123,
    99, 132, 123, 132, 132, 132, 99, 156,
  ]
  for i in 0..<expected.length() {
    assert_eq(result.samples[i].to_int(), expected[i])
  }
}
