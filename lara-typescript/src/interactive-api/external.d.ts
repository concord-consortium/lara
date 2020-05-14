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

declare const LoggerUtils: NeedToDefineExternalType;

declare const ForwardBlocker: NeedToDefineExternalType;

declare const globalIframeSaver: GlobalIframeSaver;
