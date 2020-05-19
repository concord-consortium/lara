import { GlobalIframeSaver } from "./global-iframe-saver";

export * from "./iframe-phone-manager";
export * from "./global-iframe-saver";
export * from "./iframe-saver";

$(document).ready(() => {
  if (gon.globalInteractiveState != null) {
    (window as any).globalIframeSaver = new GlobalIframeSaver(gon.globalInteractiveState);
  }
});
