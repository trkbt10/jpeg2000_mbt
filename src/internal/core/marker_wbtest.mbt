///|
// Unit tests for marker classification and validation

///|
test "classify_marker identifies delimiting markers" {
  // SOC, SOT, SOD, EOC are delimiting markers
  inspect(classify_marker(0xFF4F), content="Delimiting") // SOC
  inspect(classify_marker(0xFF90), content="Delimiting") // SOT
  inspect(classify_marker(0xFF93), content="Delimiting") // SOD
  inspect(classify_marker(0xFFD9), content="Delimiting") // EOC
}

///|
test "classify_marker identifies fixed information markers" {
  // SIZ is the only fixed information marker
  inspect(classify_marker(0xFF51), content="FixedInformation") // SIZ
}

///|
test "classify_marker identifies functional markers" {
  // COD, COC, RGN, QCD, QCC, POC are functional markers
  inspect(classify_marker(0xFF52), content="Functional") // COD
  inspect(classify_marker(0xFF53), content="Functional") // COC
  inspect(classify_marker(0xFF5E), content="Functional") // RGN
  inspect(classify_marker(0xFF5C), content="Functional") // QCD
  inspect(classify_marker(0xFF5D), content="Functional") // QCC
  inspect(classify_marker(0xFF5F), content="Functional") // POC
}

///|
test "classify_marker identifies pointer markers" {
  // TLM, PLM, PLT, PPM, PPT are pointer markers
  inspect(classify_marker(0xFF55), content="Pointer") // TLM
  inspect(classify_marker(0xFF57), content="Pointer") // PLM
  inspect(classify_marker(0xFF58), content="Pointer") // PLT
  inspect(classify_marker(0xFF60), content="Pointer") // PPM
  inspect(classify_marker(0xFF61), content="Pointer") // PPT
}

///|
test "classify_marker identifies in-bitstream markers" {
  // SOP, EPH are in-bitstream markers
  inspect(classify_marker(0xFF91), content="InBitStream") // SOP
  inspect(classify_marker(0xFF92), content="InBitStream") // EPH
}

///|
test "classify_marker identifies informational markers" {
  // CRG, COM are informational markers
  inspect(classify_marker(0xFF63), content="Informational") // CRG
  inspect(classify_marker(0xFF64), content="Informational") // COM
}

///|
test "classify_marker returns Unknown for invalid markers" {
  inspect(classify_marker(0x0000), content="Unknown")
  inspect(classify_marker(0xFF00), content="Unknown")
  inspect(classify_marker(0xFFFF), content="Unknown")
}

///|
// T.800-2015 A.8.1: SOP Nsop sequence validation tests
test "T800_A81_sop_nsop_valid_sequence_0_1_2" {
  let sops : Array[SopMetadata] = [
    { nsop: 0, position: 100 },
    { nsop: 1, position: 200 },
    { nsop: 2, position: 300 },
  ]
  let result = validate_sop_nsop_sequence(sops)
  assert_true(result.is_ok())
}

///|
test "T800_A81_sop_nsop_rollover_65535_to_0" {
  let sops : Array[SopMetadata] = [
    { nsop: 65534, position: 100 },
    { nsop: 65535, position: 200 },
    { nsop: 0, position: 300 }, // Rollover per A.8.1
  ]
  let result = validate_sop_nsop_sequence(sops)
  assert_true(result.is_ok())
}

///|
test "T800_A81_sop_nsop_gap_detection" {
  let sops : Array[SopMetadata] = [
    { nsop: 0, position: 100 },
    { nsop: 1, position: 200 },
    { nsop: 3, position: 300 }, // Gap: expected 2
  ]
  let result = validate_sop_nsop_sequence(sops)
  assert_true(result.is_err())
}

///|
test "T800_A81_sop_nsop_empty_array_ok" {
  let sops : Array[SopMetadata] = []
  let result = validate_sop_nsop_sequence(sops)
  assert_true(result.is_ok())
}

///|
test "T800_A81_sop_nsop_single_packet_ok" {
  let sops : Array[SopMetadata] = [{ nsop: 0, position: 100 }]
  let result = validate_sop_nsop_sequence(sops)
  assert_true(result.is_ok())
}

///|
test "htj2k first-packet pass splits follow cleanup then refinement" {
  assert_eq(codeblock_segment_pass_splits_for_style(1, 0x40), [1])
  assert_eq(codeblock_segment_pass_splits_for_style(2, 0x40), [1, 1])
  assert_eq(codeblock_segment_pass_splits_for_style(3, 0x40), [1, 2])
}

///|
test "termall first-packet pass splits remain one pass per segment" {
  assert_eq(codeblock_segment_pass_splits_for_style(3, 0x04), [1, 1, 1])
}
