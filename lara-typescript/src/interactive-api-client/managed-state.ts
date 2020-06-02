import { ClientEvent, IInitInteractive } from "./types";
import { EventEmitter2 } from "eventemitter2";
import * as deepFreeze from "deep-freeze";

export class ManagedState {
  private _initMessage: Readonly<IInitInteractive<any, any, any, any>> | null = null;
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
    if (typeof value === "object") {
      value = deepFreeze(value);
    }
    this._interactiveState = value;
    this.emit("interactiveStateUpdated", value);
  }

  public get authoredState() {
    return this._authoredState;
  }

  public set authoredState(value: any) {
    if (typeof value === "object") {
      value = deepFreeze(value);
    }
    this._authoredState = value;
    this.emit("authoredStateUpdated", value);
  }

  public get globalInteractiveState() {
    return this._globalInteractiveState;
  }

  public set globalInteractiveState(value: any) {
    if (typeof value === "object") {
      value = deepFreeze(value);
    }
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
