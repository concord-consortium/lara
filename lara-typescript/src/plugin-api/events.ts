import {
  onLog, offLog, ILogEventHandler,
  onInteractiveAvailable, offInteractiveAvailable, IInteractiveAvailableEventHandler,
  onInteractiveSupportedFeatures, IInteractiveSupportedFeaturesEventHandler
} from "../events";
// Export event types as a part of Plugin API.
export {
  onLog, offLog, ILogData, ILogEventHandler,
  onInteractiveAvailable, offInteractiveAvailable,
  IInteractiveAvailableEvent, IInteractiveAvailableEventHandler,
  onInteractiveSupportedFeatures, offInteractiveSupportedFeatures,
  IInteractiveSupportedFeaturesEvent, IInteractiveSupportedFeaturesEventHandler
} from "../events";

/**
 * Functions related to event observing provided by LARA.
 */
export const events = {
  // Why do we need explicit delegation instead of something like:
  // onLog: onLogImpl
  // Because that's the only way for TypeDoc to pick up types and generate nice docs.

  /**
   * Subscribes to log events. Gets called when any event is logged to the CC Log Manager app.
   */
  onLog: (handler: ILogEventHandler) => onLog(handler),
  /**
   * Removes log event handler.
   */
  offLog: (handler: ILogEventHandler) => offLog(handler),
  /**
   * Subscribes to InteractiveAvailable events. Gets called when any interactive changes its availablity state.
   * Currently uses when click to play mode is enabled and the click to play overlay is clicked.
   */
  onInteractiveAvailable: (handler: IInteractiveAvailableEventHandler) => onInteractiveAvailable(handler),
  /**
   * Removes InteractiveAvailable event handler.
   */
  offInteractiveAvailable: (handler: IInteractiveAvailableEventHandler) => offInteractiveAvailable(handler),
  /**
   * Subscribes to InteractiveAvailable events. Gets called when any interactive changes its availablity state.
   * Currently uses when click to play mode is enabled and the click to play overlay is clicked.
   */
  onInteractiveSupportedFeatures:
    (handler: IInteractiveSupportedFeaturesEventHandler) => onInteractiveSupportedFeatures(handler),
  /**
   * Removes InteractiveAvailable event handler.
   */
  offInteractiveSupportedFeatures: (handler: IInteractiveAvailableEventHandler) => offInteractiveAvailable(handler),
};
