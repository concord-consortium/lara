# Building a Host for LARA Interactives

This document describes how to build a **host** — an environment that embeds and
runs LARA/AP "interactives." It is written for engineers integrating interactives
into their own platform, **whether or not they use the
`@concord-consortium/interactive-api-host` library.** The library is an optional
convenience; the actual contract between a host and an interactive is a small
`postMessage` protocol, and you can implement it directly.

If instead you are *building an interactive* (the thing that runs inside the
iframe), see the client library `@concord-consortium/lara-interactive-api`.

---

## 1. The mental model

An **interactive** is a web page (its own URL) that a host loads inside an
`<iframe>`. The host and the interactive never share a JavaScript context — they
communicate only by `postMessage`. On top of raw `postMessage`, both sides use
[**iframe-phone**](https://github.com/concord-consortium/iframe-phone), a tiny
library that provides:

- a **handshake** so each side knows the other is ready, and
- a simple **named-message** API: `phone.post(type, payload)` and
  `phone.addListener(type, handler)`.

```
┌─────────────────────── Host (your platform) ───────────────────────┐
│                                                                     │
│   iframe-phone ParentEndpoint                                       │
│        │  post("initInteractive", …)      ── student config ──▶     │
│        │  addListener("interactiveState") ◀── student work ───      │
│        │  addListener("height")           ◀── iframe sizing ──      │
│        ▼                                                            │
│   ┌────────────────── <iframe src="…interactive…"> ─────────────┐   │
│   │   iframe-phone IFrameEndpoint (the interactive)             │   │
│   └────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

The full set of message names and their payload types is defined in one file,
which is the **authoritative protocol specification**:
[`interactive-api-shared/types.ts`](../interactive-api-shared/types.ts) (published
inside both npm packages). Everything below references types from that file.

---

## 2. The minimal host

A host that can load an interactive, hand it a student's saved work, and receive
updated work needs only **three** messages:

| Direction | Message | Purpose |
|-----------|---------|---------|
| host → interactive | `initInteractive` | Configure the interactive (mode, authored state, saved student state, host features…). Sent **once**, after the handshake. |
| interactive → host | `interactiveState` | The student's current work. The interactive posts this whenever its state changes. Persist it. |
| interactive → host | `height` | Desired iframe height in px. Resize the iframe to avoid inner scrollbars. |

```ts
import iframePhone from "iframe-phone";
import {
  IInitInteractive, IRuntimeInitInteractive
} from "@concord-consortium/interactive-api-host"; // or lara-interactive-api — same types

const iframe = document.querySelector<HTMLIFrameElement>("#interactive")!;
iframe.src = "https://example.com/some-interactive/";

// The 2nd arg fires AFTER the handshake completes — this is when to send initInteractive.
const phone = new iframePhone.ParentEndpoint(iframe, () => {
  const init: IRuntimeInitInteractive = {
    version: 1,
    mode: "runtime",
    error: null,
    hostFeatures: {},                 // advertise optional capabilities here (see §6)
    authoredState: savedAuthoredState, // how the interactive was configured by an author
    interactiveState: savedStudentState, // previously saved student work, or null
    globalInteractiveState: null,
    interactiveStateUrl: "",
    collaboratorUrls: null,
    classInfoUrl: "",
    interactive: { id: "interactive-1", name: "" },
    authInfo: { provider: "", loggedIn: true, email: "" },
    linkedInteractives: [],
    themeInfo: { colors: { colorA: "", colorB: "" } },
    accessibility: { fontSize: "normal", fontSizeInPx: 16, fontType: "normal", fontFamilyForType: "" },
    mediaLibrary: { enabled: false, items: [] },
    objectStorageConfig: {},
  };
  phone.post("initInteractive", init);
});

phone.addListener("interactiveState", (state: unknown) => {
  persistStudentWork(state);          // save to your backend
});

phone.addListener("height", (height: number) => {
  iframe.style.height = `${height}px`;
});
```

That is a complete, working host. Everything else in this document is optional and
adds features on top of this core.

> **Reference implementation:** Activity Player's
> [`iframe-runtime.tsx`](https://github.com/concord-consortium/activity-player/blob/master/src/components/activity-page/managed-interactive/iframe-runtime.tsx)
> is a production host built exactly this way — a hand-written `ParentEndpoint`
> plus a set of `addListener`/`post` calls. It's the best end-to-end example.

---

## 3. `initInteractive` modes

`initInteractive` is a discriminated union on `mode` — the same interactive URL is
reused for several purposes, and the host picks the mode:

| Mode | Type | When the host uses it |
|------|------|-----------------------|
| `runtime` | `IRuntimeInitInteractive` | A student is doing the activity. The common case. |
| `authoring` | `IAuthoringInitInteractive` | An author is configuring the interactive; the interactive edits its **authored state**. |
| `report` | `IReportInitInteractive` | Read-only display of a student's answer in a report. |
| `reportItem` | `IReportItemInitInteractive` | The interactive renders a compact/full answer summary for a report grid. |

For a first integration you typically implement `runtime` (and later `report` if
you show student work back to teachers). See the four interfaces at the top of
[`types.ts`](../interactive-api-shared/types.ts) for the exact per-mode fields.

---

## 4. Saving and loading student work

- **Loading:** put the previously saved state into `initInteractive.interactiveState`
  (or `null` for a fresh start).
- **Autosave:** the interactive posts `interactiveState` whenever its state changes;
  persist each one.
- **Final save on unload:** before you tear down the iframe (page navigation, etc.),
  ask for the latest state and wait for it:

  ```ts
  // host → interactive: "give me your final state"
  phone.post("getInteractiveState", { unloading: true }); // IGetInteractiveState
  // interactive → host: one more "interactiveState" message follows — persist it before unmounting.
  ```

  The interactive also uses `supportedFeatures.interactiveState` to tell you whether
  it saves state at all (see §6).

---

## 5. The full message catalog

These are all the message names in the runtime protocol. Implement only the ones
whose features you want; interactives degrade gracefully when a host ignores a
message. Names come from `IRuntimeClientMessage` / `IRuntimeServerMessage` in
[`types.ts`](../interactive-api-shared/types.ts).

### Interactive → host (you add a listener)

| Message | Feature |
|---------|---------|
| `interactiveState` | Student work (save it). |
| `height` | Requested iframe height. |
| `supportedFeatures` | Interactive advertises what it supports (aspect ratio, whether it saves state, custom-message handling, focus protocol). |
| `hint` | Text hint to surface in host chrome. |
| `navigation` | Request to enable/disable forward navigation, show a message. |
| `setDirtyState` | Interactive has unsaved changes (block navigation, show "saving…"). |
| `getAuthInfo` | Request current user's auth info → respond with `authInfo`. |
| `getFirebaseJWT` | Request a Firebase JWT for a named app → respond with `firebaseJWT`. |
| `getAttachmentUrl` | Request a signed URL to read/write a large attachment → respond with `attachmentUrl`. |
| `showModal` / `closeModal` | Request the host to open/close a dialog, lightbox, or alert. |
| `createChannel` / `publish` / `subscribe` / `unsubscribe` | Pub/Sub between interactives (see §6). |
| `createJob` / `cancelJob` | Long-running async work (see §6). |
| `focusExit` | Accessibility focus protocol — focus is leaving the iframe. |
| `getInteractiveSnapshot` | Request a snapshot image URL of another interactive. |
| `getLibraryInteractiveList` | Request the list of available library interactives. |
| `addLinkedInteractiveStateListener` / `removeLinkedInteractiveStateListener` | Observe another interactive's state (linked interactives). |
| `authoredState` | (authoring mode) updated authored state to save. |
| `authoringCustomReportFields` / `runtimeCustomReportValues` | Custom report field definitions/values. |
| `log` | A logging event to forward to your analytics. |

### Host → interactive (you `post`)

| Message | Feature |
|---------|---------|
| `initInteractive` | Initial configuration (§2–3). |
| `getInteractiveState` | Ask for latest state, e.g. on unload (§4). |
| `authInfo` | Response to `getAuthInfo`. |
| `firebaseJWT` | Response to `getFirebaseJWT`. |
| `attachmentUrl` | Response to `getAttachmentUrl`. |
| `pubSubMessage` / `pubSubChannelInfo` | Pub/Sub delivery. |
| `jobCreated` / `jobInfo` | Job lifecycle updates. |
| `focusEnter` | Accessibility focus protocol — focus is entering the iframe. |
| `linkedInteractiveState` | Delivery of an observed interactive's state. |
| `interactiveSnapshot` | Response to `getInteractiveSnapshot`. |
| `libraryInteractiveList` | Response to `getLibraryInteractiveList`. |
| `customMessage` | Bi-directional app-specific messages (both sides can send). |

Each message's payload has a named interface in `types.ts` (e.g. `IHintRequest`,
`IShowModal`, `IAttachmentUrlRequest`, `IJobInfo`). Request/response pairs are
correlated by a numeric `requestId` (`IBaseRequestResponse`).

---

## 6. Optional feature subsystems (and where the library helps)

The core in §2 needs no library. These richer features involve real bookkeeping
(request/response correlation, backend calls, listener maps), and that is exactly
what `@concord-consortium/interactive-api-host` provides — you can adopt it
piecemeal. Activity Player uses these managers while still driving the core loop
by hand.

| Feature | Do it yourself | Or use from the library |
|---------|----------------|-------------------------|
| **Capability advertising** | Set fields on `initInteractive.hostFeatures` (`IHostFeatures`) so the interactive knows what you support (e.g. `modal`, `getFirebaseJwt`). | — |
| **Attachments** (large blobs via signed URLs, e.g. S3) | Handle `getAttachmentUrl`, generate a signed URL, reply `attachmentUrl`. | `initializeAttachmentsManager`, `handleGetAttachmentUrl`, `IAttachmentsManagerInitOptions`, `IReadableAttachmentInfo`. |
| **Pub/Sub** (interactives talking to each other) | Track channels/subscriptions and relay `publish`→`pubSubMessage`. | `PubSubManager`. |
| **Jobs** (long-running async tasks) | Handle `createJob`/`cancelJob`, push `jobInfo` updates. | `JobManager` + implement the `IJobExecutor` interface (see AP's `firebase-job-executor.ts`). |
| **Accessibility focus** (keyboard focus crossing the iframe boundary) | Exchange `focusEnter`/`focusExit`. | `FocusManager`, `FocusTransport`. |
| **Modals / lightboxes / alerts** | Handle `showModal`/`closeModal` and render host chrome. | — (host UI concern) |

Advertise support via `supportedFeatures` (from the interactive) and `hostFeatures`
(from you) so both sides negotiate features rather than assuming them.

---

## 7. Reference material

- **Protocol spec (authoritative):**
  [`interactive-api-shared/types.ts`](../interactive-api-shared/types.ts) — every
  message name and payload type. Also shipped inside both npm packages' typings.
- **Host helper library:** `@concord-consortium/interactive-api-host` on npm —
  optional managers for attachments, pub/sub, jobs, and focus.
- **Client library (for interactive authors):**
  `@concord-consortium/lara-interactive-api` on npm.
- **Production host example:** Activity Player,
  [`iframe-runtime.tsx`](https://github.com/concord-consortium/activity-player/blob/master/src/components/activity-page/managed-interactive/iframe-runtime.tsx).
- **Example interactives to test against:**
  [question-interactives](https://github.com/concord-consortium/question-interactives),
  deployed at `https://models-resources.concord.org/question-interactives`.
- **Transport:** [iframe-phone](https://github.com/concord-consortium/iframe-phone).
