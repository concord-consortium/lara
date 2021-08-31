import { AttachmentsManager } from "./attachments-manager";
import { IAttachmentsManagerInitOptions } from "./types";

let timeoutValue = 20000; // ms

let resolveAttachmentsManager: (manager: AttachmentsManager) => void;
const attachmentsManager = new Promise<AttachmentsManager>((resolve, reject) => {
  resolveAttachmentsManager = resolve;
});

export const setAttachmentsManagerTimeout = (timeInMs: number) => {
 timeoutValue = timeInMs;
};

export const initializeAttachmentsManager = async (options: IAttachmentsManagerInitOptions) => {
  resolveAttachmentsManager(new AttachmentsManager(options));
};

export const getAttachmentsManager = async () => {
  return new Promise<AttachmentsManager>((resolve, reject) => {
    const timeoutId = setTimeout(() => {
      reject("AttachmentsManager hasn't been initialized");
    }, timeoutValue);
    attachmentsManager.then(mgr => {
      clearTimeout(timeoutId);
      resolve(mgr);
    });
  });
};
