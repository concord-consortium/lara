import { mockIFramePhone, MockedIframePhoneManager, MockPhone, setAutoConnect } from "./mock-iframe-phone";

const parentEl = document.createElement("iframe"); parentEl.src = "http://example.com/";
const iframeEl = document.createElement("iframe");
const mockedIFramePhone = mockIFramePhone(parentEl);

jest.mock("iframe-phone", () => mockedIFramePhone);

let parentEndpoint: MockPhone;
let iframeEndpoint: MockPhone;

describe("MockIframePhone", () => {
  beforeEach(() => {
    MockedIframePhoneManager.install();
    parentEndpoint = new mockedIFramePhone.ParentEndpoint(iframeEl);
    iframeEndpoint = mockedIFramePhone.getIFrameEndpoint();
  });

  afterEach(() => {
    MockedIframePhoneManager.uninstall();
  });

  it("should provide a postMessageFrom function", () => {
    expect(typeof MockedIframePhoneManager.postMessageFrom).toEqual("function");
  });

  it("should provide jasmine.mockIframePhone.messages object", () => {
    expect(typeof MockedIframePhoneManager.messages).toEqual("object");
  });

  describe("when fake message is posted *to* iframe phone", () => {
    let parentListener: jest.Mock<any>;
    let iframeListener: jest.Mock<any>;

    beforeEach(() => {
      parentListener = jest.fn();
      iframeListener = jest.fn();

      parentEndpoint.addListener("testMsg1", parentListener);
      iframeEndpoint.addListener("testMsg2", iframeListener);

      MockedIframePhoneManager.postMessageFrom(iframeEl, {type: "testMsg1", content: "foobar"});
      MockedIframePhoneManager.postMessageFrom(parentEl, {type: "testMsg2", content: "barfoo"});
    });

    it("listeners should be called", () => {
      expect(parentListener).toHaveBeenCalledWith("foobar");
      expect(parentListener).toHaveBeenCalledTimes(1);
      expect(iframeListener).toHaveBeenCalledWith("barfoo");
      expect(iframeListener).toHaveBeenCalledTimes(1);
    });

    it("should be recorded", () => {
      expect(MockedIframePhoneManager.messages.count()).toEqual(2);
      expect(MockedIframePhoneManager.messages.at(0)).toEqual({
        source: iframeEl,
        target: window,
        message: {
          type: "testMsg1",
          content: "foobar"
        }
      });
      expect(MockedIframePhoneManager.messages.at(1)).toEqual({
        source: parentEl,
        target: window,
        message: {
          type: "testMsg2",
          content: "barfoo"
        }
      });
    });
  });

  describe("when fake message is posted *from* iframe phone", () => {
    beforeEach(() => {
      parentEndpoint.post("testMsgFromParentEndpoint", {key: "value"});
      iframeEndpoint.post("testMsgFromIframeEndpoint", {param: "test"});
    });

    it("it should be recorded", () => {
      expect(MockedIframePhoneManager.messages.count()).toEqual(2);
      expect(MockedIframePhoneManager.messages.at(0)).toEqual({
        source: window,
        target: iframeEl,
        message: {
          type: "testMsgFromParentEndpoint",
          content: {key: "value"}
        }});
      expect(MockedIframePhoneManager.messages.at(1)).toEqual({
        source: window,
        target: parentEl,
        message: {
          type: "testMsgFromIframeEndpoint",
          content: {param: "test"}
        }});
    });
  });

  describe("messages object", () => {
    beforeEach(() => {
      MockedIframePhoneManager.postMessageFrom(parentEl, {type: "testMsg1", content: "barfoo"});
      MockedIframePhoneManager.postMessageFrom(iframeEl, {type: "testMsg2", content: "foobar"});
    });

    it("should allow to count recorded messages", () => expect(MockedIframePhoneManager.messages.count()).toEqual(2));

    it("should allow to get all messages", () => expect(MockedIframePhoneManager.messages.all().length).toEqual(2));

    it("should allow to get specific message", () => {
      expect(MockedIframePhoneManager.messages.at(0)).toEqual(MockedIframePhoneManager.messages.all()[0]);
      expect(MockedIframePhoneManager.messages.at(0)).toEqual({
        source: parentEl,
        target: window,
        message: {
          type: "testMsg1",
          content: "barfoo"
        }
      });
      expect(MockedIframePhoneManager.messages.at(1)).toEqual(MockedIframePhoneManager.messages.all()[1]);
      expect(MockedIframePhoneManager.messages.at(1)).toEqual({
        source: iframeEl,
        target: window,
        message: {
          type: "testMsg2",
          content: "foobar"
        }
      });
    });

    it("should allow to reset recorded messages", () => {
      MockedIframePhoneManager.messages.reset();
      expect(MockedIframePhoneManager.messages.count()).toEqual(0);
    });
  });

  describe("MockPhone afterConnectedCallback support", () => {
    describe("when autoConnect is set to true (default)", () => {
      it("(fake) connection is automatically initialized", () => {
        const afterConnectedCallback = jest.fn();
        parentEndpoint = new mockedIFramePhone.ParentEndpoint(iframeEl, afterConnectedCallback);
        expect(afterConnectedCallback).toHaveBeenCalled();
        expect(afterConnectedCallback).toHaveBeenCalledTimes(1);
        // Test different constructor too.
        afterConnectedCallback.mockReset();
        parentEndpoint = new mockedIFramePhone.ParentEndpoint(iframeEl, "origin", afterConnectedCallback);
        expect(afterConnectedCallback).toHaveBeenCalled();
        expect(afterConnectedCallback).toHaveBeenCalledTimes(1);
      });
    });

    describe("when autoConnect is set to false", () => {
      beforeEach(() => setAutoConnect(false));

      it("(fake) connection needs to be manually initialized", () => {
        const afterConnectedCallback = jest.fn();
        parentEndpoint = new mockedIFramePhone.ParentEndpoint(iframeEl, afterConnectedCallback);
        expect(afterConnectedCallback).not.toHaveBeenCalled();
        parentEndpoint.fakeConnection();
        expect(afterConnectedCallback).toHaveBeenCalled();
        expect(afterConnectedCallback).toHaveBeenCalledTimes(1);
        // Test different constructor too.
        afterConnectedCallback.mockReset();
        parentEndpoint = new mockedIFramePhone.ParentEndpoint(iframeEl, "origin", afterConnectedCallback);
        expect(afterConnectedCallback).not.toHaveBeenCalled();
        parentEndpoint.fakeConnection();
        expect(afterConnectedCallback).toHaveBeenCalled();
        expect(afterConnectedCallback).toHaveBeenCalledTimes(1);
      });
    });
  });

  describe("MockPhone#targetOrigin", () => {
    describe("of parent endpoint", () => {
      it("should return origin of an iframe", () => {
        expect(parentEndpoint.targetOrigin()).toEqual(""); // no src defined for the default iframe
        const parentIframe = document.createElement("iframe");
        parentIframe.src = "http://test.com/path/foo";
        parentEndpoint = new mockedIFramePhone.ParentEndpoint(parentIframe);
        expect(parentEndpoint.targetOrigin()).toEqual("http://test.com");
      });
    });

    describe("of iframe endpoint", () => {
      it("should return origin of the parent window", () => {
        expect(iframeEndpoint.targetOrigin()).toEqual("http://example.com");
      });
    });

    describe("when origin is specified explicitly", () => {
      it("should be returned", () => {
        const parentIframe = document.createElement("iframe");
        parentEndpoint = new mockedIFramePhone.ParentEndpoint(parentIframe, "some.origin.com");
        expect(parentEndpoint.targetOrigin()).toEqual("some.origin.com");
      });
    });
  });
});
