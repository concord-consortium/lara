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
      const body = document.body;
      const html = document.documentElement;
      const updateHeight = () => {
        setHeight(Math.max(body.scrollHeight, body.offsetHeight,
                           html.clientHeight, html.scrollHeight, html.offsetHeight));
      };
      const observer = new ResizeObserver(() => updateHeight());
      if (body) {
        observer.observe(body);
      }
      return () => observer.disconnect();
    }
  }, [initMessage]);

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
