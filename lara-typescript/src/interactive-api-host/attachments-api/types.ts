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
  contentType: string;
}

export interface IAnswerMetadataWithAttachmentsInfo {
  // tracks the most recently written details for each attachment
  attachments?: Record<string, IReadableAttachmentInfo>;
}

export interface IAttachmentsManagerInitOptions {
  tokenServiceEnv: EnvironmentName;
  tokenServiceFirestoreJWT?: string;
  // Returns a newly minted token-service JWT. Token-service JWTs expire (portal-issued ones after an hour), so a
  // host whose pages stay open longer should provide this, and then tokenServiceFirestoreJWT is not used. The
  // manager calls it when a request needs a token and the cached one is missing or near expiry, which it times from
  // when the token arrived. The promise must settle: concurrent and later requests wait on a pending call, so
  // reject on a timeout.
  getTokenServiceFirestoreJWT?: () => Promise<string>;
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
