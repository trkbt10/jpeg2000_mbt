# Spec Note: C.3 MQ Decoder Core

## Purpose
Validate arithmetic decoder core behavior for decision decode, byte input/stuffing, and initialization.

## Normative References
- T.800-2015 C.3.2
- T.800-2015 C.3.4
- T.800-2015 C.3.5

## Direct Citation
- C.3.2 (line 5349):
> "Decoding a decision (DECODE)"
- C.3.2 (line 5349):
> "Unless a conditional exchange is needed ..."
- C.3.4 (line 5587):
> "BYTEIN ... compensating for any stuff bits following the 0xFF byte"
- C.3.5 (line 5640):
> "Initialization of the decoder (INITDEC)"

Interpretation:
- DECODE/BYTEIN/INITDEC must operate as a single consistent state machine.
- Any divergence here cascades into Tier-1 sign/magnitude mismatch.

## Decoder Invariants
- Conditional exchange in DECODE is applied in spec order.
- BYTEIN handles 0xFF stuffing exactly.
- INITDEC bootstrap and renormalization states match C.3 flow.

## Observed Failures
- `p0_02.j2k`
- `p1_01.j2k`
- `p0_07.j2k`
- `p0_08.j2k`

## Planned Fixes
- `internal/decoder/jpeg2000_decode_samples_annex_c_mq.mbt`:
  - `tier1_annex_c_decode_decision`
  - `tier1_annex_c_bytein`
  - `tier1_annex_c_initdec_from_bootstrap`

## Acceptance
- No MQ state drift in segment boundaries for target fixtures.
- Target fixtures move from mismatch toward byte-match without introducing hard-fail.
