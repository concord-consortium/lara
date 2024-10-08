// iframe phone uses 1 listener per message type so we multiplex over 1 listener in this code
// to allow callbacks to optionally be tied to a requestId.  This allows us to have multiple listeners
// to the same message and auto-removing listeners when a requestId is given.
import * as iframePhone from "iframe-phone";
import { ClientMessage, ICustomMessageHandler, ICustomMessagesHandledMap, IInitInteractive, ISupportedFeaturesRequest,
         ServerMessage, ITextDecorationHandler, ITextDecorationInfo, IGetReportItemAnswerHandler,
         IGetInteractiveState, OnUnloadFunction } from "./types";
import { postDecoratedContentEvent } from "../interactive-api-client";
import { inIframe } from "./in-frame";
import { ManagedState } from "./managed-state";

interface IRequestCallback {
  requestId?: number;
  callback: iframePhone.ListenerCallback;
}
interface IListenerMap {
  [key: string]: IRequestCallback[];
}

const parseJSONIfString = (data: any) => {
  // Note that we don't want to call JSON.parse for an empty string.
  try {
    return typeof data === "string" ? JSON.parse(data) : data;
  } catch {
    // If JSON string is malformed, it's an empty string, or not a JSON at all, return the original value.
    return data;
  }
};

const phoneInitialized = () => iframePhone.getIFrameEndpoint().getListenerNames().length > 0;

let clientInstance: Client;
export const getClient = () => {
  // !phoneInitialized() part isn't really necessary. But it's fine in web browser and it helps in testing environment.
  // Tests can reset mock iframe phone and get new Client instance.
  if (!clientInstance || !phoneInitialized()) {
    clientInstance = new Client();
  }
  return clientInstance;
};

/**
 * This class is intended to provide basic helpers (like `post()` or `add/removeListener`), maintain client-specific
 * state, and generally be as minimal as possible. Most of the client-specific helpers and logic can be implemented
 * in api.ts or hooks.ts (or both so the client app has choice).
 */
export class Client {
  public phone: iframePhone.IFrameEndpoint = iframePhone.getIFrameEndpoint();
  public managedState = new ManagedState();
  public customMessagesHandled: ICustomMessagesHandledMap;

  private listeners: IListenerMap = {};
  private requestId = 1;

  private onUnload: OnUnloadFunction | undefined = undefined;

  constructor() {
    if (!inIframe()) {
      // tslint:disable-next-line:no-console
      console.warn("Interactive API is meant to be used in iframe");
    }
    if (phoneInitialized()) {
      throw new Error("IframePhone has been initialized previously. Only one Client instance is allowed.");
    }
    this.connect();

    // Warn users when they want to reload page before the data gets sent to LARA.
    window.addEventListener("beforeunload", (e) => {
      if (this.managedState.interactiveStateDirty) {
        // Browser will display different message anyway, but returnValue must be set.
        e.returnValue = "State has not been saved. Are you sure you want to leave this page?";
      }
      return e;
    });
  }

  public getNextRequestId() {
    return this.requestId++;
  }

  public post(message: ClientMessage, content?: any) {
    this.phone.post(message, content);
  }

  public addListener(message: ServerMessage, callback: iframePhone.ListenerCallback, requestId?: number) {
    if (this.phone) {
      // add either a generic message listener (no requestId) or an auto-removing request listener
      // note: we may have multiple listeners on the same generic message
      this.listeners[message] = this.listeners[message] || [];
      const noExistingListener = this.listeners[message].length === 0;
      this.listeners[message].push({ requestId, callback });

      // iframe-phone only handles 1 listener per message so add the listener if we haven't already
      if (noExistingListener) {
        this.phone.addListener(message, (content?: any) => {
          // strip requestId from the response so callbacks don't see it
          const contentRequestId = content ? content.requestId : undefined;
          if (content) {
            delete content.requestId;
          }

          this.listeners[message].forEach(listener => {
            // note: requestId can be undefined for listeners to Lara messages
            // that aren't responses to one-time requests
            if (listener.requestId === contentRequestId) {
              listener.callback(content);
            }
          });

          // if a request id was returned by lara auto-remove it from the listeners as it is a
          // response to a one-time request
          if (contentRequestId) {
            this.removeListener(message, contentRequestId);
          }
        });
      }
      return true;
    }
    return false;
  }

  public removeListener(message: ServerMessage, requestId?: number, callback?: iframePhone.ListenerCallback) {
    if (this.listeners[message]) {
      // When callback is provided, remove this particular callback.
      // Otherwise try to use requestId.
      if (callback) {
        this.listeners[message] = this.listeners[message].filter(l => l.callback !== callback);
      } else {
        // note: requestId can be undefined when using it as a generic listener
        this.listeners[message] = this.listeners[message].filter(l => l.requestId !== requestId);
      }
      // if no more local listeners exist remove it from iframe-phone
      if (this.listeners[message].length === 0) {
        this.phone.removeListener(message);
      }
      return true;
    }

    return false;
  }

  public setSupportedFeatures = (request: ISupportedFeaturesRequest) => {
    let newRequest = request;
    if (this.customMessagesHandled) {
      const { features, ...others } = request;
      features.customMessages = { handles: this.customMessagesHandled };
      newRequest = { features, ...others };
    }
    this.post("supportedFeatures", newRequest);
  }

  public setOnUnload = (onUnload?: OnUnloadFunction) => {
    this.onUnload = onUnload;
  }

  private connect() {
    this.phone = iframePhone.getIFrameEndpoint();

    this.addListener("initInteractive", (newInitMessage: IInitInteractive<any, any, any>) => {
      this.managedState.initMessage = newInitMessage;

      // parseJSONIfString is used below quite a few times, as LARA and report are not consistent about format.
      // Sometimes they send string (report page), sometimes already parsed JSON (authoring, runtime).
      if (newInitMessage.mode === "reportItem") {
        this.managedState.authoredState = {};
      } else {
        this.managedState.authoredState = parseJSONIfString(newInitMessage.authoredState);
      }
      if (newInitMessage.mode === "runtime" || newInitMessage.mode === "report") {
        this.managedState.interactiveState = parseJSONIfString(newInitMessage.interactiveState);
        // Don't consider initial state to be dirty, as user would see warnings while trying to leave page even
        // without making any change.
        this.managedState.interactiveStateDirty = false;
      }
      if (newInitMessage.mode === "runtime") {
        this.managedState.globalInteractiveState = parseJSONIfString(newInitMessage.globalInteractiveState);
      }
    });

    this.addListener("getInteractiveState", async (options?: IGetInteractiveState) => {
      if (options?.unloading && this.onUnload) {
        // call the interactive's registered onUnload function
        // and if it returns a value use that as the final interactive state
        const finalState = await this.onUnload(options);
        if (finalState) {
          this.managedState.interactiveState = finalState;
        }
      }
      this.post("interactiveState", this.managedState.interactiveState);
      this.managedState.interactiveStateDirty = false;
    });

    this.addListener("loadInteractiveGlobal", (globalState: any) => {
      this.managedState.globalInteractiveState = parseJSONIfString(globalState);
    });

    this.phone.initialize();
  }
}
