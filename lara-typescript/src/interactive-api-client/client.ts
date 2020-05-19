import * as iframePhone from "iframe-phone";

import { IClientOptions, IInitInteractive, ISupportedFeaturesRequest, INavigationOptions,
         IAuthInfo, IGetFirebaseJwtOptions, IFirebaseJwt, ClientMessage, ServerMessage,
         ISupportedFeatures
        } from "./types";
import { InIframe } from "./in-frame";

// iframe phone uses 1 listener per message type so we multipex over 1 listener in this code
// to allow callbacks to optionally be tied to a requestId.  This allows us to have multiple listeners
// to the same message and auto-removing listeners when a requestId is given
interface IRequestCallback {
  requestId?: number;
  callback: iframePhone.ListenerCallback;
}
interface IListenerMap {
  [key: string]: IRequestCallback[];
}

export class Client<AuthoredState = {}, InteractiveState = {}, GlobalInteractiveState = {}> {

  private phone: iframePhone.IFrameEndpoint | undefined;
  private options: IClientOptions<AuthoredState, InteractiveState, GlobalInteractiveState>;
  private requestId: number = 1;
  private listeners: IListenerMap = {};

  constructor(options: IClientOptions<AuthoredState, InteractiveState, GlobalInteractiveState>) {
    this.options = options;

    if (InIframe) {
      if (!options.startDisconnected) {
        this.connect();
      }
    }
  }

  public connect() {
    if (InIframe) {
      if (!this.phone) {
        this.phone = iframePhone.getIFrameEndpoint();

        this.addListener("hello", () => {
          if (this.options.onHello) {
            this.options.onHello();
          }
          if (this.options.supportedFeatures) {
            this.setSupportedFeatures(this.options.supportedFeatures);
          }
        });

        this.addListener("getInteractiveState", () => {
          if (this.options.onGetInteractiveState) {
            const interactiveState = this.options.onGetInteractiveState();
            this.setInteractiveState(interactiveState);
          }
        });

        this.addListener("initInteractive",
          // tslint:disable-next-line:max-line-length
          (initMessage: IInitInteractive<AuthoredState, InteractiveState, GlobalInteractiveState>) => {
            if (this.options.onInitInteractive) {
              this.options.onInitInteractive(initMessage);
            }
        });

        this.addListener("loadInteractiveGlobal", (globalState: GlobalInteractiveState) => {
          if (this.options.onGlobalInteractiveStateUpdated) {
            this.options.onGlobalInteractiveStateUpdated(globalState);
          }
        });

        this.phone.initialize();
      }

      return true;
    }

    return false;
  }

  // TODO: add listener and sender for global state changes

  public disconnect() {
    if (InIframe) {
      const phone = this.phone;
      if (phone) {
        Object.keys(this.listeners).forEach(message => phone.removeListener(message));
        this.listeners = {};
        phone.disconnect();
        this.phone = undefined;
      }

      return true;
    }

    return false;
  }

  public get inIFrame() {
    return InIframe;
  }

  public setInteractiveState(interactiveState: InteractiveState | string | null) {
    return this.post("interactiveState", interactiveState);
  }

  public setHeight(height: number | string) {
    return this.post("height", height);
  }

  public setSupportedFeatures(features: ISupportedFeatures) {
    const request: ISupportedFeaturesRequest = {
      apiVersion: 1,
      features
    };
    return this.post("supportedFeatures", request);
  }

  public setNavigation(options: INavigationOptions) {
    return this.post("navigation", options);
  }

  public setAuthoredState(authoredState: AuthoredState) {
    return this.post("authoredState", authoredState);
  }

  public setGlobalInteractiveState(globalState: GlobalInteractiveState) {
    return this.post("interactiveStateGlobal", globalState);
  }

  public getAuthInfo(): Promise<IAuthInfo> {
    return new Promise<IAuthInfo>((resolve, reject) => {
      if (!this.phone) {
        return reject("Not in iframe");
      }
      const listener = (authInfo: IAuthInfo) => {
        resolve(authInfo);
      };
      this.addListener("authInfo", listener, this.getNextRequestId());
      this.post("getAuthInfo");
    });
  }

  public getFirebaseJWT(options: IGetFirebaseJwtOptions): Promise<string> {
    return new Promise<string>((resolve, reject) => {
      if (!this.phone) {
        return reject("Not in iframe");
      }
      const listener = (response: IFirebaseJwt) => {
        if (response.response_type === "ERROR") {
          reject(response.message || "Error getting Firebase JWT");
        } else {
          resolve(response.token);
        }
      };
      this.addListener("firebaseJWT", listener, this.getNextRequestId());
      this.post("getFirebaseJWT", options);
    });
  }

  // tslint:disable-next-line:max-line-length
  public post(message: ClientMessage, content?: InteractiveState | AuthoredState | GlobalInteractiveState | object | string | number | null) {
    if (this.phone) {
      this.phone.post(message, content as any);
      return true;
    }
    return false;
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
        this.phone.addListener(message, (content: any) => {
          this.listeners[message].forEach(listener => {
            // note: requestId can be undefined for generic listeners
            if (listener.requestId === requestId) {
              listener.callback(content);
            }
          });

          // if a request id was given auto-remove it from the listeners
          if (requestId) {
            this.removeListener(message, requestId);
          }
        });
      }
      return true;
    }

    return false;
  }

  public removeListener(message: ServerMessage, requestId?: number) {
    if (this.phone && this.listeners[message]) {
      // note: requestId can be undefined when using it as a generic listener
      const newListeners = this.listeners[message].filter(l => l.requestId !== requestId);
      this.listeners[message] = newListeners;

      // if no more local listeners exist remove it from iframe-phone
      if (newListeners.length === 0) {
        this.phone.removeListener(message);
      }
      return true;
    }

    return false;
  }

  private getNextRequestId() {
    return this.requestId++;
  }
}
