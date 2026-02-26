# @trkbt10/jpeg2000-wasm

WASM artifact package for `trkbt10/jpeg2000`.

## Build

From repository root:

```bash
./tools/export_wasm_npm_package.sh
```

Or from this package:

```bash
npm run build
```

## Exports

- `wasmPath()` - absolute path to `dist/jpeg2000.wasm`
- `manifestPath()` - absolute path to `dist/manifest.json`
- `wasmBytes()` - reads wasm bytes
- `instantiate(imports)` - thin helper around `WebAssembly.instantiate`

## Notes

- This package distributes the compiled wasm artifact.
- Stable public library API for MoonBit users is provided by mooncakes package
  `trkbt10/jpeg2000`.
