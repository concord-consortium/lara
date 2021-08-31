import { IAttachmentUrlResponse } from "../types";
import { getAttachmentsManager } from "./attachments-manager-global";
import { IHandleGetAttachmentUrlOptions, ISignedWriteUrlOptions } from "./types";

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

  const answerMeta = options.answerMeta;
  let { attachmentsFolder, attachments } = answerMeta;
  try {
    if (operation === "write") {
      if (!attachmentsMgr.isWriteSupported() || !options.writeOptions) {
        response.error = "error getting attachment url: the write operation is not supported by the host environment";
        return response;
      }
      if (!attachmentsFolder) {
        attachmentsFolder = answerMeta.attachmentsFolder =
          await attachmentsMgr.createFolder(options.writeOptions?.interactiveId);
      }
      if (!attachments) {
        attachments = answerMeta.attachments = {};
      }
      const urlOptions: ISignedWriteUrlOptions = { ContentType: contentType, expiresIn };
      const [writeUrl, attachmentInfo] = await attachmentsMgr.getSignedWriteUrl(attachmentsFolder, name, urlOptions);
      response.url = writeUrl;
      // public path changes with sessionId
      if (!attachments[name] || (attachmentInfo.publicPath !== attachments[name].publicPath)) {
        attachments[name] = attachmentInfo;
        options.writeOptions.onAnswerMetaUpdate(answerMeta);
      }
    }
    else if (operation === "read") {
      if (attachmentsFolder && attachments && attachments[name]) {
        // TODO: this won't work for run-with-others where we won't have a readWriteToken
        const attachmentInfo = { ...attachments[name], folder: attachmentsFolder };
        response.url = await attachmentsMgr.getSignedReadUrl(attachmentInfo, { expiresIn });
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
