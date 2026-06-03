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
