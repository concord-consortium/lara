import { IEmbeddableRuntimeContext, IInteractiveState } from "../plugin-api";
import { onInteractiveAvailable, IInteractiveAvailableEvent, IInteractiveAvailableEventHandler,
        onInteractiveSupportedFeatures, IInteractiveSupportedFeaturesEvent, IInteractiveSupportedFeaturesEventHandler
        } from "../events";
import { ICustomMessage } from "../interactive-api-client/types";
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
        // Interactive has its own reporting_url
        return rawJSON.lara_options.reporting_url;
      }
      // Use a generic Portal Report URL
      if (interactiveState.external_report_url) {
        return interactiveState.external_report_url;
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

const setAnswerSharedWithClass = (shared: boolean, interactiveStateUrl: string | null) => {
  if (!interactiveStateUrl) {
    return Promise.reject("interactiveStateUrl not available");
  }
  return fetch(interactiveStateUrl, {
    method: "put",
    credentials: "include",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      metadata: {
        // class = context
        shared_with: shared ? "context" : null
      }
    })
  })
  // This is necessary, so TS doesn't complain about incompatibility of Promise<Response> and Promise<void>.
  .then(() => undefined);
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
    onInteractiveSupportedFeatures: (handler: IInteractiveSupportedFeaturesEventHandler) => {
      // Add generic listener and filter events to limit them just to this given embeddable.
      onInteractiveSupportedFeatures((event: IInteractiveSupportedFeaturesEvent) => {
        if (event.container === context.container) {
          handler(event);
        }
      });
    },
    interactiveAvailable: context.interactiveAvailable,
    sendCustomMessage: (message: ICustomMessage) => {
      context.sendCustomMessage?.(message);
    },
    setAnswerSharedWithClass: (shared: boolean) => setAnswerSharedWithClass(shared, context.interactiveStateUrl)
  };
};
