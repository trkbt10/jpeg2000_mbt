# Corpus Sources

Updated: 2026-03-10

この repo の `samples/corpus` は最小の常設 regression corpus です。追加探索用の corpus は repo に vendor せず、外部ディレクトリを `tools/*corpus*` で流す前提にしています。

## Recommended Sources

| Source | Scope | Status in this repo | Link |
| --- | --- | --- | --- |
| OpenJPEG data repo | T.803 conformance + nonregression + HTJ2K nonregression | Primary external source | https://github.com/uclouvain/openjpeg-data |
| ITU-T T.803 test signals database | JPEG 2000 conformance test signals | Authoritative source, local copy not added in this turn | https://www.itu.int/rec/T-REC-T.803 |
| JPEG WG1 GitLab | HTJ2K codestreams / reference software | Future HTJ2K intake source | https://gitlab.com/wg1 |

## Current Recommendation

1. Keep `samples/corpus` as the small always-on regression set.
2. Use `openjpeg-data/input/conformance` as the next external conformance gate.
3. Use `openjpeg-data/input/nonregression` as the next parser/roundtrip robustness gate.
4. Run `input/nonregression/htj2k` as a dedicated HTJ2K gate with `--include-htj2k`.

## Validated On 2026-03-10

Local clone:

```bash
git clone --depth 1 https://github.com/uclouvain/openjpeg-data /tmp/openjpeg-data
```


```bash
bash tools/probe_external_corpus_cycle.sh /tmp/openjpeg-data/input/conformance
python3 tools/openjpeg_compare.py --corpus-dir /tmp/openjpeg-data/input/conformance \
  --out /tmp/openjpeg-data-conformance.tsv --jobs 4
```

Observed results:

- conformance codestreams: 44
- parse/roundtrip probe: `44/44 ok`
- current additional mismatches: none


```bash
bash tools/probe_external_corpus_cycle.sh /tmp/openjpeg-data/input/nonregression
```

Observed results:

- nonregression codestreams seen by generic probe: 33
- parse/roundtrip probe: `33/33 ok`
- current roundtrip failures: none
- `input/nonregression/htj2k` has 4 files and is excluded by default


```bash
python3 tools/openjpeg_compare.py --corpus-dir /tmp/openjpeg-data/input/nonregression/htj2k \
  --include-htj2k --out /tmp/openjpeg-data-htj2k.tsv
```

Observed results:

- HTJ2K fixtures seen by compare tool: 4

Reference snapshot:

- `reference/openjpeg_data_conformance_compare_latest.tsv`
- `reference/openjpeg_data_conformance_mismatch_diffs.md` (currently empty because `fail_mismatch=0`)

## Operational Notes

- Generic external corpus tools now recurse directories.
- By default they skip `*/htj2k/*` and `.jph/.jhc`.
- Set `INCLUDE_HTJ2K=1` only when you explicitly want HTJ2K files included.
