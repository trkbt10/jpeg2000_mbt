# trkbt10/jpeg2000

T.800-2015 JPEG 2000 decoder for MoonBit.

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
  let data : Bytes = ... // JPEG 2000 codestream bytes
  let image = try { @j2k.decode(data) } catch { e => abort(e.to_string()) }
  println("w=\{image.width} h=\{image.height} comps=\{image.num_components}")
}
```

## Public API

### Decode

```moonbit nocheck
pub fn decode(Bytes) -> ImageData raise DecodeError
```

Decodes a JPEG 2000 codestream into pixel data.

### Parse

```moonbit nocheck
pub fn parse(Bytes) -> Codestream raise DecodeError
```

Parses a codestream into its marker segment structure.

### Types

```moonbit nocheck
pub(all) struct ImageData {
  width : Int
  height : Int
  num_components : Int
  bits_per_component : Int
  is_signed : Bool
  data : Bytes
}

pub(all) suberror DecodeError {
  InvalidCodestream(String)
  UnsupportedFeature(String)
  DecodeFailed(String)
}
```

## Package Layout

```
trkbt10/jpeg2000          — public API (decode, parse)
  src/internal/core       — codestream parsing internals
  src/internal/decoder    — decode pipeline (MQ, T1, DWT, MCT)
  src/cmd/main            — native CLI
  src/cmd/wasm            — wasm CLI
```

## WASM

```bash
moon build --target wasm
```

## Developer Docs

- `docs/dev-testing.md` — testing commands
- `reference/project-policy.md` — project policy
- `reference/jpeg2000_coverage_matrix.md` — spec coverage matrix
