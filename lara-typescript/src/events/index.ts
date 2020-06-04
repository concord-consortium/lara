import { EventEmitter2 } from "eventemitter2";

/**
 * That's the minimal set of properties that needs to be provided.
 * All the other properties provides go to the `extra` hash.
 */
export interface ILogData {
  event: string;
  event_value?: any;
  parameters?: any;
}

/**
 * Log event handler.
 * @param logData Data logged by the code.
 */
export type ILogEventHandler = (event: ILogData) => void;

/**
 * Data passed to InteractiveAvailable event handlers.
 */
export interface IInteractiveAvailableEvent {
  /**
   * Interactive container of the interactive that was just started.
   */
  container: HTMLElement;
  /**
   * Availablility of interactive
   */
  available: boolean;
}

/**
 * InteractiveAvailable event handler.
 */
export type IInteractiveAvailableEventHandler = (event: IInteractiveAvailableEvent) => void;

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
