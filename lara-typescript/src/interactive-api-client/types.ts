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

export interface IRuntimeInitInteractive<InteractiveState = {}, AuthoredState = {}, GlobalInteractiveState = {}>
       extends IInteractiveStateProps<InteractiveState> {
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
  linkedInteractives: ILinkedRuntimeInteractive[];
  themeInfo: IThemeInfo;
}

export interface IThemeInfo {
  colors: {
    colorA: string;
    colorB: string;
  };
}

export type InteractiveRuntimeId = string;
export interface ILinkedRuntimeInteractive {
  interactiveRuntimeId: InteractiveRuntimeId;
  label: string;
  chainedState: boolean;
  sendStateOnInit: boolean;
}

export type InteractiveAuthoredId = string;
export interface ILinkedAuthoredInteractive {
  id: InteractiveAuthoredId;
  label: string;
  chainedState: boolean;
  sendStateOnInit: boolean;
}

export interface IAuthoringInitInteractive<AuthoredState = {}> {
  version: 1;
  error: null;
  mode: "authoring";
  authoredState: AuthoredState | null;
  themeInfo: IThemeInfo;
}

export interface IReportInitInteractive<InteractiveState = {}, AuthoredState = {}> {
  version: 1;
  mode: "report";
  authoredState: AuthoredState;
  interactiveState: InteractiveState;
  themeInfo: IThemeInfo;
}

export interface IDialogInitInteractive<InteractiveState = {}, AuthoredState = {}, DialogState = {}> {
  version: 1;
  mode: "dialog";
  authoredState: AuthoredState;
  interactiveState: InteractiveState;
  dialogState: DialogState;
}

export interface IAggregateInitInteractive<InteractiveState = {}, AuthoredState = {}> {
  version: 1;
  mode: "aggregate";
  authoredState: AuthoredState;
  interactiveState: InteractiveState;
}

export type IInitInteractive<InteractiveState = {}, AuthoredState = {}, DialogState = {}, GlobalInteractiveState = {}> =
  IRuntimeInitInteractive<InteractiveState, AuthoredState, GlobalInteractiveState> |
  IAuthoringInitInteractive<AuthoredState> |
  IReportInitInteractive<InteractiveState, AuthoredState> |
  IDialogInitInteractive<InteractiveState, AuthoredState, DialogState>;

export type InitInteractiveMode = "runtime" | "authoring" | "report" | "dialog";

// tslint:disable-next-line:max-line-length
export interface IClientOptions<InteractiveState = {}, AuthoredState = {}, DialogState = {}, GlobalInteractiveState = {}> {
  startDisconnected?: boolean;
  supportedFeatures?: ISupportedFeatures;
  onHello?: () => void;
  // tslint:disable-next-line:max-line-length
  onInitInteractive?: (initMessage: IInitInteractive<InteractiveState, AuthoredState, DialogState, GlobalInteractiveState>) => void;
  onGetInteractiveState?: () => InteractiveState | string | null;
  onGlobalInteractiveStateUpdated?: (globalState: GlobalInteractiveState) => void;
}

export interface IHookOptions {
  supportedFeatures?: ISupportedFeatures;
}

/*

TODO:

Aggregate Mode
Full window header buttons

*/

//
// client/lara request messages
//

// the iframesaver messages are 1 per line to reduce merge conflicts as new ones are added
export type IFrameSaverClientMessage = "interactiveState" |
                                       "height" |
                                       "hint" |
                                       "getAuthInfo" |
                                       "supportedFeatures" |
                                       "navigation" |
                                       "getFirebaseJWT" |
                                       "authoredState" |
                                       "authoringMetadata" |
                                       "runtimeMetadata" |
                                       "authoringCustomReportFields" |
                                       "runtimeCustomReportValues" |
                                       "showModal" |
                                       "closeModal" |
                                       "getInteractiveList" |
                                       "setLinkedInteractives" |
                                       "getLibraryInteractiveList" |
                                       "getInteractiveSnapshot"
                                      ;

export type IframeSaverServerMessage = "authInfo" |
                                       "getInteractiveState" |
                                       "initInteractive" |
                                       "firebaseJWT" |
                                       "closedModal" |
                                       "customMessage" |
                                       "interactiveList" |
                                       "libraryInteractiveList" |
                                       "interactiveSnapshot" |
                                       "contextMembership"
                                       ;

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

// server messages

export interface IContextMember {
  userId: string;
  firstName: string;
  lastName: string;
}
export interface IContextMembership {
  members: IContextMember[];
}

//
// client requests only (no responses from lara)
//

export interface ISupportedFeatures {
  aspectRatio?: number;
  authoredState?: boolean;
  interactiveState?: boolean;
  customMessages?: {
    handles?: string[];
    // TODO: extend later to allow for sending custom messages from interactive
  };
}

export interface ISupportedFeaturesRequest {
  apiVersion: 1;
  features: ISupportedFeatures;
}

export interface INavigationOptions {
  enableForwardNav?: boolean;
  message?: string;
}

export type ChoiceId = string | number;

// TODO: look at portal reports to get values or enum
export interface IAuthoringMetadataBase {
  secondaryTypeForNow: any;  // TODO: this would come from the portal report
                             // codebase for the icons showing in the column headings
  isRequired: boolean;
  prompt?: string;
}
export interface IAuthoringOpenResponseMetadata extends IAuthoringMetadataBase {
  type: "open response";
}
export interface IAuthoringInteractiveMetadata extends IAuthoringMetadataBase {
  type: "interactive";
}
export interface IAuthoringMultipleChoiceChoiceMetadata {
  id: ChoiceId;
  content: string;
  isCorrect: boolean;
}
export interface IAuthoringMultipleChoiceMetadata extends IAuthoringMetadataBase {
  type: "multiple choice";
  choices: IAuthoringMultipleChoiceChoiceMetadata[];
}
export type IAuthoringMetadata = IAuthoringOpenResponseMetadata |
                                 IAuthoringInteractiveMetadata |
                                 IAuthoringMultipleChoiceMetadata;

export interface IRuntimeMetadataBase {
  isSubmitted: boolean;
  answerText: string;
}
export interface IRuntimeInteractiveMetadata extends IRuntimeMetadataBase {
  type: "interactive";
}
export interface IRuntimeMultipleChoiceMetadata extends IRuntimeMetadataBase {
  type: "multiple choice";
  choiceIds: ChoiceId[];
}
export type IRuntimeMetadata = IRuntimeInteractiveMetadata |
                               IRuntimeMultipleChoiceMetadata;

export interface IAuthoringCustomReportField {
  id: string;
  columnHeading: string;
}
export interface IAuthoringCustomReportFields {
  fields: IAuthoringCustomReportField[];
}

export interface IRuntimeCustomReportValues {
  values: {[key: string]: any};    // TODO: try to type the keys based on passed in type
}

//
// client requests with responses with id other than requestId
//

export interface IBaseShowModal {
  uuid: string;
}

export interface IShowAlert extends IBaseShowModal {
  type: "alert";
  style: "info" | "warning" | "error";
  headerText?: string;
  text: string;
}

export interface IShowLightbox extends IBaseShowModal {
  type: "lightbox";
  url: string;
}

export interface IShowDialog<DialogState = {}> extends IBaseShowModal {
  type: "dialog";
  url: string;
  dialogState: DialogState;
}

export type IShowModal = IShowAlert | IShowLightbox | IShowDialog;

export interface ICloseModal {
  uuid: string;
}

export interface IClosedModal {
  uuid: string;
}

export interface ICustomMessage {
  type: string;
  content: object;
}

export interface ISetLinkedInteractives {
  linkedInteractives: ILinkedAuthoredInteractive[];
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

export interface IGetInteractiveListOptions {
  supportsSnapshots?: boolean;
}
export interface IGetInteractiveListRequest extends IBaseRequestResponse, IGetInteractiveListOptions {
  // no extra options
}

export interface IInteractiveListResponseItem {
  id: InteractiveAuthoredId;
  name: string;
  pageLocation: "assessment list" | "interactive box" | "introduction";
  url: string;
  thumbnailUrl?: string;
}
export interface IGetInteractiveListResponse extends IBaseRequestResponse {
  interactives: IInteractiveListResponseItem[];
}

export interface IGetLibraryInteractiveListOptions {
  // no extra options
}
export interface IGetLibraryInteractiveListRequest extends IBaseRequestResponse, IGetLibraryInteractiveListOptions {
  // no extra options
}

export interface ILibraryInteractiveListResponseItem {
  id: string;
  name: string;
  description: string;
  thumbnailUrl: string;
}
export interface IGetLibraryInteractiveListResponse extends IBaseRequestResponse {
  libraryInteractives: ILibraryInteractiveListResponseItem[];
}

export interface IGetInteractiveSnapshotOptions {
  interactiveRuntimeId: InteractiveRuntimeId;
}
export interface IGetInteractiveSnapshotRequest extends IBaseRequestResponse, IGetInteractiveSnapshotOptions {
  // no extra options
}

export interface IGetInteractiveSnapshotResponse extends IBaseRequestResponse {
  snapshotUrl: string;
}
