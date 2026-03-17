///|
fn wb_bytes_to_int_array(data : Bytes) -> Array[Int] {
  let out : Array[Int] = []
  for b in data {
    out.push(b.to_int())
  }
  out
}

///|
fn wb_int_array_to_bytes(data : Array[Int]) -> Bytes {
  Bytes::from_iter(data.iter().map(fn(i) { i.to_byte() }))
}

///|
fn wb_push_bits(bits : Array[Int], value : Int, width : Int) -> Unit {
  for shift in 0..<width {
    let bit_index = width - 1 - shift
    bits.push((value >> bit_index) & 1)
  }
}

///|
fn wb_pack_bits(bits : Array[Int]) -> Array[Int] {
  let out : Array[Int] = []
  let mut idx = 0
  while idx < bits.length() {
    let mut byte = 0
    for bit in 0..<8 {
      if idx + bit < bits.length() && bits[idx + bit] != 0 {
        byte = byte | (1 << (7 - bit))
      }
    }
    out.push(byte)
    idx += 8
  }
  out
}

///|
test "ht segment maxpasses alternates cleanup and refinement" {
  assert_eq(codeblock_segment_maxpasses(0x40, true, 0), 1)
  assert_eq(codeblock_segment_maxpasses(0x40, false, 1), 2)
  assert_eq(codeblock_segment_maxpasses(0x40, false, 2), 1)
}

///|
test "ht packet pass split groups a single HT set into cleanup and refinement" {
  let seg_numpasses = [0]
  let seg_maxpasses = [0]
  let seg_count = [0]
  let split = split_packet_passes_and_advance_segment_state(
    0x40, 3, seg_numpasses, seg_maxpasses, seg_count, 0,
  )
  assert_eq(split, [1, 2])
  assert_eq(seg_numpasses[0], 2)
  assert_eq(seg_maxpasses[0], 2)
  assert_eq(seg_count[0], 2)
}

///|
test "ht packet pass split emits a trailing cleanup set in one contribution" {
  let seg_numpasses = [0]
  let seg_maxpasses = [0]
  let seg_count = [0]
  let split = split_packet_passes_and_advance_segment_state(
    0x40, 4, seg_numpasses, seg_maxpasses, seg_count, 0,
  )
  assert_eq(split, [1, 2, 1])
  assert_eq(seg_numpasses[0], 1)
  assert_eq(seg_maxpasses[0], 1)
  assert_eq(seg_count[0], 3)
}

///|
test "ht packet pass split starts a new cleanup-refinement set in later layers" {
  let seg_numpasses = [2]
  let seg_maxpasses = [2]
  let seg_count = [2]
  let split = split_packet_passes_and_advance_segment_state(
    0x40, 3, seg_numpasses, seg_maxpasses, seg_count, 0,
  )
  assert_eq(split, [1, 2])
  assert_eq(seg_numpasses[0], 2)
  assert_eq(seg_maxpasses[0], 2)
  assert_eq(seg_count[0], 4)
}

///|
priv struct WbCodeblockSpec {
  included : Bool
  zbp : Int
  passes : Int
  segment_lengths : Array[Int]
  segment_passes : Array[Int]
}

///|
fn wb_push_coding_pass_bits(bits : Array[Int], passes : Int) -> Unit {
  if passes == 1 {
    bits.push(0)
  } else if passes == 2 {
    bits.push(1)
    bits.push(0)
  } else if passes == 3 {
    wb_push_bits(bits, 0b1100, 4)
  } else if passes == 4 {
    wb_push_bits(bits, 0b1101, 4)
  } else if passes == 5 {
    wb_push_bits(bits, 0b1110, 4)
  } else if passes <= 36 {
    wb_push_bits(bits, 0b1111, 4)
    wb_push_bits(bits, passes - 6, 5)
  } else if passes <= 164 {
    wb_push_bits(bits, 0b1111, 4)
    wb_push_bits(bits, 31, 5)
    wb_push_bits(bits, passes - 37, 7)
  } else {
    panic()
  }
}

///|
fn wb_push_segment_length_bits(
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
    // B.10.7.2: one Lblock increment prefix covers the whole contribution.
    bits.push(0)
  }
  for i in 0..<count {
    let width = 3 + @math.floor_log2(segment_passes[i])
    wb_push_bits(bits, segment_lengths[i], width)
  }
}

///|
fn wb_single_codeblock_packet_header(
  first_inclusion : Bool,
  zbp : Int,
  passes : Int,
  segment_lengths : Array[Int],
  segment_passes : Array[Int],
) -> Array[Int] {
  let bits : Array[Int] = [1, 1]
  if first_inclusion {
    for _ in 0..<zbp {
      bits.push(0)
    }
    bits.push(1)
  }
  wb_push_coding_pass_bits(bits, passes)
  wb_push_segment_length_bits(bits, segment_lengths, segment_passes)
  wb_pack_bits(bits)
}

///|
fn wb_multi_codeblock_packet_header(
  blocks : Array[WbCodeblockSpec],
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
    wb_push_coding_pass_bits(bits, block.passes)
    wb_push_segment_length_bits(
      bits,
      block.segment_lengths,
      block.segment_passes,
    )
  }
  wb_pack_bits(bits)
}

///|
test "single-codeblock sequential parser preserves follow-up HT full set parts" {
  let payload : Array[Int] = []
  let packet0_header = wb_single_codeblock_packet_header(true, 5, 3, [5, 1], [
    1, 2,
  ])
  let packet1_header = wb_single_codeblock_packet_header(false, 0, 3, [5, 1], [
    1, 2,
  ])
  for b in packet0_header {
    payload.push(b)
  }
  for b in [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00] {
    payload.push(b)
  }
  for b in packet1_header {
    payload.push(b)
  }
  for b in [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00] {
    payload.push(b)
  }
  let parts_v = extract_single_codeblock_packet_parts_series(wb_int_array_to_bytes(payload), 0x40)
  guard parts_v is Ok(parts) else {
    fail("single-codeblock sequential HT full-set parse should succeed")
  }
  assert_eq(parts.length(), 2)
  assert_eq(parts[0].coding_passes, Some(3))
  assert_eq(parts[0].zero_bit_planes, Some(5))
  assert_eq(parts[0].segment_lengths, [5, 1])
  assert_eq(parts[0].segment_passes, [1, 2])
  assert_eq(wb_bytes_to_int_array(parts[0].codeword), [
    0xE3, 0x00, 0x07, 0x74, 0x00, 0x00,
  ])
  assert_eq(parts[1].coding_passes, Some(3))
  assert_eq(parts[1].zero_bit_planes, None)
  assert_eq(parts[1].segment_lengths, [5, 1])
  assert_eq(parts[1].segment_passes, [1, 2])
  assert_eq(wb_bytes_to_int_array(parts[1].codeword), [
    0xE3, 0x00, 0x07, 0x74, 0x00, 0x00,
  ])
}

///|
test "single-codeblock series split keeps full HT multi-packet contributions separate" {
  let packet0 = wb_single_codeblock_packet_header(true, 5, 3, [5, 1], [1, 2]) +
    [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00]
  let packet1 = wb_single_codeblock_packet_header(false, 0, 3, [5, 1], [1, 2]) +
    [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00]
  let payload = packet0 + packet1
  let split_v = split_sod_payload_single_codeblock_series(wb_int_array_to_bytes(payload), 0x40)
  guard split_v is Ok(packets) else {
    if split_v is Err(msg) {
      fail("expected full HT multi-packet split success: \{msg}")
    }
    fail("expected full HT multi-packet split success")
  }
  assert_eq(packets.length(), 2)
  assert_eq(packets[0], wb_int_array_to_bytes(packet0))
  assert_eq(packets[1], wb_int_array_to_bytes(packet1))
}

///|
test "multi-codeblock first-packet parse keeps mixed HT staged and cleanup metadata" {
  let payload_arr = wb_multi_codeblock_packet_header([
      {
        included: true,
        zbp: 6,
        passes: 3,
        segment_lengths: [5, 1],
        segment_passes: [1, 2],
      },
      {
        included: true,
        zbp: 6,
        passes: 1,
        segment_lengths: [5],
        segment_passes: [1],
      },
    ]) +
    [0xE3, 0x00, 0x07, 0x74, 0x00, 0x00, 0xE3, 0x00, 0x07, 0x74, 0x00]
  let candidates : Array[PacketHeaderShapeCandidate] = [
    { code_block_count: 2, width: 2, height: 1 },
  ]
  let parsed_v = parse_multi_codeblock_first_packet_parts_with_candidates(
    wb_int_array_to_bytes(payload_arr), 0x40, candidates,
  )
  guard parsed_v is Ok(parts) else {
    if parsed_v is Err(msg) {
      fail("expected mixed HT multi-codeblock parse success: \{msg}")
    }
    fail("expected mixed HT multi-codeblock parse success")
  }
  assert_eq(parts.code_block_count, 2)
  assert_eq(parts.parts.length(), 2)
  let p0 = parts.parts[0]
  let p1 = parts.parts[1]
  assert_true(p0.included)
  assert_eq(p0.segment_lengths, [5, 1])
  assert_eq(p0.segment_passes, [1, 2])
  assert_eq(p0.zero_bit_planes, Some(6))
  assert_eq(p0.coding_passes, Some(3))
  assert_eq(wb_bytes_to_int_array(p0.codeword), [
    0xE3, 0x00, 0x07, 0x74, 0x00, 0x00,
  ])
  assert_true(p1.included)
  assert_eq(p1.segment_lengths, [5])
  assert_eq(p1.segment_passes, [1])
  assert_eq(p1.zero_bit_planes, Some(6))
  assert_eq(p1.coding_passes, Some(1))
  assert_eq(wb_bytes_to_int_array(p1.codeword), [0xE3, 0x00, 0x07, 0x74, 0x00])
}
