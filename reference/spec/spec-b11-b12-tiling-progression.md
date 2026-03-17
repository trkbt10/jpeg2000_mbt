# Spec Note: B.11/B.12 Tiling and Progression

## Purpose
Validate packet traversal across tiles/tile-parts and progression orders (including POC override).

## Normative References
- T.800-2015 B.11
- T.800-2015 B.12
- T.800-2015 A.6.6 (POC)

## Direct Citation
- B.11 (line 4370):
> "Each coded tile is represented by a sequence of packets."
- B.11 (line 4370):
> "The rules governing the order ... is specified in B.12."
- B.12.1.1 (line 4424):
> "Layer-resolution level-component-position progression is defined ..."
- A.6.6 (line 2008):
> "Progression order change (POC)"
- A.6.6 (line 2015):
> "Tile-part POC > Main POC > Tile-part COD > Main COD"

Interpretation:
- Packet ordering must be derived from B.12 loops with POC precedence.
- Multi-tile streams must not be decoded with single-tile assumptions.

## Decoder Invariants
- Tile-part boundaries are honored before packet-order loops.
- LRCP/RLCP/RPCL/PCRL/CPRL loops are implemented per B.12.
- POC precedence follows A.6.6.

## Observed Failures
- `b1_mono.j2c`
- `g1_colr.j2c`
- `p0_03.j2k`
- `p0_07.j2k`
- `p0_15.j2k`
- `p1_04.j2k`
- `p1_07.j2k`

## Planned Fixes
- `internal/decoder/jpeg2000_decode_samples_annex_b10_multi_layer.mbt`
- `internal/decoder/jpeg2000_decode_samples_ds_profile_api.mbt`

## Acceptance
- No progression-order-dependent mismatch on the listed fixtures.
