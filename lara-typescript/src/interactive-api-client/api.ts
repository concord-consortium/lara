import {
  IInitInteractive, ISupportedFeaturesRequest, INavigationOptions, IAuthInfo, IGetFirebaseJwtOptions,
  IGetFirebaseJwtResponse, ISupportedFeatures, IGetFirebaseJwtRequest, IGetAuthInfoRequest
} from "./types";
import { getClient } from "./client";

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

export const setHint = (height: string) => {
  getClient().post("hint", height);
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

export const getFirebaseJWT = (options: IGetFirebaseJwtOptions): Promise<string> => {
  return new Promise<string>((resolve, reject) => {
    const listener = (response: IGetFirebaseJwtResponse) => {
      if (response.response_type === "ERROR") {
        reject(response.message || "Error getting Firebase JWT");
      } else {
        resolve(response.token);
      }
    };
    const client = getClient();
    const requestId = client.getNextRequestId();
    const request: IGetFirebaseJwtRequest = {
      requestId,
      ...options
    };
    client.addListener("firebaseJWT", listener, requestId);
    client.post("getFirebaseJWT", request);
  });
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
