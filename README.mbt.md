# trkbt10/jpeg2000

## Distribution Topology

- mooncakes package (library): `trkbt10/jpeg2000`
- wasm CLI entrypoint package: `trkbt10/jpeg2000/cmd/wasm`
- npm artifact package directory: `npm/wasm` (`@trkbt10/jpeg2000-wasm`)

Why these files exist:

- `jpeg2000_types.mbt`: public type re-exports (facade).
- `jpeg2000_public_api.mbt`: public function entrypoint (facade).
- `internal/core/`: implementation package. Internal logic lives here.
- `jpeg2000_wbtest.mbt`: whitebox tests for package-internal invariants.
  This is test-only and not part of distributed runtime API.

## Public API (Library)

Core APIs intended for library consumers:

- `parse_codestream`
- `parse_codestream_strict`
- `encode_codestream`
- `roundtrip_bytes`
- `bytes_to_hex`
- `hex_to_bytes`

API guardrail check:

```bash
./tools/check_public_api.sh
```

This check verifies:

1. required core APIs are exported
2. CLI/file-I/O style APIs are not exported from the library package

## Round-trip Sample Cycle

Build and verify a minimal JPEG2000 codestream sample with file I/O cycle:

```bash
./tools/roundtrip_sample_cycle.sh
```

Build and verify all registered samples:

```bash
./tools/roundtrip_samples_cycle.sh
```

Run round-trip for external `.j2k` corpus:

```bash
./tools/roundtrip_corpus_cycle.sh samples/corpus
```

Probe external `.j2k` corpus compatibility (non-strict by default):

```bash
./tools/probe_external_corpus_cycle.sh samples/corpus
```

Disable large-file probe path (default is enabled):

```bash
PROBE_LARGE_PATH=0 ./tools/probe_external_corpus_cycle.sh samples/corpus
```

Construct built-in `.j2k` corpus files:

```bash
./tools/build_sample_corpus.sh
```

Run all round-trip checks in one command:

```bash
./tools/roundtrip_full_cycle.sh
```

Enable strict external corpus byte-equality check:

```bash
STRICT_EXTERNAL_CORPUS=1 ./tools/roundtrip_full_cycle.sh
```

Parser API:

- `parse_codestream`: default parser for practical codestream interoperability

This runs:

1. sample codestream generation (`sample-hex`)
2. file construction (`samples/generated/minimal.j2k`)
3. file loading + round-trip re-encoding (`roundtrip-hex`)
4. output write and byte-level comparison

## WASM Usage

Build WASM target:

```bash
moon build --target wasm
```

WASM entrypoint package (`cmd/wasm`) excludes file-I/O and supports:

- `list-samples`
- `parse-sample [name]`
- `sample-hex [name]`
- `roundtrip-hex <hex>`

Run WASM smoke test:

```bash
./tools/wasm_smoke.sh
```

Run test suite on wasm-gc target:

```bash
moon test --target wasm-gc --jobs 1 --no-parallelize
```

## npm WASM Packaging

Export wasm artifact for npm package:

```bash
./tools/export_wasm_npm_package.sh
```

Package directory:

- `npm/wasm/package.json`
- `npm/wasm/index.mjs`
- `npm/wasm/index.cjs`
- `npm/wasm/dist/jpeg2000.wasm` (generated)
- `npm/wasm/dist/manifest.json` (generated)
