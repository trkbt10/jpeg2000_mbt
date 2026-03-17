# JPEG2000 Specification Coverage Matrix

Updated: 2026-02-28

Policy: [reference/project-policy.md](project-policy.md)

## Evaluation Axes (T.800-2015)

| Axis | Values in corpus | T.800 Reference |
|------|-----------------|-----------------|
| DWT | 5/3 (reversible), 9/7 (irreversible) | Annex F |
| Bit depth | 4, 8, 12 | A.5.1 ([spec](spec/spec-e1-f-irreversible-path.md)) (SIZ) |
| Signed | unsigned, signed | A.5.1 ([spec](spec/spec-e1-f-irreversible-path.md)) (SIZ) |
| Tiles | 1, 2, 4, 15, 16, 64, 225, 256 | A.4.1 (SIZ) |
| Components | 1, 2, 3, 4, 257 | A.5.1 ([spec](spec/spec-e1-f-irreversible-path.md)) (SIZ) |
| Progression | LRCP, RLCP, RPCL, PCRL, CPRL | A.6.1 (COD) |
| SOP/EPH | -, SOP, EPH, SOP+EPH | A.6.1 (COD) |
| Code-block style | BYPASS, RESET, TERMALL, VSC, CAUSAL, SEGSYM | A.6.1 (COD) |
| Quantization | reversible (0), derived (1), expounded (2) | A.6.4 (QCD) |
| ROI | roishift=0 (none), 11 | A.6.2 (RGN) |
| Layers | 1-30 | A.6.1 (COD) |
| MCT | 0 (none), 1 (RCT/ICT) | A.6.1 (COD) |

## Corpus Fixture Matrix

| Fixture | Size | Bits | DWT | Nres | Comp | Tiles | CB Size | CB Flags | Prog | Layers | MCT | SOP/EPH | ROI | Qnt | Status |
|---------|------|------|-----|------|------|-------|---------|----------|------|--------|-----|---------|-----|-----|--------|
| p0_01 | 128x128 | 8u | 5/3 | 4 | 1 | 1 | 64x64 | - | RLCP | 1 | - | - | - | 0 | pass |
| p0_02 | 127x126 | 8u | 5/3 | 4 | 1 | 1 | 32x32 | TERMALL CAUSAL SEGSYM | LRCP | 6 | - | SOP+EPH | - | 0 | fail |
| p0_03 | 256x256 | 4s | 5/3 | 2 | 1 | 4(2x2) | 64x64 | - | PCRL | 8 | - | SOP | - | 0 | fail |
| p0_04 | 640x480 | 8u | 9/7 | 7 | 3 | 1 | 64x64 | TERMALL | RLCP | 20 | 1 | - | - | 2 | fail |
| p0_05 | 1024x1024 | 8u | 9/7 | 7 | 4 | 1 | 32x32 | - | PCRL | 7 | - | - | - | 1 | fail |
| p0_06 | 513x129 | 12u | 9/7 | 7 | 4 | 1 | 64x64 | - | RPCL | 4 | - | - | 11 | 2 | fail |
| p0_07 | 2048x2048 | 12s | 5/3 | 4 | 3 | 256(16x16) | 64x64 | - | RLCP | 8 | - | SOP+EPH | - | 0 | fail |
| p0_08 | 513x3072 | 12s | 5/3 | 7 | 3 | 1 | 64x64 | - | CPRL | 30 | - | SOP+EPH | - | 0 | fail |
| p0_09 | 17x37 | 8u | 9/7 | 6 | 1 | 1 | 64x64 | - | LRCP | 1 | - | - | - | 2 | fail |
| p0_10 | 256x256 | 8u | 5/3 | 4 | 3 | 4(2x2) | 64x64 | - | LRCP | 2 | 1 | - | - | 0 | fail |
| p0_11 | 128x1 | 8u | 5/3 | 1 | 1 | 1 | 64x64 | SEGSYM | LRCP | 1 | - | EPH | - | 0 | pass |
| p0_12 | 3x5 | 8u | 5/3 | 4 | 1 | 1 | 32x32 | TERMALL | LRCP | 1 | - | SOP | - | 0 | pass |
| p0_13 | 1x1 | 8u | 5/3 | 2 | 257 | 1 | 32x32 | CAUSAL | RLCP | 1 | 1 | - | - | 0 | pass |
| p0_14 | 49x49 | 8u | 5/3 | 6 | 3 | 1 | 64x64 | - | LRCP | 1 | 1 | - | - | 0 | pass |
| p0_15 | 256x256 | 4s | 5/3 | 2 | 1 | 4(2x2) | 64x64 | - | PCRL | 8 | - | SOP | - | 0 | fail |
| p0_16 | 128x128 | 8u | 5/3 | 4 | 1 | 1 | 64x64 | - | RLCP | 3 | - | - | - | 0 | pass |
| p1_01 | 127x227 | 8u | 5/3 | 4 | 1 | 1 | 32x32 | TERMALL CAUSAL SEGSYM | LRCP | 5 | - | SOP+EPH | - | 0 | fail |
| p1_02 | 640x480 | 8u | 9/7 | 7 | 3 | 1 | 64x64 | RESET VSC | LRCP | 19 | 1 | - | - | 2 | skip |
| p1_03 | 1024x1024 | 8u | 9/7 | 7 | 4 | 1 | 32x32 | BYPASS TERMALL | PCRL | 10 | - | - | - | 1 | skip |
| p1_04 | 1024x1024 | 12u | 9/7 | 4 | 1 | 64(8x8) | 64x64 | - | LRCP | 1 | - | - | - | 2 | fail |
| p1_05 | 529x524 | 8u | 9/7 | 8 | 3 | 225(15x15) | 8x64 | BYPASS VSC CAUSAL | PCRL | 2 | 1 | SOP+EPH | - | 2 | skip |
| p1_06 | 12x12 | 8u | 9/7 | 5 | 3 | 16(4x4) | 64x32 | VSC SEGSYM | PCRL | 1 | 1 | SOP+EPH | - | 2 | skip |
| p1_07 | 12x12 | 8u | 5/3 | 2 | 2 | 1 | 64x64 | - | RPCL | 1 | - | SOP+EPH | - | 0 | fail |
| a1_mono | 303x179 | 8u | 5/3 | 6 | 1 | 1 | 64x64 | - | LRCP | 1 | - | - | - | 0 | pass |
| a2_colr | 256x149 | 8u | 5/3 | 6 | 3 | 1 | 64x64 | - | LRCP | 1 | 1 | - | - | 0 | pass |
| b1_mono | 3400x220 | 8u | 5/3 | 6 | 1 | 15(5x3) | 64x64 | - | LRCP | 1 | - | - | - | 0 | fail |
| g1_colr | 256x149 | 8u | 5/3 | 6 | 3 | 2(1x2) | 64x64 | - | LRCP | 3 | 1 | - | - | 0 | fail |

Status: pass = pass_real_match, fail = fail_mismatch, skip = skip_zero_recon

## Axis Coverage Summary

### DWT Type
| DWT | Total | Pass | Fail | Skip |
|-----|-------|------|------|------|
| 5/3 (reversible) | 18 | 8 | 10 | 0 |
| 9/7 (irreversible) | 9 | 0 | 5 | 4 |

### Bit Depth / Signedness
| Bits | Total | Pass | Fail | Skip |
|------|-------|------|------|------|
| 4s | 2 | 0 | 2 | 0 |
| 8u | 21 | 8 | 9 | 4 |
| 12u | 2 | 0 | 2 | 0 |
| 12s | 2 | 0 | 2 | 0 |

### Tile Count
| Tiles | Total | Pass | Fail | Skip |
|-------|-------|------|------|------|
| 1 | 18 | 8 | 8 | 2 |
| 2 | 1 | 0 | 1 | 0 |
| 4 | 3 | 0 | 3 | 0 |
| 15 | 1 | 0 | 1 | 0 |
| 16 | 1 | 0 | 0 | 1 |
| 64 | 1 | 0 | 1 | 0 |
| 225 | 1 | 0 | 0 | 1 |
| 256 | 1 | 0 | 1 | 0 |

### Component Count
| Comp | Total | Pass | Fail | Skip |
|------|-------|------|------|------|
| 1 | 12 | 5 | 7 | 0 |
| 2 | 1 | 0 | 1 | 0 |
| 3 | 10 | 2 | 5 | 3 |
| 4 | 3 | 0 | 2 | 1 |
| 257 | 1 | 1 | 0 | 0 |

### Progression Order
| Prog | Total | Pass | Fail | Skip |
|------|-------|------|------|------|
| LRCP | 13 | 5 | 6 | 2 |
| RLCP | 5 | 3 | 2 | 0 |
| RPCL | 2 | 0 | 2 | 0 |
| PCRL | 6 | 0 | 3 | 3 |
| CPRL | 1 | 0 | 1 | 0 |

### SOP/EPH
| Markers | Total | Pass | Fail | Skip |
|---------|-------|------|------|------|
| - | 16 | 6 | 8 | 2 |
| SOP | 3 | 1 | 2 | 0 |
| EPH | 1 | 1 | 0 | 0 |
| SOP+EPH | 7 | 0 | 5 | 2 |

### Code-block Style Flags
| Flag | Total | Pass | Fail | Skip |
|------|-------|------|------|------|
| BYPASS | 2 | 0 | 0 | 2 |
| RESET | 1 | 0 | 0 | 1 |
| TERMALL | 5 | 1 | 3 | 1 |
| VSC | 3 | 0 | 0 | 3 |
| CAUSAL | 4 | 1 | 2 | 1 |
| SEGSYM | 4 | 1 | 2 | 1 |

### Quantization Style
| Qnt | Total | Pass | Fail | Skip |
|-----|-------|------|------|------|
| 0 (reversible) | 18 | 8 | 10 | 0 |
| 1 (derived) | 2 | 0 | 1 | 1 |
| 2 (expounded) | 7 | 0 | 4 | 3 |

### Blockers: What prevents fail fixtures from passing

| Blocker | Fixtures | T.800 Reference |
|---------|----------|-----------------|
| Multi-tile support | p0_03, p0_07, p0_10, p0_15, b1_mono, g1_colr, p1_04 | A.4.1, A.3.2 ([spec](spec/spec-b11-b12-tiling-progression.md)) |
| 9/7 irreversible DWT | p0_04, p0_05, p0_06, p0_09 | Annex F.3.5 ([spec](spec/spec-e1-f-irreversible-path.md)) |
| Multi-layer + code-block flags | p0_02, p1_01 | B.9-B.11 ([spec](spec/spec-b10-packet-header.md), [spec](spec/spec-c3-mq-decoder.md)) |
| 12-bit / signed precision | p0_06, p0_07, p0_08, p1_04 | A.5.1 ([spec](spec/spec-e1-f-irreversible-path.md)) |
| Single-tile decode accuracy | p1_07 | Annex F |
