import { S3Client, GetObjectCommand, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { v4 as uuid } from "uuid";
import { Credentials, EnvironmentName, S3Resource, TokenServiceClient } from "@concord-consortium/token-service";
import { getJwtLifetime } from "./helpers";
import { IAttachmentsFolder, IAttachmentsManagerInitOptions, IReadableAttachmentInfo } from "./types";

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
const kTokenRefreshMarginSec = 5 * 60;

export class AttachmentsManager {
  public learnerId?: string;
  private sessionId = uuid();
  private tokenServiceEnv: EnvironmentName;
  private firebaseJwt?: string;
  private firebaseJwtStaleAtMs = new Map<string, number | undefined>();
  private getFirebaseJwt?: () => Promise<string>;
  private pendingFirebaseJwt?: Promise<string>;
  private tokenServiceClient: TokenServiceClient;
  private resources: Record<string, S3Resource> = {};

  constructor(options: IAttachmentsManagerInitOptions) {
    this.learnerId = options.writeOptions?.runKey || options.writeOptions?.runRemoteEndpoint;
    if (options.writeOptions && !this.learnerId) {
      throw new Error("Attachments Manager requires runKey or runRemoteEndpoint to support write operation");
    }
    this.tokenServiceEnv = options.tokenServiceEnv;
    this.getFirebaseJwt = options.getTokenServiceFirestoreJWT;
    // A token source supplies every token, so the static token is used only without one.
    this.firebaseJwt = this.getFirebaseJwt ? undefined : options.tokenServiceFirestoreJWT;
    this.tokenServiceClient = new TokenServiceClient({ env: this.tokenServiceEnv, jwt: this.firebaseJwt });
  }

  public isAnonymous() {
    return !this.firebaseJwt && !this.getFirebaseJwt;
  }

  public isWriteSupported() {
    return !!this.learnerId;
  }

  public getSessionId() {
    return this.sessionId;
  }

  public async createFolder(interactiveId: string): Promise<IAttachmentsFolder> {
    if (!this.learnerId) {
      return Promise.reject("Folder can't be created without valid learnerId");
    }
    const client = await this.getTokenServiceClient();
    const folderResource = await client.createResource({
      tool: kTokenServiceToolName,
      type: "s3Folder",
      name: `${this.learnerId}-${interactiveId}`,
      description: "attachment",
      accessRuleType: this.isAnonymous() ? "readWriteToken" : ["user", "context"]
    });
    this.resources[folderResource.id] = folderResource as S3Resource;
    return {
      id: folderResource.id,
      ownerId: this.learnerId,
      readWriteToken: client.getReadWriteToken(folderResource) || undefined
    };
  }

  public async getSignedWriteUrl(
    folder: IAttachmentsFolder, name: string, options?: ISignedWriteUrlOptions
  ): Promise<[string, IReadableAttachmentInfo]> {
    const { ContentType = "text/plain", expiresIn = kDefaultWriteExpirationSec } = options || {};
    // TODO: validate the type; cf. https://advancedweb.hu/how-to-use-s3-put-signed-urls/
    const client = await this.getTokenServiceClient();
    const folderResource = await this.getFolderResource(client, folder);
    const publicPath = client.getPublicS3Path(folderResource, `${this.sessionId}/${name}`);
    const url = await this.getSignedUrl(client, folder, "putObject", { Key: publicPath, ContentType, expiresIn });
    // returns the writable url and the information required to read it
    return [url, { folder, publicPath, contentType: ContentType }];
  }

  public async getSignedReadUrl(attachmentInfo: IReadableAttachmentInfo, options?: ISignedReadUrlOptions) {
    const { publicPath, folder } = attachmentInfo;
    const { expiresIn = kDefaultReadExpirationSec } = options || {};
    const client = await this.getTokenServiceClient();
    return this.getSignedUrl(client, folder, "getObject", {
      Key: publicPath,
      expiresIn
    });
  }

  // Public methods call this once and pass the client on, so a manager call makes at most one source call.
  private async getTokenServiceClient(): Promise<TokenServiceClient> {
    if (this.getFirebaseJwt && !this.isFirebaseJwtFresh()) {
      const jwt = await this.fetchFirebaseJwt(this.getFirebaseJwt);
      // a token returned again keeps the stale time it got when it first arrived
      if (!this.firebaseJwtStaleAtMs.has(jwt)) {
        this.firebaseJwtStaleAtMs.set(jwt, this.getStaleAtMs(jwt));
      }
      if (jwt !== this.firebaseJwt) {
        this.firebaseJwt = jwt;
        this.tokenServiceClient = new TokenServiceClient({ env: this.tokenServiceEnv, jwt });
      }
    }
    return this.tokenServiceClient;
  }

  // The lifetime is counted from receipt, so a browser clock that disagrees with the portal's does not matter.
  private getStaleAtMs(jwt: string) {
    const lifetime = getJwtLifetime(jwt);
    return lifetime !== undefined ? Date.now() + (lifetime - kTokenRefreshMarginSec) * 1000 : undefined;
  }

  private isFirebaseJwtFresh() {
    const staleAtMs = this.firebaseJwt !== undefined ? this.firebaseJwtStaleAtMs.get(this.firebaseJwt) : undefined;
    return staleAtMs !== undefined && Date.now() < staleAtMs;
  }

  // Concurrent callers share one call to the token source; a failed call is not reused.
  private fetchFirebaseJwt(getFirebaseJwt: () => Promise<string>) {
    if (!this.pendingFirebaseJwt) {
      this.pendingFirebaseJwt = Promise.resolve()
        .then(getFirebaseJwt)
        .then(jwt => {
          if (!jwt) {
            throw new Error("the token source returned no token");
          }
          return jwt;
        })
        .then(
          jwt => { this.pendingFirebaseJwt = undefined; return jwt; },
          error => { this.pendingFirebaseJwt = undefined; throw error; }
        );
    }
    return this.pendingFirebaseJwt;
  }

  private async getFolderResource(client: TokenServiceClient, folder: IAttachmentsFolder): Promise<S3Resource> {
    let folderResource: S3Resource = this.resources[folder.id];
    if (!folderResource) {
      folderResource = await client.getResource(folder.id) as S3Resource;
      this.resources[folderResource.id] = folderResource;
    }
    return folderResource;
  }

  private getCredentials(client: TokenServiceClient, folder: IAttachmentsFolder): Promise<Credentials> {
    return client.getCredentials(folder.id, folder.readWriteToken);
  }

  private async getSignedUrl(
    client: TokenServiceClient, folder: IAttachmentsFolder, operation: S3Operation, options: IS3SignedUrlOptions
  ) {
    const { Key, ContentType = "text/plain", expiresIn } = options;
    const folderResource = await this.getFolderResource(client, folder);
    const credentials = await this.getCredentials(client, folder);
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
