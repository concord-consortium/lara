import "./plugin-api/normalize.scss";
import "@concord-consortium/slate-editor/build/index.css";

import * as PluginAPI from "./plugin-api";
import * as InteractiveAPI from "./interactive-api-parent";
import * as Plugins from "./plugins";
import * as Events from "./events";
import * as PageItemAuthoring from "./page-item-authoring";

export {
  PluginAPI as PluginAPI_V3,
  InteractiveAPI,
  Plugins,
  Events,
  PageItemAuthoring
};

// Note that LARA namespace is defined for the first time by V2 API. Once V2 is removed, this code should also be
// removed and "library": "LARA" option in webpack.config.js should be re-enabled.
(window as any).LARA.PluginAPI_V3 = PluginAPI;
(window as any).LARA.Plugins = Plugins;
(window as any).LARA.Events = Events;
(window as any).LARA.InteractiveAPI = InteractiveAPI;
(window as any).LARA.PageItemAuthoring = PageItemAuthoring;
