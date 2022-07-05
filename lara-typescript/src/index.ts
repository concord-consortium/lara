import "./plugin-api/normalize.scss";

import * as PluginAPI from "./plugin-api";
import * as InteractiveAPI from "./interactive-api-lara-host";
import * as Plugins from "./plugins";
import * as Events from "./events";
import * as PageHeader from "./section-authoring/components/page-header";
import * as PageItemAuthoring from "./page-item-authoring";
import * as SectionAuthoring from "./section-authoring";
import * as Projects from "./projects";

export interface LaraGlobalType {
  PluginAPI_V3: typeof PluginAPI;
  Plugins: typeof Plugins;
  Events: typeof Events;
}

export {
  PluginAPI as PluginAPI_V3,
  InteractiveAPI,
  Plugins,
  Events,
  PageHeader,
  PageItemAuthoring,
  SectionAuthoring,
  Projects
};

// Note that LARA namespace is defined for the first time by V2 API. Once V2 is removed, this code should also be
// removed and "library": "LARA" option in webpack.config.js should be re-enabled.
(window as any).LARA || ((window as any).LARA = {});  // create if it doesn't exist
(window as any).LARA.PluginAPI_V3 = PluginAPI;
(window as any).LARA.Plugins = Plugins;
(window as any).LARA.Events = Events;
(window as any).LARA.PageHeader = PageHeader;
(window as any).LARA.InteractiveAPI = InteractiveAPI;
(window as any).LARA.PageItemAuthoring = PageItemAuthoring;
(window as any).LARA.SectionAuthoring = SectionAuthoring;
(window as any).LARA.Projects = Projects;

// for clients that don't require LARA to be a global on window
export function initializeLara(): LaraGlobalType {
  return (window as any).LARA;
}
