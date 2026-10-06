# Let the Host Supply a Fresh Token-Service JWT to the Attachments Manager

**Jira**: https://concord-consortium.atlassian.net/browse/LARA-223

**Status**: **Closed**

## Overview

The attachments manager in `@concord-consortium/interactive-api-host` keeps the token-service JWT it was given at startup for the life of the page, and that JWT expires after one hour, so long sessions lose access to student attachments. This story adds an optional token source the host can pass, so the manager can get a current token when it needs one.

Students in the Activity Player who keep a page open for more than an hour can no longer save or load attachments, such as audio recordings and image uploads, because the credential the page started with has expired. Hosts that do not use the new option behave exactly as before. A follow-up Activity Player story (AP-143) wires Activity Player to the new option, which fixes the problem for students.

## Requirements

- **R1. Token source option.** `IAttachmentsManagerInitOptions` gains an optional `getTokenServiceFirestoreJWT?: () => Promise<string>`. The existing `tokenServiceFirestoreJWT?: string` stays, with the same type and meaning.
- **R2. Fresh token on every authenticated request.** When a token source is given, every token-service request the manager makes (`createResource`, `getResource`, `getCredentials`) is sent with the cached token if it is fresh by R4, and otherwise with a token newly obtained from the source for that request. The manager sends whatever the source returns even if that token itself counts as stale (an unreadable `exp` or `iat`, or a token the source returned before), and calls the source at most once per manager call (`createFolder`, `getSignedWriteUrl`, `getSignedReadUrl`). An interactive write that has to create a folder makes two manager calls, so it can call the source twice.
- **R3. Cache while fresh.** The manager reuses a token from the source for later requests while it is fresh by R4, rather than calling the source for every request. When the token is stale, the next request calls the source again.
- **R4. Freshness rule.** A token's lifetime is its `exp` claim minus its `iat` claim, counted from when the manager received it from the source, so a browser clock that disagrees with the portal's does not change when it goes stale. A token is fresh until the refresh margin, a fixed five minutes, before that lifetime ends. A token whose `exp` or `iat` cannot be read (not a three-part JWT, payload not base64url-decodable JSON, or either claim not a number) is treated as stale, so it is fetched again on every request rather than used indefinitely. A token the source returns again keeps the stale time it got when first received. The decoder must accept base64url payloads (`-`, `_`, no padding): plain `atob` throws on them.
- **R5. One call at a time.** Concurrent requests that all find the cache stale share a single in-flight call to the source rather than each calling it. If that call fails, every request waiting on it fails per R6, and the next request after that starts a new call.
- **R6. Source failure.** If the source rejects (or resolves to an empty value), the request that needed the token fails with an error, which `handleGetAttachmentUrl` returns as `response.error` as it does for any other manager failure. The failure is not cached: the next request calls the source again, and the manager stays usable.
- **R7. Both options given.** When both `tokenServiceFirestoreJWT` and `getTokenServiceFirestoreJWT` are given, the static token is not used: the source supplies every token, starting with the first request. (The manager cannot know when a static token was received, so R4 cannot time it.)
- **R8. Static path unchanged.** With no token source, the manager behaves exactly as before: the static `tokenServiceFirestoreJWT` (or none) is used for every request, and nothing about expiry is checked.
- **R9. `isAnonymous()`.** Returns `true` only when neither `tokenServiceFirestoreJWT` nor `getTokenServiceFirestoreJWT` is given. With only a token source it returns `false` (so new folders get the `["user", "context"]` access rule) and is decided at construction, without calling the source.
- **R10. Anonymous path unchanged.** Requests authorized by a folder's `readWriteToken` behave as before; the token source does not change which credential the token service sees for them.
- **R11. Tests.** Unit tests cover: the static-token path; the token-source path, including a token that changes between two requests; cache reuse while fresh; refresh once stale; staleness timed from receipt with the browser clock both fast and slow relative to the token's claims; a token returned again not getting a new lifetime; a static token not used when a source is given; a source rejection followed by a successful request; and `isAnonymous()` for none, static only, source only, and both.
- **R12. Docs.** The `IAttachmentsManagerInitOptions` declaration documents the new option, including that the promise it returns must settle (a call that never settles blocks every later request, since they share it), and the attachments row of `interactive-api-host/interactive-host-guide.md` mentions it. The package `README.md` usage line, which named the nonexistent `initAttachmentsManager`, names `initializeAttachmentsManager`. *(The option's comment uses `//`, matching the neighboring options, so like them it does not appear in the published `.d.ts`.)*
- **R13. Release.** A new `@concord-consortium/interactive-api-host` minor version is published, with `package.json` and `package-lock.json` versions in step: first `0.13.0-pre.0` on the `beta` tag for AP-143 to verify (a later `-pre.N` if the code changes after publishing), then 0.13.0, which AP-143 needs before it can merge because Activity Player pins exact versions of the package, each tagged `interactive-api-host@v<version>`. *(`0.13.0-pre.0` went out on `beta`, AP-143 verified a session longer than an hour against it, and 0.13.0 was then released from the same code.)*

## Technical Notes

- Files in play, under `lara-typescript/src/interactive-api-host/`: `attachments-api/types.ts` (option), `attachments-api/attachments-manager.ts` (token handling), `attachments-api/helpers.ts` (`getJwtLifetime`), `attachments-api/test-utils.ts` (`base64url`, `makeJwt` for tests), the matching tests, `interactive-host-guide.md`, `README.md`, and `package.json` / `package-lock.json`.
- `TokenServiceClient.jwt` is `readonly` (token-service 2.1.0), and its constructor is cheap (reads options and `window.location`), so the manager builds a new client whenever the token changes. Each public method gets the client once and passes it to the private methods, which is what limits a manager call to one source call.
- The token service verifies with `verify(token, publicKey, { algorithms: ["RS256"] })` and no `clockTolerance`, rejecting an expired JWT with HTTP 403 and `error: "TokenExpiredError: jwt expired"`; `TokenServiceClient` surfaces only the error string.
- The portal's token-service JWT carries numeric `iat` and `exp` with `exp = iat + 3600`; `iat` is backdated 30 seconds, so a token has about 3570 seconds left when it arrives. It carries no `jti`, so two mints in the same second return the same string; under R4 that repeat keeps its first receipt time, which is correct because its claims are identical.
- Timing a token from receipt follows Activity Player's `PortalJWTManager` (AP-139). Comparing `exp` with `Date.now()` instead would call the source on every request with a clock running more than 55 minutes fast, and send expired tokens for part of every hour with one running more than five minutes slow.
- Decoding `exp` and `iat` in the browser is only a refresh hint: the manager never verifies the signature, and the token service stays the authority on whether a token is valid.
- The existing claim decoder in `interactive-api-client/api.ts` (`atob(token.split(".")[1])`) throws `InvalidCharacterError` on base64url payloads, so `getJwtLifetime` maps `-`/`_` and restores padding first.
- `initializeAttachmentsManager` resolves a module-level promise once, so a host cannot recover by initializing a second manager; the token source is the only refresh path.
- The R6 end-to-end test lives in `attachments-manager.test.ts`, because `handle-get-attachment-url.test.ts` replaces the manager's public methods with mocks.
- `test-utils.ts` is not reachable from `index.ts`, so it adds no runtime code, but like the test files it gets a `.d.ts` in the published package.
- Run `npm ci` before building: webpack builds the example interactives, which import `@concord-consortium/accessibility-tools/hooks`, and a stale `node_modules` fails the build. The build runs webpack 4, so the legacy OpenSSL flag (`NODE_OPTIONS=--openssl-legacy-provider`) is needed on Node 17+ and must be dropped on Node 16 or earlier, where Node refuses it.
- Release convention: bump `interactive-api-host/package.json` and its `package-lock.json` together, publish with `npm run publish:interactive-api-host` (or `:beta` for a pre-release) from `lara-typescript/`, and tag `interactive-api-host@v<version>`. For local testing in a host, `npm run publish:interactive-api-host:yalc` publishes to the yalc store.
- LARA's runtime compiles `interactive-api-host` from source and passes no token source, so R8 keeps its behavior unchanged.

## Out of Scope

- Changing Activity Player to pass a token source (AP-143, blocked by this story).
- Changing LARA's runtime (`iframe-saver.ts`) to pass a token source; LARA has the same one-hour limit but keeps its current behavior.
- Changing Portal Report to pass a token source. It is a third host (`js/util/get-attachments-manager-options.ts`, still on `^0.10.0`), passes only a static token, and has the same one-hour limit for a teacher who keeps a report open.
- Re-initializing the global manager (`initializeAttachmentsManager` stays resolve-once).
- Caching S3 credentials, or changing signed-URL lifetimes.
- Changes to the token service or the portal.

## Decisions

### Where should token caching live?
**Context**: Each signed-URL request makes at least one JWT-authenticated call, and Activity Player's source mints a new token through the portal on each call.
**Options considered**:
- A) The manager caches by the token's lifetime and calls the source only when stale.
- B) The manager calls the source on every request and leaves caching to the host.

**Decision**: A. With B, every attachment read or write adds a portal round trip unless every host builds its own cache, and AP-143 is meant to pass a minting function as is.

---

### What happens when both a static token and a source are given?
**Context**: A host adopting the source may keep passing the static token it already fetched.
**Options considered**:
- A) The static token seeds the cache while fresh; the source supplies later tokens.
- B) The source wins and the static token is ignored.
- C) Treat both together as a configuration error.

**Decision**: B. A was chosen first, but once freshness was timed from receipt, a static token's receipt time is unknown, and keeping A would need a second freshness rule. No host passes both, so B costs at most one mint at startup.

---

### Version number for the release
**Context**: The change adds an optional field and no breaking change.
**Options considered**:
- A) Minor bump to 0.13.0.
- B) Patch bump to 0.12.1.

**Decision**: A. A new option is a feature; in 0.x a minor bump is the conventional signal, and the previous feature release also bumped the minor.

---

### How large should the refresh margin be?
**Context**: A token is treated as stale shortly before its lifetime ends so it does not expire in flight. Too small risks rejections; too large mints more often than needed.
**Options considered**:
- A) 60 seconds.
- B) 5 minutes.
- C) Configurable, with a default.

**Decision**: B, as a fixed constant. The token service passes no `clockTolerance`, so the margin is the only allowance for mint latency, the 30-second `iat` backdating, and portal versus token-service clock differences. With one-hour tokens it costs at most one extra mint per hour, and no host has a reason to tune it.

---

### Should an authorization failure trigger one refresh and retry?
**Context**: If the portal's and the token service's clocks disagree by more than the margin, a token the manager thinks is fresh can be rejected even though the source could supply a good one.
**Options considered**:
- A) No retry: the margin covers normal skew, and the next request after the token's `exp` gets a new one anyway.
- B) On a token-service rejection, drop the cache, fetch once from the source, and retry once.

**Decision**: A. `TokenServiceClient` drops the HTTP status and rejects with only the error string, so B would have to match error text from another package or retry on every failure. Timing from receipt removes the browser clock from the question, and R6 keeps the manager usable after any failure.

---

### Should 0.13.0 go out as a pre-release first?
**Context**: AP-143 needs the release to test against; 0.12.0 went through `-pre.0` and `-pre.1` on `beta` before the final version.
**Options considered**:
- A) Publish `0.13.0-pre.0` to `beta`, verify in AP, then publish 0.13.0.
- B) Publish 0.13.0 directly.

**Decision**: A. It matches the 0.12.0 precedent, and AP-143, the only consumer, is the natural place to validate a long session before the version is final.

---

### Freshness measured from receipt, not by the browser's wall clock
**Context**: The first plan compared `exp` with `Date.now()`. A clock more than 55 minutes fast made every token look stale on arrival (a portal round trip per attachment request), and a clock more than five minutes slow kept sending expired tokens after each expiry.
**Options considered**:
- A) Compare `exp` with the browser clock.
- B) Store receipt time plus `exp - iat` minus the margin, as AP's `PortalJWTManager` does for the portal JWT.
- C) Use B for source tokens but keep a static seed under whichever rule goes stale first.

**Decision**: B, which also drops the static seed when a source is given (see above). C kept the seed at the cost of two freshness rules.

---

### How does one manager call get a single token?
**Context**: R2 allows at most one source call per manager call, but a signed-URL request makes up to two token-service calls through separate private methods.
**Options considered**:
- A) Public methods get the client once and pass it to the private methods.
- B) Each private method calls `getTokenServiceClient()` itself.

**Decision**: A. B calls the source twice per request whenever the token's `exp` is unreadable. A changes three private signatures and the existing tests that call them.

---

### How is the token swapped into the client?
**Context**: `TokenServiceClient.jwt` is `readonly`.
**Options considered**:
- A) Build a new `TokenServiceClient` when the token changes.
- B) Cast away `readonly` and assign `jwt` on the existing client.
- C) Bypass `TokenServiceClient` and send the requests directly.

**Decision**: A. The constructor only reads options and `window.location`, so building one about once an hour costs nothing, and it relies on the package's public API only.

---

### Where does the JWT decoder live?
**Context**: R4 needs a base64url-safe reader for `exp - iat`.
**Options considered**:
- A) An exported `getJwtLifetime` in `attachments-api/helpers.ts`.
- B) A private method on the manager.

**Decision**: A. It is a pure function with its own edge cases, easier to test directly, and `helpers.ts` is not re-exported from the package index, so it does not widen the public API.

---

### Documenting that the source must settle
**Context**: A source call that never settles is shared by every later request, because the pending call is cleared only when it settles, so a hung source blocks the manager for the rest of the page.
**Options considered**:
- A) Add a manager-side timeout.
- B) Document that the promise must settle and leave the timeout to the host.

**Decision**: B. AP-143 already wraps its mint in `kRenewalTimeoutMs`. The option's comment says when the source is called and that it must reject on a timeout, and R12 requires it.

---

### Sharing test helpers
**Context**: The plan first defined the same `base64url` encoder in two test files, which could drift.
**Options considered**:
- A) Keep a copy in each test file.
- B) Share `base64url` and `makeJwt` from `attachments-api/test-utils.ts`.

**Decision**: B.

---

### Test coverage for R6 and R11
**Context**: R6's `response.error` path was supported only by reading the unchanged handler, and `isAnonymous()` with both options was not asserted.
**Options considered**:
- A) Rely on the unchanged handler and the other `isAnonymous()` cases.
- B) Add an end-to-end test through `handleGetAttachmentUrl` and an `isAnonymous()` assertion with both options.

**Decision**: B (Doug).
