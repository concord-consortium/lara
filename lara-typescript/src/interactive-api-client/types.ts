interface ILaraInteractiveApiRuntimeInitInteractive {
  version: 1;
  error: any;
  mode: "runtime";
  authoredState: object | null;
  globalInteractiveState: object | null;
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

export type ILaraInteractiveApiInitInteractive = ILaraInteractiveApiRuntimeInitInteractive;

export interface ILaraInteractiveApiAuthInfo {
  provider: string;
  loggedIn: boolean;
  email?: string;
}

export type LaraInteractiveApiClientMessage = "setLearnerUrl" | "interactiveState" | "height" |
                                              "supportedFeatures" | "navigation" | "authInfo" | "getFirebaseJWT";

export type LaraInteractiveApiServerMessage = "authInfo" | "getLearnerUrl" | "getInteractiveState" | "loadInteractive" |
                                              "initInteractive" | "firebaseJWT";

export interface ILaraInteractiveApiSupportedFeatures {
  features: {
    aspectRatio: string;
  };
}

export interface ILaraInteractiveApiNavigationOptions {
  enableForwardNav?: boolean;
}

export interface ILaraInteractiveGetFirebaseJwtOptions {
  firebase_app?: string;
}

export interface ILaraInteractiveFirebaseJwtResponse {
  response_type?: "ERROR";
  message?: string;
  token?: string;
}
