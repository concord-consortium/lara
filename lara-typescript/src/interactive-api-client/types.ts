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
export interface IRuntimeInitInteractive<InteractiveState = {}, AuthoredState = {}, GlobalInteractiveState = {}> extends IInteractiveStateProps<InteractiveState> {
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

export interface IReportInitInteractive<InteractiveState = {}, AuthoredState = {}> {
  version: 1;
  mode: "report";
  authoredState: AuthoredState;
  interactiveState: InteractiveState;
}

export type IInitInteractive<InteractiveState = {}, AuthoredState = {}, GlobalInteractiveState = {}> =
  IRuntimeInitInteractive<InteractiveState, AuthoredState, GlobalInteractiveState> |
  IAuthoringInitInteractive<AuthoredState> |
  IReportInitInteractive<InteractiveState, AuthoredState>;

export type InitInteractiveMode = "runtime" | "authoring" | "report";

export interface IClientOptions<InteractiveState = {}, AuthoredState = {}, GlobalInteractiveState = {}> {
  startDisconnected?: boolean;
  supportedFeatures?: ISupportedFeatures;
  onHello?: () => void;
  // tslint:disable-next-line:max-line-length
  onInitInteractive?: (initMessage: IInitInteractive<InteractiveState, AuthoredState, GlobalInteractiveState>) => void;
  onGetInteractiveState?: () => InteractiveState | string | null;
  onGlobalInteractiveStateUpdated?: (globalState: GlobalInteractiveState) => void;
}

export interface IHookOptions {
  supportedFeatures?: ISupportedFeatures;
}

//
// client/lara request messages
//

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

//
// client requests only (no responses from lara)
//

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

//
// client requests with responses
//

interface IBaseRequestResponse {
  requestId: number;
}

export interface IAuthInfo {
  provider: string;
  loggedIn: boolean;
  email?: string;
}

export interface IGetAuthInfoRequest extends IBaseRequestResponse {
  // no extra options, just the requestId
}
export interface IGetAuthInfoResponse extends IBaseRequestResponse, IAuthInfo {
  // no extra options, just the requestId and the auth info
}

export interface IGetFirebaseJwtOptions {
  firebase_app?: string;
}

export interface IGetFirebaseJwtRequest extends IBaseRequestResponse, IGetFirebaseJwtOptions {
  // no extra options, just the requestId and the jwt options
}

export interface IGetFirebaseJwtResponse extends IBaseRequestResponse {
  response_type?: "ERROR";
  message?: string;
  token?: string;
}
