import { EnvironmentName } from "@concord-consortium/token-service";
import { AttachmentsManager } from "./attachments-manager";
import { getAttachmentsManager, initializeAttachmentsManager, setAttachmentsManagerTimeout } from "./attachments-manager-global";

describe("getAttachmentsManager", () => {
  it("fails if initializeAttachmentsManager hasn't been called before", async () => {
    setAttachmentsManagerTimeout(200);
    try {
      await getAttachmentsManager();
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
