///|
fn corpus_name_lt(a : String, b : String) -> Bool {
  let al = a.length()
  let bl = b.length()
  let n = if al < bl { al } else { bl }
  for i in 0..<n {
    if a[i] != b[i] {
      return a[i] < b[i]
    }
  }
  al < bl
}

///|
fn corpus_sorted_names(xs : Array[String]) -> Array[String] {
  let out : Array[String] = []
  for x in xs {
    out.push(x)
  }
  for i in 0..<out.length() {
    let mut best = i
    for j in (i + 1)..<out.length() {
      if corpus_name_lt(out[j], out[best]) {
        best = j
      }
    }
    if best != i {
      let tmp = out[i]
      out[i] = out[best]
      out[best] = tmp
    }
  }
  out
}

///|
fn corpus_read_file(path : String) -> Result[Bytes, String] {
  let loaded = Ok(@fs.read_file_to_bytes(path)) catch { _ => Err(()) }
  guard loaded is Ok(bytes) else {
    return Err("failed to read corpus file: \{path}")
  }
  Ok(bytes)
}
