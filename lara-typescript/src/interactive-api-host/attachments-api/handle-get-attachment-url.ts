import { IAttachmentUrlResponse } from "../types";
import { getAttachmentsManager } from "./attachments-manager-global";
import { IAnswerMetadataWithAttachmentsInfo, IHandleGetAttachmentUrlOptions, ISignedWriteUrlOptions } from "./types";

const clone = (obj: any) => obj != null ? JSON.parse(JSON.stringify(obj)) : obj;

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
    attachmentsFolder: clone(options.answerMeta.attachmentsFolder),
    attachments: clone(options.answerMeta.attachments)
  };
  try {
    if (operation === "write") {
      if (!attachmentsMgr.isWriteSupported() || !options.writeOptions) {
        response.error = "error getting attachment url: the write operation is not supported by the host environment";
        return response;
      }
      if (!answerMeta.attachmentsFolder) {
        answerMeta.attachmentsFolder = await attachmentsMgr.createFolder(options.writeOptions?.interactiveId);
      }
      if (!answerMeta.attachments) {
        answerMeta.attachments = {};
      }
      const urlOptions: ISignedWriteUrlOptions = { ContentType: contentType, expiresIn };
      const [writeUrl, attachmentInfo] =
        await attachmentsMgr.getSignedWriteUrl(answerMeta.attachmentsFolder, name, urlOptions);
      response.url = writeUrl;
      // public path changes with sessionId
      if (!answerMeta.attachments[name] || answerMeta.attachments[name].publicPath !== attachmentInfo.publicPath) {
        answerMeta.attachments[name] = attachmentInfo;
        options.writeOptions.onAnswerMetaUpdate(answerMeta);
      }
    }
    else if (operation === "read") {
      if (answerMeta.attachmentsFolder && answerMeta.attachments && answerMeta.attachments[name]) {
        response.url = await attachmentsMgr.getSignedReadUrl(
          answerMeta.attachmentsFolder, answerMeta.attachments[name], { expiresIn }
        );
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
