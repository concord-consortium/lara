import * as React from "react";
import { useEffect, useState } from "react";
import { IReportItemInitInteractive,
         addGetStudentHTMLListener,
         sendStudentHTML } from "../../../interactive-api-client";
import { getClient } from "../../../interactive-api-client/client";
import { MultipleAnswerSummaryComponent } from "./multiple-answer-summary";
import { SingleAnswerSummaryComponent } from "./single-answer-summary";

interface Props {
  initMessage: IReportItemInitInteractive;
}

export const ReportItemComponent: React.FC<Props> = (props) => {
  const {initMessage} = props;
  const {students, view} = initMessage;
  const [studentAnswers, setStudentAnswers] = useState<Record<string, any>>({});

  useEffect(() => {
    addGetStudentHTMLListener((request) => {
      const {studentId, interactiveState} = request;
      const json = JSON.stringify(interactiveState);
      setStudentAnswers(prev => ({...prev, [studentId]: interactiveState}));

      const html = `
        <div class="tall">
          <h1>TALL REPORT HERE...</h1>
          <p>
          <strong>Interactive State Size</strong>: ${json.length}
        </div>
        <div class="wide">
          <h1>WIDE REPORT HERE...</h1>
          <p>
          <strong>Interactive State Size</strong>: ${json.length}
        </div>
      `;
      sendStudentHTML({studentId, html});
    });

    // tell the portal-report we are ready for messages
    getClient().post("reportItemClientReady");
  }, []);

  return (
    <div className={`reportItem ${view}`}>
      {view === "singleAnswer"
        ? <SingleAnswerSummaryComponent initMessage={initMessage} />
        : <MultipleAnswerSummaryComponent initMessage={initMessage} />
      }
    </div>
  );
};
