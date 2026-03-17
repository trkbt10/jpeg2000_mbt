///|
// Unit tests for quantization/dequantization functions (Annex E)
// Uses sample codestreams to get real QcdMetadata instances

///|
test "qcd_subband_max_bit_planes from minimal sample" {
  // Parse minimal codestream to get real QcdMetadata
  let data = @bytes.int_array_to_bytes(@core.sample_codestream_minimal())
  let cs = @core.parse_codestream(data)
  guard cs is Ok(codestream) else { fail("parse failed") }
  guard codestream.metadata.qcd is Some(qcd) else { fail("no QCD") }
  // Minimal sample has qstyle=0, sqcd=0x00:
  // guard_bits = (0x00 >> 5) = 0, epsilon = (0x00 >> 3) = 0
  // T.800-2015 E.1.1: K = epsilon + guard_bits - 1 = 0 + 0 - 1 = -1
  let k = qcd_subband_max_bit_planes(qcd, 0)
  inspect(k, content="-1")
}

///|
test "qcd_subband_step_size from minimal sample returns 1.0 for qstyle=0" {
  let data = @bytes.int_array_to_bytes(@core.sample_codestream_minimal())
  let cs = @core.parse_codestream(data)
  guard cs is Ok(codestream) else { fail("parse failed") }
  guard codestream.metadata.qcd is Some(qcd) else { fail("no QCD") }
  // For qstyle=0 (reversible), step size should be 1.0
  if qcd.quantization_style == 0 {
    let step = qcd_subband_step_size(qcd, 0, 8)
    inspect(step, content="1")
  }
}
