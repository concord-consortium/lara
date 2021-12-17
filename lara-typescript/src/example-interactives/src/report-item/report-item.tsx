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

      let html: string;
      if (view === "singleAnswer") {
        // "tall" html
        html = `
          <style>
            body {
              background-color: #f00;
              color: #fff;
            }
          </style>
          <div>
            <p>
              <strong>Interactive State Size</strong>: ${json.length}
            </p>
            <p>
              <strong>First 100 Bytes:</strong>: ${json.substr(0, 100)}
            </p>
          </div>`;
      } else {
        // short html
        html = `
          <style>
            body {
              background-color: #00f;
              color: #fff;
            }
          </style>
          <div>
            <strong>Interactive State Size</strong>: ${json.length} /
            <strong>First 20 Bytes:</strong>: ${json.substr(0, 20)}
          </div>`;
      }
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
