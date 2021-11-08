import { ParentEndpoint } from "iframe-phone";
import * as DOMPurify from "dompurify";
import { IframePhoneManager } from "./iframe-phone-manager";
import { IFrameSaverPluginApi } from "./iframe-saver-plugin";
import { ModalApiPlugin } from "./modal-api-plugin";
import {
  handleGetAttachmentUrl, ClientMessage, IAnswerMetadataWithAttachmentsInfo, IAttachmentUrlRequest, IGetAuthInfoRequest,
  IGetAuthInfoResponse, IGetFirebaseJwtRequest, IGetFirebaseJwtResponse, IGetInteractiveSnapshotRequest,
  IGetInteractiveSnapshotResponse, IHintRequest, IInitInteractive, IInteractiveStateProps, ILinkedInteractive,
  INavigationOptions, initializeAttachmentsManager, ISupportedFeaturesRequest, ServerMessage
} from "@concord-consortium/interactive-api-host";
import { EnvironmentName } from "@concord-consortium/token-service";

// Shutterbug is imported globally and used by the old LARA JS code.
const Shutterbug = (window as any).Shutterbug;

const getTokenServiceEnv = () => {
  const host = window.location.hostname;
  if (host.match(/staging\./)) {
    return "staging";
  }
  if (host.match(/concord\.org/)) {
    return "production";
  }
  return "staging";
};

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

const getLinkedInteractives = ($dataDiv: JQuery) => {
  let linkedInteractives = $dataDiv.data("linked-interactives");
  if ((linkedInteractives == null) || (linkedInteractives === "")) {
    linkedInteractives = {};
  }
  if (typeof linkedInteractives === "string") {
    linkedInteractives = safeJSONParse(linkedInteractives) || {};
  }
  return linkedInteractives;
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
  interactive_question_id: string;
  page_number: number;
  page_name: string;
  activity_name: string;
  metadata: string;
  external_report_url: string;
}

const safeJSONParse = (obj: any) => {
  try {
    return JSON.parse(obj);
  } catch (e) {
    return undefined;
  }
};

// tslint:disable-next-line:max-line-length
const interactiveStateProps = (data: IInteractiveRunStateResponse | null): IInteractiveStateProps => ({
  interactiveState: (data != null ? safeJSONParse(data.raw_data) : undefined),
  hasLinkedInteractive: (data != null ? data.has_linked_interactive : undefined),
  linkedState: (data != null ? safeJSONParse(data.linked_state) : undefined),
  // tslint:disable-next-line:max-line-length
  allLinkedStates: (data != null && data.all_linked_states ? data.all_linked_states.map(interactiveStateProps) : undefined),
  createdAt: (data != null ? data.created_at : undefined),
  updatedAt: (data != null ? data.updated_at : undefined),
  interactiveStateUrl: (data != null ? data.interactive_state_url : undefined),

  interactive: {
    // Keep default values `undefined` (data?.something returns undefined if data is not available),
    // as they might be obtained the other way. See "init_interactive" function which extends basic data using object
    // returned from this one. `undefined` ensures that we won"t overwrite a valid value.
    id: (data != null ? data.interactive_id : undefined),
    name: (data != null ? data.interactive_name : undefined),
    questionId: (data != null ? data.interactive_question_id : undefined),
  },

  pageNumber: (data != null ? data.page_number : undefined),
  pageName: (data != null ? data.page_name : undefined),
  activityName: (data != null ? data.activity_name : undefined),

  externalReportUrl: (data != null ? data.external_report_url : undefined)
});

type SuccessCallback = () => void;

// the api client sends requestIds to route back to the correct callback but existing interactives do not
// these types allow for the requestId to be set in the client but be optional here
// TODO: AFTER TYPESCRIPT UPGRADE REPLACE WITH OPTIONAL TYPES (Omit not avaiable in current version)
// type Optional<T, K extends keyof T> = Pick<Partial<T>, K> & Omit<T, K>;
// type IGetAuthInfoRequestOptionalRequestId = Optional<IGetAuthInfoRequest, "requestId">;
// type IGetAuthInfoResponseOptionalRequestId = Optional<IGetAuthInfoResponse, "requestId">;
// type IGetFirebaseJwtRequestOptionalRequestId = Optional<IGetFirebaseJwtRequest, "requestId">;
// type IGetFirebaseJwtResponseOptionalRequestId = Optional<IGetFirebaseJwtResponse, "requestId">;
type IGetAuthInfoRequestOptionalRequestId = IGetAuthInfoRequest;
type IGetAuthInfoResponseOptionalRequestId = IGetAuthInfoResponse;
type IGetFirebaseJwtRequestOptionalRequestId = IGetFirebaseJwtRequest;
type IGetFirebaseJwtResponseOptionalRequestId = IGetFirebaseJwtResponse;

export class IFrameSaver {

  private static instances: IFrameSaver[] = [];
  private static isAttachmentsManagerInitialized = false;

  private static defaultSuccess() {
    // tslint:disable-next-line:no-console
    console.log("saved");
  }

  public saveIndicator: SaveIndicator;
  public interactiveRunStateUrl: string;

  private $iframe: JQuery;
  private $deleteButton: JQuery;
  private enableLearnerState: boolean;
  private collaboratorUrls: string;
  private authProvider: string;
  private userEmail: string;
  private loggedIn: boolean;
  private authoredState: object | null;
  private classInfoUrl: string;
  private interactiveId: number;
  private interactiveName: string;
  private interactiveQuestionId: string;
  private getFirebaseJWTUrl: string;
  private runKey: string | undefined;
  private runRemoteEndpoint: string | undefined;
  private metadata: object | undefined;
  private savedState: object | string | null;
  private autoSaveIntervalId: number | null;
  private alreadySetup: boolean;
  private iframePhone: ParentEndpoint;
  private successCallback: SuccessCallback | null | undefined;
  private plugins: IFrameSaverPluginApi[];
  private linkedInteractives: ILinkedInteractive[];

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
    this.interactiveQuestionId = $dataDiv.data("interactive-question-id");
    this.getFirebaseJWTUrl = $dataDiv.data("get-firebase-jwt-url");
    this.runKey = $dataDiv.data("run-key");
    this.runRemoteEndpoint = $dataDiv.data("run-remote-endpoint");
    this.linkedInteractives = getLinkedInteractives($dataDiv);

    this.saveIndicator = SaveIndicator.instance();

    this.$deleteButton.click(() => this.deleteData());

    this.savedState = null;
    this.autoSaveIntervalId = null;

    if (this.learnerStateSavingEnabled()) {
      IFrameSaver.instances.push(this);
    }

    this.alreadySetup = false;

    this.iframePhone = IframePhoneManager.getPhone($iframe[0] as HTMLIFrameElement, () => this.phoneAnswered());

    this.plugins = [ModalApiPlugin(this.iframePhone)];

    this.initializeAttachmentsManager();
  }

  public save(successCallback?: SuccessCallback | null) {
    this.successCallback = successCallback;
    // will call back into "@save_learner_state)
    return this.post("getInteractiveState");
  }

  public saveLearnerState(interactiveJson: string | object | null) {
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

  public saveMetadata(metadata: object) {
    if (!this.learnerStateSavingEnabled()) { return; }

    if (JSON.stringify(metadata) === JSON.stringify(this.metadata)) {
      return;
    }

    this.saveIndicator.showSaving();
    $.ajax({
      type: "PUT",
      dataType: "json",
      url: this.interactiveRunStateUrl,
      data: { metadata: JSON.stringify(metadata) },
      success: response => {
        this.metadata = metadata;
        this.saveIndicator.showSaved("Saved Interactive");
      },
      error: () => {
        this.error("couldn't save interactive metadata");
      }
    });
  }

  private async initializeAttachmentsManager() {
    if (!IFrameSaver.isAttachmentsManagerInitialized) {
      // Try to initialize manager only once.
      IFrameSaver.isAttachmentsManagerInitialized = true;
      try {
        // Lack of runRemoteEndpoint means that the run is anonymous.
        const tokenServiceJWT = this.runRemoteEndpoint ? (await this.getFirebaseJwt("token-service")).token : undefined;
        initializeAttachmentsManager({
          tokenServiceEnv: getTokenServiceEnv(),
          tokenServiceFirestoreJWT: tokenServiceJWT,
          writeOptions: {
            // LARA non-anonymous runs have both runRemoteEndpoint and runKey. In this case don't provide runKey
            // to ensure that AttachmentsManager uses runRemoteEndpoint only.
            runKey: this.runRemoteEndpoint ? undefined : this.runKey,
            runRemoteEndpoint: this.runRemoteEndpoint
          }
        });
      } catch (error) {
        // tslint:disable-next-line:no-console
        console.error("AttachmentsManager can't be initialized", error);
      }
    }
  }

  private phoneAnswered() {
    // Workaround IframePhone problem - phone_answered callback can be triggered multiple times:
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

    this.addListener("getAuthInfo", (request: IGetAuthInfoRequestOptionalRequestId) => {
      const authInfo: IGetAuthInfoResponseOptionalRequestId = {
        requestId: request.requestId,  // TODO: after typescript upgrade remove this line!
        provider: this.authProvider,
        loggedIn: this.loggedIn
      };
      // requestId may be undefined for interactives that don't use the client
      if (request.requestId) {
        authInfo.requestId = request.requestId;
      }
      if (this.userEmail != null) {
        authInfo.email = this.userEmail;
      }
      this.post("authInfo", authInfo);
    });

    this.addListener("height", (height: number | string) => {
      this.$iframe.data("height", height);
      this.$iframe.trigger("sizeUpdate");
    });

    this.addListener("hint", (hintRequest: IHintRequest) => {
      const $container = this.$iframe.closest(".embeddable-container");
      const $helpIcon = $container.find(".help-icon");
      if (hintRequest.text) {
        $helpIcon.removeClass("hidden");
      } else {
        $container.find(".help-icon").addClass("hidden");
      }
      const html = DOMPurify.sanitize(hintRequest.text || "");
      $container.find(".help-content .text").html(html);
    });

    this.addListener("supportedFeatures", (info: ISupportedFeaturesRequest) => {
      if (info.features && info.features.aspectRatio) {
        // If the author specifies the aspect-ratio-method as "DEFAULT"
        // then the Interactive can provide suggested aspect-ratio.
        if (this.$iframe.data("aspect-ratio-method") === "DEFAULT") {
          this.$iframe.data("aspect-ratio", info.features.aspectRatio);
          this.$iframe.trigger("sizeUpdate");
        }
      }
    });

    this.addListener("navigation", (opts: INavigationOptions) => {
      if (opts == null) { opts = {}; }
      if (opts.hasOwnProperty("enableForwardNav")) {
        if (opts.enableForwardNav) {
          return ForwardBlocker.instance.enable_forward_navigation_for(this.$iframe[0]);
        } else {
          return ForwardBlocker.instance.prevent_forward_navigation_for(this.$iframe[0], opts.message);
        }
      }
    });

    this.addListener("getInteractiveSnapshot", (request: IGetInteractiveSnapshotRequest) => {
      return this.getInteractiveSnapshot(request);
    });

    this.addListener("getFirebaseJWT", (request?: IGetFirebaseJwtRequestOptionalRequestId) => {
      if (!request) {
        // This doesn't seem likely, but the old code was checking for empty / non-existing request, so let's do it too.
        // It's a bit of documentation too.
        this.post("firebaseJWT", {response_type: "ERROR", message: "Missing request data with firebase_app parameter"});
        return;
      }
      const requestId = request.requestId;
      const firebaseAppName = request.firebase_app;

      this.getFirebaseJwt(firebaseAppName)
        .then(data => {
          this.post("firebaseJWT", { requestId, token: data.token });
        })
        .catch(error => {
          this.post("firebaseJWT", { requestId, response_type: "ERROR", message: error });
        });
    });

    this.addListener("getAttachmentUrl", async (request: IAttachmentUrlRequest) => {
      let answerMeta: IAnswerMetadataWithAttachmentsInfo = this.metadata || {};
      if (request.questionId) {
        answerMeta = await this.getLinkedAnswerMetadata(request.questionId);
      }
      const response = await handleGetAttachmentUrl({
        request,
        answerMeta,
        writeOptions: {
          interactiveId: this.interactiveId.toString(),
          onAnswerMetaUpdate: newMeta => {
            // don't allow writes over passed in questionId (for now, until it is needed and thought through...)
            this.saveMetadata({...(this.metadata || {}), ...newMeta});
          }
        }
      });
      this.post("attachmentUrl", response);
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

  private async getLinkedAnswerMetadata(questionId: string) {
    // start with fallback to the current answer
    let answerMeta: IAnswerMetadataWithAttachmentsInfo = this.metadata || {};
    return new Promise<IAnswerMetadataWithAttachmentsInfo>((resolve) => {
      $.ajax({
        url: this.interactiveRunStateUrl,
        type: "GET",
        data: {
          question_id: questionId
        },
        success: (response: IInteractiveRunStateResponse) => {
          answerMeta = safeJSONParse(response.metadata);
        },
        complete: () => {
          resolve(answerMeta);
        }
      });
    });
  }

  private error(msg: string) {
    return this.saveIndicator.showSaveFailed(msg);
  }

  private learnerStateSavingEnabled() {
    return this.enableLearnerState && this.interactiveRunStateUrl;
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
        this.metadata = safeJSONParse(response.metadata);
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
    const initInteractiveMsg: IInitInteractive = {
      version: 1,
      error: err,
      mode: "runtime",
      hostFeatures: {
        modal: {
          version: "1.0.0",
          dialog: false,
          lightbox: true,
          alert: true
        },
        getFirebaseJwt: {
          version: "1.0.0",
        }
      },
      authoredState: this.authoredState,
      interactiveState: null,  // set in interactiveStateProps()
      globalInteractiveState,
      interactiveStateUrl: this.interactiveRunStateUrl,
      collaboratorUrls: (this.collaboratorUrls != null) ? this.collaboratorUrls.split(";") : null,
      classInfoUrl: this.classInfoUrl,
      interactive: {
        id: this.interactiveId,
        name: this.interactiveName,
        questionId: this.interactiveQuestionId
      },
      authInfo: {
        provider: this.authProvider,
        loggedIn: this.loggedIn,
        email: this.userEmail
      },
      linkedInteractives: this.linkedInteractives,
      themeInfo: {            // TODO: add theme colors (future story)
        colors: {
          colorA: "red",
          colorB: "green"
        }
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
      this.autoSaveIntervalId = window.setInterval((() => this.save()), 5 * 1000);
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

  private getFirebaseJwt(firebaseAppName: string): Promise<{token: string}> {
    return new Promise<{token: string}>((resolve, reject) => {
      $.ajax({
        type: "POST",
        url: this.getFirebaseJWTUrl,
        data: { firebase_app: firebaseAppName },
        success: (data: {token: string}) => {
          resolve(data);
        },
        error: (jqxhr, status, error) => {
          reject(error);
        }}
      );
    });
  }

  private getInteractiveSnapshot({ requestId, interactiveItemId }: IGetInteractiveSnapshotRequest) {
    const selector = `[data-interactive-item-id="${interactiveItemId}"]`;
    if (!jQuery(selector).length) {
      // tslint:disable-next-line:no-console
      console.error("Snapshot has failed - interactive ID not found");
      this.post("interactiveSnapshot", { requestId, success: false });
    }

    Shutterbug.snapshot({
      selector,
      done: (snapshotUrl: string) => {
        const response: IGetInteractiveSnapshotResponse = {
          requestId,
          snapshotUrl,
          success: true
        };
        this.post("interactiveSnapshot", response);
      },
      fail: (jqXHR: any, textStatus: any, errorThrown: any) => {
        // tslint:disable-next-line:no-console
        console.error("Snapshot request failed: ", textStatus, errorThrown);
        const response: IGetInteractiveSnapshotResponse = {
          requestId,
          success: false
        };
        this.post("interactiveSnapshot", response);
      }
    });
  }

  private post(message: ServerMessage, content?: object | string | number | null) {
    this.iframePhone.post(message, content);
  }

  private addListener(message: ClientMessage, listener: (content: any) => void) {
    this.iframePhone.addListener(message, listener);
  }

}
