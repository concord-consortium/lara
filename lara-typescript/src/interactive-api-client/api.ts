import {
  IInitInteractive,
  ISupportedFeaturesRequest,
  INavigationOptions,
  IAuthInfo,
  IGetFirebaseJwtResponse,
  ISupportedFeatures,
  IGetFirebaseJwtRequest,
  IGetAuthInfoRequest,
  IShowModal,
  ICloseModal,
  IGetInteractiveListOptions,
  IGetInteractiveListResponse,
  ISetLinkedInteractives,
  IGetLibraryInteractiveListRequest,
  IGetInteractiveSnapshotRequest,
  IHintRequest,
  IJwtResponse,
  IGetInteractiveListRequest,
  ICustomMessageHandler,
  ICustomMessagesHandledMap,
  IGetInteractiveSnapshotOptions,
  IGetInteractiveSnapshotResponse,
  IAddLinkedInteractiveStateListenerOptions,
  ILinkedInteractiveStateResponse,
  IAddLinkedInteractiveStateListenerRequest,
  IRemoveLinkedInteractiveStateListenerRequest,
  IDecoratedContentEvent,
  ITextDecorationHandler,
  IAttachmentUrlRequest,
  IAttachmentUrlResponse,
  IWriteAttachmentRequest,
  WriteAttachmentParams,
  ReadAttachmentParams,
  GetAttachmentUrlParams,
  IGetReportItemAnswerHandler,
  IReportItemAnswer,
  OnUnloadFunction,
  IReportItemHandlerMetadata,
  ITextDecorationInfo,
  ICustomMessage
} from "./types";
import { getClient } from "./client";
import { v4 as uuidv4 } from "uuid";

const THROW_NOT_IMPLEMENTED_YET = (method: string) => {
  throw new Error(`${method} is not yet implemented in the client!`);
};

export const getInitInteractiveMessage =
  <InteractiveState = {}, AuthoredState = {}, GlobalInteractiveState = {}>():
  Promise<IInitInteractive<InteractiveState, AuthoredState, GlobalInteractiveState> | null> => {
  const client = getClient();
  return new Promise<IInitInteractive<InteractiveState, AuthoredState, GlobalInteractiveState> | null>(resolve => {
    if (client.managedState.initMessage) {
      resolve(client.managedState.initMessage);
    } else {
      client.managedState.once("initInteractive", () => resolve(client.managedState.initMessage));
    }
  });
};

export const getMode = () => {
  return getInitInteractiveMessage().then(initInteractiveMessage => initInteractiveMessage?.mode);
};

export const getInteractiveState = <InteractiveState>(): InteractiveState | null => {
  return getClient().managedState.interactiveState;
};

let setInteractiveStateTimeoutId: number;
let delayedInteractiveStateUpdate: (() => void) | null = null;
export const setInteractiveStateTimeout = 2000; // ms
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
  window.clearTimeout(setInteractiveStateTimeoutId);
  delayedInteractiveStateUpdate = () => {
    client.post("interactiveState", newInteractiveState);
    client.managedState.interactiveStateDirty = false;
    delayedInteractiveStateUpdate = null;
  };
  setInteractiveStateTimeoutId = window.setTimeout(() => {
    // Note that delayedInteractiveStateUpdate might be equal to null if it was executed before using .flush()
    delayedInteractiveStateUpdate?.();
  }, setInteractiveStateTimeout);
};

/**
 * Useful in rare cases when it's not desirable to wait for the delayed state updates (at this point it only applies
 * to interactive state updates). Internally used by the showModal and closeModal functions, as opening modal
 * usually means reloading interactive. It's necessary to make sure that the state is up to date before it happens.
 */
export const flushStateUpdates = () => {
  // Note that if delayedInteractiveStateUpdate was set, it should set itself to null and setTimeout will ignore it.
  delayedInteractiveStateUpdate?.();
  window.clearTimeout(setInteractiveStateTimeoutId);
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

export const addCustomMessageListener = (callback: ICustomMessageHandler, handles?: ICustomMessagesHandledMap) => {
  const client = getClient();
  if (handles) {
    client.customMessagesHandled = handles;
  }
  client.addListener("customMessage", callback);
};

export const removeCustomMessageListener = () => {
  return getClient().removeListener("customMessage");
};

export const addDecorateContentListener = (callback: ITextDecorationHandler) => {
  getClient().addListener("decorateContent", (msg: ITextDecorationInfo) => {
    callback({
      words: msg.words,
      replace: msg.replace,
      wordClass: msg.wordClass,
      eventListeners: msg.listenerTypes.map((listener) => {
        return {
          type: listener.type,
          listener: (evt: Event) => {
            const wordElement = evt.srcElement as HTMLElement;
            if (!wordElement) {
              return;
            }
            const clickedWord = (wordElement.textContent || "").toLowerCase();
            postDecoratedContentEvent({type: listener.type,
                                       text: clickedWord,
                                       bounds: wordElement.getBoundingClientRect()});
          }
        };
      })
    });
  });
};

export const removeDecorateContentListener = () => {
  getClient().removeListener("decorateContent");
};

// tslint:disable-next-line:max-line-length
export const addGetReportItemAnswerListener = <InteractiveState, AuthoredState>(callback: IGetReportItemAnswerHandler<InteractiveState, AuthoredState>) => {
  getClient().addListener("getReportItemAnswer", callback);
};

export const removeGetReportItemAnswerListener = () => {
  getClient().removeListener("getReportItemAnswer");
};

export const notifyReportItemClientReady = (metadata?: IReportItemHandlerMetadata) => {
  getClient().post("reportItemClientReady", metadata);
};

export const setSupportedFeatures = (features: ISupportedFeatures) => {
  const request: ISupportedFeaturesRequest = {
    apiVersion: 1,
    features
  };
  getClient().setSupportedFeatures(request);
};

export const setHeight = (height: number | string) => {
  getClient().post("height", height);
};

export const postDecoratedContentEvent = (msg: IDecoratedContentEvent) => {
  getClient().post("decoratedContentEvent", msg);
};

/**
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
    getInitInteractiveMessage().then(initMsg => {
      if (initMsg?.hostFeatures?.getFirebaseJwt?.version === "1.0.0") {
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
      } else {
        reject("getFirebaseJwt not supported by the host environment");
      }
    });
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

// Mapping between external listener and internal listener, so it's possible to remove linkedInteractiveState listeners.
const _linkedInteractiveStateListeners = new Map();
/**
 * The listener should be called immediately after it is added with any state of the linked
 * interactive that the host currently knows about. This first call might not happen
 * synchronously it could be slightly delayed. And then the listener should be called again
 * whenever the state of the linked interactive changes.
 */
export const addLinkedInteractiveStateListener = <LinkedInteractiveState>(
  listener: (linkedIntState: LinkedInteractiveState | undefined) => void,
  options: IAddLinkedInteractiveStateListenerOptions
) => {
  const client = getClient();
  const listenerId = uuidv4();
  const internalListener = (response: ILinkedInteractiveStateResponse<LinkedInteractiveState>) => {
    if (response.listenerId === listenerId) {
      listener(response.interactiveState);
    }
  };
  client.addListener("linkedInteractiveState", internalListener);
  // Initialize observing in the host environment.
  const request: IAddLinkedInteractiveStateListenerRequest = {
    ...options,
    listenerId
  };
  client.post("addLinkedInteractiveStateListener", request);
  // Save wrappedInternalListener so it's possible to remove it later.
  _linkedInteractiveStateListeners.set(listener, {
    listenerId: request.listenerId,
    internalListener
  });
};

export const removeLinkedInteractiveStateListener = <InteractiveState>(
  listener: (intState: InteractiveState | null) => void
) => {
  const client = getClient();
  if (_linkedInteractiveStateListeners.has(listener)) {
    const { internalListener, listenerId } = _linkedInteractiveStateListeners.get(listener);
    // Remove local message handler. Theoretically it's not necessary if host implementation is correct
    // (no more messages with this listenerId should be sent), but just to keep things cleaner.
    client.removeListener("linkedInteractiveState", undefined, internalListener);
    // Stop observing in the host environment.
    const request: IRemoveLinkedInteractiveStateListenerRequest = { listenerId };
    client.post("removeLinkedInteractiveStateListener", request);
    _linkedInteractiveStateListeners.delete(listener);
  }
};

/**
 * "lightbox" type is used for displaying images or generic iframes (e.g. help page, but NOT dynamic interactives).
 * "dialog" is used for showing dynamic interactives. It'll be initialized correctly by the host environment and
 * all the runtime features will be supported.
 */
export const showModal = (options: IShowModal) => {
  // Opening modal usually means reloading interactive. It's necessary to make sure that the state is up to date
  // before it happens.
  flushStateUpdates();
  getClient().post("showModal", options);
};

export const closeModal = (options: ICloseModal) => {
  // Opening modal usually means reloading interactive. It's necessary to make sure that the state is up to date
  // before it happens.
  flushStateUpdates();
  getClient().post("closeModal", options);
};

export const getInteractiveList = (options: IGetInteractiveListOptions) => {
  return new Promise<IGetInteractiveListResponse>((resolve, reject) => {
    return getMode()
      .then(mode => {
        if (mode === "authoring") {
          const client = getClient();
          const requestId = client.getNextRequestId();
          const request: IGetInteractiveListRequest = {
            requestId,
            ...options
          };
          client.addListener("interactiveList", resolve, requestId);
          client.post("getInteractiveList", request);
        } else {
          reject("getInteractiveList is only available in authoring mode");
        }
      });
  });
};

export const setLinkedInteractives = (options: ISetLinkedInteractives) => {
  getClient().post("setLinkedInteractives", options);
};

export const getInteractiveSnapshot = (options: IGetInteractiveSnapshotOptions) => {
  return new Promise<IGetInteractiveSnapshotResponse>((resolve, reject) => {
    const listener = (snapshotResponse: IGetInteractiveSnapshotResponse) => {
      resolve(snapshotResponse);
    };
    const client = getClient();
    const requestId = client.getNextRequestId();
    const request: IGetInteractiveSnapshotRequest = {
      requestId,
      ...options
    };
    client.addListener("interactiveSnapshot", listener, requestId);
    client.post("getInteractiveSnapshot", request);
  });
};

/**
 * @todo Implement this function.
 */
export const getLibraryInteractiveList = (options: IGetLibraryInteractiveListRequest) => {
  THROW_NOT_IMPLEMENTED_YET("getLibraryInteractiveList");
};

export const writeAttachment = (params: WriteAttachmentParams): Promise<Response> => {
  return new Promise<Response>((resolve, reject) => {
    const client = getClient();
    const { content, options = {}, ...others } = params;
    const { contentType = "text/plain" } = params;
    const request: IAttachmentUrlRequest = { ...others, operation: "write", requestId: client.getNextRequestId() };
    client.addListener("attachmentUrl", async (response: IAttachmentUrlResponse) => {
      if (response.url) {
        const headers: Record<string, string> = { ...(options.headers as Record<string, string>) };
        headers["Content-Type"] = contentType;
        options.headers = headers;
        try {
          // resolves with the fetch Response object, so clients can check status
          resolve(await fetch(response.url, { ...options, method: "PUT", body: content }));
        }
        catch (e) {
          reject(e);
        }
      }
      else {
        reject(new Error(response.error || "error writing attachment"));
      }
    }, request.requestId);
    client.post("getAttachmentUrl", request);
  });
};

export const readAttachment = (params: ReadAttachmentParams): Promise<Response> => {
  return new Promise<Response>((resolve, reject) => {
    // set up response listener
    const client = getClient();
    const request: IAttachmentUrlRequest = { ...params, operation: "read", requestId: client.getNextRequestId() };
    client.addListener("attachmentUrl", async (response: IAttachmentUrlResponse) => {
      if (response.url) {
        try {
          // resolves with the fetch Response object, so clients can check status
          // or convert to JSON or text or something else.
          resolve(await fetch(response.url));
        }
        catch (e) {
          reject(e);
        }
      }
      else {
        reject(new Error(response.error || "error reading attachment"));
      }
    }, request.requestId);
    client.post("getAttachmentUrl", request);
  });
};

export const getAttachmentUrl = (params: GetAttachmentUrlParams) => {
  return new Promise<string>((resolve, reject) => {
    // set up response listener
    const client = getClient();
    const requestId = client.getNextRequestId();
    const request: IAttachmentUrlRequest = { ...params, operation: "read", requestId };
    client.addListener("attachmentUrl", async (response: IAttachmentUrlResponse) => {
      if (response.url) {
        resolve(response.url);
      }
      else {
        reject(new Error(response.error || "error getting attachment url"));
      }
    }, request.requestId);
    client.post("getAttachmentUrl", request);
  });
};

export const sendReportItemAnswer = (request: Omit<IReportItemAnswer, "requestId">) => {
  getClient().post("reportItemAnswer", request);
};

export const setOnUnload = (onUnload?: OnUnloadFunction) => {
  getClient().setOnUnload(onUnload);
};

export const sendCustomMessage = (customMessage: ICustomMessage) => {
  getClient().post("customMessage", customMessage);
};
