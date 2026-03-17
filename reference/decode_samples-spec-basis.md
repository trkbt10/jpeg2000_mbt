# JPEG 2000 decode_samples spec basis (T.800-2015)

This note maps current `decode_samples` behavior to normative structure in
`reference/T.800-2015.txt`.

## Decision IDs (decode path)

- `DS-INPUT-RAW-JP2`: decode input accepts raw codestream or JP2 `jp2c`.
  - Basis: Annex A marker framing (`SOC`/`EOC`), Annex I JP2 box model.
- `DS-SOD-REQUIRED`: decode path requires `SOD` packet payload presence.
  - Basis: Annex A.4 tile-part + `SOD` structure.
- `DS-SIMPLE-PROFILE-GATE`: simple-profile branch is a constrained
  implementation subset, not a general JPEG2000 claim.
  - Basis: staged implementation policy (project-level).
- `DS-SIMPLE-PROFILE-MULTI-TILE`: simple-profile staged branch allows
  multi-tile streams when other profile constraints hold, consuming available
  SOD payloads in codestream order.
  - Basis: Annex A.4 tile-part structure + B.10 packet order per tile-part.
- `DS-SOP-EPH-STRIP`: in-bitstream `SOP/EPH` are signalling markers and are
  removed before packet-header/codeword byte interpretation.
  - Basis: A.8.1 (SOP), A.8.2 (EPH).
- `DS-TIER2-SPEC-SHAPE-CANDIDATES`: first-packet in-band extraction fallback
  is limited to packet-header shapes derived from `SIZ/COD` (component
  dimensions, decomposition level, code-block exponents), and does not use
  broad brute-force shape search.
  - Basis: Annex B packet header + Annex A.5 coding style parameters.
- `DS-TIER2-CODEBLOCK-STYLE-SEGMENTS`: packet-header segment length decoding in
  decoder path now consumes style-aware core API
  (`parse_packet_header_first_packet_with_code_blocks_and_style`), and applies
  `code_block_style` (currently TERMALL split handling) when interpreting
  code-block segment length fields.
  - Basis: Annex A.6 code-block style influence on packet header coding.
- `DS-ZERO-PACKET-RECON`: zero-length/empty effective packet codeword path
  reconstructs deterministic all-zero samples for the computed sample count.
  - Basis: deterministic staged decode policy in constrained profile.
- `DS-TIER1-PENDING`: non-zero/general codeword Tier-1 decode remains pending
  and returns explicit diagnostics.
  - Basis: staged implementation policy with explicit non-support.
- `DS-TIER1-REV-SUBSET-GATE`: non-zero codeword decode path is currently gated
  to the staged subset:
  - `code-block-style subset of {TERMALL,RESET,SEGMARK}`
  - `transformation=1` with `qstyle in {0,1}` or
    `transformation=0` with `qstyle in {0,2}`
  and otherwise returns
  explicit diagnostics.
  - Basis: staged implementation policy for Step 1 scope isolation.
- `DS-TIER1-STAGED-PREVIEW-STYLES`: staged sample reconstruction
  (`sample_count==1` / small-row preview `Ok(...)`) currently supports
  `code-block-style subset of {TERMALL,RESET,SEGMARK}`.
  - Basis: staged correctness policy with TERMALL segment-aware packet-header
    decode connected to Tier-1 preview path.
- `DS-TIER1-STAGED-PREVIEW-FULL-GRID`: staged mini-block preview path now
  operates on full component grid dimensions (no `w*h<=16` limiter) when
  SIZ-derived dimensions match sample count.
  - Basis: Annex D.3 pass processing is defined over coefficient grids.
- `DS-TIER1-STAGED-IRREV-BRIDGE`: staged Tier-1 gate additionally allows
  `transformation=0` with `qstyle in {0,2}` and
  `transformation=1` with `qstyle=1` as implementation bridge paths.
  - Basis: A.6.1 Table A.20 (irreversible transform) + QCD quantization style
    signalling (A.6.4 / E.1), under staged non-final reconstruction policy.
- `DS-TIER1-MQ-PENDING`: for reversible subset inputs, Annex C bootstrap
  metadata (`A/C` initial state seed) is computed and explicit pending is
  returned until full MQ/pass decode lands.
  - Basis: staged implementation policy for Step 1-b.
- `DS-TIER1-MQ-CONTEXT-STATE`: Annex C context state reset/save/restore is
  wired in decode path before MQ decision decode.
  - Basis: Annex C.3.6/C.3.7 staged implementation.
- `DS-TIER1-MQ-DECISION-PROBE`: a deterministic one-decision probe is wired
  from bootstrap code-register seed and default context 0, to validate decode
  path plumbing before full DECODE/RENORMD/BYTEIN landing.
  - Basis: staged implementation policy for Step 1-b.2 bootstrap.
- `DS-TIER1-MQ-MIN-DECODE`: minimal Annex C decode plumbing (`INITDEC` seed,
  `BYTEIN`, `RENORMD`, single `DECODE` decision) is now wired for one decision.
  - Basis: Annex C.3.2/C.3.4/C.3.5 staged implementation.
- `DS-TIER1-MQ-TABLE-C2`: Annex C Table C.2 (`Qe/NMPS/NLPS/SWITCH`) is now
  wired in the one-decision path.
  - Basis: Annex C.2.5 probability estimation table.
- `DS-TIER1-MQ-MULTI-DECISION-TRACE`: single-coeff pass-synchronized
  multi-decision trace is wired (cleanup/sigprop/magref context families) to
  validate repeated DECODE integration.
  - Basis: staged implementation policy for Step 1-b.2.3 bootstrap.
- `DS-TIER1-SIGN-CONTEXT-SPLIT`: single-coeff pass-synchronized trace uses
  dedicated sign-side context families for cleanup/sigprop sign decisions.
  - Basis: staged approximation of Annex D sign-coding context separation.
- `DS-TIER1-PASS-TRACE`: staged Annex D.3 pass-order trace is wired
  (`cleanup/sigprop/magref`) to validate pass scheduling integration points.
  - Basis: staged implementation policy for Step 1-b.2.3.
- `DS-TIER1-PASS-STATE`: staged pass-state accumulator is wired from pass trace
  + MQ decision bits to validate minimal pass-state integration points.
  - Basis: staged implementation policy for Step 1-b.2.3.
- `DS-TIER1-PASS-PRIMITIVES`: staged single-coefficient pass primitives
  (`cleanup/sigprop/magref`) are wired and composed in pass-state update.
  - Basis: staged implementation policy for Step 1-b.2.3.
- `DS-TIER1-PASS-NORM-PREVIEW`: single-coefficient normative preview is wired
  for sigprop condition (`has significant neighbor`) and reported alongside
  staged pass-state.
  - Basis: Annex D.3.1 condition alignment (staged preview).
- `DS-TIER1-PASS-NORM-PRIMARY`: pass-state diagnostics now use normative
  preview as primary value, with staged legacy value reported for drift checks.
  - Basis: staged migration policy toward Annex D normative logic.
- `DS-TIER1-COEFF-PREVIEW`: single-coefficient reconstructed value preview is
  reported from normative pass-state.
  - Basis: staged integration policy toward sample-domain reconstruction.
- `DS-TIER1-SINGLE-SAMPLE-RECON`: for `sample_count==1` under the reversible
  minimal subset, the reconstructed single coefficient is emitted as actual
  sample bytes (`Ok(...)`) in little-endian contract form.
  - Basis: staged end-to-end integration milestone for Step 1.
- `DS-UNSIGNED-SAMPLE-CLAMP`: unsigned sample output clamps negative preview
  values to `0` before byte serialization.
  - Basis: API contract consistency for unsigned sample domain.
- `DS-TIER1-SMALL-SAMPLE-ROW-RECON`: for small sample counts (`2..16`) under
  the reversible minimal subset, staged preview sample values are emitted as
  actual sample bytes (`Ok(...)`) in little-endian contract form.
  - Basis: staged end-to-end integration milestone for Step 1.
- `DS-TIER1-MINI-BLOCK-NORM-PREVIEW`: a minimal normative mini-block pass
  preview (full component grid) with cleanup/sigprop/magref + neighbor gating
  is wired, and staged decode path can consume this preview when SIZ dimensions
  match sample count.
  - Basis: staged Annex D block-level expansion for Step 1-b.2.3.
- `DS-TIER1-MINI-BLOCK-MQ-CONTEXTS`: mini-block MQ decision trace now uses
  neighbor-category context families (none/few/many + sign-side contexts) for
  cleanup/sigprop/magref staged integration.
  - Basis: staged Annex C/D context-selection refinement.
- `DS-TIER1-MINI-BLOCK-SIGN-PATTERN-CONTEXTS`: mini-block sign decisions now
  select sign-side context families by neighbor sign pattern
  (pos-dominant/neg-dominant/mixed-or-none).
  - Basis: staged Annex C/D sign-context refinement.
- `DS-TIER1-MINI-BLOCK-SIGN-WEIGHTING`: neighbor sign pattern uses weighted
  accumulation (orthogonal neighbors weighted higher than diagonal) before
  selecting sign-side context families.
  - Basis: staged directional-context refinement policy.
- `DS-TIER1-MINI-BLOCK-SIGN-WEIGHT-PROFILES`: sign weighting is pass-specific:
  cleanup and sigprop use separate weight profiles.
  - Basis: staged pass-kind-sensitive context refinement.
- `DS-TIER1-MINI-BLOCK-SIGN-CONTEXT-THRESHOLDS`: sign-side context selection
  thresholds are pass-specific (cleanup and sigprop may map the same score to
  different sign contexts).
  - Basis: staged pass-kind-sensitive sign-context policy.
- `DS-TIER1-MINI-BLOCK-SIGN-ADAPTIVE-THRESHOLDS`: sign-side threshold itself is
  adaptive to significant-neighbor count (higher neighbor density requires
  stronger score to choose pos/neg over mixed).
  - Basis: staged neighbor-density-sensitive sign-context policy.
- `DS-TIER1-MINI-BLOCK-SIGN-TABLE-LOOKUP`: sign-side context selection is now
  modeled as a two-axis lookup table
  (neighbor-density bucket × sign-bias bucket), with pass-specific tables.
  - Basis: staged table-driven context-policy refinement.
- `DS-TIER1-MINI-BLOCK-SIG-TABLE-LOOKUP`: significance-side context selection
  is also modeled as a two-axis lookup table
  (neighbor-density bucket × sign-bias bucket), with pass-specific tables.
  - Basis: staged table-driven context-policy refinement.
- `DS-NON-SIMPLE-PROFILE-REPORT`: non-simple-profile inputs currently return a
  structured "not implemented yet" reason including key COD/SIZ fields.
  - Basis: staged implementation policy with explicit scope boundary.
- `DS-CSIZ-SCOPE`: staged decode accepts `Csiz>1` with
  `COD multiple_component_transform in {0,1}` and currently reconstructs
  through the staged component-0 bridge path (output contract is
  component-0 sample domain, not all-component interleaved samples).
  - Basis: staged implementation policy and correctness-over-partial-output.

## Input forms

- Raw codestream accepted.
  - Basis: codestream starts at SOC and ends at EOC.
  - See: Table A.2 marker list (`SOC 0xFF4F`, `EOC 0xFFD9`) around lines 1007-1010.
- JP2-wrapped codestream accepted via `jp2c` extraction.
  - Basis: JP2 file format and defined boxes.
  - See: Annex I intro and defined boxes (TOC lines 231-236).

## Packet/header location rules

- Packet headers can be in exactly one place: in codestream, or PPM, or PPT.
  - See: A.7.4/A.7.5 around lines 2288-2293 and 2337-2342.
- SOP/EPH marker usage depends on COD signaling and packet-header placement.
  - See: A.8.1 around lines 2384-2389.
  - See: A.8.2 around lines 2413-2419.
- For decode-path packet analysis, SOP/EPH are treated as signalling markers and
  excluded from packet header/codeword byte interpretation.
  - Implementation: `strip_in_bitstream_markers_for_simple_profile`.

## Current implementation stance

- `decode_samples` currently supports a narrow simple-profile path and
  deterministic zero reconstruction for constrained packet/codeword cases.
- Tier-2 first-packet in-band extraction now prefers single-codeblock parse and
  then tries only spec-derived shape candidates (`SIZ/COD` derived); broad
  non-normative shape fallback is not used.
- For non-zero codeword paths, minimal reversible subset gating is enforced
  before Tier-1 decode work proceeds.
- Within that subset, Annex C bootstrap is now wired and reported, but MQ
  decision decode itself remains pending.
- Annex C context state lifecycle (reset/save/restore) is wired and covered by
  whitebox tests.
- A one-decision probe is wired and reported, but normative MQ decision decode
  is still partial:
  - one-decision path now uses Table C.2 transitions/Qe values
  - minimal multi-decision trace is wired
  - staged pass-order trace is wired
  - staged pass-state accumulator is wired
  - staged pass primitives are wired and tested
  - single-coeff pass core is integrated (cleanup/sigprop/magref loop unified)
    with sigprop-neighbor policy switching
  - staged normative preview (sigprop condition) is wired
  - normative pass-state is primary in diagnostics, staged is shadow output
  - single-coeff value preview is wired from normative pass-state
  - single-sample (`sample_count==1`) path now returns `Ok(...)` from coeff
    preview value
  - small sample-row (`sample_count<=16`) path now returns staged preview row
    as `Ok(...)`
  - full tier-1 pass integration remains pending.
- For general Tier-1 codeword decode, implementation is pending and returns
  explicit `Err(...)` diagnostics.
- This is consistent with staged implementation while preserving parser
  conformance and deterministic behavior.

## Fallback policy note

- No JPEG2000-level normative basis was found for a "loose leading-bit fallback"
  as part of valid packet syntax interpretation.
- Therefore, fallback behavior should be treated as non-normative compatibility
  mode only, and isolated from strict/spec-based decode behavior.
