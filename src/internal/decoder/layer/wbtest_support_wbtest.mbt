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
