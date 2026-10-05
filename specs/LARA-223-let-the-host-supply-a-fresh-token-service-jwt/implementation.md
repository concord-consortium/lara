# Implementation Plan: Let the Host Supply a Fresh Token-Service JWT to the Attachments Manager

**Jira**: https://concord-consortium.atlassian.net/browse/LARA-223
**Requirements Spec**: [requirements.md](requirements.md)
**Status**: **In Development**

## Implementation Plan

All paths below are relative to `lara-typescript/src/interactive-api-host/`.

### Read a JWT's lifetime

**Summary**: Adds `getJwtLifetime`, the R4 decoder, to the existing attachments helpers. It stands alone (nothing calls it yet), so it can be reviewed as a pure function with its own tests before the manager depends on it.

**Files affected**:
- `attachments-api/helpers.ts`: add `getJwtLifetime`.
- `attachments-api/helpers.test.ts`: add a `getJwtLifetime` block.
- `attachments-api/test-utils.ts` (new): `base64url` and `makeJwt`, shared by this step's tests and the manager tests in the next step.

**Estimated diff size**: ~45 lines

```diff
@@ -16,2 +16,18 @@ export const answerMetadataToAttachmentInfoMap = (metadata?: IAnswerMetadataWith
   return result;
 };
+
+// Returns a JWT's lifetime in seconds (`exp` minus `iat`), or undefined when either claim cannot be read.
+// The signature is not verified: the value is only a hint for when to request a new token.
+export const getJwtLifetime = (jwt?: string): number | undefined => {
+  const parts = jwt?.split(".");
+  if (parts?.length !== 3) {
+    return undefined;
+  }
+  const base64 = parts[1].replace(/-/g, "+").replace(/_/g, "/");
+  try {
+    const { exp, iat } = JSON.parse(atob(base64 + "===".slice((base64.length + 3) % 4)));
+    return typeof exp === "number" && typeof iat === "number" ? exp - iat : undefined;
+  } catch (e) {
+    return undefined;
+  }
+};
```

The payload is base64url, so `-`/`_` are mapped back and the padding restored before `atob`; plain `atob` throws on the unmapped form. Any failure, including a missing or non-numeric `exp` or `iat`, returns `undefined`, which R4 treats as stale. Only the difference `exp - iat` is used, never either claim against the browser clock.

```diff
@@ -1,3 +1,4 @@
-import { answerMetadataToAttachmentInfoMap } from "./helpers";
+import { answerMetadataToAttachmentInfoMap, getJwtLifetime } from "./helpers";
+import { base64url } from "./test-utils";
 import { IAnswerMetadataWithAttachmentsInfo } from "./types";
 
@@ -44,3 +45,24 @@ describe("helpers", () => {
     });
   });
+
+  describe("getJwtLifetime", () => {
+    const jwtWithPayload = (payload: string) => `header.${base64url(payload)}.signature`;
+
+    it("reads exp minus iat from a base64url payload", () => {
+      // this payload encodes to base64url containing "-", which plain atob rejects
+      const jwt = jwtWithPayload(JSON.stringify({ iat: 1700000000, exp: 1700003600, uid: "user?>>0" }));
+      expect(jwt).toMatch(/-/);
+      expect(getJwtLifetime(jwt)).toBe(3600);
+    });
+
+    it("returns undefined when exp or iat cannot be read", () => {
+      expect(getJwtLifetime(undefined)).toBeUndefined();
+      expect(getJwtLifetime("rawFirebaseJWT")).toBeUndefined();
+      expect(getJwtLifetime("header.!!!.signature")).toBeUndefined();
+      expect(getJwtLifetime(jwtWithPayload("not json"))).toBeUndefined();
+      expect(getJwtLifetime(jwtWithPayload(JSON.stringify({ iat: 1700000000, exp: "1700003600" })))).toBeUndefined();
+      expect(getJwtLifetime(jwtWithPayload(JSON.stringify({ iat: "1700000000", exp: 1700003600 })))).toBeUndefined();
+      expect(getJwtLifetime(jwtWithPayload(JSON.stringify({ exp: 1700003600 })))).toBeUndefined();
+    });
+  });
 });
```

`attachments-api/test-utils.ts` (new). Its name does not match Jest's `testRegex`, so it is not run as a suite. Nothing reachable from the package's `index.ts` imports it, so it adds no runtime code; like the test files, it gets a `.d.ts` in the published package, which carries one per source file:

```ts
export const base64url = (value: string) =>
  Buffer.from(value).toString("base64").replace(/=+$/, "").replace(/\+/g, "-").replace(/\//g, "_");

export const makeJwt = (claims: Record<string, unknown>) =>
  `header.${base64url(JSON.stringify(claims))}.signature`;
```

The base64url test asserts the encoded token really contains `-`, so it cannot pass vacuously on a payload plain `atob` would also accept.

---

### Accept a token source in the attachments manager

**Summary**: Adds `getTokenServiceFirestoreJWT` to `IAttachmentsManagerInitOptions` and makes the manager get its token-service client through one method that refreshes the token from the source when the cached one is stale (R1 to R10), with the tests R11 lists.

**Files affected**:
- `attachments-api/types.ts`: the new option, with its doc comment (R12, first part).
- `attachments-api/attachments-manager.ts`: token cache timed from receipt, shared in-flight call, per-call client.
- `attachments-api/attachments-manager.test.ts`: mock records the token each request was sent with; existing private-method calls pass the client; new `with a token source` block (including R6 end to end through `handleGetAttachmentUrl`) and one static-path test.

**Estimated diff size**: ~290 lines (about 100 source, 195 test)

```diff
@@ -36,4 +36,10 @@ export interface IAttachmentsManagerInitOptions {
   tokenServiceEnv: EnvironmentName;
   tokenServiceFirestoreJWT?: string;
+  // Returns a newly minted token-service JWT. Token-service JWTs expire (portal-issued ones after an hour), so a
+  // host whose pages stay open longer should provide this, and then tokenServiceFirestoreJWT is not used. The
+  // manager calls it when a request needs a token and the cached one is missing or near expiry, which it times from
+  // when the token arrived. The promise must settle: concurrent and later requests wait on a pending call, so
+  // reject on a timeout.
+  getTokenServiceFirestoreJWT?: () => Promise<string>;
   // These options are necessary only when attachments manager is expected to support write operation.
   writeOptions?: {
```

```diff
@@ -2,5 +2,6 @@ import { S3Client, GetObjectCommand, PutObjectCommand } from "@aws-sdk/client-s3
 import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
 import { v4 as uuid } from "uuid";
-import { Credentials, S3Resource, TokenServiceClient } from "@concord-consortium/token-service";
+import { Credentials, EnvironmentName, S3Resource, TokenServiceClient } from "@concord-consortium/token-service";
+import { getJwtLifetime } from "./helpers";
 import { IAttachmentsFolder, IAttachmentsManagerInitOptions, IReadableAttachmentInfo } from "./types";
 
@@ -22,9 +23,14 @@ const kTokenServiceToolName = "interactive-attachments";
 const kDefaultWriteExpirationSec = 5 * 60;
 const kDefaultReadExpirationSec = 2 * 60 * 60;
+const kTokenRefreshMarginSec = 5 * 60;
 
 export class AttachmentsManager {
   public learnerId?: string;
   private sessionId = uuid();
+  private tokenServiceEnv: EnvironmentName;
   private firebaseJwt?: string;
+  private firebaseJwtStaleAtMs?: number;
+  private getFirebaseJwt?: () => Promise<string>;
+  private pendingFirebaseJwt?: Promise<string>;
   private tokenServiceClient: TokenServiceClient;
   private resources: Record<string, S3Resource> = {};
@@ -35,11 +41,14 @@ export class AttachmentsManager {
       throw new Error("Attachments Manager requires runKey or runRemoteEndpoint to support write operation");
     }
-    this.firebaseJwt = options.tokenServiceFirestoreJWT;
-    this.tokenServiceClient = new TokenServiceClient({ env: options.tokenServiceEnv, jwt: this.firebaseJwt });
+    this.tokenServiceEnv = options.tokenServiceEnv;
+    this.getFirebaseJwt = options.getTokenServiceFirestoreJWT;
+    // A token source supplies every token, so the static token is used only without one.
+    this.firebaseJwt = this.getFirebaseJwt ? undefined : options.tokenServiceFirestoreJWT;
+    this.tokenServiceClient = new TokenServiceClient({ env: this.tokenServiceEnv, jwt: this.firebaseJwt });
   }
 
   public isAnonymous() {
-    // The client will be anonymous if firebaseJwt undefined
-    return !this.firebaseJwt;
+    // The client will be anonymous if it has neither a firebaseJwt nor a way to get one
+    return !this.firebaseJwt && !this.getFirebaseJwt;
   }
 
@@ -56,5 +65,6 @@ export class AttachmentsManager {
       return Promise.reject("Folder can't be created without valid learnerId");
     }
-    const folderResource = await this.tokenServiceClient.createResource({
+    const client = await this.getTokenServiceClient();
+    const folderResource = await client.createResource({
       tool: kTokenServiceToolName,
       type: "s3Folder",
@@ -67,5 +77,5 @@ export class AttachmentsManager {
       id: folderResource.id,
       ownerId: this.learnerId,
-      readWriteToken: this.tokenServiceClient.getReadWriteToken(folderResource) || undefined
+      readWriteToken: client.getReadWriteToken(folderResource) || undefined
     };
   }
@@ -76,15 +86,17 @@ export class AttachmentsManager {
     const { ContentType = "text/plain", expiresIn = kDefaultWriteExpirationSec } = options || {};
     // TODO: validate the type; cf. https://advancedweb.hu/how-to-use-s3-put-signed-urls/
-    const folderResource = await this.getFolderResource(folder);
-    const publicPath = this.tokenServiceClient.getPublicS3Path(folderResource, `${this.sessionId}/${name}`);
-    const url = await this.getSignedUrl(folder, "putObject", { Key: publicPath, ContentType, expiresIn });
+    const client = await this.getTokenServiceClient();
+    const folderResource = await this.getFolderResource(client, folder);
+    const publicPath = client.getPublicS3Path(folderResource, `${this.sessionId}/${name}`);
+    const url = await this.getSignedUrl(client, folder, "putObject", { Key: publicPath, ContentType, expiresIn });
     // returns the writable url and the information required to read it
     return [url, { folder, publicPath, contentType: ContentType }];
   }
 
-  public getSignedReadUrl(attachmentInfo: IReadableAttachmentInfo, options?: ISignedReadUrlOptions) {
+  public async getSignedReadUrl(attachmentInfo: IReadableAttachmentInfo, options?: ISignedReadUrlOptions) {
     const { publicPath, folder } = attachmentInfo;
     const { expiresIn = kDefaultReadExpirationSec } = options || {};
-    return this.getSignedUrl(folder, "getObject", {
+    const client = await this.getTokenServiceClient();
+    return this.getSignedUrl(client, folder, "getObject", {
       Key: publicPath,
       expiresIn
@@ -92,8 +104,49 @@ export class AttachmentsManager {
   }
 
-  private async getFolderResource(folder: IAttachmentsFolder): Promise<S3Resource> {
+  // Returns a client whose token is fresh, calling the token source when the cached token is stale.
+  // Each public method calls this once and passes the client on, so one manager call makes at most one source call.
+  private async getTokenServiceClient(): Promise<TokenServiceClient> {
+    if (this.getFirebaseJwt && !this.isFirebaseJwtFresh()) {
+      const jwt = await this.fetchFirebaseJwt(this.getFirebaseJwt);
+      // a token returned again keeps the stale time it got when it first arrived
+      if (jwt !== this.firebaseJwt) {
+        this.firebaseJwt = jwt;
+        this.firebaseJwtStaleAtMs = this.getStaleAtMs(jwt);
+        this.tokenServiceClient = new TokenServiceClient({ env: this.tokenServiceEnv, jwt });
+      }
+    }
+    return this.tokenServiceClient;
+  }
+
+  // The lifetime is counted from receipt, so a browser clock that disagrees with the portal's does not matter.
+  private getStaleAtMs(jwt: string) {
+    const lifetime = getJwtLifetime(jwt);
+    return lifetime !== undefined ? Date.now() + (lifetime - kTokenRefreshMarginSec) * 1000 : undefined;
+  }
+
+  private isFirebaseJwtFresh() {
+    return this.firebaseJwtStaleAtMs !== undefined && Date.now() < this.firebaseJwtStaleAtMs;
+  }
+
+  // Concurrent callers share one call to the token source; a failed call is not reused.
+  private fetchFirebaseJwt(getFirebaseJwt: () => Promise<string>) {
+    if (!this.pendingFirebaseJwt) {
+      this.pendingFirebaseJwt = Promise.resolve()
+        .then(getFirebaseJwt)
+        .then(jwt => {
+          if (!jwt) {
+            throw new Error("the token source returned no token");
+          }
+          return jwt;
+        })
+        .finally(() => { this.pendingFirebaseJwt = undefined; });
+    }
+    return this.pendingFirebaseJwt;
+  }
+
+  private async getFolderResource(client: TokenServiceClient, folder: IAttachmentsFolder): Promise<S3Resource> {
     let folderResource: S3Resource = this.resources[folder.id];
     if (!folderResource) {
-      folderResource = await this.tokenServiceClient.getResource(folder.id) as S3Resource;
+      folderResource = await client.getResource(folder.id) as S3Resource;
       this.resources[folderResource.id] = folderResource;
     }
@@ -101,12 +154,14 @@ export class AttachmentsManager {
   }
 
-  private getCredentials(folder: IAttachmentsFolder): Promise<Credentials> {
-    return this.tokenServiceClient.getCredentials(folder.id, folder.readWriteToken);
+  private getCredentials(client: TokenServiceClient, folder: IAttachmentsFolder): Promise<Credentials> {
+    return client.getCredentials(folder.id, folder.readWriteToken);
   }
 
-  private async getSignedUrl(folder: IAttachmentsFolder, operation: S3Operation, options: IS3SignedUrlOptions) {
+  private async getSignedUrl(
+    client: TokenServiceClient, folder: IAttachmentsFolder, operation: S3Operation, options: IS3SignedUrlOptions
+  ) {
     const { Key, ContentType = "text/plain", expiresIn } = options;
-    const folderResource = await this.getFolderResource(folder);
-    const credentials = await this.getCredentials(folder);
+    const folderResource = await this.getFolderResource(client, folder);
+    const credentials = await this.getCredentials(client, folder);
     const { bucket: Bucket, region } = folderResource;
     const { accessKeyId, secretAccessKey, sessionToken } = credentials;
```

How it meets the requirements:

- **One client per manager call (R2).** Each public method (`createFolder`, `getSignedWriteUrl`, `getSignedReadUrl`) calls `getTokenServiceClient()` once and passes the client to `getFolderResource`, `getCredentials` and `getSignedUrl`. Without that, a write to an uncached folder (`getResource` then `getCredentials`) would check freshness twice, and with an unreadable `exp` would call the source twice.
- **Cache and refresh (R3, R4).** `firebaseJwt` is the cached token. When the source returns a token different from it, the manager records `firebaseJwtStaleAtMs`, the receipt time plus `exp - iat` minus `kTokenRefreshMarginSec` (300), and builds a new client, because `TokenServiceClient.jwt` is `readonly`. `isFirebaseJwtFresh()` compares that time with `Date.now()`. A token returned again keeps its first stale time, so a host that returns an old token cannot restart its lifetime; it is sent, and the source is called again on the next call.
- **Static token with a source (R7).** The constructor drops `tokenServiceFirestoreJWT` when a source is given, so the first request calls the source. Without that, a source returning the same token as the static one would never get a stale time and would be called on every request.
- **Shared call and failure (R5, R6).** `pendingFirebaseJwt` holds the in-flight call; `finally` clears it on success or failure, so a rejection reaches every waiter and the next request starts a new call. `Promise.resolve().then(getFirebaseJwt)` turns a source that throws synchronously into a rejection too. An empty token rejects with `the token source returned no token`. `handleGetAttachmentUrl` already turns any of these into `response.error`; it needs no change.
- **Unchanged paths (R8, R10).** With no source, `getTokenServiceClient()` returns the constructor's client untouched and never decodes the token. A folder's `readWriteToken` still takes precedence inside `TokenServiceClient.fetchFromServiceUrl`.
- **`isAnonymous()` (R9).** True only with neither option. The source is not called at construction.

Tests:

```diff
@@ -2,4 +2,8 @@ import { GetObjectCommand, PutObjectCommand } from "@aws-sdk/client-s3";
 import { Credentials, Resource, TokenServiceClient } from "@concord-consortium/token-service";
 import { AttachmentsManager, IS3SignedUrlOptions, ISignedWriteUrlOptions } from "./attachments-manager";
+import { initializeAttachmentsManager } from "./attachments-manager-global";
+import { handleGetAttachmentUrl } from "./handle-get-attachment-url";
+import { makeJwt } from "./test-utils";
+import { IAttachmentUrlRequest } from "../types";
 import { IAttachmentsFolder, IReadableAttachmentInfo } from "./types";
 
@@ -63,9 +67,11 @@ const mockReadWriteToken = "read-write-token";
 const mockGetReadWriteToken = jest.fn(() => mockReadWriteToken);
 const mockGetPublicS3Path = jest.fn(() => mockResourcePublicPath);
+// the jwt of the client each token-service request was made with
+let mockRequestJwts: Array<string | undefined> = [];
 jest.mock("@concord-consortium/token-service", () => ({
-  TokenServiceClient: jest.fn(() => ({
-    getResource: mockGetResource,
-    createResource: mockCreateResource,
-    getCredentials: mockGetCredentials,
+  TokenServiceClient: jest.fn(({ jwt }: { jwt?: string }) => ({
+    getResource: (...args: any[]) => { mockRequestJwts.push(jwt); return (mockGetResource as any)(...args); },
+    createResource: (...args: any[]) => { mockRequestJwts.push(jwt); return (mockCreateResource as any)(...args); },
+    getCredentials: (...args: any[]) => { mockRequestJwts.push(jwt); return (mockGetCredentials as any)(...args); },
     getReadWriteToken: mockGetReadWriteToken,
     getPublicS3Path: mockGetPublicS3Path
@@ -73,7 +79,10 @@ jest.mock("@concord-consortium/token-service", () => ({
 }));
 
+const clientOf = (mgr: AttachmentsManager) => (mgr as any).tokenServiceClient;
+
 describe("AttachmentsManager", () => {
   beforeEach(() => {
     mockCount = 0;
+    mockRequestJwts = [];
   });
 
@@ -108,15 +117,15 @@ describe("AttachmentsManager", () => {
       expect(folder.readWriteToken).toBe(mockReadWriteToken);
       expect(folder.ownerId).toBe(mockRunKey);
-      const folderResource = await (mgr as any).getFolderResource({ id: mockFolderId });
+      const folderResource = await (mgr as any).getFolderResource(clientOf(mgr), { id: mockFolderId });
       expect(folderResource).toEqual(mockResource);
     });
 
     it("should retrieve folder", async () => {
-      const folderResource = await (mgr as any).getFolderResource({ id: mockFolderId });
+      const folderResource = await (mgr as any).getFolderResource(clientOf(mgr), { id: mockFolderId });
       expect(folderResource).toEqual(mockResource);
     });
 
     it("can get credentials", async () => {
-      const credentials: Credentials = await (mgr as any).getCredentials({ id: mockFolderId });
+      const credentials: Credentials = await (mgr as any).getCredentials(clientOf(mgr), { id: mockFolderId });
       expect(credentials.accessKeyId).toBe(mockAccessKeyId);
       expect(credentials.secretAccessKey).toBe(mockSecretAccessKey);
@@ -168,5 +177,5 @@ describe("AttachmentsManager", () => {
       };
       const options: IS3SignedUrlOptions = { Key: "foo" };
-      const url = await (mgr as any).getSignedUrl(folder, "putObject", options);
+      const url = await (mgr as any).getSignedUrl(clientOf(mgr), folder, "putObject", options);
       expect(lastSignedUrlRequestIsPut()).toBe(true);
       expect(lastSignedUrlRequest()[1].input.ContentType).toBe("text/plain");
@@ -206,15 +215,15 @@ describe("AttachmentsManager", () => {
       expect(folder.id).toBe(mockFolderId);
       expect(folder.readWriteToken).toBeUndefined();
-      const folderResource = await (mgr as any).getFolderResource({ id: mockFolderId });
+      const folderResource = await (mgr as any).getFolderResource(clientOf(mgr), { id: mockFolderId });
       expect(folderResource).toEqual(mockResource);
     });
 
     it("should retrieve folder", async () => {
-      const folderResource = await (mgr as any).getFolderResource({ id: mockFolderId });
+      const folderResource = await (mgr as any).getFolderResource(clientOf(mgr), { id: mockFolderId });
       expect(folderResource).toEqual(mockResource);
     });
 
     it("can get credentials", async () => {
-      const credentials: Credentials = await (mgr as any).getCredentials({ id: mockFolderId });
+      const credentials: Credentials = await (mgr as any).getCredentials(clientOf(mgr), { id: mockFolderId });
       expect(credentials.accessKeyId).toBe(mockAccessKeyId);
       expect(credentials.secretAccessKey).toBe(mockSecretAccessKey);
@@ -241,4 +250,167 @@ describe("AttachmentsManager", () => {
       expect(url).toEqual([mockSignedWriteUrl, readInfo]);
     });
+
+    it("sends the static token with every request, without checking its expiry", async () => {
+      const folder: IAttachmentsFolder = { id: "another-folder-id", ownerId: mockUserId };
+      await mgr.getSignedWriteUrl(folder, "foo");
+      await mgr.getSignedReadUrl({ folder, publicPath: mockResourcePublicPath, contentType: mockContentType });
+      expect(mockRequestJwts).toEqual([mockRawFirebaseJWT, mockRawFirebaseJWT, mockRawFirebaseJWT]);
+    });
+  });
+
+  describe("with a token source", () => {
+    const mockRunRemoteEndpoint = "run-remote-endpoint";
+    const startMs = new Date("2026-10-05T12:00:00Z").getTime();
+    const nowSec = () => Math.floor(Date.now() / 1000);
+    const readInfo: IReadableAttachmentInfo = {
+      folder: { id: mockFolderId, ownerId: mockUserId },
+      publicPath: mockResourcePublicPath,
+      contentType: mockContentType
+    };
+    let tokenCount: number;
+    let getToken: jest.Mock<Promise<string>, []>;
+    const makeManager = (tokenServiceFirestoreJWT?: string) => new AttachmentsManager({
+      tokenServiceEnv: "staging",
+      tokenServiceFirestoreJWT,
+      getTokenServiceFirestoreJWT: getToken,
+      writeOptions: { runRemoteEndpoint: mockRunRemoteEndpoint }
+    });
+
+    beforeEach(() => {
+      jest.useFakeTimers("modern");
+      jest.setSystemTime(startMs);
+      tokenCount = 0;
+      getToken = jest.fn(() => Promise.resolve(makeJwt({ iat: nowSec(), exp: nowSec() + 60 * 60, n: ++tokenCount })));
+    });
+
+    afterEach(() => {
+      jest.useRealTimers();
+    });
+
+    it("is not anonymous, and does not call the source until a request needs a token", () => {
+      const mgr = makeManager();
+      expect(mgr.isAnonymous()).toBe(false);
+      expect(getToken).not.toHaveBeenCalled();
+    });
+
+    it("creates folders with the user and context access rule", async () => {
+      await makeManager().createFolder("interactive-id");
+      expect(lastCall(mockCreateResource)[0].accessRuleType).toEqual(["user", "context"]);
+      expect(mockRequestJwts).toEqual([await getToken.mock.results[0].value]);
+    });
+
+    it("reuses a token while it is fresh", async () => {
+      const mgr = makeManager();
+      await mgr.getSignedReadUrl(readInfo);
+      jest.setSystemTime(startMs + 50 * 60 * 1000);
+      await mgr.getSignedReadUrl(readInfo);
+      expect(getToken).toHaveBeenCalledTimes(1);
+      const firstToken = await getToken.mock.results[0].value;
+      expect(mockRequestJwts.length).toBeGreaterThan(1);
+      expect(new Set(mockRequestJwts)).toEqual(new Set([firstToken]));
+    });
+
+    it("gets a new token once the cached one is within five minutes of expiring", async () => {
+      const mgr = makeManager();
+      await mgr.getSignedReadUrl(readInfo);
+      const firstToken = await getToken.mock.results[0].value;
+      jest.setSystemTime(startMs + 56 * 60 * 1000);
+      mockRequestJwts = [];
+      await mgr.getSignedReadUrl(readInfo);
+      expect(getToken).toHaveBeenCalledTimes(2);
+      const secondToken = await getToken.mock.results[1].value;
+      expect(secondToken).not.toBe(firstToken);
+      expect(mockRequestJwts).toEqual([secondToken]);
+    });
+
+    it("ignores a static token when a source is given", async () => {
+      const token = makeJwt({ iat: nowSec(), exp: nowSec() + 60 * 60 });
+      getToken.mockImplementation(() => Promise.resolve(token));
+      const mgr = makeManager(token);
+      expect(mgr.isAnonymous()).toBe(false);
+      await mgr.getSignedReadUrl(readInfo);
+      await mgr.getSignedReadUrl(readInfo);
+      expect(getToken).toHaveBeenCalledTimes(1);
+    });
+
+    it.each([["fast", 2 * 60], ["slow", -10]])(
+      "times the token from receipt when the browser clock is %s", async (_, skewMin: number) => {
+        // the portal's clock is skewMin minutes behind the browser's
+        getToken.mockImplementation(() => {
+          const iat = nowSec() - skewMin * 60;
+          return Promise.resolve(makeJwt({ iat, exp: iat + 60 * 60, n: ++tokenCount }));
+        });
+        const mgr = makeManager();
+        await mgr.getSignedReadUrl(readInfo);
+        jest.setSystemTime(startMs + 50 * 60 * 1000);
+        await mgr.getSignedReadUrl(readInfo);
+        expect(getToken).toHaveBeenCalledTimes(1);
+        jest.setSystemTime(startMs + 56 * 60 * 1000);
+        await mgr.getSignedReadUrl(readInfo);
+        expect(getToken).toHaveBeenCalledTimes(2);
+      }
+    );
+
+    it("does not restart a token's lifetime when the source returns it again", async () => {
+      const token = makeJwt({ iat: nowSec(), exp: nowSec() + 60 * 60 });
+      getToken.mockImplementation(() => Promise.resolve(token));
+      const mgr = makeManager();
+      await mgr.getSignedReadUrl(readInfo);
+      jest.setSystemTime(startMs + 56 * 60 * 1000);
+      await mgr.getSignedReadUrl(readInfo);
+      jest.setSystemTime(startMs + 57 * 60 * 1000);
+      await mgr.getSignedReadUrl(readInfo);
+      expect(getToken).toHaveBeenCalledTimes(3);
+      expect(new Set(mockRequestJwts)).toEqual(new Set([token]));
+    });
+
+    it("calls the source once per request when the token's expiry cannot be read", async () => {
+      getToken.mockImplementation(() => Promise.resolve(`unreadable-${++tokenCount}`));
+      const mgr = makeManager();
+      await mgr.getSignedWriteUrl({ id: "uncached-folder-id", ownerId: mockUserId }, "foo");
+      expect(getToken).toHaveBeenCalledTimes(1);
+      expect(mockRequestJwts).toEqual(["unreadable-1", "unreadable-1"]);
+      await mgr.getSignedReadUrl(readInfo);
+      expect(getToken).toHaveBeenCalledTimes(2);
+      expect(mockRequestJwts[mockRequestJwts.length - 1]).toBe("unreadable-2");
+    });
+
+    it("shares one call to the source between concurrent requests", async () => {
+      const mgr = makeManager();
+      await Promise.all([1, 2, 3].map(() => mgr.getSignedReadUrl(readInfo)));
+      expect(getToken).toHaveBeenCalledTimes(1);
+    });
+
+    it("fails the request when the source fails, and calls it again on the next request", async () => {
+      getToken.mockImplementationOnce(() => Promise.reject(new Error("portal unavailable")));
+      const mgr = makeManager();
+      await expect(mgr.getSignedReadUrl(readInfo)).rejects.toThrow("portal unavailable");
+      expect(mockRequestJwts).toEqual([]);
+      await expect(mgr.getSignedReadUrl(readInfo)).resolves.toBe(mockSignedReadUrl);
+      expect(getToken).toHaveBeenCalledTimes(2);
+      const secondToken = await getToken.mock.results[1].value;
+      expect(mockRequestJwts).toEqual([secondToken, secondToken]);
+    });
+
+    it("fails the request when the source returns no token", async () => {
+      getToken.mockImplementationOnce(() => Promise.resolve(""));
+      await expect(makeManager().getSignedReadUrl(readInfo)).rejects.toThrow("the token source returned no token");
+      expect(mockRequestJwts).toEqual([]);
+    });
+
+    it("reports a source failure to the interactive as response.error", async () => {
+      getToken.mockImplementationOnce(() => Promise.reject("portal unavailable"));
+      initializeAttachmentsManager({
+        tokenServiceEnv: "staging",
+        getTokenServiceFirestoreJWT: getToken,
+        writeOptions: { runRemoteEndpoint: mockRunRemoteEndpoint }
+      });
+      const response = await handleGetAttachmentUrl({
+        request: { name: "foo", operation: "read", requestId: 1 } as IAttachmentUrlRequest,
+        answerMeta: { attachments: { foo: readInfo } }
+      });
+      expect(response.url).toBeUndefined();
+      expect(response.error).toMatch(/portal unavailable/);
+    });
   });
 });
```

Notes for the test writer:

- The `TokenServiceClient` mock now closes over the `jwt` each client was built with and pushes it to `mockRequestJwts` on every `getResource`, `createResource` and `getCredentials`. That observes the token actually sent, so a test fails if the manager fetched a new token but kept using the old client.
- Requests against `mockFolderId` hit `getResource` only the first time per manager (the folder cache), so a first read records two tokens and a later read one. The expected arrays follow that.
- Each token from the default source embeds a counter (`n`), so successive test tokens always differ even when minted in the same second. Real portal tokens carry no `jti` and can repeat within a second (see the requirements Technical Notes).
- The R6 end-to-end test lives here rather than in `handle-get-attachment-url.test.ts`, because that file replaces the manager's public methods with mocks, so a token source would never run there. It is the only test in this file that initializes the global manager, which resolves once per test file.
- `jest.useFakeTimers("modern")` with `jest.setSystemTime` moves `Date.now()`. The "five minutes" test sets the clock to 56 minutes into a 60-minute token, a point that is stale only because of the margin.
- The two clock tests mint tokens whose `iat` is two hours behind or ten minutes ahead of the browser clock. Comparing `exp` with `Date.now()` fails the first at 50 minutes (it refreshes on every request) and the second at 56 minutes (it keeps the token).
- Default test tokens carry `iat`; a token without it is stale on every request.

---

### Document the token source for host authors

**Summary**: R12's prose half: the guide's attachments row tells host authors when they need the option, and the package README stops naming a function that does not exist. Separate from the code step because it is prose and reviews differently.

**Files affected**:
- `interactive-host-guide.md`: attachments row of the section 6 table.
- `README.md`: usage line.

**Estimated diff size**: ~4 lines

`interactive-host-guide.md`, the **Attachments** row's last cell becomes:

```markdown
`initializeAttachmentsManager`, `handleGetAttachmentUrl`, `IAttachmentsManagerInitOptions`, `IReadableAttachmentInfo`. Pages that stay open longer than the token-service JWT lives (an hour for portal-issued tokens) should pass `getTokenServiceFirestoreJWT` so the manager can get a current token. |
```

`README.md`:

```diff
-`import { initAttachmentsManager, handleGetAttachmentUrl } from "@concord-consortium/interactive-api-host"`
+`import { initializeAttachmentsManager, handleGetAttachmentUrl } from "@concord-consortium/interactive-api-host"`
```

---

### Release interactive-api-host 0.13.0-pre.0 for AP-143

**Summary**: Publishes a beta for AP-143 to build against (R13), following the 0.12.0 precedent, where the pre-release bumps and the final release were commits on the feature branch (LARA-215, PR #1260).

**Files affected**:
- `package.json`: `"version": "0.13.0-pre.0"`.
- `package-lock.json`: top-level `"version": "0.13.0-pre.0"`.

**Estimated diff size**: 4 lines

From `lara-typescript/`, after committing the bump, with an npm login that can publish `@concord-consortium` packages:

```bash
npm ci
NODE_OPTIONS=--openssl-legacy-provider npm run publish:interactive-api-host:beta
git tag -a interactive-api-host@v0.13.0-pre.0 -m "interactive-api-host 0.13.0-pre.0"
git push origin interactive-api-host@v0.13.0-pre.0
```

`npm ci` first because the publish script runs the full `npm run build` (lint, webpack over every entry including the example interactives, rollup types), which fails on a stale install. The build runs webpack 4, so the legacy OpenSSL flag applies on Node 17+ (see `CLAUDE.md`). If the code changes after publishing, bump to `-pre.1` and republish rather than reusing a published version.

---

### Release interactive-api-host 0.13.0

**Summary**: Promotes the beta to the final version once AP-143 has verified a session longer than an hour against it (R13).

**Files affected**:
- `package.json` and `package-lock.json`: `"version": "0.13.0"`.

**Estimated diff size**: 4 lines

```bash
npm ci
NODE_OPTIONS=--openssl-legacy-provider npm run publish:interactive-api-host
git tag -a interactive-api-host@v0.13.0 -m "interactive-api-host 0.13.0"
git push origin interactive-api-host@v0.13.0
```

## Verification

The plan's code was prototyped against `master` under Node 16: the `interactive-api-host` and `interactive-api-lara-host` suites pass, `tslint` and `tsc` are clean for both host folders, and each guarded behavior (margin, lifetime timed from receipt rather than by `exp` against the browser clock, lifetime not restarted by a repeated token, static token dropped with a source, shared call, failure not cached, empty token, `isAnonymous()`, client rebuild, one client per call, source failure surfaced) was mutated in turn and caught by at least one test.

## Open Questions

### RESOLVED: Judgment call: how does one request get a single token?
**Context**: R2 allows at most one source call per request, but a signed-URL request makes up to two token-service calls through separate private methods.
**Options considered**:
- A) Public methods get the client once and pass it to the private methods.
- B) Each private method calls `getTokenServiceClient()` itself.

**Decision**: A. B calls the source twice per request whenever the token's `exp` is unreadable (the mutation check confirms a test catches it). A changes three private signatures, and seven existing test calls to those methods gain a client argument.

### RESOLVED: Judgment call: how is the token swapped into the client?
**Context**: `TokenServiceClient.jwt` is `readonly`.
**Options considered**:
- A) Build a new `TokenServiceClient` when the token changes.
- B) Cast away `readonly` and assign `jwt` on the existing client.
- C) Bypass `TokenServiceClient` and send the requests directly.

**Decision**: A. The constructor only reads options and `window.location`, so building one per token (about once an hour) costs nothing, and it relies on the package's public API only.

### RESOLVED: Judgment call: where does the JWT decoder live?
**Context**: R4 needs a base64url-safe reader for `exp - iat`.
**Options considered**:
- A) An exported `getJwtLifetime` in `attachments-api/helpers.ts`, as its own step.
- B) A private method on the manager.

**Decision**: A. It is a pure function with its own edge cases (seven unreadable forms), easier to test directly, and `helpers.ts` is not re-exported from the package index, so it does not widen the public API.

## Self-Review

Roles: Senior Engineer, Commit Reviewer, Test Writer, Security Engineer, Operator (whoever runs the release steps).

### Test Writer

#### RESOLVED: the base64url helper was written twice
The plan defined the same `base64url` encoder in `helpers.test.ts` and `attachments-manager.test.ts`, and the two could drift. Fixed in place: the first step adds `attachments-api/test-utils.ts` exporting `base64url` and `makeJwt`, and both test files import from it.

---

### Senior Engineer

#### RESOLVED: the option's doc comment repeated the margin's value
The `getTokenServiceFirestoreJWT` comment in `types.ts` said "within five minutes", restating `kTokenRefreshMarginSec` in a second file where it would go stale if the constant changed. Fixed in place: the comment now says "close to its `exp` claim".

---

### Operator

#### RESOLVED: the publish steps assumed a current `node_modules`
`publish:interactive-api-host` runs the full `npm run build`, and webpack builds every example interactive, two of which import `@concord-consortium/accessibility-tools/hooks`. In the checkout used to write this plan, that declared dependency was not installed, so `tsc` reported it missing and the build would fail. Fixed in place: both release steps run `npm ci` first and name the npm publish rights they need. The requirements note that had called the two errors pre-existing on `master` now attributes them to the stale install.

---

### Cross-reference (requirements against plan)

#### RESOLVED: R6's `response.error` path had no test
R6 says a source failure reaches the interactive as `response.error`, which the plan supported only by reading the unchanged handler. A throwaway test confirmed it. Decision (Doug): add a test. The manager step now includes one that initializes the global manager with a rejecting source and asserts `handleGetAttachmentUrl` returns the error and no URL.

#### RESOLVED: R11's `isAnonymous()` with both options was not asserted
Decision (Doug): add the assertion. The "fresh static token first" test now asserts `isAnonymous()` is `false` before its first request.


---

### Second round

Roles: Senior Engineer, Host Integrator (Activity Player, AP-143), Release Engineer, Next Engineer (reads the spec after merge). Each finding below was checked against the code, and the behavioral ones were confirmed by throwaway Jest tests run against the plan's code.

#### RESOLVED: freshness is measured by the browser's wall clock
`isFirebaseJwtFresh()` compares `exp` with `Date.now()`, so a wrong device clock changes behavior in two ways, both confirmed by throwaway tests: with the clock more than 55 minutes fast, every token looks stale on arrival and every request calls the source (a portal round trip per attachment request, which the caching decision exists to avoid); with the clock more than five minutes slow, the manager keeps sending an expired token for (skew minus five minutes) after each expiry, and those requests fail. AP's `PortalJWTManager` (AP-139) already solved this for the portal JWT by counting `exp - iat` from receipt ("so a device clock that is wrong at receipt does not matter"), and the portal sets `iat` on token-service JWTs (`signed_jwt.rb`, `iat = now - 30`). A prototype that stores `receivedAt + (exp - iat) - margin` passes every plan test once the test tokens carry `iat`, and fixes both skew cases. The catch is R7's static seed, whose receipt time is unknown: under the receipt rule a static token minted 50 minutes before construction was held 50 minutes past its `exp`. AP-143 passes only the source, and LARA passes only the static token, so R7 has no consumer. Decision (Doug): measure from receipt and drop the static seed when a source is given. R4 and R7 are reworded, `getJwtLifetime` replaces `getJwtExpiration`, and the manager tests gain the two clock cases and a repeated-token case. The rejected alternative held the static seed under whichever rule went stale first, which kept R7 at the cost of two freshness rules.

#### RESOLVED: the option's contract omits that the source must settle
A source call that never settles is shared by every later request, not only concurrent ones, because `pendingFirebaseJwt` is cleared only in `finally`. A throwaway test confirmed that a hung source blocks a request made an hour later and the source is never called again. AP-143 already wraps its mint in `kRenewalTimeoutMs`, so no manager-side timeout is needed, but the doc comment on `getTokenServiceFirestoreJWT` should say the promise must settle (reject on timeout). The same comment says the manager calls the source "whenever its cached token is close to its `exp` claim", which also misses the first request and the unreadable-`exp` case. Fixed in place: the comment now says when the source is called and that it must settle, and R12 requires it.

#### RESOLVED: R2's "at most once per request" does not say what a request is
The plan means one public manager call, but a single interactive `write` that has no folder yet makes two manager calls (`createFolder`, then `getSignedWriteUrl`), so with an unreadable `exp` one `getAttachmentUrl` request calls the source twice (confirmed by a throwaway test through `handleGetAttachmentUrl`). Fixed in place: R2 now says "per manager call" and notes the folder-creating write.

---

### Release Engineer

#### RESOLVED: the pre-release number disagrees between the two files
The requirements' resolved question on the pre-release says "Publish `0.13.0-pre.1` to `beta`", while R13 says `0.13.0-pre.N` and the plan's release step publishes `0.13.0-pre.0` (the 0.12.0 precedent started at `-pre.0`). Fixed in place: option A now says `0.13.0-pre.0`.

---

### Next Engineer

#### RESOLVED: `test-utils.ts` does ship in the package
The plan says nothing imports `test-utils.ts` from `index.ts`, "so it is not bundled". True for `index.js`, but the published package carries a `.d.ts` for every source file: the 0.12.0 tarball contains `attachments-api/helpers.test.d.ts` and the other test declarations. So `test-utils.d.ts` will ship too, harmlessly and like the tests already do. Fixed in place: the plan now says it adds a declaration file and no runtime code.

#### RESOLVED: process detail that will not age well
Several passages record how the spec was produced rather than what the next engineer needs: "Every code block in this plan was applied to the working tree, tested, linted and then reverted", the Verification section's test counts and mutation table, the requirements notes on the throwaway prototype, the stale-checkout `tsc` errors and the 26-test baseline, and a self-review entry quoting 120 tests where Verification says 121. The counts will be wrong after the first rebase. Fixed in place: Verification is one paragraph without counts, the applied-and-reverted line and the stale count are gone, and the requirements notes keep only the prototype's conclusion and the `npm ci` rule. Measurements belong in the PR description.
