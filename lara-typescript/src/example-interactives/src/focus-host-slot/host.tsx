import * as React from "react";
import { FocusTile, SlotName } from "./focus-tile";

// Cross-origin trick (same as the focus-host demo): the host page is opened on one
// host name; the iframe is pointed at the other. The two hosts are different origins
// for same-origin-policy / postMessage purposes, so this yields a real cross-origin
// iframe from a single source. localhost/127.0.0.1 cover the local dev server; the
// models-resources CloudFront domain pairs with its direct S3 URL (both front the
// same bucket) so the deployed testbed is also self-demonstrating. Unknown hosts fall
// back to themselves (same-origin) rather than a broken guess.
const HOST_MAP: Record<string, string> = {
  "localhost": "127.0.0.1",
  "127.0.0.1": "localhost",
  "models-resources.concord.org": "models-resources.s3.amazonaws.com",
  "models-resources.s3.amazonaws.com": "models-resources.concord.org"
};
const otherHost = (hostname: string) => HOST_MAP[hostname] ?? hostname;
// Parse the origin of a `?interactive=` override. Returns undefined for a missing or
// invalid value so callers fall back to the default cross-origin embed rather than
// letting `new URL(...)` throw and white-screen the testbed on a typo'd override.
const overrideOrigin = (src: string | undefined): string | undefined => {
  if (!src) {
    return undefined;
  }
  try {
    return new URL(src).origin;
  } catch {
    console.warn(`Ignoring invalid ?interactive= override: ${src}`);
    return undefined;
  }
};
// Relative to the examples root (the host page and the interactives are sibling
// folders). Kept path-prefix-relative so the embed resolves both locally (served at
// "/") and deployed under a prefix like "/lara-example-interactives/branch/<name>/".
// The default embed is the cooperating interactive; the non-cooperating one is the
// fallback target reachable via the toggle link below (and via ?interactive=).
const COOP_INTERACTIVE_PATH = "focus-interactive-coop/index.html";
const NONCOOP_INTERACTIVE_PATH = "focus-interactive/index.html";

// Stable arrays (module-level) so passing them as props doesn't re-create the tiles'
// trap effects on every render.
const FULL_SLOTS: SlotName[] = ["content", "neighbor", "close", "restore"];
const SINGLE_SLOTS: SlotName[] = ["content"];

export const HostComponent: React.FC = () => {
  // Allow overriding the embedded interactive with a full URL via the
  // `?interactive=<url>` query param. Default embed is focus-interactive-coop, which
  // speaks the focus protocol => cooperating path; point `?interactive=` at a plain
  // interactive (on the OTHER origin) for the non-cooperating fallback.
  const { protocol, hostname, port } = window.location;
  const defaultOrigin = `${protocol}//${otherHost(hostname)}${port ? ":" + port : ""}`;
  const pageDir = window.location.pathname.replace(/[^/]+$/, "");
  const examplesRoot = pageDir.replace(/[^/]+\/$/, "");
  const rawOverride = new URLSearchParams(window.location.search).get("interactive") || undefined;
  // An invalid override yields no origin => ignore it and use the default embed.
  const parsedOrigin = overrideOrigin(rawOverride);
  const overrideSrc = parsedOrigin ? rawOverride : undefined;
  const iframeSrc = overrideSrc ?? `${defaultOrigin}${examplesRoot}${COOP_INTERACTIVE_PATH}`;
  const iframeOrigin = parsedOrigin ?? defaultOrigin;

  // Cooperating/non-cooperating toggle. The default (no override, or an override that
  // points at the coop interactive) is the cooperating path; anything else is treated
  // as non-cooperating. We offer a single link to the OTHER one. Both the coop and
  // non-coop targets are resolved on `defaultOrigin` (the other host), so the link
  // keeps the cross-origin demo wherever a HOST_MAP pair exists (localhost<->127.0.0.1
  // locally, CloudFront<->S3 deployed). Served from the lara docker container there is
  // no cross-domain pair, so otherHost() falls back to the same host and the embed is
  // same-origin — the toggle still switches interactives, just same-origin.
  const isCoop = !overrideSrc || overrideSrc.indexOf(COOP_INTERACTIVE_PATH) !== -1;
  const nonCoopSrc = `${defaultOrigin}${examplesRoot}${NONCOOP_INTERACTIVE_PATH}`;
  const switchParams = new URLSearchParams(window.location.search);
  if (isCoop) {
    switchParams.set("interactive", nonCoopSrc);
  } else {
    switchParams.delete("interactive");
  }
  const switchQuery = switchParams.toString();
  const switchHref = switchQuery ? `${window.location.pathname}?${switchQuery}` : window.location.pathname;

  return (
    <div style={{ padding: 16 }}>
      {/* Landing reveal: the sentinels are visually-hidden but focusable; the
          library sets [data-show-hint] on one of them in landing mode, which reveals
          the static hint text. Rendered once for the whole page. */}
      <style>{`
        .iframe-sentinel {
          position: absolute;
          width: 1px;
          height: 1px;
          overflow: hidden;
          clip: rect(0 0 0 0);
          white-space: nowrap;
        }
        .iframe-sentinel[data-show-hint] {
          position: static;
          width: auto;
          height: auto;
          overflow: visible;
          clip: auto;
          white-space: normal;
          display: inline-block;
          padding: 2px 6px;
          background: #ffe;
          border: 1px dashed #888;
          font-style: italic;
        }
      `}</style>

      <h1>focus-host-slot (iframe-slot, capability-aware)</h1>
      <div style={{ fontFamily: "monospace", marginBottom: 12 }}>
        iframeSrc: {iframeSrc} | iframeOrigin: {iframeOrigin}
      </div>
      <div style={{ marginBottom: 12 }}>
        Embed: <strong>{isCoop ? "cooperating" : "non-cooperating"}</strong>{" "}
        ({isCoop ? COOP_INTERACTIVE_PATH : NONCOOP_INTERACTIVE_PATH}) —{" "}
        <a href={switchHref}>switch to {isCoop ? "non-cooperating" : "cooperating"}</a>
      </div>
      <p style={{ marginTop: 0, marginBottom: 8, fontStyle: "italic" }}>
        Each green tile is a single Tab stop: Tab moves past it without entering. Press
        Enter on it to go inside. Both tiles embed the same interactive (default
        focus-interactive-coop, cooperating; override with <code>?interactive=</code> a
        plain interactive on the other origin for the non-cooperating fallback).
        <strong> Trap 1</strong> has host-chrome slots (neighbor / close / restore).
        <strong> Trap 2</strong> is single-slot: the iframe is the ONLY slot, mirroring
        an Activity Player dialog with no close button. In Trap 2, Tabbing forward out
        of the iframe wraps back to the iframe's own entering sentinel — watch the
        <code>landing</code> readout: <code>data-show-hint=yes</code> means the "Press Tab
        to enter" hint is shown (correct); <code>data-show-hint=no</code> while focus is
        on the before-sentinel is the stuck-on-invisible-sentinel case. Uncheck "trap
        enabled" on a tile for its native (no-trap) baseline.
      </p>

      <FocusTile
        title="Trap 1 — full host chrome"
        slots={FULL_SLOTS}
        iframeSrc={iframeSrc}
        iframeOrigin={iframeOrigin}
      />
      <FocusTile
        title="Trap 2 — single-slot (iframe only, no host chrome)"
        slots={SINGLE_SLOTS}
        iframeSrc={iframeSrc}
        iframeOrigin={iframeOrigin}
      />
    </div>
  );
};
