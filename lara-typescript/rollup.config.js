import dts from "rollup-plugin-dts";

// Rollup is used only to generate bundled .d.ts files.
// This is necessary, as some types are shared between separate NPM packages (plugin-api and interactive-api-client),
// so they need to be bundled into one file, following module resolution.
// Default typings created by TS compiler are created per-file and retain original directory structure. Imports
// are not resolved. So, when plugin-api or interactive-api-client NPM packages import some files from the
// parent folder, these files were not getting published to NPM and package was half-broken.
// See: https://www.pivotaltracker.com/story/show/176518974

// Why rollup when we already have webpack?
// There are few tools to generate bundled .d.ts, but all of them had some problems:
// - Webpack plugins didn't seem production ready or had issues with TS lazy imports.
// - API Extractor and dts-bundle-generator also don't support TS lazy imports
//   (https://github.com/microsoft/rushstack/issues/2140).
// rollup-plugin-dts seemed like the only tool that handled correctly both plugin-api and interactive-api-client.
const config = [
  {
    input: "./dist/plugin-api/index.d.ts",
    output: [{ file: "./dist/plugin-api/index-bundle.d.ts", format: "es" }],
    plugins: [dts()],
  },
  {
    input: "./dist/interactive-api-client/index.d.ts",
    output: [{ file: "./dist/interactive-api-client/index-bundle.d.ts", format: "es" }],
    plugins: [dts()],
  },
  {
    input: "./dist/interactive-api-host/index.d.ts",
    output: [{ file: "./dist/interactive-api-host/index-bundle.d.ts", format: "es" }],
    plugins: [dts()],
  },
];

export default config;
