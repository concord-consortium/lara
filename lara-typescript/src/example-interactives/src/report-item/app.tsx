import * as React from "react";

import { useInitMessage, useAutoSetHeight } from "../../../interactive-api-client";
import { IReportItemInitInteractive } from "../../../interactive-api-client";
import { ReportItemComponent } from "./report-item";

interface Props {
}

export const AppComponent: React.FC<Props> = (props) => {
  const initMessage = useInitMessage<IReportItemInitInteractive<{}, {}>, {}>();

  useAutoSetHeight();

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
