import { AttachmentInfoMap } from "../types";
import { IAnswerMetadataWithAttachmentsInfo } from "./types";

export const answerMetadataToAttachmentInfoMap = (metadata?: IAnswerMetadataWithAttachmentsInfo): AttachmentInfoMap => {
  const result: AttachmentInfoMap = {};
  const attachments = metadata?.attachments;
  if (attachments) {
    Object.keys(attachments).forEach((key) => {
      const attachmentInfo = attachments[key];
      result[key] = {
        contentType: attachmentInfo.contentType
      };
    });
  }

  return result;
};
