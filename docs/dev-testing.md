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
./tools/roundtrip_cycle.sh sample
```

Build and verify all registered samples:

```bash
./tools/roundtrip_cycle.sh samples
```

Run round-trip for external `.j2k` corpus:

```bash
./tools/roundtrip_cycle.sh corpus samples/corpus
```

Run recursive external probe on an openjpeg-data clone:

```bash
bash tools/probe_external_corpus_cycle.sh /tmp/openjpeg-data/input/conformance
```

Compare an external conformance corpus against the reference implementation:

```bash
python3 tools/reference_compare.py --corpus-dir /tmp/openjpeg-data/input/conformance \
  --out /tmp/openjpeg-data-conformance.tsv --jobs 4
```

Write `decode(original)` and `decode(roundtrip(codestream))` artifacts for one fixture:

```bash
./tools/roundtrip_cycle.sh decode-fixture samples/corpus/p1_05.j2k
```

Refresh the latest reference implementation expected vs MoonBit actual visual compare set:

```bash
./tools/decode_to_roundtrip.sh
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
./tools/roundtrip_cycle.sh build-builtins
```

Run all round-trip checks:

```bash
./tools/roundtrip_cycle.sh full
```

Enable strict external corpus byte-equality check:

```bash
STRICT_EXTERNAL_CORPUS=1 ./tools/roundtrip_cycle.sh full
```

## Test

Native:

```bash
moon test --target native --jobs 1 --no-parallelize
```

Notes:

1. local `moon.pkg` files pin native C compilation to `clang`, so native test runs build executables instead of relying on `tcc -run`
2. `jpeg2000_corpus_test.mbt` is excluded on native because full corpus decode is computationally heavy and better exercised via tooling
3. native corpus coverage lives in `jpeg2000_corpus_native_test.mbt`, which runs a small deterministic smoke subset

Native corpus smoke only:

```bash
moon test jpeg2000_corpus_native_test.mbt --target native --jobs 1 --no-parallelize -v
```

WASM GC:

```bash
moon test --target wasm-gc --jobs 1 --no-parallelize
```

WASM smoke:

```bash
./tools/wasm_smoke.sh
```
