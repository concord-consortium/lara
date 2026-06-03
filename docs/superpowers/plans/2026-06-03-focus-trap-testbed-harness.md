# Focus-trap Testbed Harness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

> **⛔ MANUAL-VERIFICATION GATES ARE HARD STOPS.** This plan has three phases. **Each phase ends with a manual-verification gate that the human performs and explicitly confirms before any work on the next phase begins.** Do NOT chain phases. Do NOT start the next phase's tasks because "the code builds." A clean build is NOT a substitute for the human eyeballing focus behavior — observing it is the entire point of the phasing. If you are an agent and you reach a gate, STOP, post the build/serve instructions, and wait for the human to report what they saw and say "proceed".

**Goal:** Build a manually-driven testbed harness in `lara-typescript/src/example-interactives/` that demonstrates focus behavior across a cross-origin iframe in three phases (native baseline → existing-trap blind spot → new iframe-slot + cooperating API).

**Architecture:** Two new example-interactive webpack entries: a parent `focus-host` page (raw `iframe-phone` `ParentEndpoint`, host-rendered sentinels/neighbors/Close, hand-tracked `focusInsideIframe`) and a minimal `focus-interactive` cooperating demo. Cross-origin is achieved with one `live-server` by serving the host on `localhost` and pointing the iframe at `127.0.0.1`. The trap is composed imperatively via `accessibility-tools`' vanilla `FocusTrapController` (not the React hook) to avoid a React-16-vs-17 mismatch.

**Tech Stack:** TypeScript, React 16, webpack 4, `iframe-phone`, `@concord-consortium/lara-interactive-api` (local source), `@concord-consortium/accessibility-tools` (Phase B+, linked). Build/run on Node 14; install with `npm ci --legacy-peer-deps`.

**Spec:** [docs/superpowers/specs/2026-06-03-focus-trap-testbed-harness-design.md](../specs/2026-06-03-focus-trap-testbed-harness-design.md)
**Branch:** `LARA-215-focus-testbed` (already created; commit each task here).

---

## File structure

```
lara-typescript/
  src/example-interactives/
    index.html                     MODIFY: add links to the two new entries
    src/
      focus-interactive/           CREATE: minimal cooperating demo interactive
        index.html
        index.tsx
        app.tsx
      focus-host/                  CREATE: parent host page
        index.html
        index.tsx
        host.tsx
  webpack.config.js                MODIFY: register the two new entries
  package.json                     MODIFY (Phase B): add accessibility-tools dependency
```

Each file has one responsibility: `*/index.tsx` mounts React; `focus-interactive/app.tsx` is the embedded interactive UI; `focus-host/host.tsx` owns the host page, the iframe-phone connection, and (Phase B+) the trap.

All commands below assume you are in `lara-typescript/` on Node 14:

```bash
cd /Users/scytacki/Development/lara/lara-typescript
export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"; nvm use 14
```

---

## Phase A — Baseline harness (no trap, no new libraries)

Goal of this phase: observe **native** cross-origin Tab/Shift+Tab traversal and the `focus`/`blur` signal, with no trap and no library link.

### Task A1: Create the `focus-interactive` demo interactive

**Files:**
- Create: `src/example-interactives/src/focus-interactive/index.html`
- Create: `src/example-interactives/src/focus-interactive/index.tsx`
- Create: `src/example-interactives/src/focus-interactive/app.tsx`

- [ ] **Step 1: Create `index.html`** (mirrors `testbed/index.html`)

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <title>focus-interactive</title>
    <link rel="stylesheet" href="../index.css" />
  </head>
  <body>
    <div id="app">
      <div class="centered">
        <div class="progress">
          Loading...
        </div>
      </div>
    </div>
    <script src="index.js"></script>
  </body>
</html>
```

- [ ] **Step 2: Create `app.tsx`** (minimal interactive with three focusable controls)

```tsx
import * as React from "react";
import { useEffect } from "react";
import { useInitMessage, setSupportedFeatures, useAutoSetHeight } from "../../../interactive-api-client";

export const AppComponent: React.FC = () => {
  const initMessage = useInitMessage();

  useAutoSetHeight();

  useEffect(() => {
    if (initMessage) {
      setSupportedFeatures({ interactiveState: true });
    }
  }, [initMessage]);

  if (!initMessage) {
    return (
      <div className="centered">
        <div className="progress">Loading...</div>
      </div>
    );
  }

  return (
    <div style={{ padding: 16, border: "3px solid purple" }}>
      <h2>focus-interactive</h2>
      <p>mode: {initMessage.mode}</p>
      <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
        <button type="button">Interactive button 1</button>
        <input type="text" aria-label="Interactive field" placeholder="Interactive field" />
        <button type="button">Interactive button 2</button>
      </div>
    </div>
  );
};
```

- [ ] **Step 3: Create `index.tsx`** (mirrors `testbed/index.tsx`)

```tsx
import * as React from "react";
import * as ReactDOM from "react-dom";
import { AppComponent } from "./app";

ReactDOM.render(<AppComponent />, document.getElementById("app"));
```

- [ ] **Step 4: Commit**

```bash
git add src/example-interactives/src/focus-interactive
git commit -m "feat(LARA-215): add minimal focus-interactive demo interactive"
```

### Task A2: Create the `focus-host` baseline parent page

**Files:**
- Create: `src/example-interactives/src/focus-host/index.html`
- Create: `src/example-interactives/src/focus-host/index.tsx`
- Create: `src/example-interactives/src/focus-host/host.tsx`

- [ ] **Step 1: Create `index.html`**

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <title>focus-host</title>
    <link rel="stylesheet" href="../index.css" />
  </head>
  <body>
    <div id="app"></div>
    <script src="index.js"></script>
  </body>
</html>
```

- [ ] **Step 2: Create `host.tsx`** (baseline: raw iframe-phone, sentinels static/inert, hand-tracked `focusInsideIframe`)

```tsx
import * as React from "react";
import { useEffect, useRef, useState } from "react";
import * as iframePhone from "iframe-phone";

// Cross-origin trick: the host page is opened on one host name; the iframe is
// pointed at the other. localhost and 127.0.0.1 are different origins for
// same-origin-policy / postMessage purposes, so this yields a real cross-origin
// iframe from a single live-server.
const otherHost = (hostname: string) => (hostname === "localhost" ? "127.0.0.1" : "localhost");
const INTERACTIVE_PATH = "/focus-interactive/index.html";

export const HostComponent: React.FC = () => {
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const phoneRef = useRef<iframePhone.ParentEndpoint>();
  const [connected, setConnected] = useState(false);
  const [focusInsideIframe, setFocusInsideIframe] = useState(false);
  const [lastEvent, setLastEvent] = useState("(none)");

  const { protocol, hostname, port } = window.location;
  const iframeOrigin = `${protocol}//${otherHost(hostname)}${port ? ":" + port : ""}`;
  const iframeSrc = `${iframeOrigin}${INTERACTIVE_PATH}`;

  // Connect the iframe-phone parent endpoint and send a minimal runtime init.
  useEffect(() => {
    const el = iframeRef.current;
    if (!el) {
      return;
    }
    const phone = new iframePhone.ParentEndpoint(el, iframeOrigin, () => {
      setConnected(true);
      phone.post("initInteractive", {
        version: 1,
        mode: "runtime",
        authoredState: {},
        interactiveState: {},
        globalInteractiveState: {}
      });
    });
    phoneRef.current = phone;
    return () => phone.disconnect();
  }, [iframeOrigin]);

  // Hand-track focusInsideIframe from the iframe element's focus/blur — the one
  // cross-origin signal the parent can observe. (focus/blur do not bubble, so
  // listen directly on the element.)
  useEffect(() => {
    const el = iframeRef.current;
    if (!el) {
      return;
    }
    const onFocus = () => { setFocusInsideIframe(true); setLastEvent("iframe focus"); };
    const onBlur = () => { setFocusInsideIframe(false); setLastEvent("iframe blur"); };
    el.addEventListener("focus", onFocus);
    el.addEventListener("blur", onBlur);
    return () => {
      el.removeEventListener("focus", onFocus);
      el.removeEventListener("blur", onBlur);
    };
  }, []);

  const sentinelStyle: React.CSSProperties = { position: "absolute", width: 0, height: 0, overflow: "hidden" };

  return (
    <div style={{ padding: 16 }}>
      <h1>focus-host — Phase A (baseline, no trap)</h1>
      <div style={{ fontFamily: "monospace", marginBottom: 12 }}>
        connected: {String(connected)} | iframeOrigin: {iframeOrigin} | focusInsideIframe:{" "}
        {String(focusInsideIframe)} | lastEvent: {lastEvent}
      </div>

      <button type="button">Host: Before</button>

      <div id="trap-container" style={{ border: "3px solid green", padding: 8, margin: "8px 0" }}>
        {/* Sentinels are present but inert in Phase A (tabIndex -1). They become active in Phase C. */}
        <span data-sentinel="before" tabIndex={-1} style={sentinelStyle} />
        <iframe
          ref={iframeRef}
          src={iframeSrc}
          title="embedded interactive"
          width="100%"
          height={320}
          tabIndex={0}
        />
        <span data-sentinel="after" tabIndex={-1} style={sentinelStyle} />
        <button type="button">Host: Close (escape hatch)</button>
      </div>

      <button type="button">Host: After</button>
    </div>
  );
};
```

- [ ] **Step 3: Create `index.tsx`**

```tsx
import * as React from "react";
import * as ReactDOM from "react-dom";
import { HostComponent } from "./host";

ReactDOM.render(<HostComponent />, document.getElementById("app"));
```

- [ ] **Step 4: Commit**

```bash
git add src/example-interactives/src/focus-host
git commit -m "feat(LARA-215): add focus-host baseline parent page (no trap)"
```

### Task A3: Register the two entries in webpack and the index page

**Files:**
- Modify: `webpack.config.js` (the `module.exports = (env, argv) => [ ... ]` array, ~line 262-270)
- Modify: `src/example-interactives/index.html` (the `<ul>` link list)

- [ ] **Step 1: Add both entries to the webpack config array**

In `webpack.config.js`, change the exported array from:

```js
module.exports = (env, argv) => [
  laraTypescript(),
  interactiveApiClient(),
  interactiveApiHost(),
  exampleInteractive("testbed"),
  exampleInteractive("linked-state"),
  exampleInteractive("report-item"),
  exampleInteractive("attachments")
];
```

to:

```js
module.exports = (env, argv) => [
  laraTypescript(),
  interactiveApiClient(),
  interactiveApiHost(),
  exampleInteractive("testbed"),
  exampleInteractive("linked-state"),
  exampleInteractive("report-item"),
  exampleInteractive("attachments"),
  exampleInteractive("focus-host"),
  exampleInteractive("focus-interactive")
];
```

- [ ] **Step 2: Add links to `src/example-interactives/index.html`**

Change the `<ul>` from:

```html
    <ul>
      <li><a href="testbed/index.html">Testbed</a></li>
      <li><a href="linked-state/index.html">Show Linked State</a></li>
      <li><a href="report-item/index.html">Report Item</a></li>
      <li><a href="attachments/index.html">Attachments</a></li>
    </ul>
```

to:

```html
    <ul>
      <li><a href="testbed/index.html">Testbed</a></li>
      <li><a href="linked-state/index.html">Show Linked State</a></li>
      <li><a href="report-item/index.html">Report Item</a></li>
      <li><a href="attachments/index.html">Attachments</a></li>
      <li><a href="focus-host/index.html">Focus Host (testbed harness)</a></li>
      <li><a href="focus-interactive/index.html">Focus Interactive (embedded by Focus Host)</a></li>
    </ul>
```

- [ ] **Step 3: Build and confirm both bundles emit**

Run:
```bash
npm run build:webpack:no-copy-to-rails 2>&1 | tail -20
```
Expected: build completes with no errors; entrypoints `example-interactive-focus-host` and `example-interactive-focus-interactive` appear. Confirm the output files exist:
```bash
ls dist/example-interactives/focus-host/index.js dist/example-interactives/focus-interactive/index.js
```
Expected: both paths listed (no "No such file").

- [ ] **Step 4: Commit**

```bash
git add webpack.config.js src/example-interactives/index.html
git commit -m "build(LARA-215): register focus-host and focus-interactive entries"
```

### Task A4: ⛔ MANUAL VERIFICATION GATE — Phase A (HUMAN, BLOCKING)

This is a hard stop. An agent MUST NOT proceed to Phase B until the human reports results and says "proceed".

- [ ] **Step 1: Serve the build** (in a separate terminal, leave running)

```bash
npm run example-interactives
```
This serves `dist/example-interactives/` on port 8888.

- [ ] **Step 2: HUMAN — open the host on `localhost`**

Open `http://localhost:8888/focus-host/index.html` (must be `localhost`, not `127.0.0.1`, so the iframe at `127.0.0.1` is cross-origin).

- [ ] **Step 3: HUMAN — confirm the cross-origin embed works**

  - The status line shows `connected: true` and `iframeOrigin: http://127.0.0.1:8888`.
  - The purple `focus-interactive` box renders inside the green container (it got past "Loading...", proving the cross-origin init handshake works).

- [ ] **Step 4: HUMAN — observe native focus traversal (the point of Phase A)**

  Click "Host: Before", then press Tab repeatedly and watch where focus goes:
  - Does Tab descend into the iframe's controls (button 1 → field → button 2)?
  - Does Tab continue out to "Host: Close" and "Host: After"?
  - Does the status line's `focusInsideIframe` flip to `true` while focus is in the iframe and back to `false` when it leaves?
  - Repeat with Shift+Tab (reverse).
  - Record the behavior (and the browser/OS). This is the native baseline the later phases are measured against.

- [ ] **Step 5: HUMAN — confirm and authorize**

Report what you observed. Only when you say "proceed" does Phase B begin.

---

## Phase B — Existing `accessibility-tools` trap around the iframe (no new features)

Goal of this phase: wrap the host container in **today's** `FocusTrapController` (iframe as an ordinary slot) and observe the iframe-blind misbehavior — the motivating failure. Also de-risks the ESM/`exports`/webpack-4 build integration against the unmodified package.

### Task B1: Add and link `accessibility-tools`

**Files:**
- Modify: `package.json` (dependencies)
- Possibly modify: `webpack.config.js` (a `resolve.alias` if the `exports` subpath does not resolve under webpack 4)

- [ ] **Step 1: Add the dependency**

In `package.json`, add to the `"dependencies"` object (published version is `0.1.0`):
```json
    "@concord-consortium/accessibility-tools": "^0.1.0",
```

- [ ] **Step 2: Link the local checkout for co-development**

The harness uses the package's built `dist/`, so build it first, then link:
```bash
( cd /Users/scytacki/Development/accessibility-tools && npm install && npm run build )
cd /Users/scytacki/Development/lara/lara-typescript
npm link @concord-consortium/accessibility-tools
```
Expected: no errors; `ls node_modules/@concord-consortium/accessibility-tools/dist/hooks/index.js` exists.

- [ ] **Step 3: Smoke-build to surface the webpack-4 `exports` risk early**

Add a temporary throwaway import at the top of `src/example-interactives/src/focus-host/host.tsx`:
```tsx
import { FocusTrapController } from "@concord-consortium/accessibility-tools/hooks";
// eslint-disable-next-line @typescript-eslint/no-unused-vars
const _smoke = FocusTrapController;
```
Run:
```bash
npm run build:webpack:no-copy-to-rails 2>&1 | tail -25
```
- Expected (success): build completes; `focus-host` bundle emits.
- If it fails with a module-resolution error (webpack 4 not honoring the `exports` map), add a `resolve.alias` to the `exampleInteractive(name)` config in `webpack.config.js`. Change its `resolve` block from:
  ```js
  resolve: {
    extensions: [ '.ts', '.tsx', '.js' ]
  },
  ```
  to:
  ```js
  resolve: {
    extensions: [ '.ts', '.tsx', '.js' ],
    alias: {
      '@concord-consortium/accessibility-tools/hooks':
        require('path').resolve(__dirname, 'node_modules/@concord-consortium/accessibility-tools/dist/hooks/index.js')
    }
  },
  ```
  Re-run the build until it succeeds.

- [ ] **Step 4: Remove the throwaway smoke import** from `host.tsx` (the real import is added in Task B2). Re-run the build to confirm it still compiles cleanly.

- [ ] **Step 5: Commit**

```bash
git add package.json webpack.config.js package-lock.json
git commit -m "build(LARA-215): add and link accessibility-tools dependency"
```

### Task B2: Wrap the host container in the existing `FocusTrapController`

**Files:**
- Modify: `src/example-interactives/src/focus-host/host.tsx`

- [ ] **Step 1: Add refs for the trapped focusables**

In `host.tsx`, add refs alongside the existing `iframeRef` (inside `HostComponent`, before the `return`):
```tsx
  const containerRef = useRef<HTMLDivElement>(null);
  const beforeBtnRef = useRef<HTMLButtonElement>(null);
  const closeBtnRef = useRef<HTMLButtonElement>(null);
  const [trapEnabled, setTrapEnabled] = useState(true);
```

- [ ] **Step 2: Add the import**

At the top of `host.tsx`, add:
```tsx
import { FocusTrapController, FocusTrapStrategy } from "@concord-consortium/accessibility-tools/hooks";
```

- [ ] **Step 3: Create the trap controller in an effect**

Add this effect after the focus/blur effect in `host.tsx`:
```tsx
  // Phase B: wrap the container in the CURRENT FocusTrapController, with the
  // iframe as an ordinary slot. This is expected to mishandle the iframe — that
  // failure is the point of this phase.
  useEffect(() => {
    const container = containerRef.current;
    if (!container) {
      return;
    }
    const strategy: FocusTrapStrategy = {
      getElements: () => ({
        before: beforeBtnRef.current ?? undefined,
        iframe: iframeRef.current ?? undefined,
        close: closeBtnRef.current ?? undefined
      }),
      cycleOrder: ["before", "iframe", "close"]
    };
    const controller = new FocusTrapController(container, strategy);
    controller.setEnabled(trapEnabled);
    if (trapEnabled) {
      controller.enterTrap();
    }
    return () => controller.destroy();
  }, [trapEnabled]);
```

- [ ] **Step 4: Wire the refs and a trap toggle into the JSX**

Update the heading to read Phase B, attach `containerRef` to the trap container div, attach `beforeBtnRef` to the "Host: Before" button (move it inside the container) and `closeBtnRef` to the Close button, and add a toggle. Replace the JSX return body with:
```tsx
  return (
    <div style={{ padding: 16 }}>
      <h1>focus-host — Phase B (existing trap, iframe-blind)</h1>
      <div style={{ fontFamily: "monospace", marginBottom: 12 }}>
        connected: {String(connected)} | iframeOrigin: {iframeOrigin} | focusInsideIframe:{" "}
        {String(focusInsideIframe)} | lastEvent: {lastEvent}
      </div>
      <label style={{ display: "block", marginBottom: 8 }}>
        <input type="checkbox" checked={trapEnabled} onChange={(e) => setTrapEnabled(e.target.checked)} />{" "}
        trap enabled
      </label>

      <button type="button">Host: Before (outside trap)</button>

      <div ref={containerRef} id="trap-container" style={{ border: "3px solid green", padding: 8, margin: "8px 0" }}>
        <button ref={beforeBtnRef} type="button">Host: trapped neighbor</button>
        <span data-sentinel="before" tabIndex={-1} style={sentinelStyle} />
        <iframe
          ref={iframeRef}
          src={iframeSrc}
          title="embedded interactive"
          width="100%"
          height={320}
          tabIndex={0}
        />
        <span data-sentinel="after" tabIndex={-1} style={sentinelStyle} />
        <button ref={closeBtnRef} type="button">Host: Close (escape hatch)</button>
      </div>

      <button type="button">Host: After (outside trap)</button>
    </div>
  );
```

- [ ] **Step 5: Build and confirm it compiles**

Run:
```bash
npm run build:webpack:no-copy-to-rails 2>&1 | tail -20
```
Expected: build completes, no errors; `focus-host` bundle emits.

- [ ] **Step 6: Commit**

```bash
git add src/example-interactives/src/focus-host/host.tsx
git commit -m "feat(LARA-215): wrap focus-host container in existing FocusTrapController"
```

### Task B3: ⛔ MANUAL VERIFICATION GATE — Phase B (HUMAN, BLOCKING)

Hard stop. An agent MUST NOT proceed to Phase C until the human reports results and says "proceed".

- [ ] **Step 1: Serve** (if not already running): `npm run example-interactives`

- [ ] **Step 2: HUMAN — open `http://localhost:8888/focus-host/index.html`**

- [ ] **Step 3: HUMAN — observe the trap's handling of the iframe (the point of Phase B)**

With "trap enabled" checked, Tab/Shift+Tab through the container and record:
  - Can you Tab *into* the iframe's controls, or does the trap skip the iframe (e.g. `setChildrenNonTabbable` set the iframe to `tabindex=-1`)?
  - When focus is inside the iframe and you Tab to its last control, does focus return to the host, get stuck, or escape the trap?
  - Does Escape do anything useful?
  - Toggle "trap enabled" off and confirm native behavior returns (matches Phase A).
  - Record the failure modes — these concretely justify the iframe-slot + cooperating API.

- [ ] **Step 4: HUMAN — confirm and authorize**

Report what you observed. Only when you say "proceed" does Phase C begin.

---

## Phase C — New features (BLOCKED: depends on separate library specs)

> **Do not start Phase C from this plan.** Phase C consumes three new library APIs that do not exist yet and are designed in their own per-repo specs (the black-box seams from the design doc). When those specs exist and the APIs are implemented/published-or-linked, Phase C gets its **own** implementation plan written against their concrete signatures. This section records the intended substitution so the harness's Phase A/B structure is known to accommodate it.

**Seams Phase C will consume** (shapes only; exact signatures come from the per-repo specs):
- `accessibility-tools` — an **iframe-slot** registration on `FocusTrapStrategy` that takes the iframe + before/after sentinel refs and an injected transport (`send`/`onMessage`), is excluded from `setChildrenNonTabbable`, and drives sentinel-`focusin` cycling.
- `interactive-api-host` — a **`FocusManager`** constructed around the iframe-phone endpoint, dispatching inbound `focusExit`/capability to host callbacks and sending `focusEnter`/`restore`. Imported from local source: `../../../interactive-api-host`.
- `lara-interactive-api` — typed focus messages (`focusEnter`, `focusExit`, optional `trapStateChanged`/`focusReady`) and the `focusProtocol` capability flag. Used by both `focus-interactive` (to declare/cooperate) and the host.

**Intended substitution (high level):**
1. In `focus-host/host.tsx`, replace the hand-rolled `focus`/`blur` sentinel tracking and the Phase-B blind strategy with the new iframe-slot registration, and construct a `FocusManager` over `phoneRef.current` to serve as the slot's transport.
2. In `focus-interactive/app.tsx`, declare `focusProtocol`, focus first/last/last-focused on `focusEnter`, and emit `focusExit` at Tab boundaries / on Escape.
3. Add a target switcher to point the iframe at a non-cooperating existing example (`testbed` / `linked-state`) on `127.0.0.1` to exercise the non-cooperating path.
4. End with **MANUAL VERIFICATION GATE — Phase C**: non-cooperating Tab-exit recovers via sentinels and the Close control works; cooperating forward/reverse/restore and Escape-to-exit work.

---

## Self-review notes

- **Spec coverage:** Phase A (baseline) ✓, Phase B (existing-trap failure) ✓, the localhost/127.0.0.1 cross-origin trick ✓, host-rendered sentinels/neighbors/Close ✓, imperative `FocusTrapController` decision ✓, manual gates as hard blocking steps ✓ (Tasks A4, B3, and the Phase C gate), accessibility-tools dependency landing in `package.json` ✓, build/run on Node 14 + `--legacy-peer-deps` ✓. Phase C is intentionally deferred (gated on separate library specs, per the spec's scope).
- **Placeholders:** none — all code is complete; the only deferred work (Phase C) is explicitly blocked and labeled, not a hidden TODO.
- **Type/name consistency:** `iframePhone.ParentEndpoint(el, iframeOrigin, cb)` matches the `iframe-phone` `index.d.ts`; `FocusTrapController` + `FocusTrapStrategy` import from `@concord-consortium/accessibility-tools/hooks` matches the package's `exports` map and `src/hooks/index.ts`; `useInitMessage`/`setSupportedFeatures`/`useAutoSetHeight` match the existing `testbed/app.tsx` usage; `initInteractive` payload (`mode: "runtime"`, `authoredState`/`interactiveState`/`globalInteractiveState`) matches `client.ts` handling and `client.spec.ts`.
