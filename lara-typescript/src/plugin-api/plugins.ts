import { IPluginConstructor } from "./types";
import { registerPlugin as _registerPlugin } from "../lib/plugins";

/****************************************************************************
 Register a new external script as `label` with `_class `, e.g.:
 ```
 registerPlugin('debugger', Dubugger)
 ```
 @param label The identifier of the script.
 @param _class The Plugin class/constructor being associated with the identifier.
 @returns `true` if plugin was registered correctly.
 ***************************************************************************/
export const registerPlugin = (label: string, _class: IPluginConstructor): boolean => {
  return _registerPlugin(label, _class);
};
