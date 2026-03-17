# trkbt10/jpeg2000

JPEG 2000 codestream primitives for MoonBit.

## Features

- Codestream parse / strict-parse / encode / roundtrip
- Packet-header and tag-tree analysis helpers
- Sample decode to a normalized `DecodeSamplesResult`
- Built-in sample codestream fixtures for tests, demos, and CLI flows

## Install

```bash
moon add trkbt10/jpeg2000
```

## Quick Start

```moonbit nocheck
import {
  "trkbt10/jpeg2000" @j2k,
}

///|
fn main {
  guard @j2k.sample_codestream_bytes_by_name("minimal") is Some(sample) else {
    return
  }
  guard @j2k.parse_codestream_bytes(sample) is Ok(stream) else { return }
  guard @j2k.encode_codestream_bytes(stream) is Ok(encoded) else { return }
  let _roundtripped = @j2k.roundtrip_codestream_bytes(encoded)
}
```

## Public API

Codestream API:

- `parse_codestream`: interoperability-first parser
- `parse_codestream_bytes`: `Bytes`-first parser for facade consumers
- `parse_codestream_strict`: strict validation parser
- `parse_codestream_strict_bytes`: strict `Bytes`-first parser
- `encode_codestream`: codestream encoder
- `encode_codestream_bytes`: `Bytes`-first codestream encoder
- `roundtrip_bytes`: parse + re-encode convenience
- `roundtrip_codestream_bytes`: `Bytes`-first parse + re-encode convenience
- `bytes_to_hex` / `hex_to_bytes`: hex conversion helpers

Sample/model API:

- `sample_codestream_*`
- `sample_codestream_by_name`
- `sample_codestream_bytes_by_name`
- `sample_codestream_names`
- `classify_marker`

Packet-header/analysis API:

- `decode_tag_tree_inclusion_flags`
- `decode_codeblock_segment_lengths_from_bits`
- `parse_packet_headers_*`
- `parse_packet_header_first_packet_with_code_blocks_and_style`

Decode API:

- `decode_samples(data : Bytes) -> Result[DecodeSamplesResult, String]`
  - fields: `width`, `height`, `num_components`, `bits_per_component`, `is_signed`, `sample_layout`, `samples`
  - current payload contract is identified by `sample_layout` (for example `component0:raster:le:...`)
- `decode_samples_audit(data : Bytes, packet_audit_limit? : Int = 300, force_relocated_ppt? : Bool = false) -> Result[DecodeSamplesResult, String]`
  - decode result plus packet/header/body audit logging

## Package Layout

- `trkbt10/jpeg2000`: single public facade package for mooncakes users
  - `lib.mbt`: package marker
  - `types.mbt`: public aliases and result types
  - `codestream.mbt`: parse / encode / roundtrip facade
  - `conversion.mbt`: hex helpers
  - `samples.mbt`: built-in sample codestream fixtures
  - `markers.mbt`: marker classification
  - `packet_headers.mbt`: packet-header analysis entrypoints
  - `decode.mbt`: top-level sample decode entrypoints
- `trkbt10/jpeg2000/cmd/main`: native/file CLI entrypoint
- `trkbt10/jpeg2000/cmd/wasm`: wasm-safe CLI entrypoint
- `npm/wasm`: npm artifact package (`@trkbt10/jpeg2000-wasm`)
- `internal/core`: codestream and packet internals
- `internal/decoder`: decode pipeline internals

## WASM

Build:

```bash
moon build --target wasm
```

CLI commands (`cmd/wasm`):

- `list-samples`
- `parse-sample [name]`
- `sample-hex [name]`
- `roundtrip-hex <hex>`

npm artifact packaging:

```bash
./tools/export_wasm_npm_package.sh
```

## Developer Docs

- Development/testing commands are in `docs/dev-testing.md`.
- Project policy: `reference/project-policy.md`
- JPEG2000 coverage matrix: `reference/jpeg2000_coverage_matrix.md`
