import * as $ from "jquery";

export interface IPlugin {
  /** No special requirements for plugin class */
}

export type IPluginConstructor = new(runtimeContext: IRuntimeContext) => IPlugin;

export interface IRuntimeContext {
  /** Name of the plugin */
  name: string;
  /** Url from which the plugin was loaded. */
  url: string;
  /** Active record ID of the plugin scope id. */
  pluginId: string;
  /** Plugin learner state key. Is this necessary and what can that be used for? TDB. */
  pluginStateKey: string;
  /** The authored configuration for this instance. */
  authoredState: string;
  /** The saved learner data for this instance. */
  learnerState: string;
  /** Reserved HTMLElement for the plugin output. */
  div: HTMLElement;
  /** The run ID for the current run. */
  runID: number;
  /** The current users email address if available. */
  userEmail: string;
  /** The portal URL for class details (if available). */
  classInfoUrl: string;
  /** The portal remote endpoint (if available). */
  remoteEndpoint: string;
  /** Interactive state URL, available only when plugin is wrapping an interactive (empty string otherwise). */
  interactiveStateUrl: string;
  /** A function that returns the URL to use fetch a JWT. */
  getFirebaseJwtUrl: () => string;
  /** Wrapped embeddable container, available only when plugin is wrapping an interactive. */
  wrappedEmbeddableDiv: HTMLElement | undefined;
  /****************************************************************************
   When plugin is wrapping an embeddable, this field will contain its properties - serialized
   form of the embeddable, e.g.:
   ```
   {
     aspect_ratio_method: "DEFAULT",
     authored_state: null,
     click_to_play: false,
     enable_learner_state: true,
     name: "Test Interactive",
     native_height: 435,
     native_width: 576,
     url: "http://concord-consortium.github.io/lara-interactive-api/iframe.html",
     type: "MwInteractive",
     ref_id: "86-MwInteractive"
   }
   ```
   ****************************************************************************/
  wrappedEmbeddableContext: any | null;
  experimental: IRuntimeContextExperimentalFeatures;
}

export interface IRuntimeContextExperimentalFeatures {
  /** DOM id of click to play overlay if enabled. */
  clickToPlayId: string | null;
}

export interface IPluginStatePath {
  savePath: string;
  loadPath: string;
}

/****************************************************************************
 Module variables to keep track of our plugins. Exported only because some tests use them directly.
 These variables are not meant to be used by plugin developers.
 ****************************************************************************/
/** @hidden Note, we call these `classes` but any constructor function will do. */
export const pluginClasses: { [label: string]: IPluginConstructor } = {};
/** @hidden */
export const plugins: IPlugin[] = [];
/** @hidden */
export const pluginLabels: string[] = [];
/** @hidden */
export const pluginStatePaths: { [pluginId: string]: IPluginStatePath } = {};

const pluginError = (e: string, other: any) => {
  // tslint:disable-next-line:no-console
  console.group("LARA Plugin Error");
  // tslint:disable-next-line:no-console
  console.error(e);
  // tslint:disable-next-line:no-console
  console.dir(other);
  // tslint:disable-next-line:no-console
  console.groupEnd();
};

/****************************************************************************
 @hidden
 Note that this method is NOT meant to be called by plugins. It's used by LARA internals.
 This method is called to initialize the plugin.
 Called at runtime by LARA to create an instance of the plugin as would happen in `views/plugin/_show.html.haml`.
 @param label The the script identifier.
 @param runtimeContext Context for the plugin.
 @param pluginStatePath For saving & loading learner data.
 ****************************************************************************/
export const initPlugin = (label: string, runtimeContext: IRuntimeContext, pluginStatePath: IPluginStatePath) => {
  const constructor = pluginClasses[label];
  let plugin = null;
  if (typeof constructor === "function") {
    try {
      plugin = new constructor(runtimeContext);
      plugins.push(plugin);
      pluginLabels.push(label);
      pluginStatePaths[runtimeContext.pluginId] = pluginStatePath;
    } catch (e) {
      pluginError(e, runtimeContext);
    }
    // tslint:disable-next-line:no-console
    console.info("Plugin", label, "is now registered");
  } else {
    // tslint:disable-next-line:no-console
    console.error("No plugin registered for label:", label);
  }
};

/****************************************************************************
 Ask LARA to save the users state for the plugin.
 ```
 LARA.saveLearnerPluginState(pluginId, '{"one": 1}').then((data) => console.log(data))
 ```
 @param pluginId ID of the plugin trying to save data, initially passed to plugin constructor in the context.
 @param state A JSON string representing serialized plugin state.
 ****************************************************************************/
export const saveLearnerPluginState = (pluginId: string, state: any): Promise<string> => {
  const paths = pluginStatePaths[pluginId];
  if (paths && paths.savePath) {
    return new Promise((resolve, reject) => {
      $.ajax({
        url: paths.savePath,
        type: "PUT",
        data: { state },
        success(data) {
          resolve(data);
        },
        error(jqXHR, errText, err) {
          reject(err);
        }
      });
    });
  }
  const msg = "Not saved.`pluginStatePaths` missing for plugin ID:";
  // tslint:disable-next-line:no-console
  console.warn(msg, pluginId);
  return Promise.reject(msg);
};

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
  if (typeof _class !== "function") {
    // tslint:disable-next-line:no-console
    console.error("Plugin did not provide constructor", label);
    return false;
  }
  if (pluginClasses[label]) {
    // tslint:disable-next-line:no-console
    console.error("Duplicate Plugin for label", label);
    return false;
  } else {
    pluginClasses[label] = _class;
    return true;
  }
};
