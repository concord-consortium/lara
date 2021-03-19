import { ISupportedFeatures } from "../interactive-api-client/types";
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

/**
 * Data passed to InteractiveSupportedFeatures event handlers.
 */
export interface IInteractiveSupportedFeaturesEvent {
  /**
   * Interactive container of the interactive that was just started.
   */
  container: HTMLElement;
  /**
   * Supported features
   */
  supportedFeatures: ISupportedFeatures;
}

export interface IPluginSyncUpdate {
  status: "started" | "working" | "failed" | "completed";
  message?: string;
}

export type PluginSyncUpdateCallback = (update: IPluginSyncUpdate) => void;

export interface IPluginSyncEvent {
  maxUpdateCallbackInterval: number;
  updateCallback: PluginSyncUpdateCallback;
}

// Events for plugin communication.

/**
 * SupportedFeatures event handler.
 */
export type IInteractiveSupportedFeaturesEventHandler = (event: IInteractiveSupportedFeaturesEvent) => void;

/**
 * PluginSync event handler.
 */
export type IPluginSyncRequestEventHandler = (event: IPluginSyncEvent) => void;

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

export const emitInteractiveSupportedFeatures = (event: IInteractiveSupportedFeaturesEvent) => {
  emitter.emit("interactiveSupportedFeatures", event);
};
export const onInteractiveSupportedFeatures = (handler: IInteractiveSupportedFeaturesEventHandler) => {
  emitter.on("interactiveSupportedFeatures", handler);
};
export const offInteractiveSupportedFeatures = (handler: IInteractiveSupportedFeaturesEventHandler) => {
  emitter.off("interactiveSupportedFeatures", handler);
};

export const emitPluginSyncRequest = (event: IPluginSyncEvent) => {
  emitter.emit("PluginSyncRequest", event);
};
export const onPluginSyncRequest = (handler: IPluginSyncRequestEventHandler) => {
  emitter.on("PluginSyncRequest", handler);
};
export const offPluginSyncRequest = (handler: IPluginSyncRequestEventHandler) => {
  emitter.off("PluginSyncRequest", handler);
};
