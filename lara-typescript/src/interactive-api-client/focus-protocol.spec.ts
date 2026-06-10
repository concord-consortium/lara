import { mockIFramePhone, MockPhone } from "../interactive-api-lara-host/mock-iframe-phone";
import * as iframePhone from "iframe-phone";
import * as api from "./api";
import { getClient } from "./client";

jest.mock("./in-frame", () => ({
  inIframe: () => true
}));

jest.mock("iframe-phone", () => {
  return mockIFramePhone();
});

const mockedPhone = iframePhone.getIFrameEndpoint() as unknown as MockPhone;

describe("focus protocol client helpers", () => {
  beforeEach(() => {
    mockedPhone.reset();
    getClient();
  });

  it("sendFocusExit posts a focusExit message", () => {
    api.sendFocusExit("escape");
    expect(mockedPhone.messages).toEqual([{ type: "focusExit", content: { mode: "escape" } }]);
  });

  it("addFocusEnterListener receives the mode from a focusEnter message", () => {
    const modes: string[] = [];
    api.addFocusEnterListener(mode => modes.push(mode));
    mockedPhone.fakeServerMessage({ type: "focusEnter", content: { mode: "forward" } });
    mockedPhone.fakeServerMessage({ type: "focusEnter", content: { mode: "restore" } });
    expect(modes).toEqual(["forward", "restore"]);
  });

  it("removeFocusEnterListener stops delivery", () => {
    const modes: string[] = [];
    api.addFocusEnterListener(mode => modes.push(mode));
    api.removeFocusEnterListener();
    mockedPhone.fakeServerMessage({ type: "focusEnter", content: { mode: "forward" } });
    expect(modes).toEqual([]);
  });

  it("setSupportedFeatures forwards focusProtocol", () => {
    api.setSupportedFeatures({ focusProtocol: true });
    expect(mockedPhone.messages).toEqual([{
      type: "supportedFeatures",
      content: { apiVersion: 1, features: { focusProtocol: true } }
    }]);
  });
});
