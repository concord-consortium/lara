import { IEventListeners } from "../plugin-api";

// Export some shared types.
export { IPortalClaims, IJwtClaims, IJwtResponse } from "../shared/types";

// Discussion about naming of these interfaces:
// https://github.com/concord-consortium/lara/pull/550#issuecomment-639021815

export interface IAttachmentInfo {
  contentType?: string;
}
export type AttachmentInfoMap = Record<string, IAttachmentInfo>;

export interface IInteractiveStateProps<InteractiveState = {}> {
  interactiveState: InteractiveState | null;
  hasLinkedInteractive?: boolean;
  linkedState?: object;
  allLinkedStates?: IInteractiveStateProps[];
  createdAt?: string;
  updatedAt?: string;
  interactiveStateUrl?: string;
  interactive: {
    id?: string;
    name?: string;
  };
  pageNumber?: number;
  pageName?: string;
  activityName?: string;
  externalReportUrl?: string;
  attachments?: AttachmentInfoMap;
}

export interface IHostFeatureSupport extends Record<string, unknown> {
  version: string;
}

export interface IHostModalSupport extends IHostFeatureSupport {
  dialog?: boolean;
  lightbox?: boolean;
  alert?: boolean;
}

export interface IHostFeatures extends Record<string, IHostFeatureSupport | string | undefined> {
  modal?: IHostModalSupport;
  getFirebaseJwt?: IHostFeatureSupport;
  domain?: string;
}

export interface IAccessibilitySettings {
  fontSize: string;
  fontSizeInPx: number;
  fontType: string;
  fontFamilyForType: string;
}

export interface IRuntimeInitInteractive<InteractiveState = {}, AuthoredState = {}, GlobalInteractiveState = {}>
       extends IInteractiveStateProps<InteractiveState> {
  version: 1;
  error: any;
  mode: "runtime";
  hostFeatures: IHostFeatures;
  authoredState: AuthoredState | null;
  globalInteractiveState: GlobalInteractiveState | null;
  interactiveStateUrl: string;
  runRemoteEndpoint?: string;
  collaboratorUrls: string[] | null;
  classInfoUrl: string;
  interactive: {
    id: string;
    name: string;
  };
  authInfo: {
    provider: string;
    loggedIn: boolean;
    email: string;
  };
  linkedInteractives: ILinkedInteractive[];
  themeInfo: IThemeInfo;
  attachments?: AttachmentInfoMap;
  accessibility: IAccessibilitySettings;
  mediaLibrary: IMediaLibrary;
}

export interface IThemeInfo {
  colors: {
    colorA: string;
    colorB: string;
  };
}

export type InteractiveItemId = string;
export interface ILinkedInteractive {
  id: InteractiveItemId;
  label: string;
}

export interface IAuthoringInitInteractive<AuthoredState = {}> {
  version: 1;
  error: null;
  mode: "authoring";
  hostFeatures: IHostFeatures;
  authoredState: AuthoredState | null;
  themeInfo: IThemeInfo;
  interactiveItemId: string;
  linkedInteractives?: ILinkedInteractive[];
}

export interface IReportInitInteractive<InteractiveState = {}, AuthoredState = {}> {
  version: 1;
  mode: "report";
  view?: "standalone";
  hostFeatures: IHostFeatures;
  authoredState: AuthoredState;
  interactiveState: InteractiveState;
  themeInfo: IThemeInfo;
  attachments?: AttachmentInfoMap;
  linkedInteractives: ILinkedInteractive[];
}

export interface IReportItemInitInteractive<InteractiveState = {}, AuthoredState = {}> {
  version: 1;
  mode: "reportItem";
  hostFeatures: IHostFeatures;
  interactiveItemId: string;
  view: "singleAnswer" | "multipleAnswer" | "hidden";
  users: Record<string, {hasAnswer: boolean}>;
  attachments?: AttachmentInfoMap;
}

export type IInitInteractive<InteractiveState = {}, AuthoredState = {}, GlobalInteractiveState = {}> =
  IRuntimeInitInteractive<InteractiveState, AuthoredState, GlobalInteractiveState> |
  IAuthoringInitInteractive<AuthoredState> |
  IReportInitInteractive<InteractiveState, AuthoredState> |
  IReportItemInitInteractive<InteractiveState, AuthoredState>;

export type InitInteractiveMode = "runtime" | "authoring" | "report" | "reportItem";

// Custom Report Fields
//
// These interfaces are used by interactives to define their custom fields and provide values for them.

export interface ICustomReportFieldsAuthoredStateField {
  key: string;
  columnHeader: string;
}
export interface ICustomReportFieldsAuthoredState {
  customReportFields: {
    version: 1;
    fields: ICustomReportFieldsAuthoredStateField[]
  };
}

export interface ICustomReportFieldsInteractiveState {
  customReportFields: {
    version: 1;
    values: {[key: string]: any};
  };
}

/*

TODO:

Full window header buttons

*/

//
// client/lara request messages
//

// the iframesaver messages are 1 per line to reduce merge conflicts as new ones are added
export type IRuntimeClientMessage = "interactiveState" |
                                       "height" |
                                       "hint" |
                                       "getAttachmentUrl" |
                                       "getAuthInfo" |
                                       "supportedFeatures" |
                                       "navigation" |
                                       "getFirebaseJWT" |
                                       "authoredState" |
                                       "authoringCustomReportFields" |
                                       "runtimeCustomReportValues" |
                                       "showModal" |
                                       "closeModal" |
                                       "getLibraryInteractiveList" |
                                       "getInteractiveSnapshot" |
                                       "addLinkedInteractiveStateListener" |
                                       "removeLinkedInteractiveStateListener" |
                                       "decoratedContentEvent" |
                                       // intentionally same name as server message to allow bi-directional messages
                                       "customMessage"
                                      ;

export type IRuntimeServerMessage = "attachmentUrl" |
                                       "authInfo" |
                                       "getInteractiveState" |
                                       "initInteractive" |
                                       "firebaseJWT" |
                                       "closedModal" |
                                       "customMessage" |
                                       "libraryInteractiveList" |
                                       "interactiveSnapshot" |
                                       "contextMembership" |
                                       "linkedInteractiveState" |
                                       "decorateContent"
                                       ;

export type IAuthoringClientMessage = "getInteractiveList" |
                                      "setLinkedInteractives" |
                                      "getFirebaseJWT"
                                      ;

export type IAuthoringServerMessage = "interactiveList" |
                                      "firebaseJWT"
                                      ;

export type IReportItemClientMessage = "reportItemAnswer" |
                                       "reportItemClientReady";

export type IReportItemServerMessage = "getReportItemAnswer";

export type GlobalIFrameSaverClientMessage = "interactiveStateGlobal";
export type GlobalIFrameSaverServerMessage = "loadInteractiveGlobal";

export type LoggerClientMessage = "log";

export type IframePhoneServerMessage = "hello";

export type DeprecatedRuntimeClientMessage = "setLearnerUrl";
export type DeprecatedRuntimeServerMessage = "getLearnerUrl" | "loadInteractive";

export type ClientMessage = DeprecatedRuntimeClientMessage |
                            IRuntimeClientMessage |
                            IAuthoringClientMessage |
                            GlobalIFrameSaverClientMessage |
                            LoggerClientMessage |
                            IReportItemClientMessage;

export type ServerMessage = IframePhoneServerMessage |
                            DeprecatedRuntimeServerMessage |
                            IRuntimeServerMessage |
                            IAuthoringServerMessage |
                            GlobalIFrameSaverServerMessage |
                            IReportItemServerMessage;

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

export type ICustomMessageOptions = Record<string, any>;
export type ICustomMessagesHandledMap = Record<string, boolean | ICustomMessageOptions>;

export interface ISupportedFeatures {
  aspectRatio?: number;
  authoredState?: boolean;
  interactiveState?: boolean;
  customMessages?: {
    handles?: ICustomMessagesHandledMap;
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

export interface IHintRequest {
  text: string | null;
}

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
  uuid?: string;
}

export type ModalType = "alert" | "lightbox" | "dialog";

export interface IShowAlert extends IBaseShowModal {
  type: "alert";
  style: "correct" | "incorrect" | "info" /* | "warning" | "error" */;
  title?: string;
  text?: string;
}

// Lightbox is used for displaying images or generic iframes (e.g. help page, but NOT dynamic interactives).
export interface IShowLightbox extends IBaseShowModal {
  type: "lightbox";
  url: string;
  title?: string;
  isImage?: boolean;
  size?: { width: number, height: number };
  allowUpscale?: boolean;
}

// Dialog is used for interactives. It'll be initialized correctly by the host environment.
export interface IShowDialog extends IBaseShowModal {
  type: "dialog";
  url: string;
  // Disables click-to-close backdrop and X icon in modal (depends on host environment).
  // Only interactive own UI itself can request modal closing by using `closeModal()` function.
  notCloseable?: boolean;
}

export type IShowModal = IShowAlert | IShowLightbox | IShowDialog;

export interface ICloseModal {
  // Necessary only when there are multiple modals. Otherwise it'll close the currently open modal.
  uuid?: string;
}

export interface IDecoratedContentEvent {
  type: string;
  text: string;
  bounds?: DOMRect;
}

interface ITextDecorationBaseInfo {
  words: string[];
  replace: string;
  wordClass: string;
}

export interface ITextDecorationInfo extends ITextDecorationBaseInfo {
  listenerTypes: Array<{type: string}>;
}

export interface ITextDecorationHandlerInfo extends ITextDecorationBaseInfo {
  eventListeners: IEventListeners;
}

export type ITextDecorationHandler = (message: ITextDecorationHandlerInfo) => void;

export interface ICustomMessage {
  type: string;
  content: Record<string, any>;
}
export type ICustomMessageHandler = (message: ICustomMessage) => void;

export interface ISetLinkedInteractives {
  linkedInteractives?: ILinkedInteractive[];
  linkedState?: InteractiveItemId;
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

export interface IAttachmentUrlRequest extends IBaseRequestResponse {
  name: string;
  operation: "read" | "write";
  interactiveId?: string;
  contentType?: string; // defaults to text/plain
  expiresIn?: number; // seconds
  platformUserId?: string;
}
export interface IWriteAttachmentRequest extends IAttachmentUrlRequest {
  content: any;
  options?: RequestInit;
}
export interface IAttachmentUrlResponse extends IBaseRequestResponse {
  url?: string;
  error?: string;
}

export type ReadAttachmentParams = Omit<IAttachmentUrlRequest, "requestId" | "operation" | "contentType" | "expiresIn">;
export type WriteAttachmentParams = Omit<IWriteAttachmentRequest, "requestId" | "operation">;
export type GetAttachmentUrlParams = Omit<IAttachmentUrlRequest, "requestId" | "operation">;

export interface IGetAuthInfoRequest extends IBaseRequestResponse {
  // no extra options, just the requestId
}
export interface IGetAuthInfoResponse extends IBaseRequestResponse, IAuthInfo {
  // no extra options, just the requestId and the auth info
}

export interface IGetFirebaseJwtRequest extends IBaseRequestResponse {
  firebase_app: string;
}

export interface IGetFirebaseJwtResponse extends IBaseRequestResponse {
  response_type?: "ERROR";
  message?: string;
  token?: string;
}

export interface IGetInteractiveListOptions {
  scope: "page"; // to allow for adding other scopes in the future
  supportsSnapshots?: boolean;
}
export interface IGetInteractiveListRequest extends IBaseRequestResponse, IGetInteractiveListOptions {
  // no extra options
}

export interface IInteractiveListResponseItem {
  id: InteractiveItemId;
  pageId: number;
  name: string;
  section: "header_block" | "assessment_block" | "interactive_box";
  url: string;
  thumbnailUrl: string | null;
  supportsSnapshots: boolean;
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
  interactiveItemId: InteractiveItemId;
}
export interface IGetInteractiveSnapshotRequest extends IBaseRequestResponse, IGetInteractiveSnapshotOptions {
  // no extra options
}

export interface IGetInteractiveSnapshotResponse extends IBaseRequestResponse {
  success: boolean;
  snapshotUrl?: string;
}

export interface IAddLinkedInteractiveStateListenerOptions {
  interactiveItemId: InteractiveItemId;
}

export interface IAddLinkedInteractiveStateListenerRequest extends IAddLinkedInteractiveStateListenerOptions {
  listenerId: string; // functions cannot be passed via postMessage, so additional ID is necessary
}

export interface IRemoveLinkedInteractiveStateListenerRequest {
  listenerId: string; // functions cannot be passed via postMessage, so additional ID is necessary
}

export interface ILinkedInteractiveStateResponse<LinkedInteractiveState> {
  listenerId: string;
  interactiveState: LinkedInteractiveState | undefined;
}

export type ReportItemsType = "fullAnswer" | "compactAnswer";

export interface IGetReportItemAnswer<InteractiveState = {}, AuthoredState = {}> extends IBaseRequestResponse {
  version: "2.1.0";
  platformUserId: string;
  interactiveState: InteractiveState;
  authoredState: AuthoredState;
  itemsType: ReportItemsType;
}

export interface IReportItemAnswerItemAttachment {
  type: "attachment";
  name: string;
  label?: string;
}
export interface IReportItemAnswerItemAnswerText {
  type: "answerText";
}
export interface IReportItemAnswerItemHtml {
  type: "html";
  html: string;
}
export interface IReportItemAnswerItemLinks {
  type: "links";
  hideViewInline?: boolean;
  hideViewInNewTab?: boolean;
}
export interface IReportItemAnswerItemScore {
  type: "score";
  score: number;
  maxScore: number;
}

export type IReportItemAnswerItem =
  IReportItemAnswerItemAttachment |
  IReportItemAnswerItemAnswerText |
  IReportItemAnswerItemHtml |
  IReportItemAnswerItemLinks |
  IReportItemAnswerItemScore;

export interface IReportItemAnswer extends IBaseRequestResponse {
  version: "2.1.0";
  platformUserId: string;
  items: IReportItemAnswerItem[];
  /**
   * When not provided, host should assume that itemsType is equal to "fullAnswer" (to maintain backward compatibility
   * with version 2.0.0).
   */
  itemsType?: ReportItemsType;
}

export type IGetReportItemAnswerHandler<InteractiveState = {}, AuthoredState = {}> =
  (message: IGetReportItemAnswer<InteractiveState, AuthoredState>) => void;

export interface IReportItemHandlerMetadata {
  /**
   * When compactAnswerReportItems is present and equal to true, report will try to get report items related to compact
   * answer (small icons visible in the dashboard grid view). An example of compact answer report item is "score"
   * used by ScoreBOT question.
   */
  compactAnswerReportItemsAvailable?: boolean;
}

/**
 * Interface that can be used by interactives to export and consume datasets. For example:
 * - Vortex interactive is exporting its dataset in the interactive state
 * - Graph interactive (part of the question-interactives) can observe Vortex interactive state
 *   (via linked interactive state observing API) and render dataset columns as bar graphs.
 */
export interface IDataset {
  type: "dataset";
  version: 1;
  properties: string[];
  rows: Array<Array<(number | string | null)>>;
  // Row indices will be used when xAxisProp is undefined.
  xAxisProp?: string;
}

/**
 * Dataset should be saved as a part of the interactive state. Example:
 * Vortex interactive state implements this interface, graph interactive uses it to make assumptions about Vortex
 * interactive state.
 */
export interface IInteractiveStateWithDataset {
  dataset?: IDataset | null;
}

export interface IGetInteractiveState {
  unloading?: boolean;  // set to true to tell the interactive it is getting the final state
}
export type OnUnloadFunction<InteractiveState = {}> = (options: IGetInteractiveState) => Promise<InteractiveState>;

/**
 * Type of the exported media library items found in the activity or sequence.  Initially this will just
 * be "image" but could be extended in the future to "video" or "audio".  The exact mime type would be
 * preferable but that is not always detectable from the exported media library urls.
 */
export type IMediaLibraryItemType = "image";

/**
 * Interface for the exported media library items found in the activity or sequence.
 */
export interface IMediaLibraryItem {
  url: string;
  type: IMediaLibraryItemType;
  caption?: string;
}

/**
 * Interface for the media library.
 */
export interface IMediaLibrary {
  enabled: boolean;
  items: IMediaLibraryItem[];
}
