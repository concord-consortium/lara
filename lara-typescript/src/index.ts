import * as PluginAPI from "./plugin-api";
import * as InternalAPI from "./internal-api";

export {
  PluginAPI as PluginAPI_V3,
  InternalAPI
};

// Note that LARA namespace is defined for the first time by V2 API. Once V2 is removed, this code should also be
// removed and "library": "LARA" option in webpack.config.js should be re-enabled.
(window as any).LARA.PluginAPI_V3 = PluginAPI;
(window as any).LARA.InternalAPI = InternalAPI;
