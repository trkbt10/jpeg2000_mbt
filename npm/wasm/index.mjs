import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const here = dirname(fileURLToPath(import.meta.url));
const wasmFile = join(here, "dist", "jpeg2000.wasm");
const manifestFile = join(here, "dist", "manifest.json");

export function wasmPath() {
  return wasmFile;
}

export function manifestPath() {
  return manifestFile;
}

export async function wasmBytes() {
  return readFile(wasmFile);
}

export async function instantiate(imports = {}) {
  const bytes = await wasmBytes();
  return WebAssembly.instantiate(bytes, imports);
}
