import * as React from "react";
import { useEffect, useRef } from "react";
import {
  useInitMessage,
  setSupportedFeatures,
  useAutoSetHeight,
  addFocusEnterListener,
  removeFocusEnterListener,
  sendFocusExit,
  showModal,
  closeModal
} from "../../../interactive-api-client";

// Phase C2 cooperating interactive: advertises focusProtocol, places entry focus
// precisely on focusEnter{forward|reverse|restore}, tracks its last-focused control
// for restore, and forwards Escape as focusExit{escape}. It does NOT trap Tab
// internally (forward/reverse exit still flows out through the host's sentinels),
// so it never sends focusExit{forward|reverse} — that is a later phase.
export const AppComponent: React.FC = () => {
  const initMessage = useInitMessage();
  const firstRef = useRef<HTMLButtonElement>(null);
  const lastRef = useRef<HTMLButtonElement>(null);
  // The most recently focused control inside this interactive, for restore.
  const lastFocusedRef = useRef<HTMLElement | null>(null);

  useAutoSetHeight();

  useEffect(() => {
    if (initMessage) {
      setSupportedFeatures({ interactiveState: true, focusProtocol: true });
    }
  }, [initMessage]);

  useEffect(() => {
    // Place entry focus where the host's focusEnter says to.
    addFocusEnterListener(mode => {
      if (mode === "reverse") {
        lastRef.current?.focus();
      } else if (mode === "restore") {
        (lastFocusedRef.current ?? firstRef.current)?.focus();
      } else {
        firstRef.current?.focus();
      }
    });
    return () => { removeFocusEnterListener(); };
  }, []);

  useEffect(() => {
    // Track last-focused control (for restore).
    const onFocusIn = (e: FocusEvent) => {
      const target = e.target as HTMLElement | null;
      if (target && target !== document.body) {
        lastFocusedRef.current = target;
      }
    };
    // Forward Escape as a cooperating exit. A real widget that consumes Escape
    // would NOT forward here (suppression is the interactive's responsibility);
    // this simple demo always forwards.
    const onKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        sendFocusExit("escape");
      }
    };
    document.addEventListener("focusin", onFocusIn);
    document.addEventListener("keydown", onKeyDown);
    return () => {
      document.removeEventListener("focusin", onFocusIn);
      document.removeEventListener("keydown", onKeyDown);
    };
  }, []);

  // Open a host dialog (lara-interactive-api `showModal` type "dialog") to THIS same
  // interactive URL. In the Activity Player this opens the cooperating interactive
  // inside an AP focus-trap modal — the image-question shape we want to test. In the
  // example-interactives testbed the embedding host does not handle showModal, so the
  // button is inert there; this is meant to be loaded as a real interactive in AP.
  const openDialog = () => showModal({ type: "dialog", url: window.location.href });
  // notCloseable disables the AP-provided X icon and click-to-close backdrop, so the
  // ONLY way out is the interactive's own UI (the "Close dialog" button / closeModal,
  // or a cooperating Escape). This is the no-host-chrome focus-trap case.
  const openDialogNoClose = () =>
    showModal({ type: "dialog", url: window.location.href, notCloseable: true });
  const closeDialog = () => closeModal({});

  if (!initMessage) {
    return (
      <div className="centered">
        <div className="progress">Loading...</div>
      </div>
    );
  }

  return (
    <div style={{ padding: 16, border: "3px solid teal" }}>
      <h2>focus-interactive-coop</h2>
      <p>mode: {initMessage.mode} — speaks the focus protocol (focusProtocol: true)</p>
      <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
        <button ref={firstRef} type="button">Coop button 1 (first)</button>
        <input type="text" aria-label="Coop field" placeholder="Coop field" />
        <button ref={lastRef} type="button">Coop button 2 (last)</button>
      </div>
      <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginTop: 12 }}>
        <button type="button" onClick={openDialog}>Open dialog to self</button>
        <button type="button" onClick={openDialogNoClose}>Open dialog (no close button)</button>
        <button type="button" onClick={closeDialog}>Close dialog</button>
      </div>
    </div>
  );
};
