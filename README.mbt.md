# trkbt10/jpeg2000

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
