# Let the Host Supply a Fresh Token-Service JWT to the Attachments Manager

**Jira**: https://concord-consortium.atlassian.net/browse/LARA-223
**Repo**: https://github.com/concord-consortium/lara
**Implementation Spec**: [implementation.md](implementation.md)
**Status**: **In Development**

## Overview

The attachments manager in `@concord-consortium/interactive-api-host` keeps the token-service JWT it was given at startup for the life of the page, and that JWT expires after one hour, so long sessions lose access to student attachments. This story adds an optional token source the host can pass, so the manager can get a current token when it needs one.

## Project Owner Overview

Students in the Activity Player who keep a page open for more than an hour can no longer save or load attachments, such as audio recordings and image uploads, because the credential the page started with has expired. The student sees the upload or playback fail and has no way to recover short of reloading the page.

This story changes the shared host library so a host can hand the attachments manager a way to fetch a current credential instead of a single fixed one. Hosts that do not use the new option behave exactly as before. A follow-up Activity Player story (AP-143) then wires Activity Player to the new option, which fixes the problem for students.

## Background

The [Jira story](https://concord-consortium.atlassian.net/browse/LARA-223) gives the cause in full; the code confirms it:

- `AttachmentsManager` (`lara-typescript/src/interactive-api-host/attachments-api/attachments-manager.ts`) copies `options.tokenServiceFirestoreJWT` into `firebaseJwt` and builds one `TokenServiceClient({ env, jwt })` in its constructor. `TokenServiceClient.jwt` is `readonly` (token-service 2.1.0, `client.ts:62`), so the token can never change.
- Every token-service call goes through `fetchFromServiceUrl`, which sends `Authorization: Bearer ${readWriteToken || jwt}`. Logged-in learners' folders are created with the `["user", "context"]` access rule and have no read/write token, so `createResource`, `getResource` and `getCredentials` all send the JWT. Folder resources are cached per manager; credentials are not, so every signed-URL request makes at least one JWT-authenticated call.
- The token service verifies with `verify(token, publicKey, { algorithms: ["RS256"] })` (`token-service/functions/src/index.ts:123`), which rejects a token past its `exp`. The portal's `SignedJwt.create_firebase_token` sets `exp: iat + 3600` (`rigse/rails/lib/signed_jwt.rb:121-133`).
- `initializeAttachmentsManager` resolves a module-level promise that can only resolve once, so a host cannot recover by initializing a second manager with a new token.
- Only the host can mint a new token: Activity Player's `getAttachmentsManagerOptions` gets it from the portal via `portalJWTManager.withToken(... getFirebaseJWT(basePortalUrl, rawPortalJWT, { firebase_app: "token-service" }))` and passes the result as `tokenServiceFirestoreJWT`.

Errors thrown inside the manager already reach the interactive: `handleGetAttachmentUrl` wraps every manager call in a `try` and returns `response.error`.

LARA's own runtime (`interactive-api-lara-host/iframe-saver.ts`) also passes a one-shot JWT, minted through LARA's `api/v1/jwt/get_firebase_jwt` proxy to the portal, so it has the same one-hour limit. The story scopes LARA out: it keeps working as today.

## Requirements

- **R1. Token source option.** `IAttachmentsManagerInitOptions` gains an optional `getTokenServiceFirestoreJWT?: () => Promise<string>`. The existing `tokenServiceFirestoreJWT?: string` stays, with the same type and meaning.
- **R2. Fresh token on every authenticated request.** When a token source is given, every token-service request the manager makes (`createResource`, `getResource`, `getCredentials`) is sent with the cached token if it is fresh by R4, and otherwise with a token newly obtained from the source for that request. A request made after the previous token has gone stale therefore uses a newer token from the source. The manager sends whatever the source returns even if that token itself counts as stale (an unreadable `exp` or `iat`, or a token the source returned before), and calls the source at most once per manager call (`createFolder`, `getSignedWriteUrl`, `getSignedReadUrl`). An interactive write that has to create a folder makes two manager calls, so it can call the source twice.
- **R3. Cache while fresh.** The manager reuses a token from the source for later requests while it is fresh by R4, rather than calling the source for every request. When the token is stale, the next request calls the source again.
- **R4. Freshness rule.** A token's lifetime is its `exp` claim minus its `iat` claim, counted from when the manager received it from the source, so a browser clock that disagrees with the portal's does not change when it goes stale. A token is fresh until the refresh margin, a fixed five minutes, before that lifetime ends. A token whose `exp` or `iat` cannot be read (not a three-part JWT, payload not base64url-decodable JSON, or either claim not a number) is treated as stale, so it is fetched again on every request rather than used indefinitely. A token the source returns again keeps the stale time it got when first received. The source is expected to return newly minted tokens. The decoder must accept base64url payloads (`-`, `_`, no padding): plain `atob` throws on them.
- **R5. One call at a time.** Concurrent requests that all find the cache stale share a single in-flight call to the source rather than each calling it. If that call fails, every request waiting on it fails per R6, and the next request after that starts a new call.
- **R6. Source failure.** If the source rejects (or resolves to an empty value), the request that needed the token fails with an error, which `handleGetAttachmentUrl` returns as `response.error` as it does for any other manager failure. The failure is not cached: the next request calls the source again, and the manager stays usable.
- **R7. Both options given.** When both `tokenServiceFirestoreJWT` and `getTokenServiceFirestoreJWT` are given, the static token is not used: the source supplies every token, starting with the first request. (The manager cannot know when a static token was received, so R4 cannot time it.)
- **R8. Static path unchanged.** With no token source, the manager behaves exactly as today: the static `tokenServiceFirestoreJWT` (or none) is used for every request, and nothing about expiry is checked.
- **R9. `isAnonymous()`.** Returns `true` only when neither `tokenServiceFirestoreJWT` nor `getTokenServiceFirestoreJWT` is given. With only a token source it returns `false` (so new folders get the `["user", "context"]` access rule) and is decided at construction, without calling the source.
- **R10. Anonymous path unchanged.** Requests authorized by a folder's `readWriteToken` behave as today; the token source does not change which credential the token service sees for them.
- **R11. Tests.** Unit tests cover: the static-token path; the token-source path, including a token that changes between two requests (the second request sends the new token); cache reuse while fresh; refresh once stale; staleness timed from receipt with the browser clock both fast and slow relative to the token's claims; a token returned again not getting a new lifetime; a static token not used when a source is given; a source rejection followed by a successful request; and `isAnonymous()` for none, static only, source only, and both.
- **R12. Docs.** The `IAttachmentsManagerInitOptions` declaration documents the new option, including that the promise it returns must settle (a call that never settles blocks every later request, since they share it), and the attachments row of `interactive-api-host/interactive-host-guide.md` mentions it so host authors know long sessions need it. The package `README.md` usage line names `initAttachmentsManager`, which the package does not export; it is corrected to `initializeAttachmentsManager`, since that README is where a host author starts looking for the option.
- **R13. Release.** A new `@concord-consortium/interactive-api-host` minor version is published, with `package.json` and `package-lock.json` versions in step: first `0.13.0-pre.0` on the `beta` tag for AP-143 to verify (a later `-pre.N` if the code changes after publishing), then 0.13.0, which AP-143 needs before it can merge because Activity Player pins exact versions of the package, each tagged `interactive-api-host@v<version>` as earlier releases were.

## Technical Notes

- Files in play: `attachments-api/types.ts` (option), `attachments-api/attachments-manager.ts` (token handling), `attachments-api/attachments-manager.test.ts` (tests), `interactive-host-guide.md` (docs), `interactive-api-host/package.json` and `package-lock.json` (version).
- `TokenServiceClient`'s constructor is cheap (reads options, `window.location`), so building one per token change is viable; the client's `jwt` cannot be reassigned.
- The existing test file mocks `TokenServiceClient` as a `jest.fn` constructor, so a test can read the `jwt` each client was built with from `TokenServiceClient.mock.calls`.
- JWT claim decoding has a precedent in `interactive-api-client/api.ts:301` (`atob(token.split(".")[1])`), but that form throws `InvalidCharacterError` on a base64url payload containing `-` or `_` (verified with a throwaway jest test under jsdom), so it cannot be copied as is.
- The portal's token-service JWT carries numeric `iat` and `exp` (seconds since epoch), with `exp = iat + 3600`; `iat` is backdated 30 seconds (`CLOCK_SKEW_ALLOWANCE`), so a token has about 3570 seconds left when it arrives, which the five-minute margin absorbs.
- The portal's token carries no `jti`, so two mints in the same second return the same string. Under R4 that repeat keeps its first receipt time, which is correct because its claims are identical. A mint made because the cached token went stale always returns a different string, since `iat` has moved.
- Timing a token from receipt follows Activity Player's `PortalJWTManager` (AP-139), which counts the portal JWT's `exp - iat` from receipt for the same reason: a device clock that is wrong does not matter. Comparing `exp` with `Date.now()` instead would call the source on every request with a clock running more than 55 minutes fast, and send expired tokens for part of every hour with one running more than five minutes slow.
- Decoding `exp` and `iat` in the browser is only a refresh hint: the manager never verifies the signature, and the token service stays the authority on whether a token is valid.
- Tests can control the clock: the repo runs Jest 27, whose default ("modern") fake timers support `jest.setSystemTime`.
- The design was prototyped against the real `TokenServiceClient` 2.1.0 under jsdom with a stubbed `fetch`: concurrent requests share one `Authorization` value, a source rejection reaches the caller, and the next request sends a new token. `Promise.prototype.finally` and `catch` without a binding type-check under the repo's `tsconfig.json`.
- Run `npm ci` before building: webpack builds the example interactives, which import `@concord-consortium/accessibility-tools/hooks`, and a stale `node_modules` without that declared dependency fails the build (`tsc` reports it as a missing module).
- LARA's runtime compiles `interactive-api-host` from source (`iframe-saver.ts` imports from `../interactive-api-host`), so LARA picks up the new code on its next build; with no token source passed, R8 keeps its behavior unchanged.
- Release convention: `f0df6d30` bumped `interactive-api-host/package.json` and its `package-lock.json` together; publishing uses `npm run publish:interactive-api-host` (or `:beta` for a pre-release) from `lara-typescript/`, and releases are tagged `interactive-api-host@v<version>`.
- The token service rejects an expired JWT with HTTP 403 and `error: "TokenExpiredError: jwt expired"`; `TokenServiceClient` surfaces only the error string.

## Out of Scope

- Changing Activity Player to pass a token source (AP-143, blocked by this story).
- Changing LARA's runtime (`iframe-saver.ts`) to pass a token source; LARA has the same one-hour limit but keeps its current behavior.
- Changing Portal Report to pass a token source. It is a third host (`js/util/get-attachments-manager-options.ts`, still on `^0.10.0`), passes only a static token, and has the same one-hour limit for a teacher who keeps a report open.
- Re-initializing the global manager (`initializeAttachmentsManager` stays resolve-once).
- Caching S3 credentials, or changing signed-URL lifetimes.
- Changes to the token service or the portal.

## Open Questions

### RESOLVED: Judgment call: where should token caching live?
**Context**: The ticket says the manager "may cache the result while it is fresh". Each signed-URL request makes at least one JWT-authenticated call, and AP's source would mint a new token through the portal on each call.
**Options considered**:
- A) The manager caches by `exp` and calls the source only when stale.
- B) The manager calls the source on every request and leaves caching to the host.

**Decision**: A. With B, every attachment read or write adds a portal round trip unless every host builds its own cache, and AP-143 is meant to be a one-line change that passes a minting function as is.

### RESOLVED: Judgment call: what happens when both a static token and a source are given?
**Context**: A host adopting the source may keep passing the static token it already fetched.
**Options considered**:
- A) The static token seeds the cache while fresh; the source supplies later tokens.
- B) The source wins and the static token is ignored.
- C) Treat both together as a configuration error.

**Decision**: B. A was chosen first, but once R4 timed tokens from receipt, a static token's receipt time is unknown, and keeping A would need a second freshness rule for it. No host passes both (Activity Player passes only the source; LARA and Portal Report only the static token), so B costs one mint at startup for a host that might.

### RESOLVED: Judgment call: version number for the release
**Context**: The change adds an optional field and no breaking change.
**Options considered**:
- A) Minor bump to 0.13.0.
- B) Patch bump to 0.12.1.

**Decision**: A. A new option is a feature; in 0.x a minor bump is the conventional signal, and the previous feature release (LARA-210 jobs) also bumped the minor.

### RESOLVED: Low confidence: how large should the refresh margin be?
**Context**: R4 treats a token as stale shortly before its lifetime ends so it does not expire in flight. Too small risks rejections; too large mints more often than needed (with one-hour tokens, any margin under a few minutes costs nothing measurable).
**Options considered**:
- A) 60 seconds.
- B) 5 minutes.
- C) Configurable, with a default.

**Decision**: B, as a fixed constant. The token service passes no `clockTolerance` to `jsonwebtoken` 8.5's `verify`, so the margin is the only allowance for mint latency, the 30-second `iat` backdating, and any difference between the portal's and the token service's clocks. With one-hour tokens, five minutes costs one extra mint per hour at most, and no host has a reason to tune it, so C adds an option nothing would set.

### RESOLVED: Low confidence: should an authorization failure trigger one refresh and retry?
**Context**: R4 relies on the token's claimed lifetime. If the portal's and the token service's clocks disagree by more than the margin, a token the manager thinks is fresh can be rejected by the token service, and the request fails even though the source could supply a good token.
**Options considered**:
- A) No retry: the margin covers normal skew, and the next request after the token's `exp` gets a new one anyway.
- B) On a token-service rejection with a token-source-supplied token, drop the cache, fetch once from the source, and retry the call once.

**Decision**: A. The token service answers an expired JWT with HTTP 403 and `error: "TokenExpiredError: jwt expired"`, but `TokenServiceClient.fetchFromServiceUrl` drops the status and rejects with only the error string, so B would have to match that text from another package, or retry on every failure, including ones a new token cannot fix. Timing from receipt removes the browser clock from the question, the five-minute margin covers server clock differences up to five minutes, and R6 keeps the manager usable after any failure.

### RESOLVED: Low confidence: should 0.13.0 go out as a pre-release first?
**Context**: AP-143 needs the release to test against. The last release (0.12.0) went through `0.12.0-pre.1` on the `beta` tag before the final version.
**Options considered**:
- A) Publish `0.13.0-pre.0` to `beta`, verify in AP, then publish 0.13.0.
- B) Publish 0.13.0 directly.

**Decision**: A. It matches the 0.12.0 precedent (tags `interactive-api-host@v0.12.0-pre.0`, `-pre.1`, then `v0.12.0`), and the only consumer, AP-143, is the natural place to validate a long session before the version is final.

## Self-Review

Roles: Senior Engineer, Security Engineer, QA Engineer, Host Integrator (an Activity Player developer adopting the option), Release Engineer.

### Senior Engineer

#### RESOLVED: R2 promised a non-expired token that R4 cannot always deliver
R2 required every request to carry a token that had not expired by its `exp`, while R4 treats a token with an unreadable `exp` as stale and fetches again on every request, and a token can also arrive already stale when the browser clock runs ahead. In both cases R2 could only be met by looping on the source. Fixed in place: R2 now says the request uses the fresh cached token or one newly fetched token, sent as is, with at most one source call per request.

#### RESOLVED: R5 left the outcome of a failed shared call undefined
With concurrent requests sharing one in-flight call, R5 did not say what the waiting requests see when it rejects, or whether the rejected call is reused. Fixed in place: all waiters fail per R6, and the next request starts a new call.

---

### Host Integrator

#### RESOLVED: the package README names a function that does not exist
`interactive-api-host/README.md` tells hosts to import `initAttachmentsManager`; the package exports only `initializeAttachmentsManager` (`attachments-manager-global.ts:15`, re-exported by `attachments-api/index.ts`). A host author looking for the new option starts there. Fixed in place by extending R12 to correct the line.

