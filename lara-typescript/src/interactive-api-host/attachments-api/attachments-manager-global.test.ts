import { EnvironmentName } from "@concord-consortium/token-service";
import { AttachmentsManager } from "./attachments-manager";
import { getAttachmentsManager, initializeAttachmentsManager, timeoutValue } from "./attachments-manager-global";

describe("getAttachmentsManager", () => {
  afterEach(() => {
    jest.useRealTimers();
  });

  it("fails if initializeAttachmentsManager hasn't been called before", async () => {
    jest.useFakeTimers();
    try {
      const getAttachmentsManagerPromise = getAttachmentsManager();
      jest.advanceTimersByTime(timeoutValue + 100);
      await getAttachmentsManagerPromise;
    } catch (e) {
      expect(e).toEqual("AttachmentsManager hasn't been initialized");
    }
  });
});

describe("initializeAttachmentsManager", () => {
  it("resolves the global promise", async () => {
    const options = {
      tokenServiceEnv: "staging" as EnvironmentName
    };
    initializeAttachmentsManager(options);
    const mgr = await getAttachmentsManager();
    expect(mgr).toBeInstanceOf(AttachmentsManager);
  });
});
