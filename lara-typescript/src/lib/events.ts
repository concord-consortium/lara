import { EventEmitter2 } from "eventemitter2";
// The reason why ILogEventHandler lives in plugin-api instead of here,
// is because it needs to be documented in LARA Plugin API docs.
import { ILogEventHandler, IInteractiveAvailableEvent, IInteractiveAvailableEventHandler } from "../plugin-api";

const emitter = new EventEmitter2({
  maxListeners: Infinity
});

export const emitLog = (logData: any) => {
  emitter.emit("log", logData);
};
export const onLog = (handler: ILogEventHandler) => {
  emitter.on("log", handler);
};
export const offLog = (handler: ILogEventHandler) => {
  emitter.off("log", handler);
};

export const emitInteractiveAvailable = (event: IInteractiveAvailableEvent) => {
  emitter.emit("interactiveAvailable", event);
};
export const onInteractiveAvailable = (handler: IInteractiveAvailableEventHandler) => {
  emitter.on("interactiveAvailable", handler);
};
export const offInteractiveAvailable = (handler: IInteractiveAvailableEventHandler) => {
  emitter.off("interactiveAvailable", handler);
};
