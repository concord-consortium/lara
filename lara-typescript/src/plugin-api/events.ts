import { onLog, offLog } from "../lib/events";
import { ILogEventHandler } from "./types";

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
  offLog: (handler: ILogEventHandler) => offLog(handler)
};
