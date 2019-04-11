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
  /** The authored configuration for this instance. */
  authoredState: string;
  /** The saved learner data for this instance. */
  learnerState: string;
  /** Reserved HTMLElement for the plugin output. */
  div: HTMLElement;
  /** The run ID for the current run. */
  runId: number;
  /** The current users email address if available. */
  userEmail: string;
  /** The portal remote endpoint (if available). */
  remoteEndpoint: string;
  /** Function that returns JWT (Promise) for given app name. */
  getFirebaseJwt: (appName: string) => Promise<IJwtResponse>;
  /** Function that returns class details (Promise) or null if class info is not available. */
  getClassInfo: () => Promise<IClassInfo> | null;
  /** Function that returns interactive state (Promise) or null if plugin is not wrapping an interactive. */
  getInteractiveState: () => Promise<IInteractiveState> | null;
  /**
   * Function that returns reporting URL (Promise) or null if plugin is not wrapping an interactive or
   * reporting URL is not defined.
   */
  getReportingUrl: () => Promise<string | null> | null;
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

export interface IPortalClaims {
  user_type: "learner" | "teacher";
  user_id: string;
  class_hash: string;
  offering_id: number;
}

export interface IJwtClaims {
  domain: string;
  returnUrl: string;
  externalId: number;
  class_info_url: string;
  claims: IPortalClaims;
}

export interface IJwtResponse {
  token: string;
  claims: IJwtClaims | {};
}

export interface IUser {
  id: string; // path
  first_name: string;
  last_name: string;
}

export interface IOffering {
  id: number;
  name: string;
  url: string;
}

export interface IClassInfo {
  id: number;
  uri: string;
  class_hash: string;
  teachers: IUser[];
  students: IUser[];
  offerings: IOffering[];
}

export interface IInteractiveState {
  id: number;
  key: string;
  raw_data: string;
  interactive_name: string;
  interactive_state_url: string;
  activity_name: string;
}
