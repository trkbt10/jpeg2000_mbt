///|
fn corpus_target_file_names() -> Result[Array[String], String] {
  let entries = Ok(@fs.read_dir("samples/corpus")) catch { _ => Err(()) }
  guard entries is Ok(raw) else { return Err("failed to read samples/corpus") }
  let picked : Array[String] = []
  for name in raw {
    if name.has_suffix(".j2k") || name.has_suffix(".j2c") {
      picked.push(name)
    }
  }
  if picked.length() <= 0 {
    return Err("no .j2k/.j2c files found in samples/corpus")
  }
  Ok(corpus_sorted_names(picked))
}



///|
fn corpus_bytes_slice_to_int_array(
  data : Bytes,
  start : Int,
  count : Int,
) -> Array[Int] {
  let out : Array[Int] = []
  if start < 0 || count <= 0 {
    return out
  }
  let end_ = start + count
  for i in start..<end_ {
    if i >= data.length() {
      break
    }
    out.push(data[i].to_int())
  }
  out
}

///|
fn corpus_decode_samples_eq(
  lhs : DecodeSamplesResult,
  rhs : DecodeSamplesResult,
) -> Bool {
  lhs.width == rhs.width &&
  lhs.height == rhs.height &&
  lhs.num_components == rhs.num_components &&
  lhs.bits_per_component == rhs.bits_per_component &&
  lhs.is_signed == rhs.is_signed &&
  lhs.sample_layout == rhs.sample_layout &&
  lhs.samples == rhs.samples
}

///|
fn corpus_all_components_payload_len_ok(
  result : @orchestrate.DecodeAllComponentsResult,
) -> Bool {
  for component in result.components {
    if component.samples.length() !=
      component.width *
      component.height *
      ((component.bits_per_component + 7) / 8) {
      return false
    }
  }
  true
}

///|
test "corpus files parse with default parser" {
  let names_v = corpus_target_file_names()
  guard names_v is Ok(names) else {
    if names_v is Err(msg) {
      fail(msg)
    }
    fail("failed to enumerate corpus files")
  }
  for name in names {
    let path = "samples/corpus/" + name
    let loaded = corpus_read_file(path)
    guard loaded is Ok(bytes) else {
      if loaded is Err(msg) {
        fail(msg)
      }
      fail("failed to read corpus file")
    }
    let parsed = parse_codestream(@bytes.bytes_to_int_array(bytes))
    guard parsed is Ok(_) else {
      if parsed is Err(msg) {
        fail("parse_codestream failed for \{name}: \{msg}")
      }
      fail("parse_codestream failed for \{name}")
    }
  }
}

///|
test "decode_samples is deterministic on corpus files" {
  let names_v = corpus_target_file_names()
  guard names_v is Ok(names) else {
    if names_v is Err(msg) {
      fail(msg)
    }
    fail("failed to enumerate corpus files")
  }
  for name in names {
    let path = "samples/corpus/" + name
    let loaded = corpus_read_file(path)
    guard loaded is Ok(bytes) else {
      if loaded is Err(msg) {
        fail(msg)
      }
      fail("failed to read corpus file")
    }
    let first = decode_samples(bytes)
    let second = decode_samples(bytes)
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

///|
test "decode_samples exposes normalized metadata on corpus files" {
  let names_v = corpus_target_file_names()
  guard names_v is Ok(names) else {
    if names_v is Err(msg) {
      fail(msg)
    }
    fail("failed to enumerate corpus files")
  }
  for name in names {
    let path = "samples/corpus/" + name
    let loaded = corpus_read_file(path)
    guard loaded is Ok(bytes) else {
      if loaded is Err(msg) {
        fail(msg)
      }
      fail("failed to read corpus file")
    }
    let decoded = decode_samples(bytes)
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
test "decode_samples_all_components_debug preserves component0 contract on representative multicomponent corpus files" {
  let fixtures : Array[(String, Int)] = [
    ("a2_colr.j2c", 3),
    ("p0_05.j2k", 4),
    ("p1_05.j2k", 3),
    ("p0_13.j2k", 257),
  ]
  for entry in fixtures {
    let (name, expected_components) = entry
    let loaded = corpus_read_file("samples/corpus/" + name)
    guard loaded is Ok(bytes) else {
      if loaded is Err(msg) {
        fail(msg)
      }
      fail("failed to read corpus file")
    }
    let public_decoded_v = decode_samples(bytes)
    guard public_decoded_v is Ok(public_decoded) else {
      if public_decoded_v is Err(msg) {
        fail("decode_samples failed for \{name}: \{msg}")
      }
      fail("decode_samples failed for \{name}")
    }
    let all_components_v = @decoder.decode_samples_all_components_debug(bytes)
    guard all_components_v is Ok(all_components) else {
      if all_components_v is Err(msg) {
        fail("decode_samples_all_components_debug failed for \{name}: \{msg}")
      }
      fail("decode_samples_all_components_debug failed for \{name}")
    }
    assert_eq(all_components.num_components, expected_components)
    assert_eq(all_components.components.length(), expected_components)
    assert_true(all_components.sample_layout.has_prefix("components:"))
    assert_true(corpus_all_components_payload_len_ok(all_components))
    let component0 = all_components.components[0]
    assert_eq(component0.component_index, 0)
    assert_eq(component0.samples, public_decoded.samples)
    assert_eq(component0.width, public_decoded.width)
    assert_eq(component0.height, public_decoded.height)
    assert_eq(component0.bits_per_component, public_decoded.bits_per_component)
    assert_eq(component0.is_signed, public_decoded.is_signed)
  }
}

///|
test "decode_samples_all_components_debug keeps p0_13 post-128 POC CPRL volume values" {
  let loaded = corpus_read_file("samples/corpus/p0_13.j2k")
  guard loaded is Ok(bytes) else {
    if loaded is Err(msg) {
      fail(msg)
    }
    fail("failed to read p0_13.j2k")
  }
  let decoded_v = @decoder.decode_samples_all_components_debug(bytes)
  guard decoded_v is Ok(decoded) else {
    if decoded_v is Err(msg) {
      fail("decode_samples_all_components_debug failed for p0_13.j2k: \{msg}")
    }
    fail("decode_samples_all_components_debug failed for p0_13.j2k")
  }
  let checkpoints : Array[(Int, Int)] = [
    (127, 127),
    (128, 128),
    (129, 129),
    (255, 255),
    (256, 0),
  ]
  for entry in checkpoints {
    let (component_index, expected) = entry
    let component = decoded.components[component_index]
    assert_eq(corpus_bytes_slice_to_int_array(component.samples, 0, 1), [
      expected,
    ])
  }
}

///|
test "parse_codestream_bytes keeps both p0_13 main-header POC entries" {
  let loaded = corpus_read_file("samples/corpus/p0_13.j2k")
  guard loaded is Ok(bytes) else {
    if loaded is Err(msg) {
      fail(msg)
    }
    fail("failed to read p0_13.j2k")
  }
  let parsed_v = parse_codestream_bytes(bytes)
  guard parsed_v is Ok(stream) else {
    if parsed_v is Err(msg) {
      fail("parse_codestream_bytes failed for p0_13.j2k: \{msg}")
    }
    fail("parse_codestream_bytes failed for p0_13.j2k")
  }
  assert_eq(stream.metadata.poc.length(), 2)
  let first = stream.metadata.poc[0]
  assert_eq(first.rspoc, 0)
  assert_eq(first.cspoc, 0)
  assert_eq(first.lyepoc, 1)
  assert_eq(first.repoc, 33)
  assert_eq(first.cepoc, 128)
  assert_eq(first.ppoc, 1)
  assert_eq(first.in_main_header, true)
  let second = stream.metadata.poc[1]
  assert_eq(second.rspoc, 0)
  assert_eq(second.cspoc, 128)
  assert_eq(second.lyepoc, 1)
  assert_eq(second.repoc, 33)
  assert_eq(second.cepoc, 257)
  assert_eq(second.ppoc, 4)
  assert_eq(second.in_main_header, true)
}

///|
test "decode_samples_all_components_debug keeps p0_05 qstyle2 component checkpoints stable" {
  let loaded = corpus_read_file("samples/corpus/p0_05.j2k")
  guard loaded is Ok(bytes) else {
    if loaded is Err(msg) {
      fail(msg)
    }
    fail("failed to read p0_05.j2k")
  }
  let decoded_v = @decoder.decode_samples_all_components_debug(bytes)
  guard decoded_v is Ok(decoded) else {
    if decoded_v is Err(msg) {
      fail("decode_samples_all_components_debug failed for p0_05.j2k: \{msg}")
    }
    fail("decode_samples_all_components_debug failed for p0_05.j2k")
  }
  let component1 = decoded.components[1]
  let component2 = decoded.components[2]
  assert_eq(corpus_bytes_slice_to_int_array(component1.samples, 0, 16), [
    45, 50, 51, 44, 50, 57, 61, 51, 37, 37, 38, 38, 35, 36, 36, 37,
  ])
  assert_eq(corpus_bytes_slice_to_int_array(component2.samples, 0, 16), [
    1, 4, 2, 2, 5, 3, 3, 5, 4, 2, 2, 3, 2, 4, 3, 2,
  ])
  let component1_checkpoints : Array[(Int, Int)] = [
    (262144, 17),
    (262145, 14),
    (327680, 225),
    (327681, 149),
    (1048572, 137),
    (1048575, 137),
  ]
  for entry in component1_checkpoints {
    let (index, expected) = entry
    assert_eq(component1.samples[index].to_int(), expected)
  }
  let component2_checkpoints : Array[(Int, Int)] = [
    (49632, 103),
    (98336, 35),
    (131488, 120),
    (147808, 4),
    (262140, 127),
    (262143, 126),
  ]
  for entry in component2_checkpoints {
    let (index, expected) = entry
    assert_eq(component2.samples[index].to_int(), expected)
  }
}

///|
test "p1_05 decode_samples keeps styled lossy tile slice stable" {
  let loaded = corpus_read_file("samples/corpus/p1_05.j2k")
  guard loaded is Ok(bytes) else {
    if loaded is Err(msg) {
      fail(msg)
    }
    fail("failed to read p1_05.j2k")
  }
  let decoded = decode_samples(bytes)
  guard decoded is Ok(result) else {
    if decoded is Err(msg) {
      fail("decode_samples failed for p1_05.j2k: \{msg}")
    }
    fail("decode_samples failed for p1_05.j2k")
  }
  assert_eq(result.width, 512)
  assert_eq(result.height, 512)
  inspect(
    corpus_bytes_slice_to_int_array(result.samples, 32, 16),
    content=(
      #|[87, 85, 82, 79, 80, 81, 81, 82, 81, 79, 77, 76, 74, 72, 69, 68]
    ),
  )
  inspect(
    corpus_bytes_slice_to_int_array(result.samples, 544, 16),
    content=(
      #|[91, 84, 82, 80, 80, 81, 81, 81, 81, 79, 77, 73, 69, 65, 63, 63]
    ),
  )
}

///|
test "p1_05 roundtrip codestream preserves decode_samples result" {
  let loaded = corpus_read_file("samples/corpus/p1_05.j2k")
  guard loaded is Ok(bytes) else {
    if loaded is Err(msg) {
      fail(msg)
    }
    fail("failed to read p1_05.j2k")
  }
  let roundtripped_v = roundtrip_bytes(
    @bytes.bytes_to_int_array(bytes),
  )
  guard roundtripped_v is Ok(roundtripped) else {
    if roundtripped_v is Err(msg) {
      fail("roundtrip_bytes failed for p1_05.j2k: \{msg}")
    }
    fail("roundtrip_bytes failed for p1_05.j2k")
  }
  let original_decoded_v = decode_samples(bytes)
  guard original_decoded_v is Ok(original_decoded) else {
    if original_decoded_v is Err(msg) {
      fail("decode_samples failed for original p1_05.j2k: \{msg}")
    }
    fail("decode_samples failed for original p1_05.j2k")
  }
  let roundtrip_decoded_v = decode_samples(
    @bytes.int_array_to_bytes(roundtripped),
  )
  guard roundtrip_decoded_v is Ok(roundtrip_decoded) else {
    if roundtrip_decoded_v is Err(msg) {
      fail("decode_samples failed for roundtripped p1_05.j2k: \{msg}")
    }
    fail("decode_samples failed for roundtripped p1_05.j2k")
  }
  assert_true(corpus_decode_samples_eq(original_decoded, roundtrip_decoded))
}
