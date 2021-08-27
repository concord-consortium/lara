import { AttachmentsManager } from "./attachments-manager";
import { IAttachmentsManagerInitOptions } from "./types";

let resolveAttachmentsManager: (manager: AttachmentsManager) => void;
export const attachmentsManager = new Promise<AttachmentsManager>((resolve, reject) => {
  resolveAttachmentsManager = resolve;
});

export const initializeAttachmentsManager = async (optionsPromise: Promise<IAttachmentsManagerInitOptions>) => {
  resolveAttachmentsManager(new AttachmentsManager(await optionsPromise));
};
