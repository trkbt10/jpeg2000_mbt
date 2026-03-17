# Spec Note: D.3/D.4 Tier-1 Passes and Contexts

## Purpose
Validate pass scheduling and context initialization/reinitialization for Tier-1 coefficient decoding.

## Normative References
- T.800-2015 D.3
- T.800-2015 D.4
- T.800-2015 Table D.7

## Direct Citation
- D.3 (line 5761):
> "Decoding passes over the bit-planes"
- D.3 (line 5761):
> "Significance states are initialized to 0"
- D.4 (line 6003):
> "When the contexts are initialized ... they are set to the values in Table D.7"
- Table D.7 (line 6006):
> "UNIFORM ... 46"
- Table D.7 (line 6006):
> "Run-length ... 3"

Interpretation:
- Pass ordering and context reset values are normative, not tunable.
- Wrong context labels or re-init timing directly breaks sign/refinement output.

## Decoder Invariants
- Pass order (sigprop/refinement/cleanup) follows D.3.
- Context init/re-init values match Table D.7 for each label.
- SEGMARK and refinement context handling preserve subsequent pass correctness.

## Observed Failures
- `p0_02.j2k`
- `p1_01.j2k`
- `p1_07.j2k`
- `p0_08.j2k`

## Planned Fixes
- `internal/decoder/jpeg2000_decode_samples_annex_d_pass.mbt`
- `internal/decoder/jpeg2000_decode_samples_annex_c_mq.mbt`
- `internal/decoder/jpeg2000_decode_samples_ds_profile_api.mbt`

## Acceptance
- Context-state traces for target fixtures are stable and reproducible.
- Target fixtures show reduced first-mismatch index and eventual byte-match.
