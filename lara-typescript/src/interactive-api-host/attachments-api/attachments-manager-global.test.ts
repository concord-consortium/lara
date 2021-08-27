import { EnvironmentName } from "@concord-consortium/token-service";
import { AttachmentsManager } from "./attachments-manager";
import { attachmentsManager, initializeAttachmentsManager } from "./attachments-manager-global";

describe("initializeAttachmentsManager", () => {
  it("resolves the global promise", async () => {
    const optionsPromise = Promise.resolve({
      tokenServiceEnv: "staging" as EnvironmentName
    });
    initializeAttachmentsManager(optionsPromise);
    const mgr = await attachmentsManager;
    expect(mgr).toBeInstanceOf(AttachmentsManager);
  });
});
