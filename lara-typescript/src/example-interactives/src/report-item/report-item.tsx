import * as React from "react";
import { IReportItemInitInteractive } from "../../../interactive-api-client";

interface Props {
  initMessage: IReportItemInitInteractive;
}

export const ReportItemComponent: React.FC<Props> = ({initMessage}) => {
  return (
    <div className="padded">
      <fieldset>
        <legend>Report Item Init Message</legend>
        <div className="padded monospace pre">{JSON.stringify(initMessage, null, 2)}</div>
      </fieldset>
    </div>
  );
};
