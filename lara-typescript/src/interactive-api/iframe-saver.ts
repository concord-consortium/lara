
import { ParentEndpoint } from "iframe-phone";
import * as LaraInteractiveApi from "../interactive-api-client";
import { IframePhoneManager } from "./iframe-phone-manager";
import { IAuthInfo } from "../interactive-api-client";

const getAuthoredState = ($dataDiv: JQuery) => {
  let authoredState = $dataDiv.data("authored-state");
  if ((authoredState == null) || (authoredState === "")) {
    authoredState = null;
  }
  if (typeof authoredState === "string") {
    authoredState = JSON.parse(authoredState);
  }
  return authoredState;
};

interface IInteractiveRunStateResponse {
  raw_data: string;
  has_linked_interactive: boolean;
  linked_state: string;
  all_linked_states: IInteractiveRunStateResponse[];
  created_at: string;
  updated_at: string;
  interactive_state_url: string;
  interactive_id: number;
  interactive_name: string;
  page_number: number;
  page_name: string;
  activity_name: string;
}

// tslint:disable-next-line:max-line-length
const interactiveStateProps = (data: IInteractiveRunStateResponse | null): LaraInteractiveApi.IInteractiveStateProps => ({
  interactiveState: (data != null ? JSON.parse(data.raw_data) : undefined),
  hasLinkedInteractive: (data != null ? data.has_linked_interactive : undefined),
  linkedState: (data != null ? JSON.parse(data.linked_state) : undefined),
  allLinkedStates: (data != null ? data.all_linked_states.map(interactiveStateProps) : undefined),
  createdAt: (data != null ? data.created_at : undefined),
  updatedAt: (data != null ? data.updated_at : undefined),
  interactiveStateUrl: (data != null ? data.interactive_state_url : undefined),

  interactive: {
    // Keep default values `undefined` (data?.something returns undefined if data is not available),
    // as they might be obtained the other way. See "init_interactive" function which extends basic data using object
    // returned from this one. `undefined` ensures that we won"t overwrite a valid value.
    id: (data != null ? data.interactive_id : undefined),
    name: (data != null ? data.interactive_name : undefined)
  },

  pageNumber: (data != null ? data.page_number : undefined),
  pageName: (data != null ? data.page_name : undefined),
  activityName: (data != null ? data.activity_name : undefined)
});

type SuccessCallback = () => void;

export class IFrameSaver {

  private static instances: IFrameSaver[] = [];

  private static defaultSuccess() {
    // tslint:disable-next-line:no-console
    console.log("saved");
  }

  private $iframe: JQuery;
  private $deleteButton: JQuery;
  private enableLearnerState: boolean;
  private interactiveRunStateUrl: string;
  private collaboratorUrls: string;
  private authProvider: string;
  private userEmail: string;
  private loggedIn: boolean;
  private authoredState: object | null;
  private classInfoUrl: string;
  private interactiveId: number;
  private interactiveName: string;
  private getFirebaseJWTUrl: string;
  private saveIndicator: SaveIndicator;
  private savedState: object | string | null;
  private autoSaveIntervalId: number | null;
  private alreadySetup: boolean;
  private iframePhone: ParentEndpoint;
  private successCallback: SuccessCallback | null;

  constructor($iframe: JQuery, $dataDiv: JQuery, $deleteButton: JQuery) {
    this.$iframe = $iframe;
    this.$deleteButton = $deleteButton;
    this.enableLearnerState = $dataDiv.data("enable-learner-state");
    this.interactiveRunStateUrl = $dataDiv.data("interactive-run-state-url"); // get and put our data here.
    this.collaboratorUrls = $dataDiv.data("collaborator-urls");
    this.authProvider = $dataDiv.data("authprovider"); // through which provider did the current user log in
    this.userEmail = $dataDiv.data("user-email");
    this.loggedIn = $dataDiv.data("loggedin"); // true/false - is the current session associated with a user
    this.authoredState = getAuthoredState($dataDiv); // state / configuration provided during authoring
    this.classInfoUrl = $dataDiv.data("class-info-url");
    this.interactiveId = $dataDiv.data("interactive-id");
    this.interactiveName = $dataDiv.data("interactive-name");
    this.getFirebaseJWTUrl = $dataDiv.data("get-firebase-jwt-url");

    this.saveIndicator = SaveIndicator.instance();

    this.$deleteButton.click(() => this.deleteData());

    this.savedState = null;
    this.autoSaveIntervalId = null;

    if (this.learnerStateSavingEnabled()) {
      IFrameSaver.instances.push(this);
    }

    this.alreadySetup = false;

    this.iframePhone = IframePhoneManager.getPhone($iframe[0] as HTMLIFrameElement, () => this.phoneAnswered());
  }

  private phoneAnswered() {
    // Workaround IframePhone problem - phone_answered cabllack can be triggered multiple times:
    // https://www.pivotaltracker.com/story/show/89602814
    if (this.alreadySetup) {
      return;
    }
    this.alreadySetup = true;

    this.addListener("setLearnerUrl", (learnerUrl: string) => {
      this.saveLearnerUrl(learnerUrl);
    });

    this.addListener("interactiveState", (interactiveJson: string | object | null) => {
      this.saveLearnerState(interactiveJson);
    });

    this.addListener("getAuthInfo", () => {
      const authInfo: IAuthInfo = {
        provider: this.authProvider,
        loggedIn: this.loggedIn
      };
      if (this.userEmail != null) {
        authInfo.email = this.userEmail;
      }
      this.post("authInfo", authInfo);
    });

    this.addListener("height", (height: number | string) => {
      this.$iframe.data("height", height);
      this.$iframe.trigger("sizeUpdate");
    });

    this.addListener("supportedFeatures", (info: LaraInteractiveApi.ISupportedFeatures) => {
      if (info.features && info.features.aspectRatio) {
        // If the author specifies the aspect-ratio-method as "DEFAULT"
        // then the Interactive can provide suggested aspect-ratio.
        if (this.$iframe.data("aspect-ratio-method") === "DEFAULT") {
          this.$iframe.data("aspect-ratio", info.features.aspectRatio);
          this.$iframe.trigger("sizeUpdate");
        }
      }
    });

    this.addListener("navigation", (opts: LaraInteractiveApi.INavigationOptions) => {
      if (opts == null) { opts = {}; }
      if (opts.hasOwnProperty("enableForwardNav")) {
        if (opts.enableForwardNav) {
          return ForwardBlocker.instance.enable_forward_navigation_for(this.$iframe[0]);
        } else {
          return ForwardBlocker.instance.prevent_forward_navigation_for(this.$iframe[0], opts.message);
        }
      }
    });

    this.addListener("getFirebaseJWT", (opts: LaraInteractiveApi.IGetFirebaseJwtOptions) => {
      if (opts == null) { opts = {}; }
      return this.getFirebaseJwt(opts);
    });

    if (this.learnerStateSavingEnabled()) {
      this.post("getLearnerUrl");
    }

    // Enable autosave after model is loaded. Theoretically we could save empty model before it's loaded,
    // so its state would be lost.
    return this.loadInteractive(() => {
      return this.setAutoSaveEnabled(true);
    });
  }

  private error(msg: string) {
    return this.saveIndicator.showSaveFailed(msg);
  }

  private learnerStateSavingEnabled() {
    return this.enableLearnerState && this.interactiveRunStateUrl;
  }

  private save(successCallback: SuccessCallback | null = null) {
    this.successCallback = successCallback;
    // will call back into "@save_learner_state)
    return this.post("getInteractiveState");
  }

  private confirmDelete(callback: () => void) {
    if (window.confirm("Are you sure you want to restart your work in this model?")) {
      return callback();
    }
  }

  private deleteData() {
    // Disable autosave, as it's possible that autosave will be triggered *after* we send to server "null" state
    // (delete it). Actually it used to happen quite often.
    this.setAutoSaveEnabled(false);

    this.successCallback = () => {
      window.location.reload();
    };
    this.confirmDelete(() => {
      this.saveLearnerState(null);
      this.saveLearnerUrl("");
    });
  }

  private saveLearnerState(interactiveJson: string | object | null) {
    if (!this.learnerStateSavingEnabled()) { return; }

    const runSuccess = () => {
      this.savedState = interactiveJson;
      if (this.successCallback) {
        return this.successCallback();
      } else {
        return IFrameSaver.defaultSuccess();
      }
    };

    // Do not send the same state to server over and over again.
    // "nochange" is a special type of response.
    // "touch" is an another special type of response which will triger timestamp update only.
    if ((interactiveJson !== "touch") &&
        ((interactiveJson === "nochange") || (JSON.stringify(interactiveJson) === JSON.stringify(this.savedState)))) {
      runSuccess();
      return;
    }

    this.saveIndicator.showSaving();
    const data = interactiveJson === "touch" ? {} : { raw_data: JSON.stringify(interactiveJson) };
    $.ajax({
      type: "PUT",
      dataType: "json",
      url: this.interactiveRunStateUrl,
      data,
      success: response => {
        runSuccess();
        // State has been saved. Show "Undo all my work" button.
        this.$deleteButton.show();
        this.saveIndicator.showSaved("Saved Interactive");
      },
      error: () => {
        this.error("couldn't save interactive");
      }
    });
  }

  private saveLearnerUrl(learnerUrl: string) {
    if (!this.learnerStateSavingEnabled()) { return; }
    return $.ajax({
      type: "PUT",
      dataType: "json",
      url: this.interactiveRunStateUrl,
      data: {
        learner_url: learnerUrl
      },
      error: () => {
        this.error("couldn't save learner url");
      }
    });
  }

  private loadInteractive(callback: () => void) {
    if (!this.learnerStateSavingEnabled()) {
      this.initInteractive();
      callback();
      return;
    }

    return $.ajax({
      url: this.interactiveRunStateUrl,
      success: (response: IInteractiveRunStateResponse) => {
        if (response.raw_data) {
          const interactive = JSON.parse(response.raw_data);
          if (interactive) {
            this.savedState = interactive;
            // DEPRECATED: the initInteractive message includes the interactive state so
            // interactives should use the initInteractive method instead
            this.post("loadInteractive", interactive);
            // Lab logging needs to be re-enabled after interactive is (re)loaded.
            LoggerUtils.enableLabLogging(this.$iframe[0]);
            // State is available. Show "Undo all my work" button.
            this.$deleteButton.show();
          }
        }
        this.initInteractive(null, response);
      },
      error: () => {
        this.initInteractive("couldn't load interactive");
        this.error("couldn't load interactive");
      },
      complete: () => {
        callback();
      }
    });
  }

  // this is the newer method of initializing an interactive
  // it returns the current state and linked state
  private initInteractive(err: string | null = null, response: IInteractiveRunStateResponse | null = null) {
    const  globalInteractiveState = (typeof globalIframeSaver !== "undefined" && globalIframeSaver !== null)
      ? globalIframeSaver.globalState
      : null;
    const initInteractiveMsg: LaraInteractiveApi.IInitInteractive = {
      version: 1,
      error: err,
      mode: "runtime",
      authoredState: this.authoredState,
      interactiveState: null,  // set in interactiveStateProps()
      globalInteractiveState,
      interactiveStateUrl: this.interactiveRunStateUrl,
      collaboratorUrls: (this.collaboratorUrls != null) ? this.collaboratorUrls.split(";") : null,
      classInfoUrl: this.classInfoUrl,
      interactive: {
        id: this.interactiveId,
        name: this.interactiveName
      },
      authInfo: {
        provider: this.authProvider,
        loggedIn: this.loggedIn,
        email: this.userEmail
      }
    };

    // Perhaps it would be nicer to keep `interactiveStateProps` in some separate property instead of mixing
    // it directly into general init message. However, multiple interactives are already using this format
    // and it doesn't seem to be worth changing at this point.
    $.extend(true, initInteractiveMsg, interactiveStateProps(response));
    this.post("initInteractive", initInteractiveMsg);
  }

  private setAutoSaveEnabled(enabled: boolean) {
    if (!this.learnerStateSavingEnabled()) {
      return;
    }

    // Save interactive every 5 seconds, on window focus and iframe mouseout just to be safe.
    // Focus event is attached to the window, so it has to have unique namespace. Mouseout is attached to the iframe
    // itself, but other code can use that event too (e.g. logging).
    const namespace = `focus.iframe_saver_${this.$iframe.data("id")}`;
    const focusNamespace = `focus.${namespace}`;
    const mouseoutNamespace = `mouseout.${namespace}`;

    if (enabled) {
      this.autoSaveIntervalId = setInterval((() => this.save()), 5 * 1000);
      $(window).on(focusNamespace, () => this.save());
      return this.$iframe.on(mouseoutNamespace, () => this.save());
    } else {
      if (this.autoSaveIntervalId) {
        clearInterval(this.autoSaveIntervalId);
      }
      $(window).off(focusNamespace);
      return this.$iframe.off(mouseoutNamespace);
    }
  }

  private getFirebaseJwt(opts: LaraInteractiveApi.IGetFirebaseJwtOptions) {
    return $.ajax({
      type: "POST",
      url: this.getFirebaseJWTUrl,
      data: opts,
      success: response => {
        this.post("firebaseJWT", response);
      },
      error: (jqxhr, status, error) => {
        this.post("firebaseJWT", {response_type: "ERROR", message: error});
      }});
  }

  private post(message: LaraInteractiveApi.ServerMessage, content?: object | string | number | null) {
    this.iframePhone.post(message, content);
  }

  private addListener(message: LaraInteractiveApi.ClientMessage, listener: (content: any) => void) {
    this.iframePhone.addListener(message, listener);
  }
}
