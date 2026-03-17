///|
fn marker_index(data : Array[Int], marker_hi : Int, marker_lo : Int) -> Int? {
  for i in 0..<(data.length() - 1) {
    if data[i] == marker_hi && data[i + 1] == marker_lo {
      return Some(i)
    }
  }
  None
}

///|
fn marker_index_nth(
  data : Array[Int],
  marker_hi : Int,
  marker_lo : Int,
  nth : Int,
) -> Int? {
  let mut count = 0
  for i in 0..<(data.length() - 1) {
    if data[i] == marker_hi && data[i + 1] == marker_lo {
      if count == nth {
        return Some(i)
      }
      count += 1
    }
  }
  None
}

///|
fn insert_bytes_at(
  data : Array[Int],
  at : Int,
  extra : Array[Int],
) -> Array[Int] {
  let out : Array[Int] = []
  for i in 0..<at {
    out.push(data[i])
  }
  for b in extra {
    out.push(b)
  }
  for i in at..<data.length() {
    out.push(data[i])
  }
  out
}

///|
fn patch_u32_be(data : Array[Int], at : Int, value : Int) -> Unit {
  data[at] = (value >> 24) & 0xFF
  data[at + 1] = (value >> 16) & 0xFF
  data[at + 2] = (value >> 8) & 0xFF
  data[at + 3] = value & 0xFF
}

///|
fn read_u32_be(data : Array[Int], at : Int) -> Int {
  match @bytes.read_u32_be_arr(data, at) {
    Ok(value) => value
    Err(_) => panic()
  }
}

///|
fn push_bits(bits : Array[Int], value : Int, width : Int) -> Unit {
  for shift in 0..<width {
    let bit_index = width - 1 - shift
    bits.push((value >> bit_index) & 1)
  }
}

///|
fn pack_bits(bits : Array[Int]) -> Array[Int] {
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
fn minimal_codestream_bytes() -> Array[Int] {
  sample_codestream_minimal()
}

///|
fn valid_siz_payload() -> Array[Int] {
  [
    0x00, 0x00, // Rsiz
     0x00, 0x00, 0x00, 0x10, // Xsiz
     0x00, 0x00, 0x00, 0x10, // Ysiz
     0x00, 0x00, 0x00, 0x00, // XOsiz
     0x00, 0x00, 0x00, 0x00, // YOsiz
     0x00, 0x00, 0x00, 0x10, // XTsiz
     0x00, 0x00, 0x00, 0x10, // YTsiz
     0x00, 0x00, 0x00, 0x00, // XTOsiz
     0x00, 0x00, 0x00, 0x00, // YTOsiz
     0x00, 0x01, // Csiz = 1
     0x07, 0x01, 0x01, // Ssiz/XRsiz/YRsiz for component 0
  ]
}

///|
fn valid_cod_payload() -> Array[Int] {
  [
    0x00, // Scod
     0x00, // Progression order (LRCP)
     0x00, 0x01, // Number of layers
     0x00, // Multiple component transform
     0x00, // Number of decomposition levels
     0x00, // Code-block width exponent minus 2
     0x00, // Code-block height exponent minus 2
     0x00, // Code-block style
     0x00,
  ] // Transformation
}

///|
fn valid_cod_payload_decomp2() -> Array[Int] {
  [
    0x00, // Scod
     0x00, // Progression order (LRCP)
     0x00, 0x01, // Number of layers
     0x00, // Multiple component transform
     0x02, // Number of decomposition levels
     0x00, // Code-block width exponent minus 2
     0x00, // Code-block height exponent minus 2
     0x00, // Code-block style
     0x00,
  ] // Transformation
}

///|
fn valid_cod_payload_decomp2_precincts_layers3() -> Array[Int] {
  [
    0x01, // Scod (precincts present)
     0x00, // Progression order (LRCP)
     0x00, 0x03, // Number of layers
     0x00, // Multiple component transform
     0x02, // Number of decomposition levels
     0x00, // Code-block width exponent minus 2
     0x00, // Code-block height exponent minus 2
     0x00, // Code-block style
     0x00, // Transformation
     0x44, 0x33, 0x22,
  ] // precinct exponents per resolution
}

///|
fn valid_siz_payload_tile_2x2() -> Array[Int] {
  [
    0x00, 0x00, // Rsiz
     0x00, 0x00, 0x00, 0x10, // Xsiz
     0x00, 0x00, 0x00, 0x10, // Ysiz
     0x00, 0x00, 0x00, 0x00, // XOsiz
     0x00, 0x00, 0x00, 0x00, // YOsiz
     0x00, 0x00, 0x00, 0x08, // XTsiz
     0x00, 0x00, 0x00, 0x08, // YTsiz
     0x00, 0x00, 0x00, 0x00, // XTOsiz
     0x00, 0x00, 0x00, 0x00, // YTOsiz
     0x00, 0x01, // Csiz = 1
     0x07, 0x01, 0x01, // Ssiz/XRsiz/YRsiz
  ]
}

///|
fn valid_siz_payload_sampling_2() -> Array[Int] {
  [
    0x00, 0x00, // Rsiz
     0x00, 0x00, 0x00, 0x10, // Xsiz
     0x00, 0x00, 0x00, 0x10, // Ysiz
     0x00, 0x00, 0x00, 0x00, // XOsiz
     0x00, 0x00, 0x00, 0x00, // YOsiz
     0x00, 0x00, 0x00, 0x10, // XTsiz
     0x00, 0x00, 0x00, 0x10, // YTsiz
     0x00, 0x00, 0x00, 0x00, // XTOsiz
     0x00, 0x00, 0x00, 0x00, // YTOsiz
     0x00, 0x01, // Csiz = 1
     0x07, 0x02, 0x02, // Ssiz/XRsiz/YRsiz
  ]
}

///|
fn valid_cod_payload_decomp2_precincts_layers3_with_order(
  progression_order : Int,
) -> Array[Int] {
  [
    0x01, // Scod (precincts present)
     progression_order, // Progression order
     0x00, 0x03, // Number of layers
     0x00, // Multiple component transform
     0x02, // Number of decomposition levels
     0x00, // Code-block width exponent minus 2
     0x00, // Code-block height exponent minus 2
     0x00, // Code-block style
     0x00, // Transformation
     0x44, 0x33, 0x22,
  ] // precinct exponents per resolution
}

///|
fn bits_to_bytes(bits : String) -> Array[Int] {
  let bytes : Array[Int] = []
  let mut current = 0
  let mut count = 0
  for c in bits {
    if c != '0' && c != '1' {
      continue
    }
    current = (current << 1) + (if c == '1' { 1 } else { 0 })
    count += 1
    if count == 8 {
      bytes.push(current)
      current = 0
      count = 0
    }
  }
  if count > 0 {
    current = current << (8 - count)
    bytes.push(current)
  }
  bytes
}

///|
fn coding_pass_codeword_bits(coding_passes : Int) -> String {
  if coding_passes == 1 {
    return "0"
  }
  if coding_passes == 2 {
    return "10"
  }
  if coding_passes == 3 {
    return "1100"
  }
  if coding_passes == 4 {
    return "1101"
  }
  if coding_passes == 5 {
    return "1110"
  }
  if coding_passes >= 6 && coding_passes <= 36 {
    let mid = coding_passes - 6
    let b4 = if (mid & 0x10) != 0 { "1" } else { "0" }
    let b3 = if (mid & 0x08) != 0 { "1" } else { "0" }
    let b2 = if (mid & 0x04) != 0 { "1" } else { "0" }
    let b1 = if (mid & 0x02) != 0 { "1" } else { "0" }
    let b0 = if (mid & 0x01) != 0 { "1" } else { "0" }
    return "1111" + b4 + b3 + b2 + b1 + b0
  }
  if coding_passes >= 37 && coding_passes <= 164 {
    let tail = coding_passes - 37
    let b6 = if (tail & 0x40) != 0 { "1" } else { "0" }
    let b5 = if (tail & 0x20) != 0 { "1" } else { "0" }
    let b4 = if (tail & 0x10) != 0 { "1" } else { "0" }
    let b3 = if (tail & 0x08) != 0 { "1" } else { "0" }
    let b2 = if (tail & 0x04) != 0 { "1" } else { "0" }
    let b1 = if (tail & 0x02) != 0 { "1" } else { "0" }
    let b0 = if (tail & 0x01) != 0 { "1" } else { "0" }
    return "111111111" + b6 + b5 + b4 + b3 + b2 + b1 + b0
  }
  ""
}

///|
fn fixed_width_bits(value : Int, width : Int) -> String {
  let mut out = ""
  let mut i = width - 1
  while i >= 0 {
    let bit = if ((value >> i) & 1) == 1 { "1" } else { "0" }
    out = out + bit
    i -= 1
  }
  out
}

///|
fn single_codeblock_header_bits(
  coding_passes : Int,
  lblock_increment : Int,
  length : Int,
) -> String {
  let mut prefix = "111"
  prefix = prefix + coding_pass_codeword_bits(coding_passes)
  for _ in 0..<lblock_increment {
    prefix = prefix + "1"
  }
  prefix = prefix + "0"
  let width = 3 + lblock_increment + @math.floor_log2(coding_passes)
  prefix + fixed_width_bits(length, width)
}

///|
