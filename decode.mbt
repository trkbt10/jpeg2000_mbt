///|
fn wrap_decode_samples_result(
  result : @orchestrate.DecodeSamplesResult,
) -> DecodeSamplesResult {
  {
    width: result.width,
    height: result.height,
    num_components: result.num_components,
    bits_per_component: result.bits_per_component,
    is_signed: result.is_signed,
    sample_layout: result.sample_layout,
    samples: result.samples,
  }
}

///|
pub fn decode_samples(data : Bytes) -> Result[DecodeSamplesResult, String] {
  match @decoder.decode_samples(data) {
    Ok(result) => Ok(wrap_decode_samples_result(result))
    Err(msg) => Err(msg)
  }
}

///|
pub fn decode_samples_audit(
  data : Bytes,
  packet_audit_limit? : Int = 300,
  force_relocated_ppt? : Bool = false,
) -> Result[DecodeSamplesResult, String] {
  match
    @decoder.decode_samples_audit(
      data,
      packet_audit_limit~,
      force_relocated_ppt~,
    ) {
    Ok(result) => Ok(wrap_decode_samples_result(result))
    Err(msg) => Err(msg)
  }
}
