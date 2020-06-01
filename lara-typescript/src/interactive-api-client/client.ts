// iframe phone uses 1 listener per message type so we multipex over 1 listener in this code
// to allow callbacks to optionally be tied to a requestId.  This allows us to have multiple listeners
// to the same message and auto-removing listeners when a requestId is given
import * as iframePhone from "iframe-phone";
import { ClientEvent, ClientMessage, IInitInteractive, ServerMessage } from "./types";
import { EventEmitter2 } from "eventemitter2";
import { inIframe } from "./in-frame";
import deepFreeze from "deep-freeze";

interface IRequestCallback {
  requestId?: number;
  callback: iframePhone.ListenerCallback;
}
interface IListenerMap {
  [key: string]: IRequestCallback[];
}

let clientInstance: Client;
export const getClient = () => {
  if (!clientInstance) {
    clientInstance = new Client();
  }
  return clientInstance;
};

let instancesCount = 0;

class Client {
  public phone: iframePhone.IFrameEndpoint = iframePhone.getIFrameEndpoint();
  public listeners: IListenerMap = {};

  public managedState = new ManagedState();

  private requestId = 1;

  constructor() {
    if (!inIframe()) {
      throw new Error("Interactive API is meant to be used in iframe");
    }
    if (instancesCount > 0) {
      throw new Error("Only once Client instance is allowed");
    }
    instancesCount += 1;
    this.connect();
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

  public removeListener(message: ServerMessage, requestId?: number) {
    if (this.listeners[message]) {
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

  private connect() {
    this.phone = iframePhone.getIFrameEndpoint();

    this.addListener("initInteractive", (newInitMessage: IInitInteractive<any, any, any, any>) => {
      this.managedState.initMessage = newInitMessage;

      this.managedState.authoredState = newInitMessage.authoredState;
      if (newInitMessage.mode === "runtime" || newInitMessage.mode === "report") {
        this.managedState.interactiveState = newInitMessage.interactiveState;
      }
      if (newInitMessage.mode === "runtime") {
        this.managedState.globalInteractiveState = newInitMessage.globalInteractiveState;
      }
    });

    this.addListener("getInteractiveState", () => {
      this.post("interactiveState", this.managedState.interactiveState);
    });

    this.addListener("loadInteractiveGlobal", (globalState: any) => {
      this.managedState.globalInteractiveState = globalState;
    });

    this.phone.initialize();
  }
}

class ManagedState {
  public _initMessage: Readonly<IInitInteractive<any, any, any, any>> | null = null;
  // State variables are kept separately from initMessage, as they might get updated. For client user convenience,
  // this state is kept here and all the updates emit appropriate event.
  private _interactiveState: Readonly<any> | null = null;
  private _authoredState: Readonly<any> | null = null;
  private _globalInteractiveState: Readonly<any> | null = null;

  private emitter = new EventEmitter2({
    maxListeners: Infinity
  });

  public get initMessage() {
    return this._initMessage;
  }

  public set initMessage(value: any) {
    value = deepFreeze(value);
    this._initMessage = value;
    this.emit("initInteractive", value);
  }

  public get interactiveState() {
    return this._interactiveState;
  }

  public set interactiveState(value: any) {
    value = deepFreeze(value);
    this._interactiveState = value;
    this.emit("interactiveStateUpdated", value);
  }

  public get authoredState() {
    return this._authoredState;
  }

  public set authoredState(value: any) {
    value = deepFreeze(value);
    this._authoredState = value;
    this.emit("authoredStateUpdated", value);
  }

  public get globalInteractiveState() {
    return this._globalInteractiveState;
  }

  public set globalInteractiveState(value: any) {
    value = deepFreeze(value);
    this._globalInteractiveState = value;
    this.emit("globalInteractiveStateUpdated", value);
  }

  public emit(event: ClientEvent, content?: any) {
    this.emitter.emit(event, content);
  }

  public on(event: ClientEvent, handler: any) {
    this.emitter.on(event, handler);
  }

  public off(event: ClientEvent, handler: any) {
    this.emitter.off(event, handler);
  }

  public once(event: ClientEvent, handler: any) {
    this.emitter.once(event, handler);
  }
}
