///|
pub enum MarkerClass {
  Delimiting
  FixedInformation
  Functional
  Pointer
  InBitStream
  Informational
  Unknown
} derive(Eq, Show)

///|
pub struct MarkerSegment {
  code : Int
  payload : Array[Int]
  position : Int
} derive(Eq, Show)

///|
pub struct Codestream {
  segments : Array[MarkerSegment]
  metadata : CodestreamMetadata
} derive(Eq, Show)

///|
pub struct CodestreamMetadata {
  siz : SizMetadata?
  cod : CodMetadata?
  qcd : QcdMetadata?
  coc : Array[CocMetadata]
  rgn : Array[RgnMetadata]
  qcc : Array[QccMetadata]
  poc : Array[PocMetadata]
  tlm : Array[TlmMetadata]
  plm : Array[PlmMetadata]
  plt : Array[PltMetadata]
  ppm : Array[PpmMetadata]
  ppt : Array[PptMetadata]
  sop : Array[SopMetadata]
  eph_positions : Array[Int]
  crg : CrgMetadata?
  com : Array[ComMetadata]
  ordering : OrderingMetadata?
  ordering_coding : OrderingCodingMetadata?
  progression : ProgressionMetadata?
  packet_headers_ppm : Array[PacketHeaderMetadata]
  packet_headers_ppt : Array[PacketHeaderMetadata]
} derive(Eq, Show)

///|
pub struct SizComponentMetadata {
  precision_bits : Int
  is_signed : Bool
  xrsiz : Int
  yrsiz : Int
} derive(Eq, Show)

///|
pub struct SizMetadata {
  rsiz : Int
  xsiz : Int
  ysiz : Int
  xosiz : Int
  yosiz : Int
  xtsiz : Int
  ytsiz : Int
  xtosiz : Int
  ytosiz : Int
  csiz : Int
  tile_count : Int
  components : Array[SizComponentMetadata]
} derive(Eq, Show)

///|
pub struct CodMetadata {
  scod : Int
  progression_order : Int
  layers : Int
  multiple_component_transform : Int
  decomposition_levels : Int
  code_block_width_exponent : Int
  code_block_height_exponent : Int
  code_block_style : Int
  transformation : Int
  uses_precincts : Bool
  uses_sop : Bool
  uses_eph : Bool
  precinct_size_bytes : Array[Int]
} derive(Eq, Show)

///|
pub struct QcdMetadata {
  sqcd : Int
  guard_bits : Int
  quantization_style : Int
  parameters : Array[Int]
} derive(Eq, Show)

///|
pub struct CocMetadata {
  component : Int
  scoc : Int
  parameters : Array[Int]
  in_main_header : Bool
} derive(Eq, Show)

///|
pub struct RgnMetadata {
  component : Int
  style : Int
  shift : Int
  in_main_header : Bool
} derive(Eq, Show)

///|
pub struct QccMetadata {
  component : Int
  sqcc : Int
  parameters : Array[Int]
  in_main_header : Bool
} derive(Eq, Show)

///|
pub struct PocMetadata {
  rspoc : Int
  cspoc : Int
  lyepoc : Int
  repoc : Int
  cepoc : Int
  ppoc : Int
  in_main_header : Bool
} derive(Eq, Show)

///|
pub struct TlmEntryMetadata {
  tile : Int?
  length : Int
} derive(Eq, Show)

///|
pub struct TlmMetadata {
  ztlm : Int
  stlm : Int
  entries : Array[TlmEntryMetadata]
} derive(Eq, Show)

///|
pub struct PlmChunkMetadata {
  nplm : Int
  packet_lengths : Array[Int]
} derive(Eq, Show)

///|
pub struct PlmMetadata {
  zplm : Int
  chunks : Array[PlmChunkMetadata]
} derive(Eq, Show)

///|
pub struct PltMetadata {
  zplt : Int
  packet_lengths : Array[Int]
} derive(Eq, Show)

///|
pub struct PpmChunkMetadata {
  nppm : Int
  ippm : Array[Int]
} derive(Eq, Show)

///|
pub struct PpmMetadata {
  zppm : Int
  chunks : Array[PpmChunkMetadata]
} derive(Eq, Show)

///|
pub struct PptMetadata {
  zppt : Int
  data : Array[Int]
} derive(Eq, Show)

///|
pub struct SopMetadata {
  nsop : Int
  position : Int
} derive(Eq, Show)

///|
pub struct CrgComponentMetadata {
  xcrg : Int
  ycrg : Int
} derive(Eq, Show)

///|
pub struct CrgMetadata {
  components : Array[CrgComponentMetadata]
} derive(Eq, Show)

///|
pub struct ComMetadata {
  rcom : Int
  ccom : Array[Int]
} derive(Eq, Show)

///|
pub struct ReferenceGridMetadata {
  x0 : Int
  y0 : Int
  x1 : Int
  y1 : Int
} derive(Eq, Show)

///|
pub struct ComponentGeometryMetadata {
  component : Int
  xrsiz : Int
  yrsiz : Int
  width : Int
  height : Int
} derive(Eq, Show)

///|
pub struct TileGeometryMetadata {
  tile_index : Int
  tx : Int
  ty : Int
  x0 : Int
  y0 : Int
  x1 : Int
  y1 : Int
} derive(Eq, Show)

///|
pub struct TileComponentGeometryMetadata {
  tile_index : Int
  component : Int
  x0 : Int
  y0 : Int
  x1 : Int
  y1 : Int
  width : Int
  height : Int
} derive(Eq, Show)

///|
pub struct OrderingMetadata {
  reference_grid : ReferenceGridMetadata
  tiles_x : Int
  tiles_y : Int
  components : Array[ComponentGeometryMetadata]
  tiles : Array[TileGeometryMetadata]
  tile_components : Array[TileComponentGeometryMetadata]
} derive(Eq, Show)

///|
pub struct OrderingCodingMetadata {
  decomposition_levels : Int
  resolution_count : Int
  subbands_per_resolution : Array[Int]
  precincts : Array[PrecinctResolutionMetadata]
  code_blocks : Array[CodeBlockResolutionMetadata]
  packets : Array[PacketUnitMetadata]
} derive(Eq, Show)

///|
pub struct PrecinctResolutionMetadata {
  resolution : Int
  ppx : Int
  ppy : Int
  precinct_width : Int
  precinct_height : Int
} derive(Eq, Show)

///|
pub struct CodeBlockResolutionMetadata {
  resolution : Int
  nominal_width : Int
  nominal_height : Int
} derive(Eq, Show)

///|
pub struct PacketUnitMetadata {
  tile_index : Int
  component : Int
  resolution : Int
  precincts_x : Int
  precincts_y : Int
  packets_per_layer : Int
  layers : Int
  packets_total : Int
} derive(Eq, Show)

///|
pub struct ProgressionStepMetadata {
  order_index : Int
  layer : Int
  resolution : Int
  component : Int
  packet_count : Int
} derive(Eq, Show)

///|
pub struct ProgressionVolumeMetadata {
  source_poc_index : Int
  order_code : Int
  layer_start : Int
  layer_end : Int
  resolution_start : Int
  resolution_end : Int
  component_start : Int
  component_end : Int
} derive(Eq, Show)

///|
pub struct ProgressionMetadata {
  order_code : Int
  volumes : Array[ProgressionVolumeMetadata]
  steps : Array[ProgressionStepMetadata]
  total_packets : Int
} derive(Eq, Show)

///|
pub struct PacketHeaderCodeBlockMetadata {
  code_block_index : Int
  included : Bool
  first_inclusion : Bool
  zero_bit_planes : Int?
  coding_passes : Int?
  lblock_increment : Int?
  segment_lengths : Array[Int]
} derive(Eq, Show)

///|
pub struct PacketHeaderMetadata {
  zero_length : Bool
  code_blocks : Array[PacketHeaderCodeBlockMetadata]
  consumed_bits : Int
} derive(Eq, Show)

///|
pub struct TagTreeLevelMetadata {
  width : Int
  height : Int
  offset : Int
} derive(Eq, Show)

///|
fn minimal_siz_payload() -> Array[Int] {
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
     0x07, 0x01, 0x01, // Ssiz/XRsiz/YRsiz
  ]
}

///|
fn minimal_cod_payload() -> Array[Int] {
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
pub fn sample_codestream_minimal() -> Array[Int] {
  let siz_payload = minimal_siz_payload()
  let cod_payload = minimal_cod_payload()
  [
    0xFF, 0x4F, // SOC
     0xFF, 0x51, // SIZ
     0x00, 0x29, ..siz_payload, 0xFF, 0x52, // COD
     0x00, 0x0C, ..cod_payload, 0xFF, 0x5C, // QCD
     0x00, 0x04, 0x00, 0x00, 0xFF, 0x90, // SOT
     0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x01, 0xFF, 0x93, // SOD
     0xFF, 0xD9, // EOC
  ]
}

///|
pub fn sample_codestream_with_com() -> Array[Int] {
  let siz_payload = minimal_siz_payload()
  let cod_payload = minimal_cod_payload()
  [
    0xFF, 0x4F, // SOC
     0xFF, 0x51, // SIZ
     0x00, 0x29, ..siz_payload, 0xFF, 0x52, // COD
     0x00, 0x0C, ..cod_payload, 0xFF, 0x5C, // QCD
     0x00, 0x04, 0x00, 0x00, 0xFF, 0x64, // COM
     0x00, 0x04, 0x00, 0x01, // Rcom
     0xFF, 0x90, // SOT
     0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x01, 0xFF, 0x93, // SOD
     0xFF, 0xD9, // EOC
  ]
}

///|
pub fn sample_codestream_with_coc_qcc() -> Array[Int] {
  let siz_payload = minimal_siz_payload()
  let cod_payload = minimal_cod_payload()
  [
    0xFF, 0x4F, // SOC
     0xFF, 0x51, // SIZ
     0x00, 0x29, ..siz_payload, 0xFF, 0x52, // COD
     0x00, 0x0C, ..cod_payload, 0xFF, 0x53, // COC
     0x00, 0x05, 0x00, 0x00, 0x00, 0xFF, 0x5C, // QCD
     0x00, 0x04, 0x00, 0x00, 0xFF, 0x5D, // QCC
     0x00, 0x05, 0x00, 0x00, 0x00, 0xFF, 0x90, // SOT
     0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x01, 0xFF, 0x93, // SOD
     0xFF, 0xD9, // EOC
  ]
}

///|
pub fn sample_codestream_with_poc() -> Array[Int] {
  let siz_payload = minimal_siz_payload()
  let cod_payload = minimal_cod_payload()
  [
    0xFF, 0x4F, // SOC
     0xFF, 0x51, // SIZ
     0x00, 0x29, ..siz_payload, 0xFF, 0x52, // COD
     0x00, 0x0C, ..cod_payload, 0xFF, 0x5C, // QCD
     0x00, 0x04, 0x00, 0x00, 0xFF, 0x5F, // POC
     0x00, 0x09, // Lpoc = 2 + 7
     0x00, // RSpoc
     0x00, // CSpoc
     0x00, 0x01, // LYEpoc
     0x01, // REpoc
     0x01, // CEpoc
     0x00, // Ppoc
     0xFF, 0x90, // SOT
     0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x01, 0xFF, 0x93, // SOD
     0xFF, 0xD9, // EOC
  ]
}

///|
pub fn sample_codestream_with_ppt_sop_eph() -> Array[Int] {
  let siz_payload = minimal_siz_payload()
  let cod_payload = minimal_cod_payload()
  [
    0xFF, 0x4F, // SOC
     0xFF, 0x51, // SIZ
     0x00, 0x29, ..siz_payload, 0xFF, 0x52, // COD
     0x00, 0x0C, ..cod_payload, 0xFF, 0x5C, // QCD
     0x00, 0x04, 0x00, 0x00, 0xFF, 0x90, // SOT
     0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1C, 0x00, 0x01, 0xFF, 0x61, // PPT
     0x00, 0x04, 0x00, 0x00, 0xFF, 0x93, // SOD
     0xFF, 0x91, // SOP
     0x00, 0x04, 0x00, 0x00, 0xFF, 0x92, // EPH
     0xFF, 0xD9, // EOC
  ]
}

///|
pub fn sample_codestream_two_tileparts() -> Array[Int] {
  let siz_payload = minimal_siz_payload()
  let cod_payload = minimal_cod_payload()
  [
    0xFF, 0x4F, // SOC
     0xFF, 0x51, // SIZ
     0x00, 0x29, ..siz_payload, 0xFF, 0x52, // COD
     0x00, 0x0C, ..cod_payload, 0xFF, 0x5C, // QCD
     0x00, 0x04, 0x00, 0x00,
    // Tile-part #1
     0xFF, 0x90, // SOT
     0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x12, 0x00, 0x02, 0xFF, 0x93, // SOD
     0x11, 0xFF, 0x00, 0x22, // packet bytes (includes stuffed 0xFF)
    // Tile-part #2
     0xFF, 0x90, // SOT
     0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x01, 0x02, 0xFF, 0x93, // SOD
     0x33, 0x44, 0x55, // packet bytes
     0xFF, 0xD9, // EOC
  ]
}

///|
pub fn sample_codestream_with_plm_plt() -> Array[Int] {
  let siz_payload = minimal_siz_payload()
  let cod_payload = minimal_cod_payload()
  [
    0xFF, 0x4F, // SOC
     0xFF, 0x51, // SIZ
     0x00, 0x29, ..siz_payload, 0xFF, 0x52, // COD
     0x00, 0x0C, ..cod_payload, 0xFF, 0x5C, // QCD
     0x00, 0x04, 0x00, 0x00, 0xFF, 0x57, // PLM
     0x00, 0x05, 0x00, 0x01, 0x01, // Zplm, Nplm, Iplm(1)
     0xFF, 0x90, // SOT
     0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x14, 0x00, 0x01, 0xFF, 0x58, // PLT
     0x00, 0x04, 0x00, 0x01, // Zplt, Iplt(1)
     0xFF, 0x93, // SOD
     0xFF, 0xD9, // EOC
  ]
}

///|
pub fn sample_codestream_with_tlm() -> Array[Int] {
  let siz_payload = minimal_siz_payload()
  let cod_payload = minimal_cod_payload()
  [
    0xFF, 0x4F, // SOC
     0xFF, 0x51, // SIZ
     0x00, 0x29, ..siz_payload, 0xFF, 0x52, // COD
     0x00, 0x0C, ..cod_payload, 0xFF, 0x5C, // QCD
     0x00, 0x04, 0x00, 0x00, 0xFF, 0x55, // TLM
     0x00, 0x06, 0x00, 0x00, 0x00, 0x0E, // Ztlm, Stlm=0, Ptlm=14
     0xFF, 0x90, // SOT
     0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x01, 0xFF, 0x93, // SOD
     0xFF, 0xD9, // EOC
  ]
}

///|
pub fn sample_codestream_with_ppm() -> Array[Int] {
  let siz_payload = minimal_siz_payload()
  let cod_payload = minimal_cod_payload()
  [
    0xFF, 0x4F, // SOC
     0xFF, 0x51, // SIZ
     0x00, 0x29, ..siz_payload, 0xFF, 0x52, // COD
     0x00, 0x0C, ..cod_payload, 0xFF, 0x5C, // QCD
     0x00, 0x04, 0x00, 0x00, 0xFF, 0x60, // PPM
     0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, // Zppm, Nppm=1, Ippm(1)
     0xFF, 0x90, // SOT
     0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x01, 0xFF, 0x93, // SOD
     0xFF, 0xD9, // EOC
  ]
}

///|
pub fn sample_codestream_by_name(name : String) -> Array[Int]? {
  if name == "minimal" {
    return Some(sample_codestream_minimal())
  }
  if name == "with-com" {
    return Some(sample_codestream_with_com())
  }
  if name == "with-coc-qcc" {
    return Some(sample_codestream_with_coc_qcc())
  }
  if name == "with-poc" {
    return Some(sample_codestream_with_poc())
  }
  if name == "with-ppt-sop-eph" {
    return Some(sample_codestream_with_ppt_sop_eph())
  }
  if name == "two-tileparts" {
    return Some(sample_codestream_two_tileparts())
  }
  if name == "with-plm-plt" {
    return Some(sample_codestream_with_plm_plt())
  }
  if name == "with-tlm" {
    return Some(sample_codestream_with_tlm())
  }
  if name == "with-ppm" {
    return Some(sample_codestream_with_ppm())
  }
  None
}

///|
pub fn sample_codestream_names() -> Array[String] {
  [
    "minimal", "with-com", "with-coc-qcc", "with-poc", "with-ppt-sop-eph", "two-tileparts",
    "with-plm-plt", "with-tlm", "with-ppm",
  ]
}

///|
const MARKER_SOC : Int = 0xFF4F

///|
const MARKER_SOT : Int = 0xFF90

///|
const MARKER_SOD : Int = 0xFF93

///|
const MARKER_EOC : Int = 0xFFD9

///|
const MARKER_SIZ : Int = 0xFF51

///|
const MARKER_COD : Int = 0xFF52

///|
const MARKER_COC : Int = 0xFF53

///|
const MARKER_RGN : Int = 0xFF5E

///|
const MARKER_QCD : Int = 0xFF5C

///|
const MARKER_QCC : Int = 0xFF5D

///|
const MARKER_POC : Int = 0xFF5F

///|
const MARKER_TLM : Int = 0xFF55

///|
const MARKER_PLM : Int = 0xFF57

///|
const MARKER_PLT : Int = 0xFF58

///|
const MARKER_PPM : Int = 0xFF60

///|
const MARKER_PPT : Int = 0xFF61

///|
const MARKER_SOP : Int = 0xFF91

///|
const MARKER_EPH : Int = 0xFF92

///|
const MARKER_CRG : Int = 0xFF63

///|
const MARKER_COM : Int = 0xFF64

///|
pub fn classify_marker(code : Int) -> MarkerClass {
  if code == MARKER_SOC ||
    code == MARKER_SOT ||
    code == MARKER_SOD ||
    code == MARKER_EOC {
    MarkerClass::Delimiting
  } else if code == MARKER_SIZ {
    MarkerClass::FixedInformation
  } else if code == MARKER_COD ||
    code == MARKER_COC ||
    code == MARKER_RGN ||
    code == MARKER_QCD ||
    code == MARKER_QCC ||
    code == MARKER_POC {
    MarkerClass::Functional
  } else if code == MARKER_TLM ||
    code == MARKER_PLM ||
    code == MARKER_PLT ||
    code == MARKER_PPM ||
    code == MARKER_PPT {
    MarkerClass::Pointer
  } else if code == MARKER_SOP || code == MARKER_EPH {
    MarkerClass::InBitStream
  } else if code == MARKER_CRG || code == MARKER_COM {
    MarkerClass::Informational
  } else {
    MarkerClass::Unknown
  }
}

///|
fn has_explicit_length(code : Int) -> Bool {
  // Spec (Annex A.1.3): "0xFF30..0xFF3F ... markers only (no marker segments)".
  if is_reserved_jpeg_marker(code) {
    return false
  }
  !(code == MARKER_SOC ||
  code == MARKER_SOD ||
  code == MARKER_EOC ||
  code == MARKER_EPH)
}

///|
fn read_u16_be(data : Array[Int], at : Int) -> Result[Int, String] {
  if at + 1 >= data.length() {
    Err("unexpected end while reading u16")
  } else {
    let hi = data[at]
    let lo = data[at + 1]
    if hi < 0 || hi > 0xFF || lo < 0 || lo > 0xFF {
      Err("byte out of range")
    } else {
      Ok((hi << 8) + lo)
    }
  }
}

///|
fn read_u16_from_payload(payload : Array[Int], at : Int) -> Result[Int, String] {
  read_u16_be(payload, at)
}

///|
fn read_u32_from_payload(payload : Array[Int], at : Int) -> Result[Int, String] {
  if at + 3 >= payload.length() {
    Err("unexpected end while reading u32")
  } else {
    let b0 = payload[at]
    let b1 = payload[at + 1]
    let b2 = payload[at + 2]
    let b3 = payload[at + 3]
    if b0 < 0 ||
      b0 > 0xFF ||
      b1 < 0 ||
      b1 > 0xFF ||
      b2 < 0 ||
      b2 > 0xFF ||
      b3 < 0 ||
      b3 > 0xFF {
      Err("byte out of range")
    } else {
      Ok((b0 << 24) + (b1 << 16) + (b2 << 8) + b3)
    }
  }
}

///|
fn is_reserved_jpeg_marker(code : Int) -> Bool {
  // Annex A.1.2/A.1.3 reserved marker range.
  code >= 0xFF30 && code <= 0xFF3F
}

///|
fn validate_marker_placement(
  code : Int,
  in_main_header : Bool,
  in_tile_part_header : Bool,
  seen_siz : Bool,
  compat_mode : Bool,
) -> Result[Unit, String] {
  // Spec (Annex A.1.3): FF30..FF3F markers are reserved/skippable.
  // strict path keeps audit-time rejection; default parser handles them in stream loop.
  if is_reserved_jpeg_marker(code) && !compat_mode {
    return Err("reserved JPEG marker range is not allowed")
  }
  if code == MARKER_SOC || code == MARKER_EOC {
    return Ok(())
  }
  if code == MARKER_SOD {
    if !in_tile_part_header {
      return Err("SOD must appear in tile-part header")
    }
    return Ok(())
  }
  if code == MARKER_SOT {
    if in_main_header || !in_tile_part_header {
      return Ok(())
    }
    return Err("SOT must appear after main header or packet data")
  }
  if code == MARKER_SOP || code == MARKER_EPH {
    if in_main_header {
      return Err("in-bit-stream marker cannot appear in main header")
    }
    return Ok(())
  }
  if code == MARKER_SIZ {
    if !in_main_header {
      return Err("SIZ must appear in main header")
    }
    if seen_siz {
      return Err("SIZ must appear exactly once")
    }
    return Ok(())
  }
  if code == MARKER_TLM ||
    code == MARKER_PLM ||
    code == MARKER_PPM ||
    code == MARKER_CRG {
    if !in_main_header {
      return Err("marker is restricted to main header")
    }
    return Ok(())
  }
  if code == MARKER_PLT || code == MARKER_PPT {
    if !in_tile_part_header {
      return Err("marker is restricted to tile-part header")
    }
    return Ok(())
  }
  Ok(())
}

///|
fn contains_int(xs : Array[Int], value : Int) -> Bool {
  for x in xs {
    if x == value {
      return true
    }
  }
  false
}

///|
fn find_next_sot_or_eoc(data : Array[Int], start : Int) -> Int {
  let mut i = start
  while i + 1 < data.length() {
    if data[i] == 0xFF {
      let n = data[i + 1]
      if n == 0x90 || n == 0xD9 {
        return i
      }
      if n == 0x00 {
        // Byte stuffing in packet data.
        i += 2
        continue
      }
    }
    i += 1
  }
  data.length()
}

///|
fn extract_in_bitstream_markers(
  packet : Array[Int],
  packet_start_pos : Int,
) -> (Array[SopMetadata], Array[Int]) {
  let sops : Array[SopMetadata] = []
  let ephs : Array[Int] = []
  let mut k = 0
  while k + 1 < packet.length() {
    if packet[k] != 0xFF {
      k += 1
      continue
    }
    let n = packet[k + 1]
    if n == 0x00 {
      k += 2
      continue
    }
    if n == 0x91 &&
      k + 5 < packet.length() &&
      packet[k + 2] == 0x00 &&
      packet[k + 3] == 0x04 {
      let nsop = (packet[k + 4] << 8) + packet[k + 5]
      sops.push({ nsop, position: packet_start_pos + k })
      k += 6
      continue
    }
    if n == 0x92 {
      ephs.push(packet_start_pos + k)
      k += 2
      continue
    }
    k += 1
  }
  (sops, ephs)
}

///|
fn validate_packet_bit_stuffing(packet : Array[Int]) -> Result[Unit, String] {
  // Spec (Annex B.10.1) defines packet-header stuffing, not a generic packet-body FFxx ban.
  let mut k = 0
  while k + 1 < packet.length() {
    if packet[k] != 0xFF {
      k += 1
      continue
    }
    let n = packet[k + 1]
    if n == 0x00 || n == 0x92 {
      k += 2
      continue
    }
    if n == 0x91 {
      if k + 5 >= packet.length() {
        return Err("truncated SOP marker in packet data")
      }
      if packet[k + 2] != 0x00 || packet[k + 3] != 0x04 {
        return Err("invalid SOP marker length in packet data")
      }
      k += 6
      continue
    }
    // Implementation policy: validate explicit SOP/EPH syntax only.
    k += 1
  }
  Ok(())
}

///|
fn read_u32_be(data : Array[Int], at : Int) -> Result[Int, String] {
  if at + 3 >= data.length() {
    Err("unexpected end while reading u32")
  } else {
    let b0 = data[at]
    let b1 = data[at + 1]
    let b2 = data[at + 2]
    let b3 = data[at + 3]
    if b0 < 0 ||
      b0 > 0xFF ||
      b1 < 0 ||
      b1 > 0xFF ||
      b2 < 0 ||
      b2 > 0xFF ||
      b3 < 0 ||
      b3 > 0xFF {
      Err("byte out of range")
    } else {
      Ok((b0 << 24) + (b1 << 16) + (b2 << 8) + b3)
    }
  }
}

///|
fn floor_log2_positive(v : Int) -> Int {
  let mut x = v
  let mut k = 0
  while x > 1 {
    x = x >> 1
    k += 1
  }
  k
}

///|
fn read_bit(data : Array[Int], bit_pos : Int) -> Result[Int, String] {
  let byte_index = bit_pos / 8
  if byte_index >= data.length() {
    return Err("packet header bitstream truncated")
  }
  let bit_index = 7 - bit_pos % 8
  Ok((data[byte_index] >> bit_index) & 1)
}

///|
fn read_bits(
  data : Array[Int],
  bit_pos : Int,
  width : Int,
) -> Result[(Int, Int), String] {
  if width <= 0 {
    return Err("invalid bit width")
  }
  let mut v = 0
  let mut p = bit_pos
  for _ in 0..<width {
    let b = read_bit(data, p)
    guard b is Ok(bit) else { return Err("packet header bitstream truncated") }
    v = (v << 1) + bit
    p += 1
  }
  Ok((v, p))
}

///|
fn ceil_div2(v : Int) -> Int {
  (v + 1) / 2
}

///|
fn build_tag_tree_levels(
  width : Int,
  height : Int,
) -> Result[Array[TagTreeLevelMetadata], String] {
  if width <= 0 || height <= 0 {
    return Err("invalid tag-tree size")
  }
  let levels : Array[TagTreeLevelMetadata] = []
  let mut w = width
  let mut h = height
  let mut offset = 0
  while true {
    levels.push({ width: w, height: h, offset })
    if w == 1 && h == 1 {
      break
    }
    offset += w * h
    w = ceil_div2(w)
    h = ceil_div2(h)
  }
  Ok(levels)
}

///|
pub fn decode_tag_tree_inclusion_flags(
  data : Array[Int],
  width : Int,
  height : Int,
  threshold : Int,
) -> Result[(Array[Bool], Int), String] {
  if threshold <= 0 {
    return Err("tag-tree threshold must be positive")
  }
  let levels_v = build_tag_tree_levels(width, height)
  guard levels_v is Ok(levels) else { return Err("invalid tag-tree size") }
  let root_level = levels.length() - 1
  let total_nodes = levels[root_level].offset + 1
  let node_low : Array[Int] = []
  let node_known : Array[Int?] = []
  for _ in 0..<total_nodes {
    node_low.push(0)
    node_known.push(None)
  }
  let mut bit_pos = 0
  let flags : Array[Bool] = []
  for y in 0..<height {
    for x in 0..<width {
      let path : Array[Int] = []
      let mut px = x
      let mut py = y
      let mut level = 0
      while level < levels.length() {
        let meta = levels[level]
        let idx = meta.offset + py * meta.width + px
        path.push(idx)
        if level == root_level {
          break
        }
        px = px / 2
        py = py / 2
        level = level + 1
      }
      let mut low = 0
      let mut rev = path.length() - 1
      while rev >= 0 {
        let idx = path[rev]
        if node_low[idx] < low {
          node_low[idx] = low
        } else {
          low = node_low[idx]
        }
        while node_low[idx] < threshold && node_known[idx] is None {
          let bit = read_bit(data, bit_pos)
          guard bit is Ok(v) else { return Err("tag-tree bitstream truncated") }
          bit_pos += 1
          if v == 0 {
            node_low[idx] += 1
          } else {
            node_known[idx] = Some(node_low[idx])
          }
        }
        if node_known[idx] is Some(v) {
          low = v
        } else {
          low = node_low[idx]
        }
        rev = rev - 1
      }
      flags.push(low < threshold)
    }
  }
  Ok((flags, bit_pos))
}

///|
fn decode_tag_tree_member_with_state(
  levels : Array[TagTreeLevelMetadata],
  node_low : Array[Int],
  node_known : Array[Int?],
  x : Int,
  y : Int,
  threshold : Int,
  data : Array[Int],
  start_bit_pos : Int,
) -> Result[(Bool, Int), String] {
  if threshold <= 0 {
    return Err("tag-tree threshold must be positive")
  }
  if levels.length() == 0 {
    return Err("invalid tag-tree size")
  }
  if x < 0 || y < 0 || x >= levels[0].width || y >= levels[0].height {
    return Err("tag-tree coordinate out of range")
  }
  let root_level = levels.length() - 1
  let path : Array[Int] = []
  let mut px = x
  let mut py = y
  let mut level = 0
  while level < levels.length() {
    let meta = levels[level]
    let idx = meta.offset + py * meta.width + px
    path.push(idx)
    if level == root_level {
      break
    }
    px = px / 2
    py = py / 2
    level = level + 1
  }
  let mut bit_pos = start_bit_pos
  let mut low = 0
  let mut rev = path.length() - 1
  while rev >= 0 {
    let idx = path[rev]
    if node_low[idx] < low {
      node_low[idx] = low
    } else {
      low = node_low[idx]
    }
    while node_low[idx] < threshold && node_known[idx] is None {
      let bit = read_bit(data, bit_pos)
      guard bit is Ok(v) else { return Err("tag-tree bitstream truncated") }
      bit_pos += 1
      if v == 0 {
        node_low[idx] += 1
      } else {
        node_known[idx] = Some(node_low[idx])
      }
    }
    if node_known[idx] is Some(v) {
      low = v
    } else {
      low = node_low[idx]
    }
    rev = rev - 1
  }
  Ok((low < threshold, bit_pos))
}

///|
fn decode_tag_tree_value_with_state(
  levels : Array[TagTreeLevelMetadata],
  node_low : Array[Int],
  node_known : Array[Int?],
  x : Int,
  y : Int,
  data : Array[Int],
  start_bit_pos : Int,
) -> Result[(Int, Int), String] {
  let mut bit_pos = start_bit_pos
  let mut threshold = 1
  while threshold <= 128 {
    let step = decode_tag_tree_member_with_state(
      levels, node_low, node_known, x, y, threshold, data, bit_pos,
    )
    guard step is Ok((included, next_pos)) else {
      return Err("failed to decode tag-tree value")
    }
    bit_pos = next_pos
    if included {
      return Ok((threshold - 1, bit_pos))
    }
    threshold += 1
  }
  Err("tag-tree value exceeds supported range")
}

///|
fn decode_tag_tree_inclusion_flags_from(
  data : Array[Int],
  width : Int,
  height : Int,
  threshold : Int,
  start_bit_pos : Int,
) -> Result[(Array[Bool], Int), String] {
  let levels_v = build_tag_tree_levels(width, height)
  guard levels_v is Ok(levels) else { return Err("invalid tag-tree size") }
  let total_nodes = levels[levels.length() - 1].offset + 1
  let node_low : Array[Int] = []
  let node_known : Array[Int?] = []
  for _ in 0..<total_nodes {
    node_low.push(0)
    node_known.push(None)
  }
  let mut bit_pos = start_bit_pos
  let flags : Array[Bool] = []
  for y in 0..<height {
    for x in 0..<width {
      let step = decode_tag_tree_member_with_state(
        levels, node_low, node_known, x, y, threshold, data, bit_pos,
      )
      guard step is Ok((included, next_pos)) else {
        return Err("failed to decode tag-tree inclusion flags")
      }
      flags.push(included)
      bit_pos = next_pos
    }
  }
  Ok((flags, bit_pos))
}

///|
fn decode_num_coding_passes(
  data : Array[Int],
  bit_pos : Int,
) -> Result[(Int, Int), String] {
  let b0 = read_bit(data, bit_pos)
  guard b0 is Ok(v0) else { return Err("packet header bitstream truncated") }
  if v0 == 0 {
    return Ok((1, bit_pos + 1))
  }
  let b1 = read_bit(data, bit_pos + 1)
  guard b1 is Ok(v1) else { return Err("packet header bitstream truncated") }
  if v1 == 0 {
    return Ok((2, bit_pos + 2))
  }
  let b2 = read_bit(data, bit_pos + 2)
  guard b2 is Ok(v2) else { return Err("packet header bitstream truncated") }
  if v2 == 0 {
    let b3 = read_bit(data, bit_pos + 3)
    guard b3 is Ok(v3) else { return Err("packet header bitstream truncated") }
    return Ok((if v3 == 0 { 3 } else { 4 }, bit_pos + 4))
  }
  let b3 = read_bit(data, bit_pos + 3)
  guard b3 is Ok(v3) else { return Err("packet header bitstream truncated") }
  if v3 == 0 {
    return Ok((5, bit_pos + 4))
  }
  let mid = read_bits(data, bit_pos + 4, 5)
  guard mid is Ok((mid5, p5)) else {
    return Err("packet header bitstream truncated")
  }
  if mid5 < 31 {
    return Ok((6 + mid5, p5))
  }
  let tail = read_bits(data, p5, 7)
  guard tail is Ok((tail7, p7)) else {
    return Err("packet header bitstream truncated")
  }
  Ok((37 + tail7, p7))
}

///|
fn parse_packet_headers_series_with_code_blocks(
  data : Array[Int],
  code_block_count : Int,
) -> Result[Array[PacketHeaderMetadata], String] {
  if code_block_count <= 0 {
    return Err("code_block_count must be positive")
  }
  let headers : Array[PacketHeaderMetadata] = []
  let mut bit_pos = 0
  let included_before : Array[Bool] = []
  let lblock_by_cb : Array[Int] = []
  for _ in 0..<code_block_count {
    included_before.push(false)
    lblock_by_cb.push(3)
  }
  let total_bits = data.length() * 8
  while bit_pos < total_bits {
    let start = bit_pos
    let z = read_bit(data, bit_pos)
    guard z is Ok(non_zero_flag) else {
      return Err("packet header bitstream truncated")
    }
    bit_pos += 1
    let code_blocks : Array[PacketHeaderCodeBlockMetadata] = []
    if non_zero_flag == 0 {
      for cb in 0..<code_block_count {
        code_blocks.push({
          code_block_index: cb,
          included: false,
          first_inclusion: false,
          zero_bit_planes: None,
          coding_passes: None,
          lblock_increment: None,
          segment_lengths: [],
        })
      }
      headers.push({
        zero_length: true,
        code_blocks,
        consumed_bits: bit_pos - start,
      })
      bit_pos = (bit_pos + 7) / 8 * 8
      continue
    }
    for cb in 0..<code_block_count {
      let inclusion = read_bit(data, bit_pos)
      guard inclusion is Ok(included_bit) else {
        return Err("packet header bitstream truncated")
      }
      bit_pos += 1
      if included_bit == 0 {
        code_blocks.push({
          code_block_index: cb,
          included: false,
          first_inclusion: false,
          zero_bit_planes: None,
          coding_passes: None,
          lblock_increment: None,
          segment_lengths: [],
        })
        continue
      }
      let mut first_inclusion = false
      let mut zero_bit_planes : Int? = None
      if !included_before[cb] {
        first_inclusion = true
        let mut p = 0
        while true {
          let bit = read_bit(data, bit_pos)
          guard bit is Ok(v) else {
            return Err("unterminated zero bit-plane code")
          }
          bit_pos += 1
          if v == 1 {
            break
          }
          p += 1
        }
        zero_bit_planes = Some(p)
        included_before[cb] = true
      }
      let pass_v = decode_num_coding_passes(data, bit_pos)
      guard pass_v is Ok((coding_passes, next_pos)) else {
        return Err("failed to decode number of coding passes")
      }
      bit_pos = next_pos
      let lengths_v = decode_lengths_for_codeblock(
        data,
        bit_pos,
        lblock_by_cb[cb],
        coding_passes,
        [],
      )
      guard lengths_v
        is Ok((segment_lengths, next_bit_pos, next_lblock, total_inc)) else {
        return Err("failed to decode code-block segment length")
      }
      bit_pos = next_bit_pos
      lblock_by_cb[cb] = next_lblock
      code_blocks.push({
        code_block_index: cb,
        included: true,
        first_inclusion,
        zero_bit_planes,
        coding_passes: Some(coding_passes),
        lblock_increment: Some(total_inc),
        segment_lengths,
      })
    }
    headers.push({
      zero_length: false,
      code_blocks,
      consumed_bits: bit_pos - start,
    })
    bit_pos = (bit_pos + 7) / 8 * 8
  }
  Ok(headers)
}

///|
fn validate_packet_len_varints(
  payload : Array[Int],
  start : Int,
) -> Result[Unit, String] {
  if start >= payload.length() {
    return Err("packet length sequence missing")
  }
  let mut saw_end = false
  for i in start..<payload.length() {
    if (payload[i] & 0x80) == 0 {
      saw_end = true
    }
  }
  if !saw_end || (payload[payload.length() - 1] & 0x80) != 0 {
    return Err("unterminated packet length sequence")
  }
  Ok(())
}

///|
fn validate_plm_payload_chunks(payload : Array[Int]) -> Result[Unit, String] {
  let mut i = 1
  while i < payload.length() {
    let nplm = payload[i]
    i += 1
    let chunk_end = i + nplm
    if chunk_end > payload.length() {
      return Err("PLM chunk exceeds payload")
    }
    let iplm : Array[Int] = []
    for j in i..<chunk_end {
      iplm.push(payload[j])
    }
    let varint_check = validate_packet_len_varints(iplm, 0)
    guard varint_check is Ok(_) else {
      return Err("invalid PLM packet length sequence")
    }
    i = chunk_end
  }
  if i != payload.length() {
    return Err("PLM payload has trailing bytes")
  }
  Ok(())
}

///|
fn validate_ppm_payload_chunks(payload : Array[Int]) -> Result[Unit, String] {
  let mut i = 1
  while i < payload.length() {
    let nppm_value = read_u32_from_payload(payload, i)
    guard nppm_value is Ok(nppm) else { return Err("failed to parse Nppm") }
    i += 4
    let chunk_end = i + nppm
    if chunk_end > payload.length() {
      return Err("PPM chunk exceeds payload")
    }
    i = chunk_end
  }
  if i != payload.length() {
    return Err("PPM payload has trailing bytes")
  }
  Ok(())
}

///|
fn decode_packet_len_varints(
  payload : Array[Int],
  start : Int,
) -> Result[Array[Int], String] {
  if start >= payload.length() {
    return Err("packet length sequence missing")
  }
  let values : Array[Int] = []
  let mut acc = 0
  let mut in_value = false
  for i in start..<payload.length() {
    let b = payload[i]
    acc = (acc << 7) + (b & 0x7F)
    in_value = true
    if (b & 0x80) == 0 {
      values.push(acc)
      acc = 0
      in_value = false
    }
  }
  if in_value {
    return Err("unterminated packet length sequence")
  }
  Ok(values)
}

///|
fn parse_plm_metadata(payload : Array[Int]) -> Result[PlmMetadata, String] {
  if payload.length() < 2 {
    return Err("PLM payload too short")
  }
  let zplm = payload[0]
  let chunks : Array[PlmChunkMetadata] = []
  let mut i = 1
  while i < payload.length() {
    let nplm = payload[i]
    i += 1
    let chunk_end = i + nplm
    if chunk_end > payload.length() {
      return Err("PLM chunk exceeds payload")
    }
    let iplm : Array[Int] = []
    for j in i..<chunk_end {
      iplm.push(payload[j])
    }
    let decoded = decode_packet_len_varints(iplm, 0)
    guard decoded is Ok(packet_lengths) else {
      return Err("invalid PLM packet lengths")
    }
    chunks.push({ nplm, packet_lengths })
    i = chunk_end
  }
  Ok({ zplm, chunks })
}

///|
fn parse_plt_metadata(payload : Array[Int]) -> Result[PltMetadata, String] {
  if payload.length() < 2 {
    return Err("PLT payload too short")
  }
  let decoded = decode_packet_len_varints(payload, 1)
  guard decoded is Ok(packet_lengths) else {
    return Err("invalid PLT packet lengths")
  }
  Ok({ zplt: payload[0], packet_lengths })
}

///|
fn parse_ppm_metadata(payload : Array[Int]) -> Result[PpmMetadata, String] {
  if payload.length() < 5 {
    return Err("PPM payload too short")
  }
  let zppm = payload[0]
  let chunks : Array[PpmChunkMetadata] = []
  let mut i = 1
  while i < payload.length() {
    let nppm_v = read_u32_from_payload(payload, i)
    guard nppm_v is Ok(nppm) else { return Err("failed to parse Nppm") }
    i += 4
    let chunk_end = i + nppm
    if chunk_end > payload.length() {
      return Err("PPM chunk exceeds payload")
    }
    let ippm : Array[Int] = []
    for j in i..<chunk_end {
      ippm.push(payload[j])
    }
    chunks.push({ nppm, ippm })
    i = chunk_end
  }
  Ok({ zppm, chunks })
}

///|
fn parse_ppt_metadata(payload : Array[Int]) -> Result[PptMetadata, String] {
  if payload.length() < 2 {
    return Err("PPT payload too short")
  }
  let data : Array[Int] = []
  for i in 1..<payload.length() {
    data.push(payload[i])
  }
  Ok({ zppt: payload[0], data })
}

///|
fn parse_tlm_metadata(payload : Array[Int]) -> Result[TlmMetadata, String] {
  if payload.length() < 4 {
    return Err("TLM payload too short")
  }
  let ztlm = payload[0]
  let stlm = payload[1]
  let tile_field = stlm & 0x30
  let tile_bytes = if tile_field == 0x00 {
    0
  } else if tile_field == 0x10 {
    1
  } else if tile_field == 0x20 {
    2
  } else {
    return Err("unsupported TLM tile index width")
  }
  let len_bytes = if (stlm & 0x40) == 0 { 2 } else { 4 }
  let entry_size = tile_bytes + len_bytes
  if entry_size <= 0 || (payload.length() - 2) % entry_size != 0 {
    return Err("TLM payload length is inconsistent")
  }
  let entries : Array[TlmEntryMetadata] = []
  let mut at = 2
  while at < payload.length() {
    let tile = if tile_bytes == 0 {
      None
    } else if tile_bytes == 1 {
      Some(payload[at])
    } else {
      let v = read_u16_from_payload(payload, at)
      guard v is Ok(t) else { return Err("failed to parse Ttlm") }
      Some(t)
    }
    let len_at = at + tile_bytes
    let length = if len_bytes == 2 {
      let v = read_u16_from_payload(payload, len_at)
      guard v is Ok(l) else { return Err("failed to parse Ptlm") }
      l
    } else {
      let v = read_u32_from_payload(payload, len_at)
      guard v is Ok(l) else { return Err("failed to parse Ptlm") }
      l
    }
    entries.push({ tile, length })
    at += entry_size
  }
  Ok({ ztlm, stlm, entries })
}

///|
fn parse_sop_metadata(
  payload : Array[Int],
  position : Int,
) -> Result[SopMetadata, String] {
  if payload.length() != 2 {
    return Err("SOP payload length is invalid")
  }
  let nsop_v = read_u16_from_payload(payload, 0)
  guard nsop_v is Ok(nsop) else { return Err("failed to parse Nsop") }
  Ok({ nsop, position })
}

///|
fn parse_crg_metadata(
  payload : Array[Int],
  csiz : Int,
) -> Result[CrgMetadata, String] {
  if payload.length() != csiz * 4 {
    return Err("CRG payload length is invalid")
  }
  let components : Array[CrgComponentMetadata] = []
  let mut at = 0
  while at + 3 < payload.length() {
    let x_v = read_u16_from_payload(payload, at)
    let y_v = read_u16_from_payload(payload, at + 2)
    guard x_v is Ok(xcrg) else { return Err("failed to parse Xcrg") }
    guard y_v is Ok(ycrg) else { return Err("failed to parse Ycrg") }
    components.push({ xcrg, ycrg })
    at += 4
  }
  Ok({ components, })
}

///|
fn parse_com_metadata(payload : Array[Int]) -> Result[ComMetadata, String] {
  if payload.length() < 2 {
    return Err("COM payload too short")
  }
  let r_v = read_u16_from_payload(payload, 0)
  guard r_v is Ok(rcom) else { return Err("failed to parse Rcom") }
  let ccom : Array[Int] = []
  for i in 2..<payload.length() {
    ccom.push(payload[i])
  }
  Ok({ rcom, ccom })
}

///|
fn build_ordering_metadata(
  siz : SizMetadata,
) -> Result[OrderingMetadata, String] {
  if siz.xsiz <= siz.xosiz || siz.ysiz <= siz.yosiz {
    return Err("invalid reference grid")
  }
  let tiles_x = ceil_div_positive(siz.xsiz - siz.xtosiz, siz.xtsiz)
  let tiles_y = ceil_div_positive(siz.ysiz - siz.ytosiz, siz.ytsiz)
  if tiles_x <= 0 || tiles_y <= 0 {
    return Err("invalid tile grid")
  }
  let components : Array[ComponentGeometryMetadata] = []
  for i, c in siz.components {
    let width = ceil_div_positive(siz.xsiz - siz.xosiz, c.xrsiz)
    let height = ceil_div_positive(siz.ysiz - siz.yosiz, c.yrsiz)
    components.push({
      component: i,
      xrsiz: c.xrsiz,
      yrsiz: c.yrsiz,
      width,
      height,
    })
  }
  let tiles : Array[TileGeometryMetadata] = []
  let mut tile_index = 0
  for ty in 0..<tiles_y {
    for tx in 0..<tiles_x {
      let tx0_raw = siz.xtosiz + tx * siz.xtsiz
      let ty0_raw = siz.ytosiz + ty * siz.ytsiz
      let tx1_raw = siz.xtosiz + (tx + 1) * siz.xtsiz
      let ty1_raw = siz.ytosiz + (ty + 1) * siz.ytsiz
      let x0 = if tx0_raw > siz.xosiz { tx0_raw } else { siz.xosiz }
      let y0 = if ty0_raw > siz.yosiz { ty0_raw } else { siz.yosiz }
      let x1 = if tx1_raw < siz.xsiz { tx1_raw } else { siz.xsiz }
      let y1 = if ty1_raw < siz.ysiz { ty1_raw } else { siz.ysiz }
      tiles.push({ tile_index, tx, ty, x0, y0, x1, y1 })
      tile_index += 1
    }
  }
  let tile_components : Array[TileComponentGeometryMetadata] = []
  for tile in tiles {
    for comp in components {
      let x0 = ceil_div_positive(tile.x0 - siz.xosiz, comp.xrsiz)
      let y0 = ceil_div_positive(tile.y0 - siz.yosiz, comp.yrsiz)
      let x1 = ceil_div_positive(tile.x1 - siz.xosiz, comp.xrsiz)
      let y1 = ceil_div_positive(tile.y1 - siz.yosiz, comp.yrsiz)
      tile_components.push({
        tile_index: tile.tile_index,
        component: comp.component,
        x0,
        y0,
        x1,
        y1,
        width: x1 - x0,
        height: y1 - y0,
      })
    }
  }
  Ok({
    reference_grid: { x0: siz.xosiz, y0: siz.yosiz, x1: siz.xsiz, y1: siz.ysiz },
    tiles_x,
    tiles_y,
    components,
    tiles,
    tile_components,
  })
}

///|
fn build_ordering_coding_metadata(
  cod : CodMetadata,
  ordering : OrderingMetadata,
) -> OrderingCodingMetadata {
  let resolution_count = cod.decomposition_levels + 1
  let subbands_per_resolution : Array[Int] = []
  let precincts : Array[PrecinctResolutionMetadata] = []
  let code_blocks : Array[CodeBlockResolutionMetadata] = []
  let packets : Array[PacketUnitMetadata] = []
  for r in 0..<resolution_count {
    subbands_per_resolution.push(if r == 0 { 1 } else { 3 })
    let mut ppx = 15
    let mut ppy = 15
    if cod.uses_precincts && r < cod.precinct_size_bytes.length() {
      let b = cod.precinct_size_bytes[r]
      ppx = b & 0x0F
      ppy = (b >> 4) & 0x0F
    }
    precincts.push({
      resolution: r,
      ppx,
      ppy,
      precinct_width: 1 << ppx,
      precinct_height: 1 << ppy,
    })
    code_blocks.push({
      resolution: r,
      nominal_width: 1 << cod.code_block_width_exponent,
      nominal_height: 1 << cod.code_block_height_exponent,
    })
  }
  for tc in ordering.tile_components {
    for r in 0..<resolution_count {
      let down = 1 << (cod.decomposition_levels - r)
      let res_w = ceil_div_positive(tc.width, down)
      let res_h = ceil_div_positive(tc.height, down)
      let precinct_w = precincts[r].precinct_width
      let precinct_h = precincts[r].precinct_height
      let precincts_x = ceil_div_positive(res_w, precinct_w)
      let precincts_y = ceil_div_positive(res_h, precinct_h)
      let packets_per_layer = precincts_x * precincts_y
      packets.push({
        tile_index: tc.tile_index,
        component: tc.component,
        resolution: r,
        precincts_x,
        precincts_y,
        packets_per_layer,
        layers: cod.layers,
        packets_total: packets_per_layer * cod.layers,
      })
    }
  }
  {
    decomposition_levels: cod.decomposition_levels,
    resolution_count,
    subbands_per_resolution,
    precincts,
    code_blocks,
    packets,
  }
}

///|
fn packet_count_for_step(
  coding : OrderingCodingMetadata,
  component : Int,
  resolution : Int,
) -> Int {
  let mut packet_count = 0
  for unit in coding.packets {
    if unit.component == component && unit.resolution == resolution {
      packet_count += unit.packets_per_layer
    }
  }
  packet_count
}

///|
fn append_progression_steps_by_order(
  steps : Array[ProgressionStepMetadata],
  order_code : Int,
  layer_start : Int,
  layer_end : Int,
  resolution_start : Int,
  resolution_end : Int,
  component_start : Int,
  component_end : Int,
  coding : OrderingCodingMetadata,
  order_index : Int,
) -> (Int, Int) {
  let mut local_index = order_index
  let mut added_packets = 0
  if order_code == 0 {
    for l in layer_start..<layer_end {
      for r in resolution_start..<resolution_end {
        for c in component_start..<component_end {
          let packet_count = packet_count_for_step(coding, c, r)
          steps.push({
            order_index: local_index,
            layer: l,
            resolution: r,
            component: c,
            packet_count,
          })
          local_index += 1
          added_packets += packet_count
        }
      }
    }
    return (local_index, added_packets)
  }
  if order_code == 1 {
    for r in resolution_start..<resolution_end {
      for l in layer_start..<layer_end {
        for c in component_start..<component_end {
          let packet_count = packet_count_for_step(coding, c, r)
          steps.push({
            order_index: local_index,
            layer: l,
            resolution: r,
            component: c,
            packet_count,
          })
          local_index += 1
          added_packets += packet_count
        }
      }
    }
    return (local_index, added_packets)
  }
  if order_code == 2 {
    for r in resolution_start..<resolution_end {
      for c in component_start..<component_end {
        for l in layer_start..<layer_end {
          let packet_count = packet_count_for_step(coding, c, r)
          steps.push({
            order_index: local_index,
            layer: l,
            resolution: r,
            component: c,
            packet_count,
          })
          local_index += 1
          added_packets += packet_count
        }
      }
    }
    return (local_index, added_packets)
  }
  if order_code == 3 {
    for c in component_start..<component_end {
      for r in resolution_start..<resolution_end {
        for l in layer_start..<layer_end {
          let packet_count = packet_count_for_step(coding, c, r)
          steps.push({
            order_index: local_index,
            layer: l,
            resolution: r,
            component: c,
            packet_count,
          })
          local_index += 1
          added_packets += packet_count
        }
      }
    }
    return (local_index, added_packets)
  }
  for c in component_start..<component_end {
    for l in layer_start..<layer_end {
      for r in resolution_start..<resolution_end {
        let packet_count = packet_count_for_step(coding, c, r)
        steps.push({
          order_index: local_index,
          layer: l,
          resolution: r,
          component: c,
          packet_count,
        })
        local_index += 1
        added_packets += packet_count
      }
    }
  }
  (local_index, added_packets)
}

///|
fn build_progression_metadata(
  cod : CodMetadata,
  ordering : OrderingMetadata,
  coding : OrderingCodingMetadata,
  poc : Array[PocMetadata],
) -> ProgressionMetadata {
  let component_count = ordering.components.length()
  let resolution_count = coding.resolution_count
  let volumes : Array[ProgressionVolumeMetadata] = []
  if poc.length() == 0 {
    volumes.push({
      source_poc_index: -1,
      order_code: cod.progression_order,
      layer_start: 0,
      layer_end: cod.layers,
      resolution_start: 0,
      resolution_end: resolution_count,
      component_start: 0,
      component_end: component_count,
    })
  } else {
    for idx, entry in poc {
      volumes.push({
        source_poc_index: idx,
        order_code: entry.ppoc,
        layer_start: 0,
        layer_end: entry.lyepoc,
        resolution_start: entry.rspoc,
        resolution_end: entry.repoc,
        component_start: entry.cspoc,
        component_end: entry.cepoc,
      })
    }
  }
  let steps : Array[ProgressionStepMetadata] = []
  let mut order_index = 0
  let mut total_packets = 0
  for v in volumes {
    let layer_start = if v.layer_start > 0 { v.layer_start } else { 0 }
    let layer_end = if v.layer_end < cod.layers {
      v.layer_end
    } else {
      cod.layers
    }
    let resolution_start = if v.resolution_start > 0 {
      v.resolution_start
    } else {
      0
    }
    let resolution_end = if v.resolution_end < resolution_count {
      v.resolution_end
    } else {
      resolution_count
    }
    let component_start = if v.component_start > 0 {
      v.component_start
    } else {
      0
    }
    let component_end = if v.component_end < component_count {
      v.component_end
    } else {
      component_count
    }
    if layer_start >= layer_end ||
      resolution_start >= resolution_end ||
      component_start >= component_end {
      continue
    }
    let (next_index, added_packets) = append_progression_steps_by_order(
      steps,
      v.order_code,
      layer_start,
      layer_end,
      resolution_start,
      resolution_end,
      component_start,
      component_end,
      coding,
      order_index,
    )
    order_index = next_index
    total_packets += added_packets
  }
  { order_code: cod.progression_order, volumes, steps, total_packets }
}

///|
fn refresh_progression_metadata(
  cod : CodMetadata?,
  ordering : OrderingMetadata?,
  coding : OrderingCodingMetadata?,
  poc : Array[PocMetadata],
) -> ProgressionMetadata? {
  guard cod is Some(cod_meta) else { return None }
  guard ordering is Some(ordering_meta) else { return None }
  guard coding is Some(coding_meta) else { return None }
  Some(build_progression_metadata(cod_meta, ordering_meta, coding_meta, poc))
}

///|
fn validate_marker_payload(
  code : Int,
  length : Int,
  payload : Array[Int],
  in_main_header : Bool,
  siz_components : Int?,
  main_seen_poc : Bool,
  tile_seen_poc : Bool,
  header_coc_components : Array[Int],
  header_qcc_components : Array[Int],
  seen_crg : Bool,
  has_ppm : Bool,
  has_ppt : Bool,
  compat_mode : Bool,
) -> Result[Int?, String] {
  let mut next_siz_components = siz_components
  if code == MARKER_SOT && length != 10 {
    return Err("SOT marker segment length must be 10")
  }
  if code == MARKER_SIZ {
    if length < 41 {
      return Err("SIZ marker segment length is too short")
    }
    let csiz_value = read_u16_from_payload(payload, 34)
    guard csiz_value is Ok(csiz) else {
      return Err("failed to parse SIZ component count")
    }
    if csiz <= 0 {
      return Err("SIZ component count must be positive")
    }
    if length != 38 + csiz * 3 {
      return Err("SIZ marker segment length does not match component count")
    }
    let xtsiz_value = read_u32_from_payload(payload, 18)
    let ytsiz_value = read_u32_from_payload(payload, 22)
    guard xtsiz_value is Ok(xtsiz) else { return Err("failed to parse XTsiz") }
    guard ytsiz_value is Ok(ytsiz) else { return Err("failed to parse YTsiz") }
    if xtsiz <= 0 || ytsiz <= 0 {
      return Err("SIZ tile size must be positive")
    }
    for i in 0..<csiz {
      let xrsiz = payload[37 + i * 3]
      let yrsiz = payload[38 + i * 3]
      if xrsiz <= 0 || yrsiz <= 0 {
        return Err("SIZ component sampling must be positive")
      }
    }
    next_siz_components = Some(csiz)
  }
  if code == MARKER_COD && length < 12 {
    return Err("COD marker segment length is too short")
  }
  if code == MARKER_COD {
    let progression_order = payload[1]
    let layers_v = read_u16_from_payload(payload, 2)
    guard layers_v is Ok(layers) else {
      return Err("failed to parse COD layers")
    }
    let multiple_component_transform = payload[4]
    let decomposition_levels = payload[5]
    let cblk_width_minus2 = payload[6]
    let cblk_height_minus2 = payload[7]
    let transformation = payload[9]
    if progression_order < 0 || progression_order > 4 {
      return Err("COD progression order is out of range")
    }
    if layers <= 0 {
      return Err("COD number of layers must be positive")
    }
    if multiple_component_transform != 0 && multiple_component_transform != 1 {
      return Err("COD multiple component transform is invalid")
    }
    if cblk_width_minus2 < 0 ||
      cblk_width_minus2 > 8 ||
      cblk_height_minus2 < 0 ||
      cblk_height_minus2 > 8 ||
      cblk_width_minus2 + cblk_height_minus2 > 8 {
      return Err("COD code-block size exponents are invalid")
    }
    if transformation != 0 && transformation != 1 {
      return Err("COD transformation is invalid")
    }
    let uses_precincts = (payload[0] & 0x01) != 0
    let expected_len = if uses_precincts {
      13 + decomposition_levels
    } else {
      12
    }
    if length != expected_len {
      return Err(
        "COD marker segment length is inconsistent with precinct settings",
      )
    }
  }
  if code == MARKER_QCD && length < 4 {
    return Err("QCD marker segment length is too short")
  }
  if code == MARKER_QCD {
    let sqcd = payload[0]
    let qstyle = sqcd & 0x1F
    if qstyle < 0 || qstyle > 2 {
      return Err("QCD quantization style is invalid")
    }
    let param_bytes = payload.length() - 1
    if param_bytes <= 0 {
      return Err("QCD quantization parameters are missing")
    }
    if (qstyle == 1 || qstyle == 2) && param_bytes % 2 != 0 {
      return Err("QCD quantization parameters have invalid byte count")
    }
  }
  if code == MARKER_SOP && length != 4 {
    return Err("SOP marker segment length must be 4")
  }
  if code == MARKER_COM && length < 4 {
    return Err("COM marker segment length is too short")
  }
  if code == MARKER_TLM && length < 5 {
    return Err("TLM marker segment length is too short")
  }
  if code == MARKER_PLM && length < 5 {
    return Err("PLM marker segment length is too short")
  }
  if code == MARKER_PLT && length < 4 {
    return Err("PLT marker segment length is too short")
  }
  if code == MARKER_PPM && length < 7 {
    return Err("PPM marker segment length is too short")
  }
  if code == MARKER_PPT && length < 4 {
    return Err("PPT marker segment length is too short")
  }
  if code == MARKER_PLM {
    let plm_structure = validate_plm_payload_chunks(payload)
    guard plm_structure is Ok(_) else {
      return Err("invalid PLM chunk bookkeeping")
    }
  }
  if code == MARKER_PLT {
    let plt_check = validate_packet_len_varints(payload, 1)
    guard plt_check is Ok(_) else {
      return Err("invalid PLT packet length sequence")
    }
  }
  if code == MARKER_PPM {
    let ppm_structure = validate_ppm_payload_chunks(payload)
    guard ppm_structure is Ok(_) else {
      return Err("invalid PPM chunk bookkeeping")
    }
  }
  if code == MARKER_CRG {
    if seen_crg {
      return Err("CRG must appear at most once")
    }
    guard siz_components is Some(csiz) else {
      return Err("CRG requires SIZ component count")
    }
    if length != 2 + csiz * 4 {
      return Err("CRG marker segment length does not match component count")
    }
  }
  if code == MARKER_POC {
    if in_main_header {
      if main_seen_poc {
        return Err("POC must appear at most once per header")
      }
    } else if tile_seen_poc {
      return Err("POC must appear at most once per header")
    }
    guard siz_components is Some(csiz) else {
      return Err("POC requires SIZ component count")
    }
    let unit = if csiz < 257 { 7 } else { 9 }
    if length < 2 + unit || (length - 2) % unit != 0 {
      return Err("POC marker segment length is invalid")
    }
    let entries = parse_poc_entries(payload, csiz, in_main_header)
    guard entries is Ok(poc_entries) else {
      return Err("failed to parse POC entries")
    }
    for entry in poc_entries {
      if entry.ppoc < 0 || entry.ppoc > 4 {
        return Err("POC progression order is out of range")
      }
      if entry.cspoc < 0 || entry.cspoc >= csiz {
        return Err("POC CSpoc is out of range")
      }
      // Spec (Annex A.6.6 / Table A.32):
      // CEpoc allows "... 255, 0" for Csiz<257, and "0 is interpreted as 256".
      let cepoc_upper = if csiz < 257 { 256 } else { 16384 }
      let cepoc = if entry.cepoc == 0 { cepoc_upper } else { entry.cepoc }
      if compat_mode && cepoc > csiz {
        // Compatibility policy for external corpora with broad progression volumes.
        // This is intentionally broader than strict conformance checking.
        continue
      }
      if cepoc <= entry.cspoc || cepoc > cepoc_upper {
        return Err("POC CEpoc is out of range")
      }
    }
  }
  if code == MARKER_PPM && has_ppt {
    return Err("PPM and PPT cannot be mixed")
  }
  if code == MARKER_PPT && has_ppm {
    return Err("PPM and PPT cannot be mixed")
  }
  if code == MARKER_COC || code == MARKER_QCC || code == MARKER_RGN {
    guard siz_components is Some(csiz) else {
      return Err("component-specific marker requires SIZ component count")
    }
    let cbytes = if csiz < 257 { 1 } else { 2 }
    let min_len = if code == MARKER_RGN { 4 + cbytes } else { 4 + cbytes }
    if length < min_len {
      return Err("component-specific marker segment length is too short")
    }
    let comp = if cbytes == 1 {
      payload[0]
    } else {
      let comp_value = read_u16_from_payload(payload, 0)
      guard comp_value is Ok(cno) else {
        return Err("failed to parse component index")
      }
      cno
    }
    if comp < 0 || comp >= csiz {
      return Err("component index out of range")
    }
    if code == MARKER_COC && contains_int(header_coc_components, comp) {
      return Err("COC duplicated for component in same header")
    }
    if code == MARKER_QCC && contains_int(header_qcc_components, comp) {
      return Err("QCC duplicated for component in same header")
    }
    if code == MARKER_RGN && payload[cbytes] != 0 {
      return Err("RGN style is invalid")
    }
  }
  Ok(next_siz_components)
}

///|
fn find_tile_state_index(tile_ids : Array[Int], isot : Int) -> Int? {
  for i, t in tile_ids {
    if t == isot {
      return Some(i)
    }
  }
  None
}

///|
fn ceil_div_positive(a : Int, b : Int) -> Int {
  if a <= 0 {
    0
  } else {
    (a + b - 1) / b
  }
}

///|
fn compute_tile_count_from_siz(payload : Array[Int]) -> Result[Int, String] {
  let xsiz_v = read_u32_from_payload(payload, 2)
  let ysiz_v = read_u32_from_payload(payload, 6)
  let xtsiz_v = read_u32_from_payload(payload, 18)
  let ytsiz_v = read_u32_from_payload(payload, 22)
  let xtosiz_v = read_u32_from_payload(payload, 26)
  let ytosiz_v = read_u32_from_payload(payload, 30)
  guard xsiz_v is Ok(xsiz) else { return Err("failed to parse Xsiz") }
  guard ysiz_v is Ok(ysiz) else { return Err("failed to parse Ysiz") }
  guard xtsiz_v is Ok(xtsiz) else { return Err("failed to parse XTsiz") }
  guard ytsiz_v is Ok(ytsiz) else { return Err("failed to parse YTsiz") }
  guard xtosiz_v is Ok(xtosiz) else { return Err("failed to parse XTOsiz") }
  guard ytosiz_v is Ok(ytosiz) else { return Err("failed to parse YTOsiz") }
  if xsiz <= xtosiz || ysiz <= ytosiz {
    return Err("invalid SIZ image/tile origin relation")
  }
  let nx = ceil_div_positive(xsiz - xtosiz, xtsiz)
  let ny = ceil_div_positive(ysiz - ytosiz, ytsiz)
  let tiles = nx * ny
  if tiles <= 0 {
    return Err("invalid tile count derived from SIZ")
  }
  Ok(tiles)
}

///|
fn parse_siz_metadata(payload : Array[Int]) -> Result[SizMetadata, String] {
  if payload.length() < 36 {
    return Err("SIZ payload too short")
  }
  let rsiz_v = read_u16_from_payload(payload, 0)
  let xsiz_v = read_u32_from_payload(payload, 2)
  let ysiz_v = read_u32_from_payload(payload, 6)
  let xosiz_v = read_u32_from_payload(payload, 10)
  let yosiz_v = read_u32_from_payload(payload, 14)
  let xtsiz_v = read_u32_from_payload(payload, 18)
  let ytsiz_v = read_u32_from_payload(payload, 22)
  let xtosiz_v = read_u32_from_payload(payload, 26)
  let ytosiz_v = read_u32_from_payload(payload, 30)
  let csiz_v = read_u16_from_payload(payload, 34)
  let tile_count_v = compute_tile_count_from_siz(payload)
  guard rsiz_v is Ok(rsiz) else { return Err("failed to parse Rsiz") }
  guard xsiz_v is Ok(xsiz) else { return Err("failed to parse Xsiz") }
  guard ysiz_v is Ok(ysiz) else { return Err("failed to parse Ysiz") }
  guard xosiz_v is Ok(xosiz) else { return Err("failed to parse XOsiz") }
  guard yosiz_v is Ok(yosiz) else { return Err("failed to parse YOsiz") }
  guard xtsiz_v is Ok(xtsiz) else { return Err("failed to parse XTsiz") }
  guard ytsiz_v is Ok(ytsiz) else { return Err("failed to parse YTsiz") }
  guard xtosiz_v is Ok(xtosiz) else { return Err("failed to parse XTOsiz") }
  guard ytosiz_v is Ok(ytosiz) else { return Err("failed to parse YTOsiz") }
  guard csiz_v is Ok(csiz) else { return Err("failed to parse Csiz") }
  guard tile_count_v is Ok(tile_count) else {
    return Err("failed to parse tile count")
  }

  if csiz <= 0 {
    return Err("invalid Csiz")
  }
  if payload.length() != 36 + csiz * 3 {
    return Err("invalid SIZ payload length")
  }
  let components : Array[SizComponentMetadata] = []
  for i in 0..<csiz {
    let ssiz = payload[36 + i * 3]
    let xrsiz = payload[37 + i * 3]
    let yrsiz = payload[38 + i * 3]
    components.push({
      precision_bits: (ssiz & 0x7F) + 1,
      is_signed: (ssiz & 0x80) != 0,
      xrsiz,
      yrsiz,
    })
  }
  Ok({
    rsiz,
    xsiz,
    ysiz,
    xosiz,
    yosiz,
    xtsiz,
    ytsiz,
    xtosiz,
    ytosiz,
    csiz,
    tile_count,
    components,
  })
}

///|
fn parse_cod_metadata(payload : Array[Int]) -> Result[CodMetadata, String] {
  if payload.length() < 10 {
    return Err("COD payload too short")
  }
  let layers_v = read_u16_from_payload(payload, 2)
  guard layers_v is Ok(layers) else { return Err("failed to parse layers") }
  let scod = payload[0]
  let uses_precincts = (scod & 0x01) != 0
  let uses_sop = (scod & 0x02) != 0
  let uses_eph = (scod & 0x04) != 0
  let precinct_size_bytes : Array[Int] = []
  if uses_precincts {
    for i in 10..<payload.length() {
      precinct_size_bytes.push(payload[i])
    }
  }
  Ok({
    scod,
    progression_order: payload[1],
    layers,
    multiple_component_transform: payload[4],
    decomposition_levels: payload[5],
    code_block_width_exponent: payload[6] + 2,
    code_block_height_exponent: payload[7] + 2,
    code_block_style: payload[8],
    transformation: payload[9],
    uses_precincts,
    uses_sop,
    uses_eph,
    precinct_size_bytes,
  })
}

///|
fn parse_qcd_metadata(payload : Array[Int]) -> Result[QcdMetadata, String] {
  if payload.length() < 2 {
    return Err("QCD payload too short")
  }
  let parameters : Array[Int] = []
  for i in 1..<payload.length() {
    parameters.push(payload[i])
  }
  let sqcd = payload[0]
  Ok({
    sqcd,
    guard_bits: (sqcd >> 5) & 0x07,
    quantization_style: sqcd & 0x1F,
    parameters,
  })
}

///|
fn parse_component_index(
  payload : Array[Int],
  csiz : Int,
) -> Result[(Int, Int), String] {
  let cbytes = if csiz < 257 { 1 } else { 2 }
  if payload.length() < cbytes {
    return Err("component index payload too short")
  }
  if cbytes == 1 {
    Ok((payload[0], 1))
  } else {
    let comp_v = read_u16_from_payload(payload, 0)
    guard comp_v is Ok(comp) else {
      return Err("failed to parse component index")
    }
    Ok((comp, 2))
  }
}

///|
fn parse_coc_metadata(
  payload : Array[Int],
  csiz : Int,
  in_main_header : Bool,
) -> Result[CocMetadata, String] {
  let comp_v = parse_component_index(payload, csiz)
  guard comp_v is Ok((component, at)) else {
    return Err("failed to parse COC component")
  }
  if payload.length() < at + 1 {
    return Err("COC payload too short")
  }
  let parameters : Array[Int] = []
  for i in (at + 1)..<payload.length() {
    parameters.push(payload[i])
  }
  Ok({ component, scoc: payload[at], parameters, in_main_header })
}

///|
fn parse_rgn_metadata(
  payload : Array[Int],
  csiz : Int,
  in_main_header : Bool,
) -> Result[RgnMetadata, String] {
  let comp_v = parse_component_index(payload, csiz)
  guard comp_v is Ok((component, at)) else {
    return Err("failed to parse RGN component")
  }
  if payload.length() < at + 2 {
    return Err("RGN payload too short")
  }
  Ok({ component, style: payload[at], shift: payload[at + 1], in_main_header })
}

///|
fn parse_qcc_metadata(
  payload : Array[Int],
  csiz : Int,
  in_main_header : Bool,
) -> Result[QccMetadata, String] {
  let comp_v = parse_component_index(payload, csiz)
  guard comp_v is Ok((component, at)) else {
    return Err("failed to parse QCC component")
  }
  if payload.length() < at + 1 {
    return Err("QCC payload too short")
  }
  let parameters : Array[Int] = []
  for i in (at + 1)..<payload.length() {
    parameters.push(payload[i])
  }
  Ok({ component, sqcc: payload[at], parameters, in_main_header })
}

///|
fn parse_poc_entries(
  payload : Array[Int],
  csiz : Int,
  in_main_header : Bool,
) -> Result[Array[PocMetadata], String] {
  let entries : Array[PocMetadata] = []
  let cbytes = if csiz < 257 { 1 } else { 2 }
  let unit = if csiz < 257 { 7 } else { 9 }
  let mut at = 0
  while at + unit <= payload.length() {
    let rspoc = payload[at]
    let cspoc = if cbytes == 1 {
      payload[at + 1]
    } else {
      let v = read_u16_from_payload(payload, at + 1)
      guard v is Ok(c) else { return Err("failed to parse CSpoc") }
      c
    }
    let lyepoc_at = at + 1 + cbytes
    let lyepoc_v = read_u16_from_payload(payload, lyepoc_at)
    guard lyepoc_v is Ok(lyepoc) else { return Err("failed to parse LYEpoc") }
    let repoc = payload[lyepoc_at + 2]
    let cepoc = if cbytes == 1 {
      payload[lyepoc_at + 3]
    } else {
      let v = read_u16_from_payload(payload, lyepoc_at + 3)
      guard v is Ok(c) else { return Err("failed to parse CEpoc") }
      c
    }
    let ppoc = payload[lyepoc_at + 3 + cbytes]
    entries.push({ rspoc, cspoc, lyepoc, repoc, cepoc, ppoc, in_main_header })
    at += unit
  }
  if at != payload.length() {
    return Err("POC payload trailing bytes")
  }
  Ok(entries)
}

///|
fn nibble_to_char(n : Int) -> Char {
  if n < 10 {
    ('0'.to_int() + n).unsafe_to_char()
  } else {
    ('a'.to_int() + (n - 10)).unsafe_to_char()
  }
}

///|
fn char_to_nibble(c : Char) -> Int? {
  if c is ('0'..='9') {
    Some(c.to_int() - '0'.to_int())
  } else if c is ('a'..='f') {
    Some(c.to_int() - 'a'.to_int() + 10)
  } else if c is ('A'..='F') {
    Some(c.to_int() - 'A'.to_int() + 10)
  } else {
    None
  }
}

///|
pub fn bytes_to_hex(data : Array[Int]) -> String {
  let sb = StringBuilder::new()
  for b in data {
    let hi = (b >> 4) & 0x0F
    let lo = b & 0x0F
    sb.write_char(nibble_to_char(hi))
    sb.write_char(nibble_to_char(lo))
  }
  sb.to_string()
}

///|
pub fn hex_to_bytes(hex : String) -> Result[Array[Int], String] {
  let out : Array[Int] = []
  let mut high : Int? = None
  for c in hex {
    if c == ' ' || c == '\n' || c == '\r' || c == '\t' {
      continue
    }
    let nibble = char_to_nibble(c)
    guard nibble is Some(n) else { return Err("invalid hex character") }
    if high is Some(h) {
      out.push((h << 4) + n)
      high = None
    } else {
      high = Some(n)
    }
  }
  if high is Some(_) {
    return Err("hex string has odd length")
  }
  Ok(out)
}

///|
pub fn roundtrip_bytes(data : Array[Int]) -> Result[Array[Int], String] {
  let parsed = parse_codestream(data)
  if parsed is Ok(stream) {
    return encode_codestream(stream)
  }
  if parsed is Err(msg) {
    return Err("parse failed in roundtrip: \{msg}")
  }
  Err("parse failed in roundtrip")
}

///|
pub fn parse_packet_headers_single_codeblock(
  data : Array[Int],
) -> Result[Array[PacketHeaderMetadata], String] {
  parse_packet_headers_series_with_code_blocks(data, 1)
}

///|
pub fn parse_packet_headers_with_code_blocks(
  data : Array[Int],
  code_block_count : Int,
) -> Result[Array[PacketHeaderMetadata], String] {
  parse_packet_headers_series_with_code_blocks(data, code_block_count)
}

///|
pub fn parse_packet_header_single_packet_with_tag_tree(
  data : Array[Int],
  width : Int,
  height : Int,
  layer_index : Int,
) -> Result[PacketHeaderMetadata, String] {
  if layer_index < 0 {
    return Err("layer_index must be non-negative")
  }
  let code_block_count = width * height
  if code_block_count <= 0 {
    return Err("invalid tag-tree size")
  }
  let z = read_bit(data, 0)
  guard z is Ok(non_zero_flag) else {
    return Err("packet header bitstream truncated")
  }
  if non_zero_flag == 0 {
    let code_blocks : Array[PacketHeaderCodeBlockMetadata] = []
    for cb in 0..<code_block_count {
      code_blocks.push({
        code_block_index: cb,
        included: false,
        first_inclusion: false,
        zero_bit_planes: None,
        coding_passes: None,
        lblock_increment: None,
        segment_lengths: [],
      })
    }
    return Ok({ zero_length: true, code_blocks, consumed_bits: 1 })
  }
  let include_v = decode_tag_tree_inclusion_flags_from(
    data,
    width,
    height,
    layer_index + 1,
    1,
  )
  guard include_v is Ok((inclusion_flags, include_next_pos)) else {
    return Err("failed to decode tag-tree inclusion flags")
  }
  let mut bit_pos = include_next_pos
  let lblock_by_cb : Array[Int] = []
  for _ in 0..<code_block_count {
    lblock_by_cb.push(3)
  }
  let code_blocks : Array[PacketHeaderCodeBlockMetadata] = []
  for cb in 0..<code_block_count {
    if !inclusion_flags[cb] {
      code_blocks.push({
        code_block_index: cb,
        included: false,
        first_inclusion: false,
        zero_bit_planes: None,
        coding_passes: None,
        lblock_increment: None,
        segment_lengths: [],
      })
      continue
    }
    let mut p = 0
    while true {
      let bit = read_bit(data, bit_pos)
      guard bit is Ok(v) else { return Err("unterminated zero bit-plane code") }
      bit_pos += 1
      if v == 1 {
        break
      }
      p += 1
    }
    let pass_v = decode_num_coding_passes(data, bit_pos)
    guard pass_v is Ok((coding_passes, next_pos)) else {
      return Err("failed to decode number of coding passes")
    }
    bit_pos = next_pos
    let lengths_v = decode_lengths_for_codeblock(
      data,
      bit_pos,
      lblock_by_cb[cb],
      coding_passes,
      [],
    )
    guard lengths_v
      is Ok((segment_lengths, next_len_pos, next_lblock, total_inc)) else {
      return Err("failed to decode code-block segment length")
    }
    bit_pos = next_len_pos
    lblock_by_cb[cb] = next_lblock
    code_blocks.push({
      code_block_index: cb,
      included: true,
      first_inclusion: true,
      zero_bit_planes: Some(p),
      coding_passes: Some(coding_passes),
      lblock_increment: Some(total_inc),
      segment_lengths,
    })
  }
  Ok({ zero_length: false, code_blocks, consumed_bits: bit_pos })
}

///|
pub fn parse_packet_header_single_packet_with_tag_tree_and_pass_splits(
  data : Array[Int],
  width : Int,
  height : Int,
  layer_index : Int,
  added_passes_per_code_block : Array[Array[Int]],
) -> Result[PacketHeaderMetadata, String] {
  if layer_index < 0 {
    return Err("layer_index must be non-negative")
  }
  let code_block_count = width * height
  if code_block_count <= 0 {
    return Err("invalid tag-tree size")
  }
  let z = read_bit(data, 0)
  guard z is Ok(non_zero_flag) else {
    return Err("packet header bitstream truncated")
  }
  if non_zero_flag == 0 {
    let code_blocks : Array[PacketHeaderCodeBlockMetadata] = []
    for cb in 0..<code_block_count {
      code_blocks.push({
        code_block_index: cb,
        included: false,
        first_inclusion: false,
        zero_bit_planes: None,
        coding_passes: None,
        lblock_increment: None,
        segment_lengths: [],
      })
    }
    return Ok({ zero_length: true, code_blocks, consumed_bits: 1 })
  }
  let include_v = decode_tag_tree_inclusion_flags_from(
    data,
    width,
    height,
    layer_index + 1,
    1,
  )
  guard include_v is Ok((inclusion_flags, include_next_pos)) else {
    return Err("failed to decode tag-tree inclusion flags")
  }
  let mut bit_pos = include_next_pos
  let lblock_by_cb : Array[Int] = []
  for _ in 0..<code_block_count {
    lblock_by_cb.push(3)
  }
  let code_blocks : Array[PacketHeaderCodeBlockMetadata] = []
  for cb in 0..<code_block_count {
    if !inclusion_flags[cb] {
      code_blocks.push({
        code_block_index: cb,
        included: false,
        first_inclusion: false,
        zero_bit_planes: None,
        coding_passes: None,
        lblock_increment: None,
        segment_lengths: [],
      })
      continue
    }
    let mut p = 0
    while true {
      let bit = read_bit(data, bit_pos)
      guard bit is Ok(v) else { return Err("unterminated zero bit-plane code") }
      bit_pos += 1
      if v == 1 {
        break
      }
      p += 1
    }
    let pass_v = decode_num_coding_passes(data, bit_pos)
    guard pass_v is Ok((coding_passes, next_pos)) else {
      return Err("failed to decode number of coding passes")
    }
    bit_pos = next_pos
    let added_passes_override = if cb < added_passes_per_code_block.length() {
      added_passes_per_code_block[cb]
    } else {
      []
    }
    let lengths_v = decode_lengths_for_codeblock(
      data,
      bit_pos,
      lblock_by_cb[cb],
      coding_passes,
      added_passes_override,
    )
    guard lengths_v
      is Ok((segment_lengths, next_len_pos, next_lblock, total_inc)) else {
      return Err("failed to decode code-block segment length")
    }
    bit_pos = next_len_pos
    lblock_by_cb[cb] = next_lblock
    code_blocks.push({
      code_block_index: cb,
      included: true,
      first_inclusion: true,
      zero_bit_planes: Some(p),
      coding_passes: Some(coding_passes),
      lblock_increment: Some(total_inc),
      segment_lengths,
    })
  }
  Ok({ zero_length: false, code_blocks, consumed_bits: bit_pos })
}

///|
pub fn parse_packet_headers_with_tag_tree_sequence(
  data : Array[Int],
  width : Int,
  height : Int,
  packet_count : Int,
) -> Result[Array[PacketHeaderMetadata], String] {
  parse_packet_headers_with_tag_tree_sequence_and_pass_splits(
    data,
    width,
    height,
    packet_count,
    [],
  )
}

///|
pub fn parse_packet_headers_with_tag_tree_sequence_and_pass_splits(
  data : Array[Int],
  width : Int,
  height : Int,
  packet_count : Int,
  added_passes_per_packet_per_code_block : Array[Array[Array[Int]]],
) -> Result[Array[PacketHeaderMetadata], String] {
  if packet_count <= 0 {
    return Err("packet_count must be positive")
  }
  let code_block_count = width * height
  if code_block_count <= 0 {
    return Err("invalid tag-tree size")
  }
  let levels_v = build_tag_tree_levels(width, height)
  guard levels_v is Ok(levels) else { return Err("invalid tag-tree size") }
  let total_nodes = levels[levels.length() - 1].offset + 1
  let incl_low : Array[Int] = []
  let incl_known : Array[Int?] = []
  let zbp_low : Array[Int] = []
  let zbp_known : Array[Int?] = []
  for _ in 0..<total_nodes {
    incl_low.push(0)
    incl_known.push(None)
    zbp_low.push(0)
    zbp_known.push(None)
  }
  let included_before : Array[Bool] = []
  let lblock_by_cb : Array[Int] = []
  for _ in 0..<code_block_count {
    included_before.push(false)
    lblock_by_cb.push(3)
  }
  let headers : Array[PacketHeaderMetadata] = []
  let mut bit_pos = 0
  for layer in 0..<packet_count {
    let start = bit_pos
    let nz = read_bit(data, bit_pos)
    guard nz is Ok(non_zero_flag) else {
      return Err("packet header bitstream truncated")
    }
    bit_pos += 1
    let code_blocks : Array[PacketHeaderCodeBlockMetadata] = []
    if non_zero_flag == 0 {
      for cb in 0..<code_block_count {
        code_blocks.push({
          code_block_index: cb,
          included: false,
          first_inclusion: false,
          zero_bit_planes: None,
          coding_passes: None,
          lblock_increment: None,
          segment_lengths: [],
        })
      }
      headers.push({
        zero_length: true,
        code_blocks,
        consumed_bits: bit_pos - start,
      })
      bit_pos = (bit_pos + 7) / 8 * 8
      continue
    }
    for y in 0..<height {
      for x in 0..<width {
        let cb = y * width + x
        let mut is_included = false
        let mut first_inclusion = false
        let mut zero_bit_planes : Int? = None
        if !included_before[cb] {
          let inc = decode_tag_tree_member_with_state(
            levels,
            incl_low,
            incl_known,
            x,
            y,
            layer + 1,
            data,
            bit_pos,
          )
          guard inc is Ok((inc_flag, inc_next_pos)) else {
            return Err("failed to decode tag-tree inclusion flags")
          }
          bit_pos = inc_next_pos
          if inc_flag {
            is_included = true
            first_inclusion = true
            included_before[cb] = true
            let zbp = decode_tag_tree_value_with_state(
              levels, zbp_low, zbp_known, x, y, data, bit_pos,
            )
            guard zbp is Ok((p, zbp_next_pos)) else {
              return Err("failed to decode zero bit-plane tag-tree")
            }
            bit_pos = zbp_next_pos
            zero_bit_planes = Some(p)
          }
        } else {
          let inc = read_bit(data, bit_pos)
          guard inc is Ok(v) else {
            return Err("packet header bitstream truncated")
          }
          bit_pos += 1
          is_included = v == 1
        }
        if !is_included {
          code_blocks.push({
            code_block_index: cb,
            included: false,
            first_inclusion: false,
            zero_bit_planes: None,
            coding_passes: None,
            lblock_increment: None,
            segment_lengths: [],
          })
          continue
        }
        let pass_v = decode_num_coding_passes(data, bit_pos)
        guard pass_v is Ok((coding_passes, pass_next_pos)) else {
          return Err("failed to decode number of coding passes")
        }
        bit_pos = pass_next_pos
        let pass_override = if layer <
          added_passes_per_packet_per_code_block.length() &&
          cb < added_passes_per_packet_per_code_block[layer].length() {
          added_passes_per_packet_per_code_block[layer][cb]
        } else {
          []
        }
        let lengths_v = decode_lengths_for_codeblock(
          data,
          bit_pos,
          lblock_by_cb[cb],
          coding_passes,
          pass_override,
        )
        guard lengths_v
          is Ok((segment_lengths, len_next_pos, next_lblock, total_inc)) else {
          return Err("failed to decode code-block segment length")
        }
        bit_pos = len_next_pos
        lblock_by_cb[cb] = next_lblock
        code_blocks.push({
          code_block_index: cb,
          included: true,
          first_inclusion,
          zero_bit_planes,
          coding_passes: Some(coding_passes),
          lblock_increment: Some(total_inc),
          segment_lengths,
        })
      }
    }
    headers.push({
      zero_length: false,
      code_blocks,
      consumed_bits: bit_pos - start,
    })
    bit_pos = (bit_pos + 7) / 8 * 8
  }
  Ok(headers)
}

///|
pub fn decode_codeblock_segment_lengths_from_bits(
  data : Array[Int],
  lblock_initial : Int,
  added_passes : Array[Int],
) -> Result[(Array[Int], Int), String] {
  let internal = decode_codeblock_segment_lengths_from_bits_at(
    data, 0, lblock_initial, added_passes,
  )
  guard internal is Ok((lengths, bit_pos, _, _)) else {
    guard internal is Err(msg) else {
      return Err("failed to decode code-block segment lengths")
    }
    return Err(msg)
  }
  Ok((lengths, bit_pos))
}

///|
fn decode_codeblock_segment_lengths_from_bits_at(
  data : Array[Int],
  start_bit_pos : Int,
  lblock_initial : Int,
  added_passes : Array[Int],
) -> Result[(Array[Int], Int, Int, Int), String] {
  if lblock_initial <= 0 {
    return Err("lblock_initial must be positive")
  }
  let lengths : Array[Int] = []
  let mut lblock = lblock_initial
  let mut bit_pos = start_bit_pos
  let mut total_lblock_increment = 0
  for passes in added_passes {
    if passes <= 0 {
      return Err("added passes must be positive")
    }
    let mut lblock_increment = 0
    while true {
      let b = read_bit(data, bit_pos)
      guard b is Ok(bit) else {
        return Err("unterminated Lblock increment code")
      }
      bit_pos += 1
      if bit == 0 {
        break
      }
      lblock_increment += 1
    }
    lblock = lblock + lblock_increment
    total_lblock_increment += lblock_increment
    let width = lblock + floor_log2_positive(passes)
    let v = read_bits(data, bit_pos, width)
    guard v is Ok((length, next_pos)) else {
      return Err("failed to decode code-block segment length")
    }
    lengths.push(length)
    bit_pos = next_pos
  }
  Ok((lengths, bit_pos, lblock, total_lblock_increment))
}

///|
fn sum_positive_values(values : Array[Int]) -> Result[Int, String] {
  let mut sum = 0
  for v in values {
    if v <= 0 {
      return Err("added passes must be positive")
    }
    sum += v
  }
  Ok(sum)
}

///|
fn decode_lengths_for_codeblock(
  data : Array[Int],
  bit_pos : Int,
  lblock_current : Int,
  coding_passes : Int,
  added_passes_override : Array[Int],
) -> Result[(Array[Int], Int, Int, Int), String] {
  let added_passes = if added_passes_override.length() == 0 {
    [coding_passes]
  } else {
    added_passes_override
  }
  let sum_v = sum_positive_values(added_passes)
  guard sum_v is Ok(total_added) else {
    return Err("invalid added passes override")
  }
  if total_added != coding_passes {
    return Err("added passes override does not match coding passes")
  }
  decode_codeblock_segment_lengths_from_bits_at(
    data, bit_pos, lblock_current, added_passes,
  )
}

///|
fn parse_codestream_impl(
  data : Array[Int],
  compat_mode : Bool,
) -> Result[Codestream, String] {
  if data.length() < 4 {
    return Err("codestream too short")
  }
  let first = read_u16_be(data, 0)
  guard first is Ok(first_code) else {
    return Err("failed to read first marker")
  }
  if first_code != MARKER_SOC {
    return Err("SOC must appear at codestream start")
  }

  let segments : Array[MarkerSegment] = []
  segments.push({ code: MARKER_SOC, payload: [], position: 0 })

  let mut i = 2
  let mut seen_sot = false
  let mut seen_sod = false
  let mut seen_siz = false
  let mut seen_cod = false
  let mut seen_qcd = false
  let mut first_marker_after_soc = true
  let mut in_main_header = true
  let mut in_tile_part_header = false
  let mut siz_components : Int? = None
  let mut main_seen_poc = false
  let mut tile_seen_poc = false
  let mut main_seen_crg = false
  let mut tile_seen_cod = false
  let mut tile_seen_qcd = false
  let mut header_coc_components : Array[Int] = []
  let mut header_qcc_components : Array[Int] = []
  let mut has_ppm = false
  let mut has_ppt = false
  let mut current_sot_pos = -1
  let mut current_psot = 0
  let tile_ids : Array[Int] = []
  let tile_last_tpsot : Array[Int] = []
  let tile_declared_tnsot : Array[Int] = []
  let mut tile_count : Int? = None
  let mut next_plm_index = 0
  let mut next_ppm_index = 0
  let mut next_plt_index = 0
  let mut next_ppt_index = 0
  let mut siz_metadata : SizMetadata? = None
  let mut cod_metadata : CodMetadata? = None
  let mut qcd_metadata : QcdMetadata? = None
  let coc_metadata : Array[CocMetadata] = []
  let rgn_metadata : Array[RgnMetadata] = []
  let qcc_metadata : Array[QccMetadata] = []
  let poc_metadata : Array[PocMetadata] = []
  let tlm_metadata : Array[TlmMetadata] = []
  let plm_metadata : Array[PlmMetadata] = []
  let plt_metadata : Array[PltMetadata] = []
  let ppm_metadata : Array[PpmMetadata] = []
  let ppt_metadata : Array[PptMetadata] = []
  let packet_headers_ppm : Array[PacketHeaderMetadata] = []
  let packet_headers_ppt : Array[PacketHeaderMetadata] = []
  let sop_metadata : Array[SopMetadata] = []
  let eph_positions : Array[Int] = []
  let mut crg_metadata : CrgMetadata? = None
  let com_metadata : Array[ComMetadata] = []
  let mut ordering_metadata : OrderingMetadata? = None
  let mut ordering_coding_metadata : OrderingCodingMetadata? = None
  let mut progression_metadata : ProgressionMetadata? = None

  while i < data.length() {
    let marker = read_u16_be(data, i)
    guard marker is Ok(code) else { return Err("failed to read marker") }
    if code >> 8 != 0xFF {
      return Err("invalid marker prefix")
    }
    let placement = validate_marker_placement(
      code, in_main_header, in_tile_part_header, seen_siz, compat_mode,
    )
    guard placement is Ok(_) else { return Err("invalid marker placement") }

    if code == MARKER_EOC {
      segments.push({ code, payload: [], position: i })
      i += 2
      if i != data.length() {
        return Err("EOC must be the last marker")
      }
      if !seen_sot || !seen_sod {
        return Err("at least one SOT/SOD pair is required")
      }
      if !seen_siz || !seen_cod || !seen_qcd {
        return Err("missing required main header markers")
      }
      return Ok({
        segments,
        metadata: {
          siz: siz_metadata,
          cod: cod_metadata,
          qcd: qcd_metadata,
          coc: coc_metadata,
          rgn: rgn_metadata,
          qcc: qcc_metadata,
          poc: poc_metadata,
          tlm: tlm_metadata,
          plm: plm_metadata,
          plt: plt_metadata,
          ppm: ppm_metadata,
          ppt: ppt_metadata,
          sop: sop_metadata,
          eph_positions,
          crg: crg_metadata,
          com: com_metadata,
          ordering: ordering_metadata,
          ordering_coding: ordering_coding_metadata,
          progression: progression_metadata,
          packet_headers_ppm,
          packet_headers_ppt,
        },
      })
    }

    if code == MARKER_SOD {
      if !seen_sot {
        return Err("SOD requires preceding SOT")
      }
      let packet_start = i + 2
      let packet_end = if current_psot > 0 {
        let declared_end = current_sot_pos + current_psot
        if declared_end < packet_start {
          return Err("invalid Psot in SOT")
        }
        if declared_end > data.length() {
          return Err("Psot exceeds codestream size")
        }
        declared_end
      } else {
        find_next_sot_or_eoc(data, packet_start)
      }
      let packet : Array[Int] = []
      for j in packet_start..<packet_end {
        packet.push(data[j])
      }
      let stuffing_check = validate_packet_bit_stuffing(packet)
      guard stuffing_check is Ok(_) else { return Err("invalid packet data") }
      let (found_sops, found_ephs) = extract_in_bitstream_markers(
        packet, packet_start,
      )
      for sop_entry in found_sops {
        sop_metadata.push(sop_entry)
      }
      for eph_pos in found_ephs {
        eph_positions.push(eph_pos)
      }
      in_tile_part_header = false
      seen_sod = true
      segments.push({ code, payload: packet, position: i })
      i = packet_end
      continue
    }

    if !has_explicit_length(code) {
      // Spec (Annex A.1.3): reserved markers are marker-only and decoder-skippable.
      if compat_mode && is_reserved_jpeg_marker(code) {
        segments.push({ code, payload: [], position: i })
        i += 2
        continue
      }
      return Err("unexpected marker without length")
    }

    let l = read_u16_be(data, i + 2)
    guard l is Ok(length) else {
      return Err("failed to read marker segment length")
    }
    if length < 2 {
      return Err("invalid marker segment length")
    }
    let payload_len = length - 2
    let payload_start = i + 4
    let payload_end = payload_start + payload_len
    if payload_end > data.length() {
      return Err("marker segment exceeds codestream size")
    }

    let payload : Array[Int] = []
    for j in payload_start..<payload_end {
      payload.push(data[j])
    }

    if first_marker_after_soc {
      if code != MARKER_SIZ {
        return Err("SIZ must be the second marker segment")
      }
      first_marker_after_soc = false
    }

    let payload_validation = validate_marker_payload(
      code, length, payload, in_main_header, siz_components, main_seen_poc, tile_seen_poc,
      header_coc_components, header_qcc_components, main_seen_crg, has_ppm, has_ppt,
      compat_mode,
    )
    guard payload_validation is Ok(next_siz_components) else {
      return Err("invalid marker payload")
    }
    siz_components = next_siz_components

    if code == MARKER_SIZ {
      seen_siz = true
      let tc = compute_tile_count_from_siz(payload)
      guard tc is Ok(n_tiles) else {
        return Err("failed to compute tile count")
      }
      tile_count = Some(n_tiles)
      let sm = parse_siz_metadata(payload)
      guard sm is Ok(meta) else { return Err("failed to parse SIZ metadata") }
      let om = build_ordering_metadata(meta)
      guard om is Ok(ordered) else {
        return Err("failed to build ordering metadata")
      }
      siz_metadata = Some(meta)
      ordering_metadata = Some(ordered)
    }
    if code == MARKER_COD {
      if in_main_header {
        if seen_cod {
          return Err("COD must appear at most once in main header")
        }
        seen_cod = true
        let cm = parse_cod_metadata(payload)
        guard cm is Ok(meta) else { return Err("failed to parse COD metadata") }
        cod_metadata = Some(meta)
        if ordering_metadata is Some(ordering) {
          let coding = build_ordering_coding_metadata(meta, ordering)
          ordering_coding_metadata = Some(coding)
          progression_metadata = refresh_progression_metadata(
            cod_metadata, ordering_metadata, ordering_coding_metadata, poc_metadata,
          )
        }
      } else {
        if tile_seen_cod {
          return Err("COD must appear at most once in tile-part header")
        }
        tile_seen_cod = true
      }
    }
    if code == MARKER_QCD {
      if in_main_header {
        if seen_qcd {
          return Err("QCD must appear at most once in main header")
        }
        seen_qcd = true
        let qm = parse_qcd_metadata(payload)
        guard qm is Ok(meta) else { return Err("failed to parse QCD metadata") }
        qcd_metadata = Some(meta)
      } else {
        if tile_seen_qcd {
          return Err("QCD must appear at most once in tile-part header")
        }
        tile_seen_qcd = true
      }
    }
    if code == MARKER_POC {
      guard siz_components is Some(csiz) else {
        return Err("missing SIZ component count")
      }
      let parsed = parse_poc_entries(payload, csiz, in_main_header)
      guard parsed is Ok(entries) else {
        return Err("failed to parse POC metadata")
      }
      for entry in entries {
        poc_metadata.push(entry)
      }
      if in_main_header {
        main_seen_poc = true
      } else {
        tile_seen_poc = true
      }
      progression_metadata = refresh_progression_metadata(
        cod_metadata, ordering_metadata, ordering_coding_metadata, poc_metadata,
      )
    }
    if code == MARKER_RGN {
      guard siz_components is Some(csiz) else {
        return Err("missing SIZ component count")
      }
      let parsed = parse_rgn_metadata(payload, csiz, in_main_header)
      guard parsed is Ok(entry) else {
        return Err("failed to parse RGN metadata")
      }
      rgn_metadata.push(entry)
    }
    if code == MARKER_CRG {
      main_seen_crg = true
      guard siz_components is Some(csiz) else {
        return Err("missing SIZ component count")
      }
      let parsed = parse_crg_metadata(payload, csiz)
      guard parsed is Ok(entry) else {
        return Err("failed to parse CRG metadata")
      }
      crg_metadata = Some(entry)
    }
    if code == MARKER_COM {
      let parsed = parse_com_metadata(payload)
      guard parsed is Ok(entry) else {
        return Err("failed to parse COM metadata")
      }
      com_metadata.push(entry)
    }
    if code == MARKER_SOP {
      let parsed = parse_sop_metadata(payload, i)
      guard parsed is Ok(entry) else {
        return Err("failed to parse SOP metadata")
      }
      sop_metadata.push(entry)
    }
    if code == MARKER_EPH {
      eph_positions.push(i)
    }
    if code == MARKER_PPM {
      has_ppm = true
    }
    if code == MARKER_PPT {
      has_ppt = true
    }
    if code == MARKER_TLM {
      let parsed = parse_tlm_metadata(payload)
      guard parsed is Ok(entry) else {
        return Err("failed to parse TLM metadata")
      }
      tlm_metadata.push(entry)
    }
    if code == MARKER_PLM {
      let parsed = parse_plm_metadata(payload)
      guard parsed is Ok(entry) else {
        return Err("failed to parse PLM metadata")
      }
      plm_metadata.push(entry)
    }
    if code == MARKER_PLT {
      let parsed = parse_plt_metadata(payload)
      guard parsed is Ok(entry) else {
        return Err("failed to parse PLT metadata")
      }
      plt_metadata.push(entry)
    }
    if code == MARKER_PPM {
      let parsed = parse_ppm_metadata(payload)
      guard parsed is Ok(entry) else {
        return Err("failed to parse PPM metadata")
      }
      ppm_metadata.push(entry)
      for chunk in entry.chunks {
        let decoded = parse_packet_headers_series_with_code_blocks(
          chunk.ippm,
          1,
        )
        if decoded is Err(_) {
          if compat_mode {
            // Spec (Annex B): PPM relocates packet headers.
            // Policy: keep payload opaque when local packet-header model cannot decode it.
            continue
          }
          return Err("failed to parse packet headers in PPM")
        }
        guard decoded is Ok(headers) else {
          return Err("failed to parse packet headers in PPM")
        }
        for h in headers {
          packet_headers_ppm.push(h)
        }
      }
    }
    if code == MARKER_PPT {
      let parsed = parse_ppt_metadata(payload)
      guard parsed is Ok(entry) else {
        return Err("failed to parse PPT metadata")
      }
      ppt_metadata.push(entry)
      let decoded = parse_packet_headers_series_with_code_blocks(entry.data, 1)
      if decoded is Err(_) {
        if compat_mode {
          // Same policy as PPM path for PPT-relocated packet headers.
          // Keep the original PPT marker segment payload for roundtrip safety.
          // Spec basis:
          // - Annex B (packet headers may be relocated by PPM/PPT)
          //   /sections/annex-b-image-and-compressed-image-data-ordering.md:744-747
          // Policy:
          // - metadata decode failure must not drop raw PPT segment bytes.
          // - strict mode still fails below.
        } else {
          return Err("failed to parse packet headers in PPT")
        }
      } else if decoded is Ok(headers) {
        for h in headers {
          packet_headers_ppt.push(h)
        }
      }
    }
    if code == MARKER_COC || code == MARKER_QCC {
      guard siz_components is Some(csiz) else {
        return Err("missing SIZ component count")
      }
      let comp = if csiz < 257 {
        payload[0]
      } else {
        let cvalue = read_u16_from_payload(payload, 0)
        guard cvalue is Ok(component_idx) else {
          return Err("failed to parse component index")
        }
        component_idx
      }
      if code == MARKER_COC {
        header_coc_components.push(comp)
        let parsed = parse_coc_metadata(payload, csiz, in_main_header)
        guard parsed is Ok(entry) else {
          return Err("failed to parse COC metadata")
        }
        coc_metadata.push(entry)
      } else {
        header_qcc_components.push(comp)
        let parsed = parse_qcc_metadata(payload, csiz, in_main_header)
        guard parsed is Ok(entry) else {
          return Err("failed to parse QCC metadata")
        }
        qcc_metadata.push(entry)
      }
    }
    if code == MARKER_PLM {
      let zplm = payload[0]
      if zplm != next_plm_index {
        return Err("invalid Zplm sequence")
      }
      next_plm_index += 1
    }
    if code == MARKER_PPM {
      let zppm = payload[0]
      if zppm != next_ppm_index {
        return Err("invalid Zppm sequence")
      }
      next_ppm_index += 1
    }
    if code == MARKER_PLT {
      let zplt = payload[0]
      if zplt != next_plt_index {
        return Err("invalid Zplt sequence")
      }
      next_plt_index += 1
    }
    if code == MARKER_PPT {
      let zppt = payload[0]
      if zppt != next_ppt_index {
        return Err("invalid Zppt sequence")
      }
      next_ppt_index += 1
    }

    segments.push({ code, payload, position: i })
    if code == MARKER_SOT {
      seen_sot = true
      in_main_header = false
      in_tile_part_header = true
      current_sot_pos = i
      let isot_value = read_u16_from_payload(payload, 0)
      let psot_value = read_u32_be(payload, 2)
      guard isot_value is Ok(isot) else { return Err("failed to parse Isot") }
      guard psot_value is Ok(psot) else { return Err("failed to parse Psot") }
      let tpsot = payload[6]
      let tnsot = payload[7]
      if tnsot != 0 && tpsot >= tnsot {
        return Err("invalid TPsot/TNsot relation")
      }
      if tile_count is Some(n_tiles) {
        if isot < 0 || isot >= n_tiles {
          return Err("Isot out of range")
        }
      }
      if find_tile_state_index(tile_ids, isot) is Some(idx) {
        if tpsot != tile_last_tpsot[idx] + 1 {
          return Err("invalid tile-part index sequence")
        }
        if tile_declared_tnsot[idx] != 0 &&
          tnsot != 0 &&
          tnsot != tile_declared_tnsot[idx] {
          return Err("inconsistent TNsot for tile")
        }
        tile_last_tpsot[idx] = tpsot
        if tile_declared_tnsot[idx] == 0 {
          tile_declared_tnsot[idx] = tnsot
        }
      } else {
        if tpsot != 0 {
          return Err("first tile-part index must be zero")
        }
        tile_ids.push(isot)
        tile_last_tpsot.push(tpsot)
        tile_declared_tnsot.push(tnsot)
      }
      current_psot = psot
      tile_seen_poc = false
      tile_seen_cod = false
      tile_seen_qcd = false
      header_coc_components = []
      header_qcc_components = []
      next_plt_index = 0
      next_ppt_index = 0
    }
    i = payload_end
  }

  Err("EOC marker missing")
}

///|
pub fn parse_codestream(data : Array[Int]) -> Result[Codestream, String] {
  // Runtime/default API: interoperability-first parser behavior.
  parse_codestream_impl(data, true)
}

///|
pub fn parse_codestream_strict(data : Array[Int]) -> Result[Codestream, String] {
  // Audit API: strict conformance checks for investigation workflows.
  parse_codestream_impl(data, false)
}

///|
pub fn encode_codestream(stream : Codestream) -> Result[Array[Int], String] {
  let out : Array[Int] = []
  for segment in stream.segments {
    if segment.code >> 8 != 0xFF {
      return Err("invalid marker value")
    }
    out.push((segment.code >> 8) & 0xFF)
    out.push(segment.code & 0xFF)

    if segment.code == MARKER_SOD {
      for b in segment.payload {
        if b < 0 || b > 0xFF {
          return Err("payload byte out of range")
        }
        out.push(b)
      }
    } else if has_explicit_length(segment.code) {
      let length = segment.payload.length() + 2
      if length > 0xFFFF {
        return Err("segment payload too long")
      }
      out.push((length >> 8) & 0xFF)
      out.push(length & 0xFF)
      for b in segment.payload {
        if b < 0 || b > 0xFF {
          return Err("payload byte out of range")
        }
        out.push(b)
      }
    }
  }
  Ok(out)
}
