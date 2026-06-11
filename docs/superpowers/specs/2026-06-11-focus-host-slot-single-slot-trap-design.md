# focus-host-slot Single-Slot Trap Demo — Design

**Date:** 2026-06-11
**Ticket:** LARA-215 (focus-trap testbed)
**Branch / PR:** `LARA-215-focus-testbed` / PR #1260 (additive commits)
**Status:** Approved (brainstorm) — ready for implementation plan

## Goal

Add a **single-slot (iframe-only) focus trap** to the `focus-host-slot` example-interactive
so we can reproduce, and later verify a fix for, the Activity Player (AP) scenario where a
focus-trap dialog has **no host chrome** (no close button) and the iframe-slot is the only
slot in the trap.

The page will host **two traps**, both embedding the same interactive (driven by the existing
`?interactive=` override):

- **Trap 1 — full host chrome** (existing behavior): cycle = `content → neighbor → close → restore`.
- **Trap 2 — single-slot** (new): cycle = `content` only.

The single-slot trap exercises the wrap path: tabbing forward out of the iframe wraps back to
the iframe's **own** entering sentinel. That is the path that currently fails to switch the
entering sentinel into landing mode.

## Non-goal

This change does **not** fix the underlying bug in `@concord-consortium/accessibility-tools`.
It only makes the bug observable in the testbed and provides a place to confirm a future fix.
The suspected root cause is recorded below for follow-up.

## Background: the bug being reproduced

In a single-slot trap (only the iframe-slot has content), when focus tabs forward out of the
iframe:

1. The after-sentinel's `focusin` fires the IframeSlot's `onExit(+1)`, which calls
   `controller.cycleToAdjacentSlot(+1)`.
2. `findNextSlot` skips empty slots; with only `content` populated it returns the same slot,
   so the controller re-enters `content`.
3. The entering (before-)sentinel ends up in **positioner mode** (silent, `clearLanding()`,
   invisible sentinel) instead of **landing mode** (`data-landing` set, the visible
   "Press Tab to enter the interactive" hint). Focus appears stuck on an invisible sentinel
   with no affordance to continue.

The expected behavior is that wrapping back to a single nativeTabSlot lands in **landing mode**
so the user sees the hint and can Tab in (non-cooperating), or is re-placed precisely
(cooperating). Reference: `accessibility-tools/src/hooks/` —
`focus-trap-controller.ts` (`cycleToAdjacentSlot`, `focusSlot`, the nativeTabSlot Tab handler)
and `iframe-slot.ts` (`focusContent`, sentinel `data-landing`/tabindex logic).

This is suspected to require a fix in `accessibility-tools`, not in the testbed.

## Architecture

Extract the per-trap logic out of `focus-host-slot/host.tsx` into a reusable component so the
two traps run identical logic and differ only by which slots they include.

### New file: `focus-host-slot/focus-tile.tsx`

Exports `<FocusTile>`, which owns everything for **one** trap:

- Refs: container, wrapper (iframe-slot content), iframe, before/after sentinels, and the
  host-chrome button refs it uses (`neighbor`, `close`, `restore`).
- Its own iframe-phone `ParentEndpoint` + `FocusManager`, `IframeSlot`, `FocusTrapController`,
  and `strategy`.
- Its own per-tile state and status line: `connected`, `cooperating`, `focusInsideIframe`,
  `lastEvent`, plus the landing-state readout (see Observability).
- The Enter-to-open tile model, `setIframeEnterable` open/closed iframe-tabindex handling,
  cooperating escape (`onRequestExit`), restore wiring, capability subscription, the
  dismiss-when-focus-leaves-tile behavior, and full cleanup — exactly as Trap 1 does today.

Props (the only things that differ between tiles):

```ts
interface FocusTileProps {
  title: string;
  iframeSrc: string;
  iframeOrigin: string;
  slots: Array<"content" | "neighbor" | "close" | "restore">;
}
```

- `slots` drives both `cycleOrder` and which chrome buttons render.
- `content` is always present; it is the `contentSlot` and the sole `nativeTabSlot`.
- `getElements` returns only the refs for the slots in `slots` (others omitted/undefined).
- Trap 1 passes `["content","neighbor","close","restore"]`; the single-slot trap passes
  `["content"]` and renders no chrome buttons.

### `host.tsx` becomes a thin page shell

- Keeps the cross-origin host map (`HOST_MAP`/`otherHost`) and the examples-root path logic;
  computes `iframeSrc`/`iframeOrigin` once (shared by both tiles), reads `?interactive=`.
- Renders the page heading + instructional copy (updated to describe the two traps).
- Renders the two tiles:

```tsx
<FocusTile
  title="Trap 1 — full host chrome"
  slots={["content", "neighbor", "close", "restore"]}
  iframeSrc={iframeSrc}
  iframeOrigin={iframeOrigin}
/>
<FocusTile
  title="Trap 2 — single-slot (iframe only, no host chrome)"
  slots={["content"]}
  iframeSrc={iframeSrc}
  iframeOrigin={iframeOrigin}
/>
```

Both tiles instantiate independent iframes/phones of the same interactive URL; they connect
and advertise capability independently. 2 iframes total.

## Interaction model

Both tiles use the same Enter-to-open tile model (consistent page behavior; gives a keyboard
way into each trap). What differs is what happens **inside** the single-slot trap:

- **Open:** Tab to the tile (a single Tab stop), press Enter → enters the trap. Cooperating
  embed lands precisely via `focusEnter`; non-cooperating shows the landing hint — same as
  Trap 1.
- **Tab forward out of the iframe:** after-sentinel `onExit(+1)` → `cycleToAdjacentSlot(+1)` →
  with only `content` in the cycle, re-enters `content`. This is the wrap path under test.
- **Getting out:**
  - *Cooperating:* Escape inside the iframe → `focusExit{escape}` → `exitTrap`. Expected to
    work.
  - *Non-cooperating:* no Escape protocol → keyboard-only focus is stuck inside (clicking an
    outside element still dismisses via the existing focus-leaves-tile handler). This is the
    bug, made visible.

The demo applies no special-casing; it lets the real library behavior show through.

## Observability

Each tile's status line gains one readout: the **entering sentinel's landing state**, so the
"stuck" condition is visible and screenshot-able and a future fix has a concrete pass/fail
signal.

Format (appended to the existing status line):

```
landing: data-landing=<yes|no> | activeEl=<before-sentinel|after-sentinel|iframe|other>
```

- **Landing (correct):** focus on the entering sentinel with `data-landing` present and the
  visible hint shown → `landing: data-landing=yes`.
- **Bug (single-slot wrap):** focus on the before-sentinel but `data-landing` absent and no
  hint visible → `landing: data-landing=no, activeEl=before-sentinel`.

Implementation: read-only observation in the tile — on `focusin` (and/or a `MutationObserver`
on the before-sentinel's `data-landing`), update the readout from the live DOM. This does not
change library behavior; it only surfaces it. The existing `lastEvent` trail
(`sentinel exit +1 -> cycle`, capability, escape, restore, etc.) is preserved.

## Files

**Create:**
- `lara-typescript/src/example-interactives/src/focus-host-slot/focus-tile.tsx` — the shared
  `<FocusTile>` component (per-trap logic, extracted from the current host).

**Modify:**
- `lara-typescript/src/example-interactives/src/focus-host-slot/host.tsx` — reduce to the page
  shell; compute shared `iframeSrc`/`iframeOrigin`; render two `<FocusTile>`s; update heading +
  instructions.

No new webpack entry, index.html, or example link (same page, same entry).

## Testing & verification

Consistent with `example-interactives`, there are no unit tests (browser-only UI). Verification:

1. **Build + lint clean** — `npm run build`; tslint on `focus-tile.tsx` and `host.tsx`.
2. **Regression — Trap 1 unchanged:** re-run the Phase C2 manual gate on Trap 1 (cooperating
   handshake, Enter precise entry, Escape exit, restore) to confirm the extraction preserved
   behavior exactly.
3. **Single-slot — cooperating** (default embed), via Chrome DevTools event/landing-state
   capture: Enter enters the iframe; Tab forward out wraps; Escape inside exits cleanly.
4. **Single-slot — non-cooperating** (`?interactive=<plain interactive on the S3 origin>`):
   Enter shows the landing hint; Tab forward out wraps and the readout shows
   `landing: data-landing=no, activeEl=before-sentinel` — the bug, captured.
5. **Deployed cross-origin sanity** (CloudFront ⇄ S3): both tiles connect after the branch
   redeploys.

The landing-state readout is the concrete signal a future `accessibility-tools` fix can be
checked against (`data-landing=yes` after the single-slot wrap).

## Follow-up (out of scope here)

File/track an `accessibility-tools` fix so that wrapping back to a single nativeTabSlot honors
landing mode regardless of whether the wrap was driven by a real Tab keydown or a programmatic
cycle. This testbed change is what verifies that fix.
