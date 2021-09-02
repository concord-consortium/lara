import { S3Client, GetObjectCommand, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { v4 as uuid } from "uuid";
import { Credentials, S3Resource, TokenServiceClient } from "@concord-consortium/token-service";
import {
  IAttachmentsFolder, IAttachmentsManagerInitOptions, IReadableAttachmentInfo, IWritableAttachmentsFolder
} from "./types";

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

const kTokenServiceToolName = "interactive-attachments";
const kDefaultWriteExpirationSec = 5 * 60;
const kDefaultReadExpirationSec = 2 * 60 * 60;

export const isWritableAttachmentsFolder = (folder: IAttachmentsFolder): folder is IWritableAttachmentsFolder =>
              !!(folder as IWritableAttachmentsFolder).readWriteToken;

export class AttachmentsManager {
  private sessionId = uuid();
  private learnerId?: string;
  private firebaseJwt?: string;
  private tokenServiceClient: TokenServiceClient;
  private resources: Record<string, S3Resource> = {};

  constructor(options: IAttachmentsManagerInitOptions) {
    this.learnerId = options.writeOptions?.runKey || options.writeOptions?.runRemoteEndpoint;
    if (options.writeOptions && !this.learnerId) {
      throw new Error("Attachments Manager requires runKey or runRemoteEndpoint to support write operation");
    }
    this.firebaseJwt = options.tokenServiceFirestoreJWT;
    this.tokenServiceClient = new TokenServiceClient({ env: options.tokenServiceEnv, jwt: this.firebaseJwt });
  }

  public isAnonymous() {
    // The client will be anonymous if firebaseJwt undefined
    return !this.firebaseJwt;
  }

  public isWriteSupported() {
    return !!this.learnerId;
  }

  public getSessionId() {
    return this.sessionId;
  }

  public async createFolder(interactiveId: string): Promise<IWritableAttachmentsFolder> {
    const folderResource = await this.tokenServiceClient.createResource({
      tool: kTokenServiceToolName,
      type: "s3Folder",
      name: `${this.learnerId}-${interactiveId}`,
      description: "attachment",
      accessRuleType: this.isAnonymous() ? "readWriteToken" : ["user", "context"]
    });
    this.resources[folderResource.id] = folderResource as S3Resource;
    return {
      id: folderResource.id,
      readWriteToken: this.tokenServiceClient.getReadWriteToken(folderResource) || undefined
    };
  }

  public async getSignedWriteUrl(
    folder: IAttachmentsFolder, name: string, options?: ISignedWriteUrlOptions
  ): Promise<[string, IReadableAttachmentInfo]> {
    const { ContentType = "text/plain", expiresIn = kDefaultWriteExpirationSec } = options || {};
    // TODO: validate the type; cf. https://advancedweb.hu/how-to-use-s3-put-signed-urls/
    const folderResource = await this.getFolderResource(folder);
    const publicPath = this.tokenServiceClient.getPublicS3Path(folderResource, `${this.sessionId}/${name}`);
    const url = await this.getSignedUrl(folder, "putObject", { Key: publicPath, ContentType, expiresIn });
    // returns the writable url and the information required to read it
    return [url, { folder: { id: folder.id }, publicPath }];
  }

  public getSignedReadUrl(attachmentInfo: IReadableAttachmentInfo, options?: ISignedReadUrlOptions) {
    const { folder, publicPath } = attachmentInfo;
    const { expiresIn = kDefaultReadExpirationSec } = options || {};
    return this.getSignedUrl(folder, "getObject", { Key: publicPath, expiresIn });
  }

  private async getFolderResource(folder: IAttachmentsFolder): Promise<S3Resource> {
    let folderResource: S3Resource = this.resources[folder.id];
    if (!folderResource) {
      folderResource = await this.tokenServiceClient.getResource(folder.id) as S3Resource;
      this.resources[folderResource.id] = folderResource;
    }
    return folderResource;
  }

  private getCredentials(folder: IAttachmentsFolder): Promise<Credentials> {
    const readWriteToken = isWritableAttachmentsFolder(folder) ? folder.readWriteToken : undefined;
    return this.tokenServiceClient.getCredentials(folder.id, readWriteToken);
  }

  private async getSignedUrl(folder: IAttachmentsFolder, operation: S3Operation, options: IS3SignedUrlOptions) {
    const { Key, ContentType = "text/plain", expiresIn } = options;
    const folderResource = await this.getFolderResource(folder);
    const credentials = await this.getCredentials(folder);
    const { bucket: Bucket, region } = folderResource;
    const { accessKeyId, secretAccessKey, sessionToken } = credentials;
    const s3 = new S3Client({ region, credentials: { accessKeyId, secretAccessKey, sessionToken } });
    // https://aws.amazon.com/blogs/developer/generate-presigned-url-modular-aws-sdk-javascript/
    const command = operation === "putObject"
                      ? new PutObjectCommand({ Bucket, Key, ContentType })
                      : new GetObjectCommand({ Bucket, Key });
    return getSignedUrl(s3, command, { expiresIn } );
  }
}
