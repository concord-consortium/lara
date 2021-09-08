import { IAttachmentUrlResponse } from "../types";
import { getAttachmentsManager } from "./attachments-manager-global";
import { IAnswerMetadataWithAttachmentsInfo, IHandleGetAttachmentUrlOptions, ISignedWriteUrlOptions } from "./types";

const clone = (obj: any) => obj != null ? JSON.parse(JSON.stringify(obj)) : obj;

// This function will return an existing folder that has `ownerId` equal to the current user `learnerId`.
// In 99.9% it'll be the folder of requested attachment. However, ownerId and learnerId might not match when
// answerMetadata is copied between users (run with others use case).
export const findFolder = (answerMeta: IAnswerMetadataWithAttachmentsInfo, name: string, learnerId?: string) => {
  if (!learnerId) {
    return null;
  }
  // First, check folder of the requested attachment.
  if (answerMeta.attachments?.[name]?.folder.ownerId === learnerId) {
    return answerMeta.attachments[name].folder;
  }
  // If it belongs to someone else, look for any other folder that belongs to the current user.
  for (const key in answerMeta.attachments) {
    if (answerMeta.attachments.hasOwnProperty(key)) {
      const folder = answerMeta.attachments[key].folder;
      if (folder.ownerId === learnerId) {
        return folder;
      }
    }
  }
  // If nothing is found, return null. A new folder will need to be created.
  return null;
};

export const handleGetAttachmentUrl =
  async (options: IHandleGetAttachmentUrlOptions): Promise<IAttachmentUrlResponse> => {

  const { name, operation, contentType, expiresIn, requestId } = options.request;
  const response: IAttachmentUrlResponse = { requestId };
  let attachmentsMgr;

  try {
    attachmentsMgr = await getAttachmentsManager();
  } catch (e) {
    response.error = "error getting attachment url: the host environment did not initialize the attachments manager";
    return response;
  }

  // Do not clone the whole answerMeta, as it can be a large object (for example, AP provides the whole Firestore doc).
  const answerMeta: IAnswerMetadataWithAttachmentsInfo = {
    attachments: clone(options.answerMeta.attachments)
  };
  try {
    if (operation === "write") {
      if (!attachmentsMgr.isWriteSupported() || !options.writeOptions) {
        response.error = "error getting attachment url: the write operation is not supported by the host environment";
        return response;
      }
      if (!answerMeta.attachments) {
        answerMeta.attachments = {};
      }
      let folder = findFolder(answerMeta, name, attachmentsMgr.learnerId);
      if (!folder) {
        folder = await attachmentsMgr.createFolder(options.writeOptions?.interactiveId);
      }
      const urlOptions: ISignedWriteUrlOptions = { ContentType: contentType, expiresIn };
      const [writeUrl, attachmentInfo] = await attachmentsMgr.getSignedWriteUrl(folder, name, urlOptions);
      response.url = writeUrl;
      // public path changes with sessionId
      if (!answerMeta.attachments[name] ||
          answerMeta.attachments[name].publicPath !== attachmentInfo.publicPath ||
          answerMeta.attachments[name].folder.id !== attachmentInfo.folder.id) {
        answerMeta.attachments[name] = attachmentInfo;
        options.writeOptions.onAnswerMetaUpdate(answerMeta);
      }
    }
    else if (operation === "read") {
      if (answerMeta.attachments && answerMeta.attachments[name]) {
        response.url = await attachmentsMgr.getSignedReadUrl(answerMeta.attachments[name], { expiresIn });
      } else {
        response.error = `error getting attachment url: ${name} ["No attachment info in answer metadata"]`;
        return response;
      }
    }
  }
  catch (e) {
    response.error = `error creating url for attachment: "${name}" [s3: "${e}"]`;
  }
  return response;
};
