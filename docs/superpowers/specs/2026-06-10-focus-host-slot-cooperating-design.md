# focus-host-slot — cooperating iframe-slot testbed (Phase C2)

**Status:** Ready for review
**Jira:** [LARA-215](https://concord-consortium.atlassian.net/browse/LARA-215)
**Branch:** `LARA-215-focus-testbed` (lara); `LARA-215-iframe-slot-focus-trap`
(accessibility-tools, yalc-linked)

## Summary

Phase C2 turns the existing **`focus-host-slot`** example-interactive into a
**capability-aware** host that exercises the iframe-slot's **cooperating path** —
the focus protocol (`focusEnter` / `focusExit` / capability) carried over the
**real `interactive-api`**, not a testbed-only channel. It adds one
protocol-speaking interactive (`focus-interactive-coop`) and the supporting wire
layer across three lara-typescript packages.

The cooperating mechanism already exists in shipped
`@concord-consortium/accessibility-tools` (`IframeSlot` takes a `transport` +
`onRequestExit`, auto-consumes inbound `focusExit` / `capability` via
`handleMessage`, sends `focusEnter{forward|reverse|restore}` from
`focusContent`'s programmatic branch and from `requestRestore`). So C2 is mostly
**wiring** — a `FocusTransport` adapter, a capability handshake, and an
interactive that actually speaks the protocol — plus the new wire-message types.

C2 builds directly on Phase C1
([2026-06-09-focus-host-slot-noncooperating-design.md](2026-06-09-focus-host-slot-noncooperating-design.md)),
which ironed out the **non-cooperating** inline-tile path (sentinels + native Tab
descent, landing hints). C1 explicitly deferred the cooperating protocol,
`requestRestore`, Escape-to-exit, and `lara-interactive-api` /
`interactive-api-host` changes to this phase.

## Background / why this is needed

C1 proved the iframe-slot drives correct Tab traversal into/through/out of a
cross-origin interactive with **no cooperation** from the interactive. That path
has two inherent costs the cooperating path removes:

- **Programmatic entry costs an explicit Tab.** A no-Tab open (Enter/click) or a
  wrap-around lands on a visible "Press Tab to enter …" **landing hint**, and the
  user's *next* Tab descends. There is no live keydown to descend with, so the
  sentinel can only *rest* (§4 of the library design). Cooperating entry sends
  `focusEnter{forward|reverse}` and the interactive places focus **precisely**, in
  one step.
- **Escape inside the iframe is invisible to the host.** Keystrokes inside the
  iframe never reach the parent, so a non-cooperating host cannot offer
  Escape-to-exit from inside — the user must Tab out to a host slot first.
  Cooperating, the interactive sends `focusExit{escape}` and the host releases the
  trap.

A third cooperating affordance, **focus restore** after an AP-owned overlay
closes, is plumbed end-to-end here as a minimal round-trip (see §5).

Per-repo library design (cooperating sections):
[accessibility-tools/docs/iframe-slot-design.md](/Users/scytacki/Development/accessibility-tools/docs/iframe-slot-design.md)
§§2–7. Modality is the host's responsibility:
[accessibility-tools/docs/trap-composition.md](/Users/scytacki/Development/accessibility-tools/docs/trap-composition.md).
Cross-repo design: AP-108.

## Reference: the shipped library API (consumed here)

From `@concord-consortium/accessibility-tools/hooks` (already yalc-linked into
lara). The cooperating surface — all present in the shipped `IframeSlot`, unused
by C1:

- `new IframeSlot({ …, transport?: FocusTransport, onRequestExit?: () => void })`.
- `IframeSlot.notifyCapability(focusProtocol: boolean)` — flip to cooperating
  (also set by an inbound `capability` `FocusMessage`).
- `IframeSlot.handleMessage` (internal) consumes inbound `focusExit { forward |
  reverse | escape }` → `onExit(±1)` / `onRequestExit()`, and `capability` →
  `notifyCapability`.
- `IframeSlot.focusContent(ctx)` cooperating branch: when `cooperating &&
  transport` and `ctx.trigger === "programmatic"`, sends
  `focusEnter { mode: ctx.entryMode }` instead of a landing hint. The
  `"sequentialNavigation"` (live-Tab positioner) branch is **unchanged** —
  cooperating or not, Tab entry is native descent via sentinels.
- `IframeSlot.requestRestore()` — cooperating: send `focusEnter{restore}`;
  non-cooperating: fall back to a forward landing hint.
- `FocusMessage` / `FocusTransport` vocabulary (§7 of the library design):
  ```ts
  type FocusMessage =
    | { type: "focusEnter"; mode: "forward" | "reverse" | "restore" }
    | { type: "focusExit";  mode: "forward" | "reverse" | "escape" }
    | { type: "capability"; focusProtocol: boolean }
    | { type: "trapStateChanged"; active: boolean }   // unused here
    | { type: "focusReady" };                          // unused here
  interface FocusTransport {
    send: (msg: FocusMessage) => void;
    onMessage: (cb: (msg: FocusMessage) => void) => () => void;
  }
  ```

The library never imports a concord package; the host adapter maps the real wire
types ↔ `FocusMessage`.

## Scope

**In scope (C2):**
- The protocol **wire layer** across three lara-typescript packages
  (`interactive-api-shared`, `interactive-api-host`, `interactive-api-client`).
- **`focus-host-slot` becomes capability-aware** — always installs the transport;
  cooperates iff the embed advertises `focusProtocol`, else falls back to C1's
  non-cooperating behavior (so C1 is **re-verified through the same code path**).
- One new cooperating interactive **`focus-interactive-coop`**.
- `focusEnter{forward|reverse}` (precise programmatic placement),
  `focusExit{escape}` (Escape-to-exit), and a **restore round-trip** stand-in.
- Re-verify C1's three real-browser library fixes still hold on this path.
- A manual-verification gate (cross-origin + iframe-phone, browser).

**Out of scope (deferred to later phases):**
- **Directional exit / internal Tab trap** — an interactive that traps Tab
  internally and emits `focusExit{forward|reverse}`. The wire `mode` values are
  *defined* but C2 never sends `forward`/`reverse`.
- **Multiple iframe-slots + `IframeSlotRegistry`** — orthogonal to the protocol;
  `getIntercept` stays the single-iframe constant `{ forward: true, reverse: true }`.
- **Wiring the protocol into production LARA iframe-runtime / AP** — C2 adds the
  packages but only the testbed consumes them.
- **The AP modal-overlay engagement model** and a real react-modal restore trigger
  (the `showModal`/`closeModal` loop). Restore here is a minimal round-trip
  stand-in (§5); the engagement model stays C1's inline tile.

## Design

### 1. Capability-aware single host

`focus-host-slot` is extended (not duplicated). It **always** constructs the
`FocusTransport` and passes it to the `IframeSlot`. Whether it behaves
cooperatively is decided entirely by what the embed advertises — no flag in the
host names "the cooperating demo":

- **Embed advertises `focusProtocol`** (default embed = `focus-interactive-coop`)
  → `IframeSlot.cooperating` flips true → programmatic entry sends `focusEnter`;
  Escape-from-inside and restore become observable.
- **Embed is silent** (C1's `focus-interactive`, reachable via
  `?interactive=<url>`) → identical to C1: landing-hint fallback, no
  Escape-from-inside, restore degrades to a landing hint.

So C1's non-cooperating path is the host's **fallback branch**, re-verified rather
than frozen as a copy. The inline-tile engagement model is unchanged from C1
(Enter-to-enter, Escape/Close-to-exit, dismiss-on-focus-leaves-tile via
`exitTrap({ refocus: false })`). The `trap enabled` checkbox and the cross-origin
(`localhost`↔`127.0.0.1`) + iframe-phone mechanism carry over.

### 2. The protocol wire layer

Three real package changes (reusable by AP later; only the testbed consumes them
in C2). **Payloads are objects** (`{ mode }`), not bare strings, so they extend
without a breaking change.

**`interactive-api-shared/types.ts`:**

- `IRuntimeServerMessage` gains **`"focusEnter"`** (host→interactive), payload
  `{ mode: "forward" | "reverse" | "restore" }`.
- `IRuntimeClientMessage` gains **`"focusExit"`** (interactive→host), payload
  `{ mode: "forward" | "reverse" | "escape" }`. *(C2 only ever sends `escape`;
  `forward`/`reverse` are defined but unused until the deferred internal-trap
  phase.)*
- `ISupportedFeatures` gains **`focusProtocol?: boolean`** — the capability
  handshake rides the existing `supportedFeatures` mechanism the interactive
  already uses.

**`interactive-api-host` — new `FocusManager`:** a standalone class over an
iframe-phone `ParentEndpoint` (the "maps wire ↔ `FocusMessage`" adapter the
library design names). It exposes a `FocusTransport`:

- `send({ type: "focusEnter", mode })` → `phone.post("focusEnter", { mode })`.
- `onMessage(cb)` subscribes to **two** wire messages and translates:
  - `"focusExit"` → `cb({ type: "focusExit", mode })`.
  - `"supportedFeatures"` → if `features.focusProtocol`,
    `cb({ type: "capability", focusProtocol: true })`.

The second translation is deliberate: **capability reaches the `IframeSlot`
through `transport.onMessage`**, where the library's `handleMessage` already
auto-consumes `{ type: "capability" }` → `notifyCapability`. So the host passes
only `transport` and never calls `notifyCapability` itself, and late capability is
safe by the library's "robust timing" guarantee (§ Open questions).

**`interactive-api-client`:** small client helpers the cooperating interactive
uses — `addFocusEnterListener((mode) => …)`, `sendFocusExit(mode)`, and
`focusProtocol` accepted by `setSupportedFeatures`. (A thin `useFocusProtocol`
hook may wrap these; settle when writing the plan.)

### 3. Host wiring (imperative, building on C1)

The C1 host already builds the `IframeSlot` + `FocusTrapController` imperatively in
one effect. C2 adds:

1. Construct a `FocusManager` over the existing `ParentEndpoint` (the same `phone`
   C1 connects), and pass `focusManager.transport` to the `IframeSlot` options.
2. Wire `onRequestExit: () => controller.exitTrap()` (present in the shipped
   `IframeSlot`, unused in C1) — **with `refocus: true`** (default), because
   Escape-from-inside means focus was inside the trap and must land back on the
   visible tile container. (Contrast C1's focus-leaves-tile dismiss, which keeps
   `refocus: false`.)
3. Everything else — sentinels, `nativeTabSlots`, `getNativeTabSlotSentinels`,
   the host-owned iframe `tabIndex` across open/closed (C1 §2), the build-order
   cycle break — is unchanged.

Capability flows in passively: when the interactive's `supportedFeatures` message
arrives, the `FocusManager` emits a `capability` `FocusMessage` into
`transport.onMessage`, the `IframeSlot` flips `cooperating`, and subsequent
programmatic entries take the `focusEnter` branch. No host code reads capability
directly.

### 4. The cooperating interactive (`focus-interactive-coop`)

A new sibling to `focus-interactive`, deliberately the **simple** cooperating kind
(no internal Tab trap — that is the deferred directional-exit phase). It lets Tab
flow natively, so forward/reverse **exit** still goes through the host's sentinels
exactly as non-cooperating. It adds only what the protocol needs:

- **Advertise:** `setSupportedFeatures({ interactiveState: true, focusProtocol: true })`.
- **Inbound `focusEnter`:** `forward` → `.focus()` its first control; `reverse` →
  its last; `restore` → its last-focused control.
- **Track last-focused:** a `focusin` listener records the most recent focused
  control, for `restore`.
- **`focusExit{escape}`:** a `keydown` listener — Escape → `sendFocusExit("escape")`.

It reuses C1's three controls (button / field / button) so traversal is
comparable. No `accessibility-tools` dependency inside the child — placement is
plain `.focus()`. (Dogfooding the library's own trap inside the child only matters
for the deferred internal-trap variant.)

**`focusExit{escape}` is suppressible by the interactive — by design, not
demonstrated in C2.** Whether Escape forwards is the *interactive's* decision (an
inner widget may consume Escape — e.g. cancel an edit — and not forward it). C2's
simple interactive always forwards; the suppression hook is exercised in the later
internal-trap phase.

### 5. Restore: minimal round-trip stand-in

Overlay rendering and the "it closed, now restore" decision are **AP-app-level**,
not library code — `accessibility-tools` explicitly does not own react-modal or
the close control (§ "This library does not own"), and `interactive-api-host` has
no modal manager. So C2 does **not** build the `showModal` loop or an overlay.

Instead the host adds a **"Restore focus" button** (a normal slot), honestly
labeled as a stand-in for AP's post-overlay glue. Activating it calls
`slot.requestRestore()`:

- **Cooperating** → `focusEnter{restore}` → interactive re-focuses its
  last-focused control (precise).
- **Non-cooperating** → degrades to the library's forward landing hint.

This lands and browser-verifies all the *new* restore code — the client `restore`
handler + last-focused tracking, the `focusEnter` wire message, the `FocusManager`
passthrough, and the `IframeSlot.requestRestore()` cooperating branch — without
building AP-shaped overlay glue the testbed would not ship.

### 6. Re-verifying C1's three library fixes on the cooperating path

All three live in shared code the cooperating path also hits, so C2 re-confirms
them in a real browser:

1. **Inside-tracking** (window blur/focus + deferred `document.activeElement`
   re-read): cooperating entry has the *child* call `.focus()` on its own control.
   That still moves parent `activeElement` to the iframe and blurs the parent
   window → the same signal must flip `focusInsideIframe`. Confirm it fires for
   protocol-driven placement, not just native descent.
2. **Landing-hint clears on sentinel `focusout`:** cooperating entry uses
   `focusEnter`, *not* landing — but the **fallback** embed still uses landing, so
   confirm C1's clear-on-focusout holds for the `?interactive=<non-coop>` case.
3. **`exitTrap({ refocus: false })`** host-driven dismiss: unchanged; still used
   for focus-leaves-tile. The new Escape-from-inside path uses
   `exitTrap()` with the default `refocus: true`.

### 7. Observability & verification

- Status line extends C1's with `cooperating: <bool>` (from capability), and
  `lastEvent` also reports `focusEnter sent {mode}`, `focusExit recv {mode}`,
  `capability recv`, and `restore`.
- **Manual-verification gate** (human, blocking) — cross-origin
  `localhost`↔`127.0.0.1` + iframe-phone, Chrome DevTools as a dev aid; same
  approach as C1 because jsdom cannot do cross-frame focus or real postMessage
  timing. Covers:
  - capability handshake flips `cooperating`;
  - **open (Enter)** → `focusEnter{forward}` lands *precisely* on the interactive's
    first control (no landing hint);
  - **Shift+Tab wrap** → `focusEnter{reverse}` lands on its last control;
  - Tab-through + native sentinel exit → cycle to neighbor (unchanged from C1);
  - **Escape inside the iframe** → `focusExit{escape}` → trap releases, focus back
    on the tile container;
  - **Restore button** → precise re-focus of the last control;
  - then **`?interactive=<non-coop>`** reproduces C1 exactly (landing hints, no
    Escape-from-inside, restore degrades to landing).

## Testing

No automated tests in the testbed (consistent with the other example-interactive
entries and with the library's own out-of-repo browser verification — jsdom can't
do cross-iframe native Tab descent or real cross-frame postMessage). Verification
is the manual gate plus the existing Node-14 webpack build. New **unit** coverage
belongs with the code it tests:

- `interactive-api-host` `FocusManager`: against a mock iframe-phone endpoint,
  `send` posts `focusEnter`; inbound `focusExit` and `supportedFeatures` translate
  to the right `FocusMessage`s (including the `focusProtocol` → `capability`
  synthesis). These are plain JS-observable, so they *are* unit-testable here.
- `interactive-api-client` helpers: `addFocusEnterListener` / `sendFocusExit` /
  `setSupportedFeatures({ focusProtocol })` round-trip against the existing client
  test harness.

The `accessibility-tools` cooperating branches (`focusContent` cooperating,
`handleMessage`, `requestRestore`) already have jsdom unit coverage in that repo;
C2 only re-verifies them end-to-end in the browser.

## Findings (integration lessons for AP / CLUE / CODAP)

To be filled in from the manual gate — the cooperating-path analogues of C1's
inline-pattern findings. Expected themes: the capability handshake is passive and
order-independent (the host wires only `transport`); Escape-from-inside is the
single biggest UX win over the non-cooperating path; restore is a one-call host
responsibility, not library-owned.

## Open questions / risks

- **Capability-handshake timing.** `supportedFeatures` arrives async, possibly
  after the trap effect has built the `IframeSlot`. The design relies on the
  library's "late capability is safe — it only *adds* cooperating extras"
  guarantee, but the `FocusManager` must funnel a capability message that arrives
  *before* the slot subscribes to the slot once it does (replay the last-known
  capability on `onMessage` subscribe, or have the host re-emit it). A wiring
  detail to settle in the plan.
- **`focusExit{escape}` suppressibility** is the interactive's responsibility
  (settled: yes, not demonstrated in C2). C2's interactive always forwards.
- **Wire payload shape** is an object `{ mode }` (settled), leaving room for
  future fields (e.g. an element hint) without a breaking change.
- **Cross-browser** behavior of protocol-driven `.focus()` inside the child
  triggering the parent's window-blur inside-tracking is assumed from AP-108's
  macOS findings; re-confirm by hand in the gate.
- **Controller `focusin` auto-enter vs the protocol-driven exit** — C1 flagged
  verifying ordering when the controller's `document` `focusin` and the slot's
  exit both fire; the Escape path now adds a programmatic `exitTrap()` to watch
  alongside it.
