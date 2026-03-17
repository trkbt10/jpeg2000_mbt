# Spec Note: B.10 Packet Header Coding

## Purpose
Validate packet-header parsing and per-codeblock pass/length decoding for `decode_samples`.

## Normative References
- T.800-2015 B.10.1
- T.800-2015 B.10.5
- T.800-2015 B.10.6
- T.800-2015 B.10.7.2
- T.800-2015 B.10.8

## Direct Citation
- B.10.1 (line 4081):
> "Bits are packed into bytes from the MSB to the LSB."
- B.10.1 (line 4081):
> "If the value of the byte is 0xFF, the next byte includes an extra zero bit stuffed"
- B.10.6 (line 4185):
> "The number of coding passes included in this packet ... is identified in the packet header"
- B.10.7.2 (line 4245):
> "Multiple codeword segments"
- B.10.8 (line 4262):
> "Order of information within packet header"

Interpretation:
- Parser must respect bit-stuffing and packet-header field order before codeword extraction.
- `num_passes` and segment lengths must match packet semantics for each code-block.

## Decoder Invariants
- Bit-stuffing is applied exactly as B.10.1 requires.
- `P` (zero bit-planes) and `num_passes` are parsed per code-block, not globally.
- Multi-segment length decoding follows B.10.7.2 ordering.
- Packet-header fields are consumed in B.10.8 order.

## Observed Failures
- `p0_02.j2k`
- `p1_01.j2k`
- `p1_02.j2k`
- `p1_03.j2k`
- `p1_05.j2k`
- `p1_06.j2k` (`skip_zero_recon`)

## Planned Fixes
- `internal/decoder/jpeg2000_decode_samples_annex_a8_packet_parts.mbt`
- `internal/decoder/jpeg2000_decode_samples_annex_b10_multi_layer.mbt` (`parse_layer_packet_header`)
- `internal/decoder/jpeg2000_decode_samples_ds_profile_api.mbt` (`decode_single_codeblock_coefficients`)

## Acceptance
- No malformed bit offset between packet header and codeword payload on target fixtures.
- `skip_zero_recon` does not arise from parser under-consumption for the listed fixtures.
