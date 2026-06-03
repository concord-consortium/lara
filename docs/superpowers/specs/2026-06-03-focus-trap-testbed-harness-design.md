# Focus-trap testbed harness — design

**Jira**: [LARA-215](https://concord-consortium.atlassian.net/browse/LARA-215) — "iframe-slot library + non-nested testbed for focus protocol"
**Design source of truth**: [AP-108 focus-traps spec](../../../../activity-player/specs/AP-108-focus-traps-cross-origin-interactives.md) (if a discrepancy arises, AP-108 wins)
**Date**: 2026-06-03

## Summary

Build a manually-driven **testbed harness** in `lara-typescript/src/example-interactives/` that lets a developer
watch focus behavior across a **cross-origin iframe** and incrementally pull in the LARA-215 library work. The
harness is two new example-interactive entries:

- **`focus-host`** — a parent host page that embeds an interactive in a cross-origin iframe, with host-side
  focusable neighbors, focus sentinels around the iframe, and a focusable Close control.
- **`focus-interactive`** — a minimal cooperating demo interactive (a few focusable controls) that completes the
  init handshake and, in the final phase, speaks the focus-coordination protocol.

The harness is built in **three phases** so the *problem* (an existing single-document trap is iframe-blind) is
demonstrated before the *solution* (the new iframe-slot + cooperating API) is added.

## Scope

**In scope (this design):** the harness itself — the two new pages, how they are built/served, how they achieve a
cross-origin iframe locally, and the manual verification workflow. The three new library APIs the harness consumes
are treated as **black-box seams**: this design fixes only the *consumer-facing shape* the harness needs, not the
internals.

**Out of scope (separate specs / stories):**

- The internals of the `accessibility-tools` iframe-slot, the `interactive-api-host` `FocusManager`, and the
  `lara-interactive-api` focus message types. Each gets its own per-repo spec.
- Activity Player integration (separate AP story).
- A real cooperating interactive in `question-interactives` (separate QI story).
- Automated end-to-end tests (manual verification first; see [Verification](#verification)).
- The nested-host relay, focus ring, and host-configured key forwarding (deferred per AP-108 / out of scope per LARA-215).

## Locked decisions

| Decision | Choice | Rationale |
|---|---|---|
| Where the harness lives | `lara-typescript/src/example-interactives/` | Spec's stated home; `lara-interactive-api` and `interactive-api-host` are local source here, minimizing cross-repo links (only `accessibility-tools` is external). |
| Demo interactive | A **new minimal** cooperating interactive; an existing example is the non-cooperating case | Clean demo, no entanglement with the feature-rich existing `testbed` interactive. |
| Cross-origin locally | One `live-server`; host page on `localhost`, iframe `src` on `127.0.0.1` (different hosts → different origins) | True cross-origin with zero extra dev setup. |
| Trap composition | Imperative `FocusTrapController` (vanilla), **not** the `useFocusTrap` hook | `accessibility-tools` peers React `>=17`; lara-typescript is React 16. The controller has no React import, so it sidesteps a dispatcher mismatch. React is used only for page UI. |
| Verification | Manual first | Matches existing example-interactives (no tests today). Automated e2e can be a later story. |
| Harness style | "Faithful mini-AP" (Approach 1) | Mirrors AP's intended `iframe-runtime` division of labor; cheap scaffolding; doubles as the reference for the later AP integration. |

## Architecture & layout

The existing `exampleInteractive(name)` webpack pattern
([webpack.config.js](../../../lara-typescript/webpack.config.js)) maps one folder →
`src/example-interactives/src/<name>/index.tsx` → `dist/example-interactives/<name>/index.js`, and copies
`<name>/index.html`. Each entry is registered in the `module.exports` array.

```
src/example-interactives/src/
  focus-host/            NEW: parent host page (React)
    index.html
    index.tsx
  focus-interactive/     NEW: minimal cooperating demo interactive (React)
    index.html
    index.tsx
  testbed/  linked-state/  ...   UNCHANGED; one serves as the non-cooperating iframe target
```

Both new entries are added to the webpack `module.exports` array and to the example-interactives
`index.html` link list.

**Cross-origin wiring.** The host page is opened at `http://localhost:8888/focus-host/index.html`. It derives the
iframe origin by swapping its own host to `127.0.0.1` and sets
`iframe.src = http://127.0.0.1:8888/focus-interactive/index.html`. `localhost` and `127.0.0.1` are distinct hosts,
so the browser treats them as different origins for same-origin-policy / `postMessage` purposes. `iframe-phone`'s
`ParentEndpoint` works cross-origin.

**Dependency.** `@concord-consortium/accessibility-tools` is added to `lara-typescript/package.json`. During
development it is `npm link`/`yalc`-ed (we co-develop the iframe-slot). Example-interactives build with **no
externals**, so it is bundled into the `focus-host` bundle. It is consumed as built `dist/` output (the link/yalc
loop must rebuild it).

## Host page composition (`focus-host/index.tsx`)

DOM the host renders, inside one trap container:

```
[ neighbor button "Before" ]      plain host focusable
[ before-sentinel ]   ┐
[ <iframe> ]          │  iframe-slot region (host renders DOM; a11y owns behavior in Phase C)
[ after-sentinel ]    ┘
[ host "Close" control ]          focusable; the non-cooperating escape hatch (per AP-108)
[ neighbor button "After" ]       plain host focusable
```

Neighbors make Tab cycling (host → iframe → host) observable. The Close control is the spec-mandated keyboard exit
for the non-cooperating path.

Wiring (imperative; the trap is not React-driven):

1. `iframePhone.ParentEndpoint(iframeEl, onReady)` — the transport, pointed cross-origin at `127.0.0.1`.
2. The host tracks `focusInsideIframe` from the iframe element's `focus`/`blur` and toggles sentinel tabbability on
   that transition (host owns this DOM behavior, per AP-108). In Phase A/B this is hand-rolled; in Phase C the
   iframe-slot takes it over.
3. `new FocusTrapController(container, strategy)` (from `accessibility-tools`) wraps the container. In Phase C the
   strategy registers the iframe as an **iframe-slot** (the new API): host passes `{ iframe, beforeSentinel,
   afterSentinel }` refs plus a transport.
4. `new FocusManager(...)` (from `interactive-api-host`) wraps the phone and is supplied as the iframe-slot's
   transport in Phase C: it dispatches inbound `focusExit`/capability to host callbacks and sends
   `focusEnter`/`restore`.

**Page controls** (read-only / demo aids): a trap on/off toggle (`controller.setEnabled`), a target switcher
(cooperating demo `@127.0.0.1` vs. a non-cooperating existing example), and a status readout showing the
capability-handshake result, `focusInsideIframe`, and the last protocol message.

## Demo interactive (`focus-interactive/index.tsx`)

A minimal React interactive:

- 2–3 focusable controls (buttons / inputs) with a visible focus style.
- Completes the init handshake via the existing `lara-interactive-api` client (`useInitMessage`), so Phases A and B
  have a live cross-origin interactive to embed.
- In Phase C: declares `focusProtocol`, focuses its first / last / last-focused element on
  `focusEnter { forward | reverse | restore }`, and sends `focusExit { forward | reverse | escape }` at its Tab
  boundaries / on Escape.

**Non-cooperating target.** An existing example interactive (e.g. `testbed` or `linked-state`) pointed at
`127.0.0.1`; it never speaks the protocol, exercising the non-cooperating path with no extra code.

## Build phasing

**Phase A — Baseline, no trap, no new libraries.**
Host renders neighbors + sentinels (static/inert) + iframe + Close; embeds the cross-origin iframe via raw
`iframePhone.ParentEndpoint`; hand-tracks and logs `focusInsideIframe`. No trap, no `FocusManager`, no
`accessibility-tools`. Demo interactive completes init; no protocol.
*Observe:* native cross-origin Tab / Shift+Tab traversal, the `focus`/`blur` signal fidelity, and where focus lands
— reproducing or falsifying the AP-108 matrix on our setup.
*Deps:* `iframe-phone` + local `lara-interactive-api`. Nothing linked.

**Phase B — Existing `accessibility-tools` trap around the iframe (no new features).**
Wrap the host container in today's `FocusTrapController`, with the iframe as an ordinary slot/element.
*Observe:* the iframe-blind misbehavior — `setChildrenNonTabbable` treats the iframe as a normal descendant; the
keydown listener never sees Tab inside the iframe; `findNextFocusableOutside` is same-document only — so cycling
around the iframe breaks. This is the **motivating failure** that justifies the new work.
*Bonus:* shakes out the build-integration risks (below) against the *unmodified* package before we change it.
*Deps:* adds the `accessibility-tools` link at its current version; no new accessibility-tools code.

**Phase C — New features: cooperating protocol + iframe-slot + FocusManager.**
Replace hand-rolled / blind behavior with the new iframe-slot (sentinels + `focusInsideIframe`-driven cycling), the
`lara-interactive-api` focus messages + `focusProtocol` flag, and the `interactive-api-host` `FocusManager` as the
slot transport. Internally sub-stageable: non-cooperating sentinels first, then the cooperating transport.
*Deps:* local `interactive-api-host` (FocusManager) + linked `accessibility-tools` (new iframe-slot) + local
`lara-interactive-api` (focus messages).

## Integration seams (black-box APIs this design pins down)

Each is fully designed in its own repo's spec; the harness fixes only the consumer-facing shape it needs.

- **`accessibility-tools`** — an **iframe-slot** registration on `FocusTrapStrategy` that accepts iframe + before/after
  sentinel refs and an injected transport (`send` / `onMessage`), is excluded from `setChildrenNonTabbable`
  (self-managing, like `tabHandlers` slots), and drives sentinel-`focusin` cycling via `FocusTrapResult`.
- **`interactive-api-host`** — a **`FocusManager`** following the `PubSubManager` / `JobManager` idiom: constructed
  around an iframe-phone endpoint, dispatches inbound `focusExit` / capability messages to host callbacks, and sends
  `focusEnter` / `restore`.
- **`lara-interactive-api`** — the typed focus messages (`focusEnter`, `focusExit`, optional `trapStateChanged` /
  `focusReady`) and the `focusProtocol` capability flag on `supportedFeatures`.

## Dev workflow & verification

Established constraints: build/run on **Node 14**; install with `npm ci --legacy-peer-deps` (the toolchain predates
strict peer resolution; CI uses the npm bundled with old Node).

1. `cd lara-typescript`
2. `npm run build:dev:lara-typescript` (or `npm run build:webpack` / `build:watch`) — rebuilds the bundles; example
   interactives are **not** auto-rebuilt on change.
3. `npm run example-interactives` — serves `dist/example-interactives/` on port 8888.
4. Open `http://localhost:8888/focus-host/index.html`. The host sets the iframe to
   `http://127.0.0.1:8888/focus-interactive/index.html`.

Unlike the existing example-interactives workflow ([docs/example-interactives.md](../../example-interactives.md)),
the harness is **self-hosting** — it does not require running LARA (`docker-compose`) to embed the interactive.

**Verification:** manual, per phase — Tab / Shift+Tab / Escape through the page and watch focus and the status
readout. Phase A: native traversal matches expectations. Phase B: the trap visibly mishandles the iframe. Phase C:
non-cooperating Tab-exit recovers via sentinels and the Close control works; cooperating forward/reverse/restore and
Escape-to-exit work.

**Manual verification is a hard gate between phases — not optional, not skippable.** Each phase ends with a STOP:
the implementer hands off to the human, who performs the manual checks above and explicitly confirms before any work
on the next phase begins. Do **not** chain phases together, and do **not** treat "code compiles / builds" as a
substitute for the manual check. The whole point of the phasing is to *observe* focus behavior with human eyes at
each step (native → blind-trap failure → fixed); skipping a checkpoint defeats the design. The implementation plan
must encode each checkpoint as an explicit, blocking step assigned to the human.

## Risks & open questions

- **ESM / `exports` under webpack 4.** `accessibility-tools` is `"type": "module"` with an `exports` map; webpack 4's
  resolver handles `exports` only partially. May require a `resolve.alias` to its `dist/`. Surfaces in Phase B.
- **React peer mismatch.** Mitigated by using the vanilla `FocusTrapController`; confirmed it has no React import.
  Watch for transitive React pulled via `accessibility-tools` during bundling.
- **link/yalc rebuild loop.** `accessibility-tools` is consumed as built `dist/`; changes require rebuilding it
  before the harness picks them up.
- **Capability-detection timing.** The iframe loads asynchronously; the harness must behave as non-cooperating until
  `focusProtocol` is declared, and adapt if it arrives later (mirrors an AP-108 open question).
- **Non-cooperating target choice.** Confirm a chosen existing example (`testbed` / `linked-state`) has usable
  focusable content for the non-cooperating demo; otherwise add a trivial static page.

## References

- [AP-108 focus-traps spec](../../../../activity-player/specs/AP-108-focus-traps-cross-origin-interactives.md) — design source of truth.
- [docs/example-interactives.md](../../example-interactives.md) — existing example-interactives workflow.
- `question-interactives` `wrapper` package — a ~32-line iframe + `ParentEndpoint` host harness; the pattern the host page follows.
- `accessibility-tools` `src/hooks/` — `FocusTrapController`, `FocusTrapStrategy`, `FocusTrapResult`; `docs/trap-composition.md` (single-document limits / slot patterns).
