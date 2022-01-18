import * as React from "react";
import { IReportItemInitInteractive } from "../../../interactive-api-client";
import { InitMessageInfoComponent } from "./init-message-info";

interface Props {
  initMessage: IReportItemInitInteractive;
}

export const SingleAnswerSummaryComponent: React.FC<Props> = (props) => {
  return (
    <div>
      <strong>Single Answer Summary</strong>
      <InitMessageInfoComponent initMessage={props.initMessage} />
    </div>
  );
};
