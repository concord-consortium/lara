import { mockIFramePhone, MockedIframePhoneManager, setAutoConnect, MockPhone } from "./mock-iframe-phone";
import { GlobalIframeSaver } from "./global-iframe-saver";

const parentEl = document.createElement("iframe");

jest.mock("iframe-phone", () => mockIFramePhone(parentEl));

const successResponse = {
  status: 200,
  responseText: "{}"
};

const saveUrl = "https://lara.url/global_state_endpoint";
const globalState = {key: "val"};

let oldAjax: any;
let globalSaver: GlobalIframeSaver;

const mockSaveIndicator = () => {
  return jest.fn().mockImplementation(() => ({
    showSaved: jest.fn(),
    showSaving: jest.fn(),
    showSaveFailed: jest.fn()
  }))();
};

(window as any).SaveIndicator = mockSaveIndicator();
(window as any).SaveIndicator.instance = mockSaveIndicator;

describe("GlobalIFrameSaver", () => {
  let ajaxParams: any;

  beforeEach(() => {
    oldAjax = $.ajax;
    $.ajax = jest.fn().mockImplementation((params: any) => {
      ajaxParams = params;
      params.success();
    });
    MockedIframePhoneManager.install();
    $(document.body).html(`
      <iframe src="" class="interactive"></iframe>
      <iframe src="" class="interactive"></iframe>
      <iframe src="" class="interactive"></iframe>
    `);
  });

  afterEach(() => {
    $.ajax = oldAjax;
    MockedIframePhoneManager.uninstall();
  });

  it("should broadcast global state if it is provided in config", () => {
    globalSaver = new GlobalIframeSaver({save_url: saveUrl, raw_data: JSON.stringify(globalState)});

    $("iframe").each((idx, iframeEl) => {
      globalSaver.addNewInteractive(iframeEl as HTMLIFrameElement);
    });

    expect(MockedIframePhoneManager.messages.count()).toEqual(3);
    $("iframe").each((idx, iframeEl) => {
      expect(MockedIframePhoneManager.messages.at(idx)).toEqual({
        source: window,
        target: iframeEl,
        message: {
          type: "loadInteractiveGlobal",
          content: globalState
        }
      });
    });
  });

  describe("when interactiveStateGlobal message is received from iframe", () => {
    beforeEach(() => {
      globalSaver = new GlobalIframeSaver({save_url: saveUrl});

      $("iframe").each((idx, iframeEl) => {
        globalSaver.addNewInteractive(iframeEl as HTMLIFrameElement);
      });

      MockedIframePhoneManager.postMessageFrom($("iframe")[0], {
        type: "interactiveStateGlobal", content: globalState
      });
    });

    it("should broadcast loadInteractiveGlobal to other iframes", () => {
      // Initial message.
      expect(MockedIframePhoneManager.messages.at(0)).toEqual({
        source: $("iframe")[0],
        target: window,
        message: {
          type: "interactiveStateGlobal",
          content: globalState
        }
      });
      // Messages posted by GlobalIframeSaver:
      expect(MockedIframePhoneManager.messages.at(1)).toEqual({
        source: window,
        target: $("iframe")[1],
        message: {
          type: "loadInteractiveGlobal",
          content: globalState
        }
      });
      expect(MockedIframePhoneManager.messages.at(2)).toEqual({
        source: window,
        target: $("iframe")[2],
        message: {
          type: "loadInteractiveGlobal",
          content: globalState
        }
      });
    });

    it("should send state to LARA server", () => {
      expect(ajaxParams.url).toBe(saveUrl);
      expect(ajaxParams.type).toBe("POST");
      expect(ajaxParams.data).toEqual({raw_data: JSON.stringify(globalState)});
    });
  });
});
