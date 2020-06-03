import { IEmbeddableRuntimeContext, IInteractiveState } from "../plugin-api";
import { onInteractiveAvailable, IInteractiveAvailableEvent, IInteractiveAvailableEventHandler } from "../events";
import { IEmbeddableContextOptions } from "./plugin-context";

const getInteractiveState = (interactiveStateUrl: string | null): Promise<IInteractiveState> | null => {
  if (!interactiveStateUrl) {
    return null;
  }
  return fetch(interactiveStateUrl, {method: "get", credentials: "include"}).then(resp => resp.json());
};

const getReportingUrl = (
  interactiveStateUrl: string | null,
  interactiveStatePromise?: Promise<IInteractiveState>
): Promise<string | null> | null => {
  if (!interactiveStateUrl) {
    return null;
  }
  if (!interactiveStatePromise) {
    interactiveStatePromise = getInteractiveState(interactiveStateUrl)!;
  }
  return interactiveStatePromise.then(interactiveState => {
    try {
      const rawJSON = JSON.parse(interactiveState.raw_data);
      if (rawJSON && rawJSON.lara_options && rawJSON.lara_options.reporting_url) {
        return rawJSON.lara_options.reporting_url;
      }
      return null;
    }
    catch (error) {
      // tslint:disable-next-line:no-console
      console.error(error);
      return null;
    }
  });
};

export const generateEmbeddableRuntimeContext = (context: IEmbeddableContextOptions): IEmbeddableRuntimeContext => {
  return {
    container: context.container,
    laraJson: context.laraJson,
    getInteractiveState: () => getInteractiveState(context.interactiveStateUrl),
    getReportingUrl: (getInteractiveStatePromise?: Promise<IInteractiveState>) =>
      getReportingUrl(context.interactiveStateUrl, getInteractiveStatePromise),
    onInteractiveAvailable: (handler: IInteractiveAvailableEventHandler) => {
      // Add generic listener and filter events to limit them just to this given embeddable.
      onInteractiveAvailable((event: IInteractiveAvailableEvent) => {
        if (event.container === context.container) {
          handler(event);
        }
      });
    },
    interactiveAvailable: context.interactiveAvailable
  };
};
