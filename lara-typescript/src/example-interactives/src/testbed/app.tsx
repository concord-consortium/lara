import * as React from "react";
import { useEffect } from "react";

import { useInitMessage, setSupportedFeatures, useAutoSetHeight  } from "../../../interactive-api-client";
import { AuthoringComponent } from "./authoring";
import { ReportComponent } from "./report";
import { RuntimeComponent } from "./runtime";
import { IAuthoredState } from "../types";

interface Props {
}

export const AppComponent: React.FC<Props> = (props) => {
  const initMessage = useInitMessage<{}, IAuthoredState>();

  useAutoSetHeight();

  useEffect(() => {
    if (initMessage) {
      setSupportedFeatures({
        authoredState: true,
        interactiveState: true
      });
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
