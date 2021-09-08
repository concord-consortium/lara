import { EnvironmentName } from "@concord-consortium/token-service";
import { IAttachmentUrlRequest } from "../types";

export type S3Operation = "getObject" | "putObject";

export interface ISignedReadUrlOptions {
  expiresIn?: number; // seconds
}

export interface ISignedWriteUrlOptions extends ISignedReadUrlOptions {
  ContentType?: string;
}

export interface IS3SignedUrlOptions extends ISignedWriteUrlOptions {
  Key: string;
}

export interface IAttachmentsFolder {
  id: string;
  ownerId: string;
  readWriteToken?: string;
}

export interface IReadableAttachmentInfo {
  publicPath: string;
  folder: IAttachmentsFolder;
}

export interface IAnswerMetadataWithAttachmentsInfo {
  // tracks the most recently written details for each attachment
  attachments?: Record<string, IReadableAttachmentInfo>;
}

export interface IAttachmentsManagerInitOptions {
  tokenServiceEnv: EnvironmentName;
  tokenServiceFirestoreJWT?: string;
  // These options are necessary only when attachments manager is expected to support write operation.
  writeOptions?: {
    runKey?: string; // for anonymous users
    runRemoteEndpoint?: string; // for logged in users
  };
}

export interface IHandleGetAttachmentUrlOptions {
  request: IAttachmentUrlRequest;
  answerMeta: IAnswerMetadataWithAttachmentsInfo;
  writeOptions?: {
    // This is necessary only for write operation.
    interactiveId: string;
    // This callback should save the updated answer metadata.
    onAnswerMetaUpdate: (newAnswerMeta: IAnswerMetadataWithAttachmentsInfo) => void;
  };
}
