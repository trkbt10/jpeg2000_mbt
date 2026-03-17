# T.814 Intake Notes (HTJ2K)

Source PDF:
- `/Users/terukichi/Downloads/T-REC-T.814-201906-I!!PDF-E.pdf`

## 1. Summary

- `ITU-T T.814 (06/2019)` is JPEG 2000 Part 15 (HTJ2K).
- It introduces a high-throughput Tier-1 block coder (HT SigProp / HT MagRef / HT Cleanup).
- Codestream syntax outside block coding and packet parsing is largely inherited from `T.800`.

## 2. Applicability Gate For This Repository

Current corpus (`samples/corpus`) scan result:
- CAP marker (`FF50`) present: `0 / 27`
- Therefore, current mismatch set is still primarily `T.800` path, not HTJ2K.

One-liner used:

```bash
for f in samples/corpus/*.{j2k,j2c}; do
  [ -f "$f" ] || continue
  /opt/homebrew/bin/opj_dump -i "$f" 2>/dev/null | rg -q "CAP marker|type=0xff50|ff50" \
    && echo "$(basename "$f"): CAP" || true
done
```

## 3. Why Import T.814 Anyway

- Future corpora may include HT codestreams.
- Some code-block style combinations overlap conceptually with bypass/raw paths, so explicit gating avoids accidental mis-decode.
- Adding explicit HT detection improves diagnostics (`unsupported` vs silent mismatch).

## 4. Extension Plan (Incremental)

1. Marker-level gating
- Parse and store `CAP` marker presence/capabilities in codestream metadata.
- If HT capability is signalled, branch into HT-aware packet/Tier-1 path.

2. Decoder guardrail
- Implemented on 2026-03-10:
  - if HT is signalled outside the current cleanup-only subset, fail with explicit reason:
    - `DS-UNSUPPORTED-HTJ2K:cap_present_no_ht_decoder`

3. Cleanup-only HT decode subset
- Implemented on 2026-03-10:
  - pure-MoonBit HT cleanup decoding is enabled for the current staged subset:
    - `passes=1`
    - `code-block-style=0x40/0x48`
    - `layers=1`
    - no ROI
    - quantization / transform combinations already accepted by the baseline decoder
- This keeps the path wasm-safe: no native FFI, no external decoder calls.

4. Compare script categorization
- Implemented on 2026-03-10:
    - `skip_htj2k_not_supported`

5. Tests
- Add fixtures (or synthetic marker tests) for:
  - CAP present + cleanup-only subset enabled
  - HTJ2K fixture decode regression
  - HTJ2K wrapper decode regression (`.jph` / `.jhc`)
  - CAP present + out-of-scope unsupported path

## 5. Current Local Status (2026-03-10)

- `openjpeg-data/input/nonregression/htj2k` の parser/roundtrip probe は `4/4 ok`
  - `Bretagne1_ht.j2k`
  - `Bretagne1_ht_lossy.j2k`
  - `byte.jph`
  - `byte_causal.jhc`
- `byte.jph` / `byte_causal.jhc` は wrapper のまま `parse-file` / `roundtrip-file-verify` が通る
  - `Bretagne1_ht.j2k`
  - `Bretagne1_ht_lossy.j2k`
  - `byte.jph`
  - `byte_causal.jhc`
- `decode-file` では zero-payload / zero-total-segment の HTJ2K は既存 zero-recon で通り、
- explicit unsupported path は残してあり、cleanup-only subset の外に出た HTJ2K は fail-fast のまま

## 6. Relationship To Current Priority Mismatches

- `p1_07` / `p1_06` currently have no CAP marker, so they remain `T.800` debugging targets.
- T.814 work should be tracked as a parallel readiness task, not the primary root cause for those two fixtures.
