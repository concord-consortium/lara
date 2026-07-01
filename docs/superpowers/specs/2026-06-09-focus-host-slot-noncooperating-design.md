# focus-host-slot — non-cooperating iframe-slot testbed (Phase C1)

**Status:** Ready for review
**Jira:** [LARA-215](https://concord-consortium.atlassian.net/browse/LARA-215)
**Branch:** `LARA-215-focus-testbed`

## Summary

Add a new example-interactive entry, **`focus-host-slot`**, that demonstrates the
new `@concord-consortium/accessibility-tools` **iframe-slot** driving correct Tab
traversal into, through, and out of a **cross-origin interactive** in an iframe —
the **non-cooperating** path (sentinels + native Tab descent, no focus protocol).

This is Phase C1 of the focus-trap testbed. It is the runnable verification target
for the iframe-slot work, and it irons out the **inline-tile** integration pattern
that CLUE and CODAP will reuse (Tab to a tile, press Enter to go inside) — as
distinct from Activity Player's modal-overlay case.

It supersedes the original plan's deferred "Phase C" sketch
([2026-06-03-focus-trap-testbed-harness.md](../plans/2026-06-03-focus-trap-testbed-harness.md)),
now written against the concrete shipped API. The cooperating path (focus
protocol, `FocusManager`, restore, Escape-to-exit) is **Phase C2** and gets its
own spec/plan.

## Background / why this is needed

Phase B (`focus-host`) showed that today's `FocusTrapController`, with the iframe
as an ordinary slot, is **iframe-blind**: `iframe.focus()` lands on the iframe's
`<body>`, and the next Tab is handled *natively inside* the iframe (the parent
trap never sees it). The iframe-slot fixes this by never focusing the iframe
directly — instead it focuses a parent-side **sentinel** positioned one step
before/after the iframe and lets the browser's native Tab default descend from
there, and it catches native Tab-out on a sentinel `focusin` to cycle the trap.

Per-repo library design:
[accessibility-tools/docs/iframe-slot-design.md](/Users/scytacki/Development/accessibility-tools/docs/iframe-slot-design.md).
Cross-repo design: AP-108.

## Reference: the shipped API (consumed here)

From `@concord-consortium/accessibility-tools/hooks` (already yalc-linked into
lara; webpack-4/TS-4.4/React-16 build de-risked):

- **`IframeSlot`** (framework-agnostic core — used here imperatively, **not** the
  React `useIframeSlot` hook, to stay clear of the React-version mismatch):
  - `new IframeSlot(options)` where `options` =
    `{ slotName, getIframe, getBeforeSentinel, getAfterSentinel, onExit(dir: 1|-1), onRequestExit?, getIntercept: () => { forward, reverse }, transport?, enterLabel? }`
  - `attach()` / `detach()`, `getSentinels(): { before, after }`,
    `focusContent(ctx): boolean`, `requestRestore()`, `refreshIntercept()`,
    `get focusInsideIframe()`.
- **`FocusTrapController`** gains `cycleToAdjacentSlot(direction: 1|-1)` (plus the
  existing `setEnabled`/`enterTrap`/`exitTrap`/`destroy`/`isTrapped`).
- **`FocusTrapStrategy`** gains `nativeTabSlots?: string[]` and
  `getNativeTabSlotSentinels?(slotName) => { before, after }`.
- **`FocusContentContext`** = `{ entryMode: "forward" | "reverse", viaKeydown: boolean }`.

## Scope

**In scope (C1):**
- One new entry `focus-host-slot` (non-cooperating, single iframe).
- Inline-tile engagement model (Tab-to-tile, Enter-to-enter, Escape/Close-to-exit).
- The host responsibility for the iframe's `tabIndex` across open/closed.
- Live-keydown **positioner** entry and programmatic **landing** entry both
  exercised; native Tab traversal in both directions; sentinel-`focusin` exit→cycle.
- A manual-verification gate.

**Out of scope (deferred to C2 / later):**
- The cooperating focus protocol, `FocusTransport`, `requestRestore`,
  Escape-to-exit, reverse/restore precise placement.
- Multiple iframe-slots and the shared `IframeSlotRegistry` (`getIntercept` here
  is the single-iframe constant `{ forward: true, reverse: true }`).
- Any change to the Phase A/B entries (`focus-host` stays the iframe-blind demo).
- `lara-interactive-api` / `interactive-api-host` changes.

## Design

### 1. Placement

A new sibling entry alongside the existing ones:

```
src/example-interactives/src/focus-host-slot/
  index.html      (mirrors focus-host/index.html)
  index.tsx       (mounts HostComponent)
  host.tsx        (the iframe-slot host)
```

Registered in `webpack.config.js` (`exampleInteractive("focus-host-slot")`) and
linked from `src/example-interactives/index.html`. `focus-host` is untouched, so
the Phase B "iframe-blind" behavior stays demonstrable side by side.

Default embed = `focus-interactive` (speaks no protocol ⇒ non-cooperating);
`?interactive=<url>` overrides the target (reusing the Phase B mechanism), and the
iframe-phone connect + cross-origin (`localhost`↔`127.0.0.1`) trick carry over.

### 2. The crux: iframe `tabIndex` across open/closed (host-owned)

In the inline-tile model the tile is always present in the page, so a **closed**
tile must not put its iframe in the Tab order — otherwise Tab descends into it
instead of passing the tile by. The trap cannot do this for us: the iframe-slot's
wrapper is **excluded** from `setChildrenNonTabbable` (§8 of the library spec), so
the trap never touches the iframe's `tabIndex`.

**Therefore the host owns the iframe's `tabIndex` and toggles it with state:**

- **Closed** (trap disabled): iframe `tabIndex = -1` → Tab skips the whole tile;
  the container (`tabIndex 0`) is the single stop; Enter enters.
- **Open** (trap enabled + trapped): iframe `tabIndex = 0` → the sentinel
  positioner's native descent can enter it.

The library continues to own the **sentinels'** `tabindex` (toggled `0`↔`-1` from
`focusInsideIframe` + `getIntercept`). This host responsibility *is* the
inline-pattern detail being ironed out for CLUE/CODAP. (Alternative considered:
`inert` on the wrapper while closed — rejected: it fights the library's sentinel
toggling and is fuzzier cross-browser with iframes.)

### 3. DOM and trap structure

```
container (tabIndex 0, the single tile Tab stop)
  ├─ wrapper    <div>               (the iframe-slot's getElements() element)
  │    ├─ before-sentinel <span>
  │    ├─ iframe           <iframe> (host-owned tabIndex per §2)
  │    └─ after-sentinel  <span>
  ├─ neighbor   <button>            (normal slot — host chrome)
  └─ close      <button>            (normal slot — the escape hatch)
```

Wiring (imperative, in one effect):

1. Create the `IframeSlot`:
   `{ slotName: "content", getIframe, getBeforeSentinel, getAfterSentinel,
   onExit: (dir) => controller.cycleToAdjacentSlot(dir),
   getIntercept: () => ({ forward: true, reverse: true }),
   enterLabel: "Press Tab to enter the interactive" }`, then `slot.attach()`.
2. Build the strategy for `FocusTrapController`:
   - `getElements: () => ({ content: wrapper, neighbor, close })`
   - `cycleOrder: ["content", "neighbor", "close"]`
   - `contentSlot: "content"`
   - `nativeTabSlots: ["content"]`
   - `focusContent: (ctx) => slot.focusContent(ctx)`
   - `getNativeTabSlotSentinels: () => slot.getSentinels()`
3. `new FocusTrapController(container, strategy)`; reuse the Phase B inline-dialog
   shell — Enter on the container opens with a single `enterTrap()` (the iframe-slot
   is the **first** slot, so it lands there in **landing** mode, see §4);
   `onExit`/Escape closes — plus the §2 iframe `tabIndex` toggle on each open/close
   transition; `slot.detach()` + `controller.destroy()` on cleanup.

**The iframe-slot is the first slot.** `enterTrap()` now enters its first slot in
**landing** mode (it is a programmatic entry — see the `accessibility-tools` commit
`enterTrap enters a content slot in landing mode`). So opening the tile (an Enter
keydown, not a Tab) lands focus on the iframe-slot's **visible, labeled**
before-sentinel ("Press Tab to enter the interactive"), not silently on an invisible
one. This realizes the "Enter to go inside" tile semantics in a single call. The
`neighbor` slot is now ordinary demo chrome (a normal slot in the cycle), not a
positioner shim. Later re-entries into the iframe via live Tab use positioner mode.

The build-order cycle (`onExit` → controller → strategy → `slot`) is broken the
same way Phase B does it: construct the slot first, reference the
later-assigned `controller` through the effect closure.

### 4. Interaction the demo exercises

cycleOrder is `["content", "neighbor", "close"]` (iframe-slot first).

- **Open** (Enter on the container): a single `enterTrap()` lands on the **first**
  slot = the iframe-slot in **landing mode** — the **before-sentinel** becomes
  **visible + labeled** ("Press Tab to enter the interactive") and focus *rests* on
  it. The next Tab (live keydown) ⇒ **native descent** into the iframe's **first**
  control. This is the "Enter to go inside" tile semantics; the Enter→hint→Tab
  two-step is the inherent non-cooperating cost (C2's cooperating path collapses it).
- **Tab through the iframe** walks its controls natively; past the last, native Tab
  lands on the **after-sentinel** (now `tabindex 0` because `focusInsideIframe` is
  true) ⇒ sentinel `focusin` ⇒ `onExit(+1)` ⇒ `cycleToAdjacentSlot(+1)` ⇒ **neighbor**.
- **Cycling + re-entry (positioner):** Tab/Shift+Tab among `neighbor` and `Close`
  wrap normally. **Tab from Close → iframe** (forward wrap) and **Shift+Tab from
  neighbor → iframe** are live keydowns ⇒ **positioner mode** (silent, no hint):
  forward descends to the iframe's first control, reverse to its last. Shift+Tab past
  the iframe's first ⇒ before-sentinel `focusin` ⇒ `onExit(-1)` ⇒ wrap to **Close**.
  So the demo shows **landing** (on open) and **positioner** (on re-entry) both.
- **Exit:** Escape on a host slot, or activating **Close**, releases the trap
  (iframe → `tabIndex -1`, native traversal returns ⇒ "Host: After" is reachable).
  Escape *inside* the iframe is **not** observable (non-cooperating) — the user
  Tabs out to a host slot first. A `trap enabled` checkbox flips the whole
  mechanism off for the native baseline.

### 5. Landing-mode rendering

The host renders the static label text inside each sentinel; CSS reveals it only
when the library sets `[data-landing]` on that sentinel, and the sentinel is
zero-size/silent otherwise. (Exact label wording and SR phrasing are flagged for
the AP/testbed accessibility pass, not settled here.)

### 6. Observability & verification

- A monospace status line (extending Phase B's): `connected`, `iframeSrc`,
  `iframeOrigin`, `focusInsideIframe`, `lastEvent` (sentinel/cycle/open/close).
- **Manual-verification gate** (human, blocking): open → **landing** hint on the
  interactive → Tab descends into it; Tab through the iframe → after-sentinel →
  neighbor; cycle neighbor↔Close; re-enter the iframe by Tab from Close (forward
  positioner) and Shift+Tab from neighbor (reverse positioner) → native descent; Tab/
  Shift+Tab out → correct adjacent slot; Close/Escape release → native traversal
  returns and "Host: After" is reachable; `?interactive=` against another
  non-cooperating target (`testbed`/`linked-state`) behaves the same.

## Testing

No automated tests (consistent with the other example-interactive entries and with
the iframe-slot library's own out-of-repo browser verification — jsdom can't do
cross-iframe native Tab descent). Verification is the manual gate plus the
existing Node-14 webpack build. The implementation may use Chrome DevTools to
script the JS-observable parts (sentinel tabindex toggles, `focusInsideIframe`,
cycle callbacks) as a development aid.

## Findings (inline-pattern lessons for CLUE/CODAP)

These are the inline-tile integration lessons this testbed exists to surface:

- **The host owns the iframe's `tabIndex` across open/closed** (§2). The trap's
  tabindex sweep deliberately skips the iframe-slot, so an always-present (never
  "closed by removal") inline tile must set the iframe `-1` while not entered and
  `0` while entered, or a closed tile's iframe stays in the Tab order.
- **`enterTrap` enters its first slot in landing mode** (`accessibility-tools` fix
  landed before this work). `enterTrap` is a programmatic entry (no pending Tab
  default), so it had to stop using positioner mode for a content slot — otherwise a
  no-Tab open (Enter/click) onto an iframe-first tile rests silently on the invisible
  before-sentinel. With the fix, an inline tile **can** be entered directly onto its
  interactive with a visible "Press Tab to enter…" hint via a single `enterTrap()`,
  which is what C1 does (iframe-slot first). The live-Tab engage paths don't go
  through `enterTrap`, so positioner there is unaffected. (Before the fix, the host
  would have needed an `enterTrap()` + `cycleToAdjacentSlot(+1)` two-step or a
  host-chrome-first cycle.)

## Open questions / risks

- **Landing-label wording / SR announcement** — working text only; real-SR
  validation deferred to the AP/testbed accessibility pass.
- **Cross-browser native descent** is assumed from AP-108's macOS findings
  (Chrome/Firefox/Safari); this testbed is a place to re-confirm by hand.
- **Controller `focusin` auto-enter vs sentinel `focusin`** — the library spec
  flags verifying ordering when both fire; watch for it during the manual gate.
