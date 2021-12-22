import * as React from "react";
const { useEffect } = React;

import { useInitMessage, setSupportedFeatures, useAutoSetHeight, useSetSupportedFeatures } from "../../../interactive-api-client";
import { AuthoringComponent } from "./authoring";
import { ReportComponent } from "./report";
import { RuntimeComponent } from "./runtime";
import { IAuthoredState } from "../types";

interface Props {
}

export const AppComponent: React.FC<Props> = (props) => {
  const initMessage = useInitMessage<{}, IAuthoredState>();

  useAutoSetHeight();
  useSetSupportedFeatures({
    authoredState: true,
    interactiveState: true
  });

  if (!initMessage) {
    return (
      <div className="centered">
        <div className="progress">
          Loading...
        </div>
      </div>
    );
  }

  switch (initMessage.mode) {
    case "authoring":
      return <AuthoringComponent initMessage={initMessage} />;
    case "report":
      return <ReportComponent initMessage={initMessage} />;
    case "runtime":
      return <RuntimeComponent initMessage={initMessage} />;
    case "reportItem":
      return <div>The "reportItem" mode is not implemented in this example interactive</div>;
  }
};
