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
