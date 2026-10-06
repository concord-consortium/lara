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

// Returns a JWT's lifetime in seconds (`exp` minus `iat`), or undefined when either claim cannot be read.
// The signature is not verified: the value is only a hint for when to request a new token.
export const getJwtLifetime = (jwt?: string): number | undefined => {
  const parts = jwt?.split(".");
  if (parts?.length !== 3) {
    return undefined;
  }
  const base64 = parts[1].replace(/-/g, "+").replace(/_/g, "/");
  try {
    const { exp, iat } = JSON.parse(atob(base64 + "===".slice((base64.length + 3) % 4)));
    return typeof exp === "number" && typeof iat === "number" ? exp - iat : undefined;
  } catch (e) {
    return undefined;
  }
};
