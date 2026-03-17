# Spec Note: E.1 + F (Irreversible 9/7 Path)

## Purpose
Validate irreversible pipeline: inverse quantization and inverse 9/7 DWT.

## Normative References
- T.800-2015 E.1
- T.800-2015 F.3.6

## Direct Citation
- E.1 (line 6310):
> "Inverse quantization procedure"
- E.1 (line 6310):
> "For each transform coefficient ..."
- F.3.6 (line 6880):
> "The 1D_SR procedure"
- F.3.6 (line 6880):
> "produces as output an array X"

Interpretation:
- 9/7 path must apply E.1 dequantization before inverse transform stages.
- Subband gains, step sizes, and scaling must be coherent with F lifting steps.

## Decoder Invariants
- QCD/QCC-derived step size extraction is correct for qstyle 1/2.
- Dequantization is applied before 9/7 inverse transform.
- 9/7 inverse transform uses consistent scaling and boundary handling.

## Observed Failures
- `p0_04.j2k`
- `p0_05.j2k`
- `p0_06.j2k`
- `p1_02.j2k`
- `p1_03.j2k`
- `p1_05.j2k`
- `p1_06.j2k` (`skip_zero_recon`)
- `p1_04.j2k`

## Planned Fixes
- `internal/decoder/jpeg2000_decode_samples_annex_e_dequant.mbt` (`dequantize_coefficients`)
- `internal/decoder/jpeg2000_decode_samples_annex_f_dwt.mbt` (`apply_inverse_dwt_97`, `apply_inverse_dwt`)
- `internal/decoder/jpeg2000_decode_samples_ds_profile_api.mbt` (`qcd_subband_max_bit_planes`)

## Acceptance
- 9/7 fixtures no longer collapse to zero-recon due to path logic.
- At least one currently failing 9/7 fixture transitions to pass_real_match.
