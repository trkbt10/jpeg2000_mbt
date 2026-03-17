# T.800-2015 (JPEG 2000 Core Coding System) - Sectioned Reference

This directory contains the ITU-T T.800 (11/2015) specification split into logical sections for easier reference.

## File Structure

| File | Section | Description | Lines |
|------|---------|-------------|-------|
| `00_frontmatter.txt` | — | Title page, TOC, recommendations | 288 |
| `01_scope.txt` | 1 | Scope | 15 |
| `02_references.txt` | 2 | Normative references | 55 |
| `03_definitions.txt` | 3 | Definitions | 225 |
| `04_abbreviations.txt` | 4 | Abbreviations and symbols | 90 |
| `05_general_description.txt` | 5 | General description | 151 |
| `06_encoder_requirements.txt` | 6 | Encoder requirements | 8 |
| `07_decoder_requirements.txt` | 7 | Decoder requirements | 27 |
| `08_implementation_requirements.txt` | 8 | Implementation requirements | 10 |

## Annexes (Normative)

| File | Annex | Description | Lines |
|------|-------|-------------|-------|
| `annex_a_codestream_syntax.txt` | A | Codestream syntax (markers, SIZ, COD, QCD, etc.) | 2462 |
| `annex_b_image_data_ordering.txt` | B | Image and compressed data ordering (tiles, packets, tag trees) | 1301 |
| `annex_c_arithmetic_coding.txt` | C | Arithmetic entropy coding (MQ coder) | 1067 |
| `annex_d_coefficient_bit_modelling.txt` | D | Coefficient bit modelling (T1 contexts, coding passes) | 598 |
| `annex_e_quantization.txt` | E | Quantization | 153 |
| `annex_f_dwt.txt` | F | Discrete wavelet transformation (5/3, 9/7) | 1070 |
| `annex_g_mct.txt` | G | DC level shifting and MCT (RCT, ICT) | 155 |
| `annex_h_roi.txt` | H | Coding of images with regions of interest | 213 |
| `annex_i_jp2_format.txt` | I | JP2 file format syntax | 1517 |
| `annex_j_examples.txt` | J | Examples and guidelines (informative) | 2811 |
| `annex_k_bibliography.txt` | K | Bibliography | 193 |
| `annex_l_patent.txt` | L | Patent statement | 21 |
| `annex_m_broadcast.txt` | M | Elementary stream for broadcast applications | 380 |

## Quick Reference by Topic

### Codestream Parsing
- **Markers**: `annex_a_codestream_syntax.txt` (A.1-A.4)
- **SIZ marker**: `annex_a_codestream_syntax.txt` (A.5)
- **COD/COC/QCD/QCC**: `annex_a_codestream_syntax.txt` (A.6)

### Decoding Pipeline
- **Packet structure**: `annex_b_image_data_ordering.txt` (B.9-B.12)
- **Tag trees**: `annex_b_image_data_ordering.txt` (B.10.2)
- **MQ decoder**: `annex_c_arithmetic_coding.txt` (C.1-C.3)
- **T1 (coefficient decoding)**: `annex_d_coefficient_bit_modelling.txt` (D.1-D.7)
- **Dequantization**: `annex_e_quantization.txt` (E.1)
- **IDWT (5/3 & 9/7)**: `annex_f_dwt.txt` (F.3-F.4)
- **MCT (RCT/ICT)**: `annex_g_mct.txt` (G.2-G.3)

### File Format
- **JP2 boxes**: `annex_i_jp2_format.txt` (I.4-I.7)

## Usage Notes

- Original source: `../T.800-2015.txt` (complete file, 12810 lines)
- Split based on section headers for targeted reading
- Section numbers (e.g., A.5.1) preserved within files
