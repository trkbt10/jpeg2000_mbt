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
