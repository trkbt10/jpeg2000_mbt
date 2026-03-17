///|
fn native_corpus_file_names() -> Array[String] {
  ["a2_colr.j2c", "b1_mono.j2c", "p0_03.j2k"]
}


///|
test "native corpus decode smoke" {
  for name in native_corpus_file_names() {
    let path = "samples/corpus/" + name
    let loaded = corpus_read_file(path)
    guard loaded is Ok(bytes) else {
      if loaded is Err(msg) {
        fail(msg)
      }
      fail("failed to read corpus file")
    }
    let decoded = @jpeg2000.decode_samples(bytes)
    guard decoded is Ok(result) else {
      if decoded is Err(msg) {
        fail("decode_samples failed for \{name}: \{msg}")
      }
      fail("decode_samples failed for \{name}")
    }
    assert_true(result.width > 0)
    assert_true(result.height > 0)
    assert_true(result.num_components > 0)
    assert_true(result.bits_per_component > 0)
    assert_true(result.sample_layout.has_prefix("component0:"))
    assert_eq(
      result.samples.length(),
      result.width * result.height * ((result.bits_per_component + 7) / 8),
    )
  }
}

///|
test "native corpus decode deterministic smoke" {
  for name in native_corpus_file_names() {
    let path = "samples/corpus/" + name
    let loaded = corpus_read_file(path)
    guard loaded is Ok(bytes) else {
      if loaded is Err(msg) {
        fail(msg)
      }
      fail("failed to read corpus file")
    }
    let first = @jpeg2000.decode_samples(bytes)
    let second = @jpeg2000.decode_samples(bytes)
    if first is Ok(a) {
      guard second is Ok(b) else {
        fail("decode_samples became non-deterministic for \{name}")
      }
      assert_eq(a.width, b.width)
      assert_eq(a.height, b.height)
      assert_eq(a.num_components, b.num_components)
      assert_eq(a.bits_per_component, b.bits_per_component)
      assert_eq(a.is_signed, b.is_signed)
      assert_eq(a.sample_layout, b.sample_layout)
      assert_eq(a.samples, b.samples)
    } else if first is Err(msg_a) {
      guard second is Err(msg_b) else {
        fail("decode_samples became non-deterministic for \{name}")
      }
      assert_eq(msg_a, msg_b)
    }
  }
}
