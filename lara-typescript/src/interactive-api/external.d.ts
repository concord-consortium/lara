declare class SaveIndicator {
  public static instance(): SaveIndicator;
  public showSaveFailed(message?: string): void;
  public showSaving(): void;
  public showSaved(message?: string): void;
  public showUnauthorized(): void;
}

declare const gon: {
  globalInteractiveState: IGlobalIframeSaverConfig
};

// NOTE: this is only a partial description, using only the methods used in the api .ts files
declare const LoggerUtils: {
  enableLabLogging: (iframeEl: HTMLElement) => void;
};

declare class ForwardBlocker {
  public static instance: ForwardBlocker;
  public enable_forward_navigation_for(el: HTMLElement): void;
  public prevent_forward_navigation_for(el: HTMLElement, message?: string): void;
}

declare const globalIframeSaver: GlobalIframeSaver;
