import { generateRuntimeContext } from "./runtime-context";
import { IClassInfo } from "../api/types";
import * as fetch from "jest-fetch-mock";
(window as any).fetch = fetch;

describe("Runtime context helper", () => {
  beforeEach(() => {
    fetch.resetMocks();
  });

  const pluginContext = {
    name: "test",
    url: "http://plugin.url",
    pluginId: 123,
    authoredState: "{authoredState: 123}",
    learnerState: "{learnerState: 321}",
    learnerStateSaveUrl: "http://state.save.url",
    container: document.createElement("div"),
    runId: 100,
    remoteEndpoint: "http://remote.portal.endpoint",
    userEmail: "user@email.com",
    classInfoUrl: "http://portal.class.info.url",
    firebaseJwtUrl: "http://firebase.jwt._FIREBASE_APP_.com",
    wrappedEmbeddable: {
      container: document.createElement("div"),
      laraJson: {
        name: "Test Interactive",
        type: "MwInteractive",
        ref_id: "86-MwInteractive"
      },
      interactiveStateUrl: "http://interactive.state.url",
      clickToPlayId: "#clickToPlayId"
    }
  };
  const runtimeContext = generateRuntimeContext(pluginContext);

  it("should copy basic properties to runtime context", () => {
    expect(runtimeContext.name).toEqual(pluginContext.name);
    expect(runtimeContext.url).toEqual(pluginContext.url);
    expect(runtimeContext.pluginId).toEqual(pluginContext.pluginId);
    expect(runtimeContext.authoredState).toEqual(pluginContext.authoredState);
    expect(runtimeContext.learnerState).toEqual(pluginContext.learnerState);
    expect(runtimeContext.container).toEqual(pluginContext.container);
    expect(runtimeContext.runId).toEqual(pluginContext.runId);
    expect(runtimeContext.remoteEndpoint).toEqual(pluginContext.remoteEndpoint);
    expect(runtimeContext.userEmail).toEqual(pluginContext.userEmail);
  });

  describe("#getClassInfo", () => {
    it("provides class information", done => {
      const classInfo: IClassInfo = {id: 123} as IClassInfo;
      fetch.mockResponse(JSON.stringify(classInfo));
      const resp = runtimeContext.getClassInfo();
      expect(fetch.mock.calls[0][0]).toEqual(pluginContext.classInfoUrl);
      expect(resp).toBeInstanceOf(Promise);
      resp!.then(data => {
        expect(data).toEqual(classInfo);
        done();
      });
    });

    it("returns error when LARA response is malformed", done => {
      fetch.mockResponse("{malformedString:");
      const resp = runtimeContext.getClassInfo();
      expect(fetch.mock.calls[0][0]).toEqual(pluginContext.classInfoUrl);
      expect(resp).toBeInstanceOf(Promise);
      resp!.catch(err => {
        done();
      });
    });
  });

  describe("#getFirebaseJwt", () => {
    it("provides token when LARA response is valid", done => {
      const jwtResp = { token: `jwtToken.${btoa(JSON.stringify({claimsJson: true}))}`};
      fetch.mockResponse(JSON.stringify(jwtResp));
      const resp = runtimeContext.getFirebaseJwt("testAppName");
      expect(fetch.mock.calls[0][0]).toEqual(pluginContext.firebaseJwtUrl.replace("_FIREBASE_APP_", "testAppName"));
      expect(resp).toBeInstanceOf(Promise);
      resp!.then(data => {
        expect(data).toEqual({
          token: jwtResp.token,
          claims: {claimsJson: true}
        });
        done();
      });
    });

    it("returns error when LARA response is malformed", done => {
      const jwtResp = { token: `bad.jwtToken`};
      fetch.mockResponse(JSON.stringify(jwtResp));
      const resp = runtimeContext.getFirebaseJwt("testAppName");
      expect(fetch.mock.calls[0][0]).toEqual(pluginContext.firebaseJwtUrl.replace("_FIREBASE_APP_", "testAppName"));
      expect(resp).toBeInstanceOf(Promise);
      resp!.catch(err => {
        expect(err.message).toEqual("Unable to parse JWT Token");
        done();
      });
    });
  });
});
