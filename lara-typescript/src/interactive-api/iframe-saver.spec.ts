import { mockIFramePhone, MockedIframePhoneManager, setAutoConnect } from "./mock-iframe-phone";
import { IFrameSaver } from "./iframe-saver";

const parentEl = document.createElement("iframe");

jest.mock("iframe-phone", () => mockIFramePhone(parentEl));

const successResponse = {
  status: 200,
  responseText: "{}"
};

const mockSaveIndicator = () => {
  return jest.fn().mockImplementation(() => ({
    showSaved: jest.fn(),
    showSaving: jest.fn(),
    showSaveFailed: jest.fn()
  }))();
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
          >
          </div>
          <button class="delete_interactive_data">Undo all my work</button>
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
          activityName: "test act"
        });
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
          authoredState: {test: 123},
          interactiveState: null,
          globalInteractiveState: null,
          interactiveStateUrl: "foo/42",
          collaboratorUrls: null,
          classInfoUrl: null,
          interactive: {id: 1, name: "test"},
          authInfo: {provider: "fakeprovider", loggedIn: true, email: "user@example.com"}
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
      MockedIframePhoneManager.postMessageFrom($("#interactive")[0], { type: "hint", content: "new hint" });
      expect($helpIcon.hasClass("hidden")).toEqual(false);
      expect($(".help-content .text").text()).toEqual("new hint");

      MockedIframePhoneManager.postMessageFrom($("#interactive")[0], { type: "hint", content: "" });
      expect($helpIcon.hasClass("hidden")).toEqual(true);
      expect($(".help-content .text").text()).toEqual("");
    });
  });
});
