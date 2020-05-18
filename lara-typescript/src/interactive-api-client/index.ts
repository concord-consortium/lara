import * as iframePhone from "iframe-phone";
import { ILaraInteractiveApiAuthInfo, LaraInteractiveApiClientMessage, LaraInteractiveApiServerMessage,
         ILaraInteractiveApiSupportedFeatures, ILaraInteractiveApiNavigationOptions,
         ILaraInteractiveGetFirebaseJwtOptions, ILaraInteractiveFirebaseJwtResponse, ILaraInteractiveApiInitInteractive
       } from "./types";

const verbosityLevels = {
  error: 0,
  warning: 1,
  info: 2,
  debug: 3,
  all: 4
};
type VerbosityLevel = keyof typeof verbosityLevels;

const inIframe = (() => {
  try {
    return window.self !== window.top;
  }
  catch (e) {
    return true;
  }
})();

export * from "./types";

export interface ILaraInteractiveApiClientOptions {
  name: string;
  verbosity?: VerbosityLevel;
  startDisconnected?: boolean;
  onInitInteractive?: (initMessage: ILaraInteractiveApiInitInteractive) => void;
  onGetLearnerUrl?: () => string | null;
  onGetInteractiveState?: () => object | string | null;
}

export class LaraInteractiveApiClient {
  public static GetLocalVerbosityLevel(name: string) {
    const level =
      window.localStorage.getItem(`LaraInteractiveApiVerbosity[${name}]`) ||
      window.localStorage.getItem(`LaraInteractiveApiVerbosity`);
    return level !== null ? level as VerbosityLevel : undefined;
  }

  private phone: iframePhone.IFrameEndpoint | undefined;
  private options: ILaraInteractiveApiClientOptions;

  constructor(options: ILaraInteractiveApiClientOptions) {
    options.verbosity = LaraInteractiveApiClient.GetLocalVerbosityLevel(options.name) || options.verbosity;
    this.options = options;
    this.log("debug", "constructor: verbosity level is", options.verbosity);

    if (inIframe) {
      this.log("debug", "constructor: in iframe");
      if (!options.startDisconnected) {
        this.log("debug", "constructor: automatically connecting");
        this.connect();
      }
    } else {
      this.log("debug", "constructor: not in iframe");
    }
  }

  public connect() {
    if (inIframe) {
      if (!this.phone) {
        this.log("debug", "#connect: connecting");
        this.phone = iframePhone.getIFrameEndpoint();

        this.addListener("getLearnerUrl", () => {
          if (this.options.onGetLearnerUrl) {
            const learnerUrl = this.options.onGetLearnerUrl();
            this.log("debug", "getLearnerUrl listener called, client returned:", learnerUrl);
            this.setLearnerUrl(learnerUrl);
          } else {
            this.log("debug", "getLearnerUrl listener called, no client callback found");
          }
        });

        this.addListener("getInteractiveState", () => {
          if (this.options.onGetInteractiveState) {
            const interactiveState = this.options.onGetInteractiveState();
            this.log("debug", "getInteractiveState listener called, client returned:", interactiveState);
            this.setInteractiveState(interactiveState);
          } else {
            this.log("debug", "getInteractiveState listener called, no client callback found");
          }
        });

        this.addListener("initInteractive", (initMessage: ILaraInteractiveApiInitInteractive) => {
          if (this.options.onInitInteractive) {
            this.log("debug", "initInteractive listener called, calling client callback");
            this.options.onInitInteractive(initMessage);
          } else {
            this.log("debug", "initInteractive listener called, no client callback found");
          }
        });
      } else {
        this.log("info", "#connect: this.phone already connected");
      }
      return true;
    }
    this.log("error", "#connect: not in iframe");
    return false;
  }

  public disconnect() {
    if (inIframe) {
      if (this.phone) {
        this.log("debug", "#disconnect: disconnecting");
        this.phone.disconnect();
        this.phone = undefined;
      } else {
        this.log("info", "#disconnect: this.phone already disconnected");
      }
      return true;
    }
    this.log("error", "#disconnect: not in iframe");
    return false;
  }

  public get inIFrame() {
    return inIframe;
  }

  public setLearnerUrl(url: string | null) {
    return this.post("setLearnerUrl", url);
  }

  public setInteractiveState(interactiveState: string | object | null) {
    return this.post("interactiveState", interactiveState);
  }

  public setHeight(height: number | string) {
    return this.post("height", height);
  }

  public setSupportedFeatures(supportedFeatures: ILaraInteractiveApiSupportedFeatures) {
    return this.post("supportedFeatures", supportedFeatures);
  }

  public setNavigation(options: ILaraInteractiveApiNavigationOptions) {
    return this.post("navigation", options);
  }

  public getAuthInfo(): Promise<ILaraInteractiveApiAuthInfo> {
    return new Promise<ILaraInteractiveApiAuthInfo>((resolve, reject) => {
      if (!this.phone) {
        this.log("debug", "#getAuthInfo: this.phone undefined");
        return reject("Not in iframe");
      }
      const listener = (authInfo: ILaraInteractiveApiAuthInfo) => {
        resolve(authInfo);
        this.removeListener("authInfo");
      };
      this.addListener("authInfo", listener);
      this.post("authInfo");
    });
  }

  public getFirebaseJWT(options: ILaraInteractiveGetFirebaseJwtOptions): Promise<string> {
    return new Promise<string>((resolve, reject) => {
      if (!this.phone) {
        this.log("debug", "#getFirebaseJWT: this.phone undefined");
        return reject("Not in iframe");
      }
      const listener = (response: ILaraInteractiveFirebaseJwtResponse) => {
        if (response.response_type === "ERROR") {
          reject(response.message || "Error getting Firebase JWT");
        } else {
          resolve(response.token);
        }
        this.removeListener("firebaseJWT");
      };
      this.addListener("firebaseJWT", listener);
      this.post("getFirebaseJWT", options);
    });
  }

  private post(message: LaraInteractiveApiClientMessage, content?: object | string | number | null) {
    if (this.phone) {
      this.log("debug", "#post: calling this.phone.post() with", message, content);
      this.phone.post(message, content);
      return true;
    }
    this.log("debug", "#post: this.phone undefined for", message, content);
    return false;
  }

  private addListener(message: LaraInteractiveApiServerMessage, listener: (content: any) => void) {
    if (this.phone) {
      this.log("debug", "#addListener: calling this.phone.addListener() for", message);
      this.phone.addListener(message, listener);
      return true;
    }
    this.log("debug", "#addListener: this.phone undefined for", message);
    return false;
  }

  private removeListener(message: LaraInteractiveApiServerMessage) {
    if (this.phone) {
      this.log("debug", "#removeListener: calling this.phone.removeListener() for", message);
      this.phone.removeListener(message);
      return true;
    }
    this.log("debug", "#removeListener: this.phone undefined for", message);
    return false;
  }

  private log(level: VerbosityLevel, ...args: any) {
    const { name, verbosity } = this.options;
    if (verbosity && (verbosityLevels[level] <= verbosityLevels[verbosity])) {
      // tslint:disable-next-line:no-console
      const logger = level === "error" ? console.error : (level === "warning" ? console.warn : console.info);
      logger.apply(this, [`[${level}]: ${name}`, ...args]);
    }
  }
}
