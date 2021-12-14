import * as React from "react";
const { useEffect } = React;
import ResizeObserver from "resize-observer-polyfill";

import { useInitMessage, setSupportedFeatures, setHeight } from "../../../interactive-api-client";
import { IReportItemInitInteractive } from "../../../interactive-api-client";
import { ReportItemComponent } from "./report-item";

interface Props {
}

export const AppComponent: React.FC<Props> = (props) => {
  const initMessage = useInitMessage<IReportItemInitInteractive<{}, {}>, {}>();

  // TODO: this should really be moved into a client hook file so it can be reused
  useEffect(() => {
    if (initMessage) {
      const body = document.getElementsByTagName("BODY")[0];
      const updateHeight = () => {
        if (body && body.clientHeight) {
          setHeight(body.clientHeight);
        }
      };
      const observer = new ResizeObserver(() => updateHeight());
      if (body) {
        observer.observe(body);
      }
      return () => observer.disconnect();
    }
  }, [initMessage]);

  /*

  REMOVE?

  useEffect(() => {
    if (initMessage) {
      setSupportedFeatures({
        authoredState: true,
        interactiveState: true
      });
    }
  }, [initMessage]);
  */

  if (!initMessage) {
    return (
      <div className="centered">
        <div className="progress">
          Loading...
        </div>
      </div>
    );
  }

  if (initMessage.mode !== "reportItem") {
    return (
      <div>
        <h1>Oops!</h1>
        <p>
        ¯\_(ツ)_/¯
        </p>
        <p>
          This interactive is only available in 'reportItem' mode but '{initMessage.mode}' was given.
        </p>
      </div>
    );
  }

  return <ReportItemComponent initMessage={initMessage} />;
};
