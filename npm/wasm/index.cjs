const fs = require("node:fs/promises");
const path = require("node:path");

const wasmFile = path.join(__dirname, "dist", "jpeg2000.wasm");
const manifestFile = path.join(__dirname, "dist", "manifest.json");

function wasmPath() {
  return wasmFile;
}

function manifestPath() {
  return manifestFile;
}

async function wasmBytes() {
  return fs.readFile(wasmFile);
}

async function instantiate(imports = {}) {
  const bytes = await wasmBytes();
  return WebAssembly.instantiate(bytes, imports);
}

module.exports = {
  wasmPath,
  manifestPath,
  wasmBytes,
  instantiate,
};
