import * as iframePhone from "iframe-phone";

export namespace LaraInteractiveApi {

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

  export interface IInteractiveStateProps<InteractiveState = {}> {
    interactiveState: InteractiveState | null;
    hasLinkedInteractive?: boolean;
    linkedState?: object;
    allLinkedStates?: IInteractiveStateProps[];
    createdAt?: string;
    updatedAt?: string;
    interactiveStateUrl?: string;
    interactive: {
      id?: number;
      name?: string;
    };
    pageNumber?: number;
    pageName?: string;
    activityName?: string;
  }

  // tslint:disable-next-line:max-line-length
  interface IRuntimeInitInteractive<AuthoredState = {}, InteractiveState = {}, GlobalInteractiveState = {}> extends IInteractiveStateProps<InteractiveState> {
    version: 1;
    error: any;
    mode: "runtime";
    authoredState: AuthoredState | null;
    globalInteractiveState: GlobalInteractiveState | null;
    interactiveStateUrl: string;
    collaboratorUrls: string[] | null;
    classInfoUrl: string;
    interactive: {
      id: number;
      name: string;
    };
    authInfo: {
      provider: string;
      loggedIn: boolean;
      email: string;
    };
  }

  interface IAuthoringInitInteractive<AuthoredState = {}> {
    version: 1;
    error: null;
    mode: "authoring";
    authoredState: AuthoredState | null;
  }

  interface IReportInitInteractive<AuthoredState = {}, InteractiveState = {}> {
    version: 1;
    mode: "report";
    authoredState: AuthoredState;
    interactiveState: InteractiveState;
  }

  export type IInitInteractive<AuthoredState = {}, InteractiveState = {}, GlobalInteractiveState = {}> =
    IRuntimeInitInteractive<AuthoredState, InteractiveState, GlobalInteractiveState> |
    IAuthoringInitInteractive<AuthoredState> |
    IReportInitInteractive<AuthoredState, InteractiveState>;

  export interface IAuthInfo {
    provider: string;
    loggedIn: boolean;
    email?: string;
  }

  export type ClientMessage = "setLearnerUrl" | "interactiveState" | "height" | "getAuthInfo" |
                              "supportedFeatures" | "navigation" | "getFirebaseJWT" | "authoredState";

  export type ServerMessage = "hello" | // hello is from base iframe-phone
                              "authInfo" | "getLearnerUrl" | "getInteractiveState" | "loadInteractive" |
                              "initInteractive" | "firebaseJWT";

  export interface ISupportedFeatures {
    apiVersion: 1;
    features: {
      aspectRatio?: string;
      authoredState?: boolean;
    };
  }

  export interface INavigationOptions {
    enableForwardNav?: boolean;
    message?: string;
  }

  export interface IGetFirebaseJwtOptions {
    firebase_app?: string;
  }

  export interface IFirebaseJwtResponse {
    response_type?: "ERROR";
    message?: string;
    token?: string;
  }

  export interface IClientOptions<AuthoredState = {}, InteractiveState = {}, GlobalInteractiveState = {}> {
    name: string;
    verbosity?: VerbosityLevel;
    startDisconnected?: boolean;
    supportedFeatures?: ISupportedFeatures;
    onHello?: () => void;
    onLoadInteractive?: (interactiveState: InteractiveState | null) => void;
    // tslint:disable-next-line:max-line-length
    onInitInteractive?: (initMessage: IInitInteractive<AuthoredState, InteractiveState, GlobalInteractiveState>) => void;
    onGetLearnerUrl?: () => string | null;
    onGetInteractiveState?: () => InteractiveState | string | null;
  }

  export const InIframe = inIframe;

  export class Client<AuthoredState = {}, InteractiveState = {}, GlobalInteractiveState = {}> {

    public static GetLocalVerbosityLevel(name: string) {
      const level =
        window.localStorage.getItem(`LaraInteractiveApiVerbosity[${name}]`) ||
        window.localStorage.getItem(`LaraInteractiveApiVerbosity`);
      return level !== null ? level as VerbosityLevel : undefined;
    }

    private phone: iframePhone.IFrameEndpoint | undefined;
    private options: IClientOptions<AuthoredState, InteractiveState, GlobalInteractiveState>;

    constructor(options: IClientOptions<AuthoredState, InteractiveState, GlobalInteractiveState>) {
      options.verbosity = Client.GetLocalVerbosityLevel(options.name) || options.verbosity;
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

          this.addListener("hello", () => {
            if (this.options.onHello) {
              this.log("debug", "onHello listener called, calling client callback");
              this.options.onHello();
            } else {
              this.log("debug", "onHello listener called, no client callback found");
            }

            if (this.options.supportedFeatures) {
              this.setSupportedFeatures(this.options.supportedFeatures);
            }
          });

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

          this.addListener("initInteractive",
            // tslint:disable-next-line:max-line-length
            (initMessage: LaraInteractiveApi.IInitInteractive<AuthoredState, InteractiveState, GlobalInteractiveState>) => {
              if (this.options.onInitInteractive) {
                this.log("debug", "initInteractive listener called, calling client callback");
                this.options.onInitInteractive(initMessage);
              } else {
                this.log("debug", "initInteractive listener called, no client callback found");
              }
          });

          this.addListener("loadInteractive", (interactiveState: InteractiveState | null) => {
            if (this.options.onLoadInteractive) {
              this.log("debug", "loadInteractive listener called, calling client callback");
              this.options.onLoadInteractive(interactiveState);
            } else {
              this.log("debug", "loadInteractive listener called, no client callback found");
            }
          });

          this.phone.initialize();
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

    public setInteractiveState(interactiveState: InteractiveState | string | null) {
      return this.post("interactiveState", interactiveState);
    }

    public setHeight(height: number | string) {
      return this.post("height", height);
    }

    public setSupportedFeatures(supportedFeatures: ISupportedFeatures) {
      return this.post("supportedFeatures", supportedFeatures);
    }

    public setNavigation(options: INavigationOptions) {
      return this.post("navigation", options);
    }

    public setAuthoredState(authoredState: AuthoredState) {
      return this.post("authoredState", authoredState);
    }

    public getAuthInfo(): Promise<IAuthInfo> {
      return new Promise<IAuthInfo>((resolve, reject) => {
        if (!this.phone) {
          this.log("debug", "#getAuthInfo: this.phone undefined");
          return reject("Not in iframe");
        }
        const listener = (authInfo: IAuthInfo) => {
          resolve(authInfo);
          this.removeListener("authInfo");
        };
        this.addListener("authInfo", listener);
        this.post("getAuthInfo");
      });
    }

    public getFirebaseJWT(options: IGetFirebaseJwtOptions): Promise<string> {
      return new Promise<string>((resolve, reject) => {
        if (!this.phone) {
          this.log("debug", "#getFirebaseJWT: this.phone undefined");
          return reject("Not in iframe");
        }
        const listener = (response: IFirebaseJwtResponse) => {
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

    public post(message: ClientMessage, content?: InteractiveState | AuthoredState | object | string | number | null) {
      if (this.phone) {
        this.log("debug", "#post: calling this.phone.post() with", message, content);
        this.phone.post(message, content as any);
        return true;
      }
      this.log("debug", "#post: this.phone undefined for", message, content);
      return false;
    }

    public addListener(message: ServerMessage, listener: (content: any) => void) {
      if (this.phone) {
        this.log("debug", "#addListener: calling this.phone.addListener() for", message);
        this.phone.addListener(message, listener);
        return true;
      }
      this.log("debug", "#addListener: this.phone undefined for", message);
      return false;
    }

    public removeListener(message: ServerMessage) {
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
}
