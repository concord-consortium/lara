import { GetObjectCommand, PutObjectCommand } from "@aws-sdk/client-s3";
import { Credentials, Resource, TokenServiceClient } from "@concord-consortium/token-service";
import { AttachmentsManager, IS3SignedUrlOptions, ISignedWriteUrlOptions } from "./attachments-manager";
import { initializeAttachmentsManager } from "./attachments-manager-global";
import { handleGetAttachmentUrl } from "./handle-get-attachment-url";
import { makeJwt } from "./test-utils";
import { IAttachmentUrlRequest } from "../types";
import { IAttachmentsFolder, IReadableAttachmentInfo } from "./types";

let mockCount = 0;
jest.mock("uuid", () => ({
  v4: () => `uuid-${++mockCount}`
}));

const mockSignedReadUrl = "https://concord.org/read/url";
const mockSignedWriteUrl = "https://concord.org/write/url";
const mockGetSignedUrl = jest.fn((client: any, command: any, options: any) => {
  return Promise.resolve(command instanceof PutObjectCommand ? mockSignedWriteUrl : mockSignedReadUrl);
});
const lastCall = (mockFn: jest.Mock) => mockFn.mock.calls[mockFn.mock.calls.length - 1];
const lastSignedUrlRequest = () => lastCall(mockGetSignedUrl);
const lastSignedUrlRequestIsGet = () => lastSignedUrlRequest()[1] instanceof GetObjectCommand;
const lastSignedUrlRequestIsPut = () => lastSignedUrlRequest()[1] instanceof PutObjectCommand;
jest.mock("@aws-sdk/s3-request-presigner", () => ({
  getSignedUrl: (client: any, command: any, options: any) => mockGetSignedUrl(client, command, options)
}));

const mockRawFirebaseJWT = "rawFirebaseJWT";

const mockUserId = "user-1";
const mockFolderId = "folder-id";
const mockResourceType = "s3Folder";
const mockResourceBucket = "bucket";
const mockResourcePublicPath = "public-path";
const mockContentType = "text/plain";
const mockResource: Resource = {
    id: mockFolderId,
    name: "folder-name",
    type: mockResourceType,
    description: "description",
    tool: "attachments",
    bucket: mockResourceBucket,
    folder: "folder",
    region: "region",
    publicPath: mockResourcePublicPath,
    publicUrl: "public-url"
};
const mockGetResource = jest.fn((resourceId: string) => {
  const resource = { ...mockResource, id: resourceId };
  return Promise.resolve<Resource>(resource);
});
const mockCreateResource = jest.fn((interactiveId: string) => {
  return Promise.resolve<Resource>(mockResource);
});
const mockAccessKeyId = "access-key-id";
const mockExpiration = new Date();
const mockSecretAccessKey = "secret-access-key";
const mockSessionToken = "session-token";
const mockCredentials: Credentials = {
  accessKeyId: mockAccessKeyId,
  expiration: mockExpiration,
  secretAccessKey: mockSecretAccessKey,
  sessionToken: mockSessionToken
};
const mockGetCredentials = jest.fn(() => mockCredentials);
const mockReadWriteToken = "read-write-token";
const mockGetReadWriteToken = jest.fn(() => mockReadWriteToken);
const mockGetPublicS3Path = jest.fn(() => mockResourcePublicPath);
// the jwt of the client each token-service request was made with
let mockRequestJwts: Array<string | undefined> = [];
jest.mock("@concord-consortium/token-service", () => ({
  TokenServiceClient: jest.fn(({ jwt }: { jwt?: string }) => ({
    getResource: (...args: any[]) => { mockRequestJwts.push(jwt); return (mockGetResource as any)(...args); },
    createResource: (...args: any[]) => { mockRequestJwts.push(jwt); return (mockCreateResource as any)(...args); },
    getCredentials: (...args: any[]) => { mockRequestJwts.push(jwt); return (mockGetCredentials as any)(...args); },
    getReadWriteToken: mockGetReadWriteToken,
    getPublicS3Path: mockGetPublicS3Path
  }))
}));

const clientOf = (mgr: AttachmentsManager) => (mgr as any).tokenServiceClient;

describe("AttachmentsManager", () => {
  beforeEach(() => {
    mockCount = 0;
    mockRequestJwts = [];
  });

  describe("when anonymous", () => {
    const mockRunKey = "anonymous-run-key";
    let mgr: AttachmentsManager;

    beforeEach(() => {
      mgr = new AttachmentsManager({
        tokenServiceEnv: "staging",
        tokenServiceFirestoreJWT: undefined,
        writeOptions: {
          runKey: mockRunKey,
          runRemoteEndpoint: undefined
        }
      });
    });

    it("should initialize", async () => {
      expect(mgr.getSessionId()).toBe("uuid-1");
      expect((mgr as any).learnerId).toBe(mockRunKey);
      expect((mgr as any).firebaseJwt).toBeUndefined();
      expect(mgr.isAnonymous()).toBe(true);
      // mock constructor should have been called
      expect(TokenServiceClient).toHaveBeenCalled();
      expect((mgr as any).tokenServiceClient).toBeDefined();
    });

    it("should create folder", async () => {
      const folder = await mgr.createFolder("interactive-id");
      expect(folder.id).toBe(mockFolderId);
      expect(folder.readWriteToken).toBe(mockReadWriteToken);
      expect(folder.ownerId).toBe(mockRunKey);
      const folderResource = await (mgr as any).getFolderResource(clientOf(mgr), { id: mockFolderId });
      expect(folderResource).toEqual(mockResource);
    });

    it("should retrieve folder", async () => {
      const folderResource = await (mgr as any).getFolderResource(clientOf(mgr), { id: mockFolderId });
      expect(folderResource).toEqual(mockResource);
    });

    it("can get credentials", async () => {
      const credentials: Credentials = await (mgr as any).getCredentials(clientOf(mgr), { id: mockFolderId });
      expect(credentials.accessKeyId).toBe(mockAccessKeyId);
      expect(credentials.secretAccessKey).toBe(mockSecretAccessKey);
    });

    it("can get signed read url", async () => {
      const readInfo: IReadableAttachmentInfo = {
        folder: { id: mockFolderId, ownerId: mockUserId},
        publicPath: mockResourcePublicPath,
        contentType: mockContentType
      };
      const url = await mgr.getSignedReadUrl(readInfo);
      expect(lastSignedUrlRequestIsGet()).toBe(true);
      expect(url).toBe(mockSignedReadUrl);
    });

    it("can get signed write url with default options", async () => {
      const folder: IAttachmentsFolder = {
        id: mockFolderId, readWriteToken: mockReadWriteToken, ownerId: mockUserId
      };
      const url = await mgr.getSignedWriteUrl(folder, "foo");
      const readInfo: IReadableAttachmentInfo = {
        publicPath: mockResourcePublicPath, folder, contentType: mockContentType
      };
      expect(lastSignedUrlRequestIsPut()).toBe(true);
      expect(url).toEqual([mockSignedWriteUrl, readInfo]);
    });

    it("can get signed write url with explicit options", async () => {
      const folder: IAttachmentsFolder = {
        id: mockFolderId, readWriteToken: mockReadWriteToken, ownerId: mockUserId
      };
      const options: ISignedWriteUrlOptions = {
        ContentType: mockContentType,
        expiresIn: 60 * 60
      };
      const url = await mgr.getSignedWriteUrl(folder, "foo", options);
      const readInfo: IReadableAttachmentInfo = {
        publicPath: mockResourcePublicPath, folder, contentType: mockContentType
      };
      expect(lastSignedUrlRequestIsPut()).toBe(true);
      expect(lastSignedUrlRequest()[1].input.ContentType).toBe(mockContentType);
      expect(url).toEqual([mockSignedWriteUrl, readInfo]);
    });

    it("type of signed write url defaults to text/plain", async () => {
      const folder: IAttachmentsFolder = {
        id: mockFolderId, readWriteToken: mockReadWriteToken, ownerId: mockUserId
      };
      const options: IS3SignedUrlOptions = { Key: "foo" };
      const url = await (mgr as any).getSignedUrl(clientOf(mgr), folder, "putObject", options);
      expect(lastSignedUrlRequestIsPut()).toBe(true);
      expect(lastSignedUrlRequest()[1].input.ContentType).toBe("text/plain");
      expect(url).toEqual(mockSignedWriteUrl);
    });
  });

  describe("when authenticated", () => {
    const mockRunRemoteEndpoint = "run-remote-endpoint";
    let mgr: AttachmentsManager;

    beforeEach(() => {
      mgr = new AttachmentsManager({
        tokenServiceEnv: "staging",
        tokenServiceFirestoreJWT: mockRawFirebaseJWT,
        writeOptions: {
          runKey: undefined,
          runRemoteEndpoint: mockRunRemoteEndpoint
        }
      });
    });

    it("should initialize", () => {
      expect(mgr.getSessionId()).toBe("uuid-1");
      expect((mgr as any).learnerId).toBe(mockRunRemoteEndpoint);
      expect((mgr as any).firebaseJwt).toBe(mockRawFirebaseJWT);
      expect(mgr.isAnonymous()).toBe(false);
      // mock constructor should have been called
      expect(TokenServiceClient).toHaveBeenCalled();
      expect((mgr as any).tokenServiceClient).toBeDefined();
    });

    it("should create folder", async () => {
      // authenticated users don't require readWriteToken
      mockGetReadWriteToken.mockImplementation(() => "");
      const folder = await mgr.createFolder("interactive-id");
      expect(folder.id).toBe(mockFolderId);
      expect(folder.readWriteToken).toBeUndefined();
      const folderResource = await (mgr as any).getFolderResource(clientOf(mgr), { id: mockFolderId });
      expect(folderResource).toEqual(mockResource);
    });

    it("should retrieve folder", async () => {
      const folderResource = await (mgr as any).getFolderResource(clientOf(mgr), { id: mockFolderId });
      expect(folderResource).toEqual(mockResource);
    });

    it("can get credentials", async () => {
      const credentials: Credentials = await (mgr as any).getCredentials(clientOf(mgr), { id: mockFolderId });
      expect(credentials.accessKeyId).toBe(mockAccessKeyId);
      expect(credentials.secretAccessKey).toBe(mockSecretAccessKey);
    });

    it("can get signed read url", async () => {
      const folder: IAttachmentsFolder = { id: mockFolderId, ownerId: mockUserId };
      const readInfo: IReadableAttachmentInfo = {
        publicPath: mockResourcePublicPath, folder, contentType: mockContentType
      };
      const url = await mgr.getSignedReadUrl(readInfo, { expiresIn: 60 * 60 });
      expect(lastSignedUrlRequestIsGet()).toBe(true);
      expect(url).toBe(mockSignedReadUrl);
    });

    it("can get signed write url", async () => {
      const url = await mgr.getSignedWriteUrl({ id: mockFolderId, ownerId: mockUserId }, "foo", { expiresIn: 60 * 60 });
      const readInfo: IReadableAttachmentInfo = {
        publicPath: mockResourcePublicPath,
        folder: { id: mockFolderId, ownerId: mockUserId },
        contentType: mockContentType
      };
      expect(lastSignedUrlRequestIsPut()).toBe(true);
      expect(url).toEqual([mockSignedWriteUrl, readInfo]);
    });

    it("sends the static token with every request, without checking its expiry", async () => {
      const folder: IAttachmentsFolder = { id: "another-folder-id", ownerId: mockUserId };
      await mgr.getSignedWriteUrl(folder, "foo");
      await mgr.getSignedReadUrl({ folder, publicPath: mockResourcePublicPath, contentType: mockContentType });
      expect(mockRequestJwts).toEqual([mockRawFirebaseJWT, mockRawFirebaseJWT, mockRawFirebaseJWT]);
    });
  });

  describe("with a token source", () => {
    const mockRunRemoteEndpoint = "run-remote-endpoint";
    const startMs = new Date("2026-10-05T12:00:00Z").getTime();
    const nowSec = () => Math.floor(Date.now() / 1000);
    const readInfo: IReadableAttachmentInfo = {
      folder: { id: mockFolderId, ownerId: mockUserId },
      publicPath: mockResourcePublicPath,
      contentType: mockContentType
    };
    let tokenCount: number;
    let getToken: jest.Mock<Promise<string>, []>;
    const makeManager = (tokenServiceFirestoreJWT?: string) => new AttachmentsManager({
      tokenServiceEnv: "staging",
      tokenServiceFirestoreJWT,
      getTokenServiceFirestoreJWT: getToken,
      writeOptions: { runRemoteEndpoint: mockRunRemoteEndpoint }
    });

    beforeEach(() => {
      jest.useFakeTimers("modern");
      jest.setSystemTime(startMs);
      tokenCount = 0;
      getToken = jest.fn(() => Promise.resolve(makeJwt({ iat: nowSec(), exp: nowSec() + 60 * 60, n: ++tokenCount })));
    });

    afterEach(() => {
      jest.useRealTimers();
    });

    it("is not anonymous, and does not call the source until a request needs a token", () => {
      const mgr = makeManager();
      expect(mgr.isAnonymous()).toBe(false);
      expect(getToken).not.toHaveBeenCalled();
    });

    it("creates folders with the user and context access rule", async () => {
      await makeManager().createFolder("interactive-id");
      expect(lastCall(mockCreateResource)[0].accessRuleType).toEqual(["user", "context"]);
      expect(mockRequestJwts).toEqual([await getToken.mock.results[0].value]);
    });

    it("reuses a token while it is fresh", async () => {
      const mgr = makeManager();
      await mgr.getSignedReadUrl(readInfo);
      jest.setSystemTime(startMs + 50 * 60 * 1000);
      await mgr.getSignedReadUrl(readInfo);
      expect(getToken).toHaveBeenCalledTimes(1);
      const firstToken = await getToken.mock.results[0].value;
      expect(mockRequestJwts.length).toBeGreaterThan(1);
      expect(new Set(mockRequestJwts)).toEqual(new Set([firstToken]));
    });

    it("gets a new token once the cached one is within five minutes of expiring", async () => {
      const mgr = makeManager();
      await mgr.getSignedReadUrl(readInfo);
      const firstToken = await getToken.mock.results[0].value;
      jest.setSystemTime(startMs + 56 * 60 * 1000);
      mockRequestJwts = [];
      await mgr.getSignedReadUrl(readInfo);
      expect(getToken).toHaveBeenCalledTimes(2);
      const secondToken = await getToken.mock.results[1].value;
      expect(secondToken).not.toBe(firstToken);
      expect(mockRequestJwts).toEqual([secondToken]);
    });

    it("ignores a static token when a source is given", async () => {
      const token = makeJwt({ iat: nowSec(), exp: nowSec() + 60 * 60 });
      getToken.mockImplementation(() => Promise.resolve(token));
      const mgr = makeManager(token);
      expect(mgr.isAnonymous()).toBe(false);
      await mgr.getSignedReadUrl(readInfo);
      await mgr.getSignedReadUrl(readInfo);
      expect(getToken).toHaveBeenCalledTimes(1);
    });

    it.each([["fast", 2 * 60], ["slow", -10]])(
      "times the token from receipt when the browser clock is %s", async (_, skewMin: number) => {
        // the portal's clock is skewMin minutes behind the browser's
        getToken.mockImplementation(() => {
          const iat = nowSec() - skewMin * 60;
          return Promise.resolve(makeJwt({ iat, exp: iat + 60 * 60, n: ++tokenCount }));
        });
        const mgr = makeManager();
        await mgr.getSignedReadUrl(readInfo);
        jest.setSystemTime(startMs + 50 * 60 * 1000);
        await mgr.getSignedReadUrl(readInfo);
        expect(getToken).toHaveBeenCalledTimes(1);
        jest.setSystemTime(startMs + 56 * 60 * 1000);
        await mgr.getSignedReadUrl(readInfo);
        expect(getToken).toHaveBeenCalledTimes(2);
      }
    );

    it("does not restart a token's lifetime when the source returns it again", async () => {
      const token = makeJwt({ iat: nowSec(), exp: nowSec() + 60 * 60 });
      getToken.mockImplementation(() => Promise.resolve(token));
      const mgr = makeManager();
      await mgr.getSignedReadUrl(readInfo);
      jest.setSystemTime(startMs + 56 * 60 * 1000);
      await mgr.getSignedReadUrl(readInfo);
      jest.setSystemTime(startMs + 57 * 60 * 1000);
      await mgr.getSignedReadUrl(readInfo);
      expect(getToken).toHaveBeenCalledTimes(3);
      expect(new Set(mockRequestJwts)).toEqual(new Set([token]));
    });

    it("does not restart a token's lifetime when the source returns it after a different token", async () => {
      const tokenA = makeJwt({ iat: nowSec(), exp: nowSec() + 60 * 60, n: "a" });
      const tokenB = makeJwt({ iat: nowSec() + 56 * 60, exp: nowSec() + 116 * 60, n: "b" });
      getToken
        .mockImplementationOnce(() => Promise.resolve(tokenA))
        .mockImplementationOnce(() => Promise.resolve(tokenB))
        .mockImplementation(() => Promise.resolve(tokenA));
      const mgr = makeManager();
      await mgr.getSignedReadUrl(readInfo);
      jest.setSystemTime(startMs + 56 * 60 * 1000);
      await mgr.getSignedReadUrl(readInfo);
      jest.setSystemTime(startMs + 112 * 60 * 1000);
      await mgr.getSignedReadUrl(readInfo);
      jest.setSystemTime(startMs + 113 * 60 * 1000);
      await mgr.getSignedReadUrl(readInfo);
      expect(getToken).toHaveBeenCalledTimes(4);
      expect(mockRequestJwts[mockRequestJwts.length - 1]).toBe(tokenA);
    });

    it("calls the source once per request when the token's expiry cannot be read", async () => {
      getToken.mockImplementation(() => Promise.resolve(`unreadable-${++tokenCount}`));
      const mgr = makeManager();
      await mgr.getSignedWriteUrl({ id: "uncached-folder-id", ownerId: mockUserId }, "foo");
      expect(getToken).toHaveBeenCalledTimes(1);
      expect(mockRequestJwts).toEqual(["unreadable-1", "unreadable-1"]);
      await mgr.getSignedReadUrl(readInfo);
      expect(getToken).toHaveBeenCalledTimes(2);
      expect(mockRequestJwts[mockRequestJwts.length - 1]).toBe("unreadable-2");
    });

    it("shares one call to the source between concurrent requests", async () => {
      const mgr = makeManager();
      await Promise.all([1, 2, 3].map(() => mgr.getSignedReadUrl(readInfo)));
      expect(getToken).toHaveBeenCalledTimes(1);
    });

    it("fails the request when the source fails, and calls it again on the next request", async () => {
      getToken.mockImplementationOnce(() => Promise.reject(new Error("portal unavailable")));
      const mgr = makeManager();
      await expect(mgr.getSignedReadUrl(readInfo)).rejects.toThrow("portal unavailable");
      expect(mockRequestJwts).toEqual([]);
      await expect(mgr.getSignedReadUrl(readInfo)).resolves.toBe(mockSignedReadUrl);
      expect(getToken).toHaveBeenCalledTimes(2);
      const secondToken = await getToken.mock.results[1].value;
      expect(mockRequestJwts).toEqual([secondToken, secondToken]);
    });

    it("fails the request when the source returns no token", async () => {
      getToken.mockImplementationOnce(() => Promise.resolve(""));
      await expect(makeManager().getSignedReadUrl(readInfo)).rejects.toThrow("the token source returned no token");
      expect(mockRequestJwts).toEqual([]);
    });

    it("reports a source failure to the interactive as response.error", async () => {
      getToken.mockImplementationOnce(() => Promise.reject("portal unavailable"));
      initializeAttachmentsManager({
        tokenServiceEnv: "staging",
        getTokenServiceFirestoreJWT: getToken,
        writeOptions: { runRemoteEndpoint: mockRunRemoteEndpoint }
      });
      const response = await handleGetAttachmentUrl({
        request: { name: "foo", operation: "read", requestId: 1 } as IAttachmentUrlRequest,
        answerMeta: { attachments: { foo: readInfo } }
      });
      expect(response.url).toBeUndefined();
      expect(response.error).toMatch(/portal unavailable/);
    });
  });
});
