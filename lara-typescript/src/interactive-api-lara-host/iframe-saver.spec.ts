import { mockIFramePhone, MockedIframePhoneManager, setAutoConnect } from "./mock-iframe-phone";
import { IFrameSaver } from "./iframe-saver";
import { IAttachmentUrlRequest } from "../interactive-api-host";

const parentEl = document.createElement("iframe");

jest.mock("iframe-phone", () => mockIFramePhone(parentEl));

const mockInitializeAttachmentsManager = jest.fn();
const mockHandleGetAttachmentUrl = jest.fn();
jest.mock("../interactive-api-host", () => ({
  initializeAttachmentsManager: (options: any) => mockInitializeAttachmentsManager(options),
  handleGetAttachmentUrl: (options: any) => mockHandleGetAttachmentUrl(options)
}));

const mockSaveIndicator = () => {
  return jest.fn().mockImplementation(() => ({
    showSaved: jest.fn(),
    showSaving: jest.fn(),
    showSaveFailed: jest.fn()
  }))();
};

const mockMetadata = {
  attachments: {
    "test.txt": {
      folder: {
        id: "1",
        ownerId: "user-1"
      },
      publicPath: "1/1",
      contentType: "text/plain"
    },
    "test.mp3": {
      folder: {
        id: "1",
        ownerId: "user-1"
      },
      publicPath: "1/2",
      contentType: "audio/mp3"
    }
  }
};

const getSaver = () => {
  (window as any).SaveIndicator = mockSaveIndicator();
  (window as any).SaveIndicator.instance = mockSaveIndicator;
  return new IFrameSaver($("#interactive"), $("#interactive_data_div"), $(".delete_interactive_data"));
};

let saver: IFrameSaver;
let fakeSaveIndicator: any;
let oldAjax: any;

describe("IFrameSaver", () => {
  beforeEach(() => {
    MockedIframePhoneManager.install();
    setAutoConnect(false);
    $(document.body).html(`
      <div class="embeddable-container">
        <div class="help-icon hidden"/>
        <div class="help-content"><div class="text">Test hint</div></div>

        <iframe src="" id="interactive" frameborder="0"></iframe>
        <div id="under_iframe">
          <div id="interactive_data_div"
              data-enable-learner-state="true"
              data-interactive-run-state-url="foo/42"
              data-authored-state='{"test": 123}'
              data-class-info-url=null
              data-interactive-id=1
              data-interactive-name="test"
              data-authprovider="fakeprovider"
              data-user-email="user@example.com"
              data-loggedin="true"
              data-linked-interactives='{"1":{"label":"one"}}'
              data-font-size="normal"
          >
          </div>
          <button class="delete_interactive_data">Clear & start over</button>
        </div>
      </div>

      <!-- save indicator -->
      <div id="save" class="" style="opacity: 0;">Your data will not be saved.</div>
    `);
  });

  afterEach(() => {
    MockedIframePhoneManager.uninstall();
  });

  describe("with an interactive in in iframe", () => {
    beforeEach(() => {
      fakeSaveIndicator = mockSaveIndicator();
      saver = getSaver();
      saver.saveIndicator = fakeSaveIndicator as unknown as SaveIndicator;
    });

    describe("a sane testing environment", () => {
      it("has an instance of IFrameSaver defined", () => expect(saver).toBeDefined());

      it("has an iframe to work with", () => expect($("#interactive")[0]).toBeDefined());

      it("has an interactive data element", () => expect($("#interactive_data_div")).toBeDefined());
    });

    describe("constructor called in the correct context", () => {
      it("should have a interactive run state url", () => expect(saver.interactiveRunStateUrl).toBe("foo/42"));
    });

    describe("save", () => {
      beforeEach(() => saver.save());

      it("invokes the correct message on the iframePhone", () => {
        expect(MockedIframePhoneManager.messages.findType("getInteractiveState")).toBeTruthy();
      });
    });

    describe("save learner state", () => {
      beforeEach(() => {
        oldAjax = $.ajax;
        $.ajax = jest.fn().mockImplementation((params: any) => {
          params.success();
        });
        saver.saveLearnerState({foo: "bar"});
      });

      afterEach(() => {
        $.ajax = oldAjax;
      });

      describe("a successful save", () => {
        it("should display the show saved indicator", () => {
          expect((fakeSaveIndicator as any).showSaveFailed).not.toHaveBeenCalled();
          expect((fakeSaveIndicator as any).showSaving).toHaveBeenCalled();
          expect((fakeSaveIndicator as any).showSaved).toHaveBeenCalled();
        });
      });
    });
  });

  describe("interactive initialization", () => {
    describe("when state saving is enabled", () => {
      let oldLoggerUtils: any;

      beforeEach(() => {
        oldAjax = $.ajax;
        oldLoggerUtils = (window as any).LoggerUtils;
        (window as any).LoggerUtils = jest.fn().mockImplementation(() => {
          return {
            enableLabLogging: jest.fn()
          };
        })();
        $.ajax = jest.fn().mockImplementation((params: any) => {
          params.success({
            raw_data: JSON.stringify({interactiveState: 321}),
            metadata: JSON.stringify(mockMetadata),
            created_at: "2017",
            updated_at: "2018",
            activity_name: "test act",
            page_name: "test page",
            page_number: 2
          });
        });
        $("#interactive_data_div").data("enable-learner-state", true);
        saver = getSaver();
        MockedIframePhoneManager.connect();
      });

      afterEach(() => {
        $.ajax = oldAjax;
        (window as any).LoggerUtils = oldLoggerUtils;
      });

      it("should post initInteractive", () => {
        expect(MockedIframePhoneManager.messages.findType("initInteractive").message.content).toEqual({
          version: 1,
          error: null,
          mode: "runtime",
          hostFeatures: {
            modal: {
              version: "1.0.0",
              alert: true,
              lightbox: true,
              dialog: false
            },
            getFirebaseJwt: {
              version: "1.0.0"
            },
            domain: "localhost"
          },
          authoredState: {test: 123},
          interactiveState: {interactiveState: 321},
          createdAt: "2017",
          updatedAt: "2018",
          globalInteractiveState: null,
          interactiveStateUrl: "foo/42",
          collaboratorUrls: null,
          classInfoUrl: null,
          interactive: {id: 1, name: "test"},
          authInfo: {provider: "fakeprovider", loggedIn: true, email: "user@example.com"},
          pageNumber: 2,
          pageName: "test page",
          activityName: "test act",
          linkedInteractives: {1: {label: "one"}},
          themeInfo: {
            colors: {
              colorA: "red",
              colorB: "green"
            }
          },
          attachments: {
            "test.mp3": {
              contentType: "audio/mp3",
            },
            "test.txt": {
              contentType: "text/plain",
            },
          },
          accessibility: {
            fontSize: "normal",
            fontSizeInPx: 16,
          },
        });
      });

      it("should parse interactive state and metadata", () => {
        expect((saver as any).savedState).toEqual({ interactiveState: 321 });
        expect((saver as any).metadata).toEqual(mockMetadata);
      });
    });

    describe("when state saving is disabled", () => {
      beforeEach(() => {
        $("#interactive_data_div").data("enable-learner-state", false);
        saver = getSaver();
        MockedIframePhoneManager.connect();
      });

      it("should post initInteractive", () => {
        expect(MockedIframePhoneManager.messages.findType("initInteractive").message.content).toEqual({
          version: 1,
          error: null,
          mode: "runtime",
          hostFeatures: {
            modal: {
              version: "1.0.0",
              alert: true,
              lightbox: true,
              dialog: false
            },
            getFirebaseJwt: {
              version: "1.0.0"
            },
            domain: "localhost"
          },
          authoredState: {test: 123},
          interactiveState: null,
          globalInteractiveState: null,
          interactiveStateUrl: "foo/42",
          collaboratorUrls: null,
          classInfoUrl: null,
          interactive: {id: 1, name: "test"},
          authInfo: {provider: "fakeprovider", loggedIn: true, email: "user@example.com"},
          linkedInteractives: {1: {label: "one"}},
          themeInfo: {
            colors: {
              colorA: "red",
              colorB: "green"
            }
          },
          attachments: {},
          accessibility: {
            fontSize: "normal",
            fontSizeInPx: 16,
          }
        });
      });
    });
  });

  describe("hint iframe-phone message", () => {
    beforeEach(() => {
      saver = getSaver();
      MockedIframePhoneManager.connect();
    });

    it("should enable hint", () => {
      const $helpIcon = $(".help-icon");
      expect($helpIcon.hasClass("hidden")).toEqual(true);
      MockedIframePhoneManager.postMessageFrom($("#interactive")[0], { type: "hint", content: {text: "new hint"} });
      expect($helpIcon.hasClass("hidden")).toEqual(false);
      expect($(".help-content .text").text()).toEqual("new hint");

      MockedIframePhoneManager.postMessageFrom($("#interactive")[0], { type: "hint", content: {text: ""} });
      expect($helpIcon.hasClass("hidden")).toEqual(true);
      expect($(".help-content .text").text()).toEqual("");
    });

    it("should support rich text (HTML) hints", () => {
      const richText = "<strong>Bold</strong> <em>Text</em>";
      MockedIframePhoneManager.postMessageFrom($("#interactive")[0], { type: "hint", content: {text: richText} });
      expect($(".help-content .text").html()).toEqual(richText);

      const scriptText = richText + `<script>alert("Oh, no you don't!")</script>`;
      MockedIframePhoneManager.postMessageFrom($("#interactive")[0], { type: "hint", content: {text: scriptText} });
      expect($(".help-content .text").html()).toEqual(richText);
    });
  });

  describe("showModal/closeModal iframe-phone messages", () => {
    beforeEach(() => {
      saver = getSaver();
      MockedIframePhoneManager.connect();
    });

    it("should have installed listeners for showModal/closeModal", () => {
      expect(MockedIframePhoneManager.hasListener("showModal")).toBe(true);
      expect(MockedIframePhoneManager.hasListener("closeModal")).toBe(true);
    });
  });

  describe("Attachments API iframe-phone messages", () => {

    beforeEach(() => {
      $.ajax = jest.fn().mockImplementation((params: any) => {
        params.success({
          metadata: JSON.stringify({
            attachmentFolder: { id: 123 },
            attachments: {
              "file.json": { publicPath: "123/123" }
            }
          }),
        });
      });
      $("#interactive_data_div").data("enable-learner-state", true);

      saver = getSaver();
      MockedIframePhoneManager.connect();
    });

    it("should have installed listeners for getAttachmentUrl", () => {
      expect(mockInitializeAttachmentsManager).toHaveBeenCalledTimes(1);
      expect(MockedIframePhoneManager.hasListener("getAttachmentUrl")).toBe(true);
    });

    it("should handle getAttachmentUrl", () => {
      expect(mockHandleGetAttachmentUrl).toHaveBeenCalledTimes(0);

      const content: IAttachmentUrlRequest = {
        name: "file.json",
        operation: "read",
        requestId: 1
      };
      MockedIframePhoneManager.postMessageFrom($("#interactive")[0], { type: "getAttachmentUrl", content });

      expect(mockHandleGetAttachmentUrl).toHaveBeenCalledTimes(1);
      expect(mockHandleGetAttachmentUrl.mock.calls[0][0].answerMeta).toEqual({
        attachmentFolder: {
          id: 123
        },
        attachments: {
          "file.json": {
            publicPath: "123/123"
          }
        }
      });
      expect(mockHandleGetAttachmentUrl.mock.calls[0][0].request).toEqual(content);
      expect(mockHandleGetAttachmentUrl.mock.calls[0][0].writeOptions.interactiveId).toEqual("1");
    });
  });
});
