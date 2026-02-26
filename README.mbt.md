# trkbt10/jpeg2000

JPEG 2000 codestream parser/encoder library for MoonBit.

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
  let bytes = @j2k.sample_codestream_minimal()
  let parsed = @j2k.parse_codestream(bytes)
  if parsed is Ok(stream) {
    let encoded = @j2k.encode_codestream(stream)
    // ...
  }
}
```

## Public API

Public functions are exported from `jpeg2000.mbt`.  
Public types are exported from `jpeg2000_types.mbt`.

Core API:

- `parse_codestream`: interoperability-first parser
- `parse_codestream_strict`: strict validation parser
- `encode_codestream`: codestream encoder
- `roundtrip_bytes`: parse + re-encode convenience
- `bytes_to_hex` / `hex_to_bytes`: hex conversion helpers

Sample/model API:

- `sample_codestream_*`
- `sample_codestream_by_name`
- `sample_codestream_names`
- `classify_marker`

Packet-header/analysis API:

- `decode_tag_tree_inclusion_flags`
- `decode_codeblock_segment_lengths_from_bits`
- `parse_packet_headers_*`

## Package Layout

- `trkbt10/jpeg2000`: library facade for mooncakes users
- `trkbt10/jpeg2000/cmd/main`: native/file CLI entrypoint
- `trkbt10/jpeg2000/cmd/wasm`: wasm-safe CLI entrypoint
- `npm/wasm`: npm artifact package (`@trkbt10/jpeg2000-wasm`)
- `internal/core`: internal implementation package

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
