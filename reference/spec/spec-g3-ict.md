# Spec Note: G.3 Irreversible MCT (ICT)

## Purpose
Validate irreversible color transform path (ICT) for 9/7 + MCT codestreams.

## Normative References
- T.800-2015 G.3

## Direct Citation
- G.3 (line 7631):
> "Irreversible multiple component transformation (ICT)"
- G.3 (line 7631):
> "The ICT shall be used only with the 9-7 irreversible filter."
- G.3 (line 7631):
> "applied to the first three components"

Interpretation:
- ICT dispatch is conditional on transform signaling and component topology.
- Component length/grid consistency must be enforced before transform.

## Decoder Invariants
- ICT path only when irreversible transform is signaled.
- First three components are transformed with aligned sample lengths.
- Invalid component-length combinations fail-fast.

## Observed Failures
- `g1_colr.j2c`
- `p0_04.j2k`
- `p0_05.j2k`
- `p1_02.j2k`
- `p1_03.j2k`
- `p1_05.j2k`

## Planned Fixes
- `internal/decoder/jpeg2000_decode_samples_annex_g_mct.mbt` (`tier1_annex_g_inverse_ict_components`)
- `internal/decoder/jpeg2000_decode_samples_ds_profile_api.mbt` (MCT dispatch in DWT decode path)

## Acceptance
- ICT-enabled fixtures preserve component alignment and improve byte-compare outcomes.
