///|
fn wb_marker_index(data : Array[Int], marker_hi : Int, marker_lo : Int) -> Int? {
  for i in 0..<(data.length() - 1) {
    if data[i] == marker_hi && data[i + 1] == marker_lo {
      return Some(i)
    }
  }
  None
}

///|
fn wb_insert_bytes_at(
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
fn wb_patch_u32_be(data : Array[Int], at : Int, value : Int) -> Unit {
  data[at] = (value >> 24) & 0xFF
  data[at + 1] = (value >> 16) & 0xFF
  data[at + 2] = (value >> 8) & 0xFF
  data[at + 3] = value & 0xFF
}
