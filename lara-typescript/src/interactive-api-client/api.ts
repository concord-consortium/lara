import {
  IInitInteractive,
  ISupportedFeaturesRequest,
  INavigationOptions,
  IAuthInfo,
  IGetFirebaseJwtResponse,
  ISupportedFeatures,
  IGetFirebaseJwtRequest,
  IGetAuthInfoRequest,
  IAuthoringCustomReportFields,
  IRuntimeCustomReportValues,
  IShowModal,
  ICloseModal,
  IGetInteractiveListOptions,
  ISetLinkedInteractives,
  IGetLibraryInteractiveListRequest,
  IGetInteractiveSnapshotRequest,
  IHintRequest,
  IJwtResponse
} from "./types";
import { getClient } from "./client";

const THROW_NOT_IMPLEMENTED_YET = (method: string) => {
  throw new Error(`${method} is not yet implemented in the client!`);
};

export const getInitInteractiveMessage =
  <InteractiveState = {}, AuthoredState = {}, DialogState = {}, GlobalInteractiveState = {}>():
  Promise<IInitInteractive<InteractiveState, AuthoredState, DialogState, GlobalInteractiveState> | null> => {
  const client = getClient();
  // tslint:disable-next-line:max-line-length
  return new Promise<IInitInteractive<InteractiveState, AuthoredState, DialogState, GlobalInteractiveState> | null>(resolve => {
    if (client.managedState.initMessage) {
      resolve(client.managedState.initMessage);
    } else {
      client.managedState.once("initInteractive", () => resolve(client.managedState.initMessage));
    }
  });
};

export const getInteractiveState = <InteractiveState>(): InteractiveState | null => {
  return getClient().managedState.interactiveState;
};

/**
 * Note that state will become frozen and should never be mutated.
 * Each time you update state, make sure that a new object is passed.
 *
 * Good:
 * ```
 * setInteractiveState(Object.assign({}, previousState, {someProperty: "a new value"}));
 * // or
 * setInteractiveState({...previousState, someProperty: "a new value"});
 * ```
 *
 * Bad:
 * ```
 * previousState.someProperty = "a new value";
 * setInteractiveState(previousState);
 * ```
 */
export const setInteractiveState = <InteractiveState>(newInteractiveState: InteractiveState | null) => {
  const client = getClient();
  client.managedState.interactiveState = newInteractiveState;
  client.post("interactiveState", newInteractiveState);
};

export const getAuthoredState = <AuthoredState>(): AuthoredState | null => {
  return getClient().managedState.authoredState;
};

/**
 * Note that state will become frozen and should never be mutated.
 * Each time you update state, make sure that a new object is passed.
 *
 * Good:
 * ```
 * setAuthoredState(Object.assign({}, previousState, {someProperty: "a new value"}));
 * // or
 * setAuthoredState({...previousState, someProperty: "a new value"});
 * ```
 *
 * Bad:
 * ```
 * previousState.someProperty = "a new value";
 * setAuthoredState(previousState);
 * ```
 */
export const setAuthoredState = <AuthoredState>(newAuthoredState: AuthoredState | null) => {
  const client = getClient();
  client.managedState.authoredState = newAuthoredState;
  client.post("authoredState", newAuthoredState);
};

export const getGlobalInteractiveState = <GlobalInteractiveState>(): GlobalInteractiveState | null => {
  return getClient().managedState.globalInteractiveState;
};

/**
 * Note that state will become frozen and should never be mutated.
 * Each time you update state, make sure that a new object is passed.
 *
 * Good:
 * ```
 * setGlobalInteractiveState(Object.assign({}, previousState, {someProperty: "a new value"}));
 * // or
 * setGlobalInteractiveState({...previousState, someProperty: "a new value"});
 * ```
 *
 * Bad:
 * ```
 * previousState.someProperty = "a new value";
 * setGlobalInteractiveState(previousState);
 * ```
 */
export const setGlobalInteractiveState = <GlobalInteractiveState>(newGlobalState: GlobalInteractiveState | null) => {
  const client = getClient();
  client.managedState.globalInteractiveState = newGlobalState;
  client.post("interactiveStateGlobal", newGlobalState);
};

export const setSupportedFeatures = (features: ISupportedFeatures) => {
  const request: ISupportedFeaturesRequest = {
    apiVersion: 1,
    features
  };
  getClient().post("supportedFeatures", request);
};

export const setHeight = (height: number | string) => {
  getClient().post("height", height);
};

/*
 * Providing empty string or null disables hint.
 */
export const setHint = (hint: string | null) => {
  const request: IHintRequest = { text: hint };
  getClient().post("hint", request);
};

export const setNavigation = (options: INavigationOptions) => {
  getClient().post("navigation", options);
};

export const getAuthInfo = (): Promise<IAuthInfo> => {
  return new Promise<IAuthInfo>((resolve, reject) => {
    const listener = (authInfo: IAuthInfo) => {
      resolve(authInfo);
    };
    const client = getClient();
    const requestId = client.getNextRequestId();
    const request: IGetAuthInfoRequest = {
      requestId
    };
    client.addListener("authInfo", listener, requestId);
    client.post("getAuthInfo", request);
  });
};

export const getFirebaseJwt = (firebaseApp: string): Promise<IJwtResponse> => {
  return new Promise<IJwtResponse>((resolve, reject) => {
    const listener = (response: IGetFirebaseJwtResponse) => {
      if (response.response_type === "ERROR") {
        reject(response.message || "Error getting Firebase JWT");
      } else if (response.token) {
        try {
          const claimsJson = atob(response.token.split(".")[1]);
          resolve({token: response.token, claims: JSON.parse(claimsJson)});
        } catch (error) {
          reject("Unable to parse JWT Token");
        }
      } else {
        reject("Empty token");
      }
    };
    const client = getClient();
    const requestId = client.getNextRequestId();
    const request: IGetFirebaseJwtRequest = {
      requestId,
      firebase_app: firebaseApp
    };
    client.addListener("firebaseJWT", listener, requestId);
    client.post("getFirebaseJWT", request);
  });
};

export const log = (action: string, data?: object) => {
  getClient().post("log", {action, data});
};

// tslint:disable-next-line:max-line-length
export const addInteractiveStateListener = <InteractiveState>(listener: (interactiveState: InteractiveState) => void) => {
  getClient().managedState.on("interactiveStateUpdated", listener);
};

// tslint:disable-next-line:max-line-length
export const removeInteractiveStateListener = <InteractiveState>(listener: (interactiveState: InteractiveState) => void) => {
  getClient().managedState.off("interactiveStateUpdated", listener);
};

export const addAuthoredStateListener = <AuthoredState>(listener: (authoredState: AuthoredState) => void) => {
  getClient().managedState.on("authoredStateUpdated", listener);
};

export const removeAuthoredStateListener = <AuthoredState>(listener: (authoredState: AuthoredState) => void) => {
  getClient().managedState.off("authoredStateUpdated", listener);
};

// tslint:disable-next-line:max-line-length
export const addGlobalInteractiveStateListener = <GlobalInteractiveState>(listener: (globalInteractiveState: GlobalInteractiveState) => void) => {
  getClient().managedState.on("globalInteractiveStateUpdated", listener);
};

// tslint:disable-next-line:max-line-length
export const removeGlobalInteractiveStateListener = <GlobalInteractiveState>(listener: (globalInteractiveState: GlobalInteractiveState) => void) => {
  getClient().managedState.off("globalInteractiveStateUpdated", listener);
};

/**
 * @todo Implement this function.
 */
export const setAuthoringCustomReportFields = (fields: IAuthoringCustomReportFields) => {
  THROW_NOT_IMPLEMENTED_YET("setAuthoringCustomReportFields");
};

/**
 * @todo Implement this function.
 */
export const setRuntimeCustomReportValues = (values: IRuntimeCustomReportValues) => {
  THROW_NOT_IMPLEMENTED_YET("setRuntimeCustomReportValues");
};

/**
 * @todo Implement this function.
 */
export const showModal = (options: IShowModal) => {
  if ((options.type === "alert") || (options.type === "lightbox")) {
    getClient().post("showModal", options);
  }
  else {
    THROW_NOT_IMPLEMENTED_YET(`showModal { type: "${options.type}" }`);
  }
};

/**
 * @todo Implement this function.
 */
export const closeModal = (options: ICloseModal) => {
  getClient().post("closeModal", options);
};

/**
 * @todo Implement this function.
 */
export const getInteractiveList = (options: IGetInteractiveListOptions) => {
  THROW_NOT_IMPLEMENTED_YET("getInteractiveList");
};

/**
 * @todo Implement this function.
 */
export const setLinkedInteractives = (options: ISetLinkedInteractives) => {
  THROW_NOT_IMPLEMENTED_YET("setLinkedInteractives");
};

/**
 * @todo Implement this function.
 */
export const getLibraryInteractiveList = (options: IGetLibraryInteractiveListRequest) => {
  THROW_NOT_IMPLEMENTED_YET("getLibraryInteractiveList");
};

/**
 * @todo Implement this function.
 */
export const getInteractiveSnapshot = (options: IGetInteractiveSnapshotRequest) => {
  THROW_NOT_IMPLEMENTED_YET("getInteractiveSnapshot");
};
