import { ParentEndpoint } from "iframe-phone";
import { IframePhoneManager } from "./iframe-phone-manager";
import { GlobalIFrameSaverClientMessage, GlobalIFrameSaverServerMessage } from "../interactive-api-client/types";

export interface IGlobalIframeSaverConfig {
  save_url: string;
  raw_data?: string;
}

export class GlobalIframeSaver {

  private saveUrl: string;
  private globalState: object | null;
  private saveIndicator: SaveIndicator;
  private iframePhones: ParentEndpoint[];

  constructor(config: IGlobalIframeSaverConfig) {
    this.saveUrl = config.save_url;
    this.globalState = config.raw_data ? JSON.parse(config.raw_data) : null;

    this.saveIndicator = SaveIndicator.instance();
    this.iframePhones = [];
  }

  public addNewInteractive(iframeEl: HTMLIFrameElement) {
    const phone = IframePhoneManager.getPhone($(iframeEl)[0]);
    this.iframePhones.push(phone);
    this.setupPhoneListeners(phone);
    if (this.globalState) {
      this.loadGlobalState(phone);
    }
  }

  private setupPhoneListeners(phone: ParentEndpoint) {
    const clientMessage: GlobalIFrameSaverClientMessage = "interactiveStateGlobal";
    phone.addListener(clientMessage, (state: object) => {
      this.globalState = state;
      this.saveGlobalState();
      this.broadcastGlobalState(phone);
    });
  }

  private loadGlobalState(phone: ParentEndpoint) {
    const serverMessage: GlobalIFrameSaverServerMessage = "loadInteractiveGlobal";
    phone.post(serverMessage, this.globalState);
  }

  private broadcastGlobalState(sender: ParentEndpoint) {
    this.iframePhones.forEach(phone => {
      // Do not send state again to the same iframe that posted global state.
      if (phone !== sender) {
        this.loadGlobalState(phone);
      }
    });
  }

  private saveGlobalState() {
    this.saveIndicator.showSaving();
    return $.ajax({
      type: "POST",
      url: this.saveUrl,
      data: {
        raw_data: JSON.stringify(this.globalState)
      },
      success: () => {
        this.saveIndicator.showSaved();
      },
      error: (jqxhr) => {
        if (jqxhr.status === 401) {
          this.saveIndicator.showUnauthorized();
          $(document).trigger("unauthorized");
        } else {
          this.saveIndicator.showSaveFailed();
        }
      }
    });
  }
}
