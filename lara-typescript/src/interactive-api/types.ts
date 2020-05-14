export interface IInitRuntimeInteractive {
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
