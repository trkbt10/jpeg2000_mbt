# Development and Testing

## API Guardrail

```bash
./tools/check_public_api.sh
```

Checks:

1. required core APIs are exported
2. CLI/file-I/O style APIs are not exported from the library package
3. public function definitions stay in `jpeg2000.mbt`

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

Disable large-file probe path:

```bash
PROBE_LARGE_PATH=0 ./tools/probe_external_corpus_cycle.sh samples/corpus
```

Construct built-in `.j2k` corpus files:

```bash
./tools/build_sample_corpus.sh
```

Run all round-trip checks:

```bash
./tools/roundtrip_full_cycle.sh
```

Enable strict external corpus byte-equality check:

```bash
STRICT_EXTERNAL_CORPUS=1 ./tools/roundtrip_full_cycle.sh
```

## Test

Native:

```bash
moon test --jobs 1 --no-parallelize
```

WASM GC:

```bash
moon test --target wasm-gc --jobs 1 --no-parallelize
```

WASM smoke:

```bash
./tools/wasm_smoke.sh
```
