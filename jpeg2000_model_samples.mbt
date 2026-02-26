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
