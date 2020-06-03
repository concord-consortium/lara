import { registerPlugin as _registerPlugin } from "../plugins/plugins";
import { IRegisterPluginOptions } from "./types";

/****************************************************************************
 Register a new external script
 ```
 registerPlugin({runtimeClass: DebuggerRuntime, authoringClass: DebuggerAuthoring})
 ```
 @param options The registration options
 @returns `true` if plugin was registered correctly.
 ***************************************************************************/
export const registerPlugin = (options: IRegisterPluginOptions): boolean => {
  return _registerPlugin(options);
};
