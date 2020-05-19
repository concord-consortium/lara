// the iframesaver messages are 1 per line to reduce merge conflicts as new ones are added
export type IFrameSaverClientMessage = "interactiveState" |
                                "height" |
                                "getAuthInfo" |
                                "supportedFeatures" |
                                "navigation" |
                                "getFirebaseJWT" |
                                "authoredState";

export type IframeSaverServerMessage = "authInfo" |
                                "getInteractiveState" |
                                "initInteractive" |
                                "firebaseJWT";

export type GlobalIFrameSaverClientMessage = "interactiveStateGlobal";
export type GlobalIFrameSaverServerMessage = "loadInteractiveGlobal";

export type IframePhoneServerMessage = "hello";

export type DeprecatedIFrameSaverClientMessage = "setLearnerUrl";
export type DeprecatedIFrameSaverServerMessage = "getLearnerUrl" | "loadInteractive";

export type ClientMessage = DeprecatedIFrameSaverClientMessage |
                            IFrameSaverClientMessage |
                            GlobalIFrameSaverClientMessage;

export type ServerMessage = IframePhoneServerMessage |
                            DeprecatedIFrameSaverServerMessage |
                            IframeSaverServerMessage |
                            GlobalIFrameSaverServerMessage;

export interface IInteractiveStateProps<InteractiveState = {}> {
  interactiveState: InteractiveState | null;
  hasLinkedInteractive?: boolean;
  linkedState?: object;
  allLinkedStates?: IInteractiveStateProps[];
  createdAt?: string;
  updatedAt?: string;
  interactiveStateUrl?: string;
  interactive: {
    id?: number;
    name?: string;
  };
  pageNumber?: number;
  pageName?: string;
  activityName?: string;
}

// tslint:disable-next-line:max-line-length
export interface IRuntimeInitInteractive<AuthoredState = {}, InteractiveState = {}, GlobalInteractiveState = {}> extends IInteractiveStateProps<InteractiveState> {
  version: 1;
  error: any;
  mode: "runtime";
  authoredState: AuthoredState | null;
  globalInteractiveState: GlobalInteractiveState | null;
  interactiveStateUrl: string;
  collaboratorUrls: string[] | null;
  classInfoUrl: string;
  interactive: {
    id: number;
    name: string;
  };
  authInfo: {
    provider: string;
    loggedIn: boolean;
    email: string;
  };
}

export interface IAuthoringInitInteractive<AuthoredState = {}> {
  version: 1;
  error: null;
  mode: "authoring";
  authoredState: AuthoredState | null;
}

export interface IReportInitInteractive<AuthoredState = {}, InteractiveState = {}> {
  version: 1;
  mode: "report";
  authoredState: AuthoredState;
  interactiveState: InteractiveState;
}

export type IInitInteractive<AuthoredState = {}, InteractiveState = {}, GlobalInteractiveState = {}> =
  IRuntimeInitInteractive<AuthoredState, InteractiveState, GlobalInteractiveState> |
  IAuthoringInitInteractive<AuthoredState> |
  IReportInitInteractive<AuthoredState, InteractiveState>;

export type InitInteractiveMode = "runtime" | "authoring" | "report";

export interface ISupportedFeatures {
  aspectRatio?: number;
  authoredState?: boolean;
  interactiveState?: boolean;
}

export interface ISupportedFeaturesRequest {
  apiVersion: 1;
  features: ISupportedFeatures;
}

export interface INavigationOptions {
  enableForwardNav?: boolean;
  message?: string;
}

export interface IAuthInfo {
  provider: string;
  loggedIn: boolean;
  email?: string;
}

export interface IGetFirebaseJwtOptions {
  firebase_app?: string;
}

export interface IFirebaseJwt {
  response_type?: "ERROR";
  message?: string;
  token?: string;
}

export interface IClientOptions<AuthoredState = {}, InteractiveState = {}, GlobalInteractiveState = {}> {
  startDisconnected?: boolean;
  supportedFeatures?: ISupportedFeatures;
  onHello?: () => void;
  // tslint:disable-next-line:max-line-length
  onInitInteractive?: (initMessage: IInitInteractive<AuthoredState, InteractiveState, GlobalInteractiveState>) => void;
  onGetInteractiveState?: () => InteractiveState | string | null;
  onGlobalInteractiveStateUpdated?: (globalState: GlobalInteractiveState) => void;
}

export interface IHookOptions {
  supportedFeatures?: ISupportedFeatures;
}
