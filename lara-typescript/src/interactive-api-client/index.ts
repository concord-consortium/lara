export * from "./types";
export * from "./metadata-types";
export * from "./in-frame";
export * from "./api";
export * from "./hooks";
export * from "./client";

import * as packageJson from "./package.json";

const version = packageJson.version;

const warningMsg = (loadedVersion: string, newVersion: string) => `
LARA Interactive API is loaded multiple times. This will lead to unexpected behavior and might break multiple features
of the API (especially interactive state saving). Please ensure that the library is loaded only once by the main app
and that all its dependencies specify "lara-interactive-api" as "peerDependency" in their package.json files.

Already imported version: v${loadedVersion}, trying to load: v${newVersion}.
`;

if ((window as any).__LARA_INTERACTIVE_API__) {
  const msg = warningMsg((window as any).__LARA_INTERACTIVE_API__.version, version);
  window.alert(msg);
  throw new Error(msg);
} else {
  (window as any).__LARA_INTERACTIVE_API__ = {
    version: packageJson.version
  };
}
