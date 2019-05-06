import { ILogData } from "./types";

/**
 * Logs event to the CC Log Server. Note that logging must be enabled for a given activity.
 * Either by setting URL param logging=true or by enabling logging in Portal.
 * ```
 * PluginAPI.log("testEvent");
 * PluginAPI.log({event: "testEvent", event_value: 123});
 * PluginAPI.log({event: "testEvent", someExtraParam: 123});
 * PluginAPI.log({event: "testEvent", params: { paramInParamsHash: 123 }});
 * ```
 * @param logData Data to log. Can be either event name or hash with at least `event` property.
 */
export const log = (logData: string | ILogData) => {
  // Check app/assets/javascripts/logger.js
  const logger = (window as any).loggerUtils;
  if (logger) {
    logger.log(logData);
  }
};
