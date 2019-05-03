import {onLog, offLog, onClickToPlayStarted, offClickToPlayStarted} from "../lib/events";
import {IClickToPlayStartedEventHandler, ILogEventHandler} from "./types";

/**
 * Functions related to event observing provided by LARA.
 */
export const events = {
  /**
   * Subscribes to log events. Gets called when any event is logged to the CC Log Manager app.
   */
  onLog: (handler: ILogEventHandler) => onLog(handler),
  /**
   * Removes log event handler.
   */
  offLog: (handler: ILogEventHandler) => offLog(handler),
  /**
   * Subscribes to ClickToPlayStarted events. Gets called when any interactive that has click to play mode enabled
   * is started by the user.
   */
  onClickToPlayStarted: (handler: IClickToPlayStartedEventHandler) => onClickToPlayStarted(handler),
  /**
   * Removes ClickToPlayStarted event handler.
   */
  offClickToPlayStarted: (handler: IClickToPlayStartedEventHandler) => offClickToPlayStarted(handler),
};
