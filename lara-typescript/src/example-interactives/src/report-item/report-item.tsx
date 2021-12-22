import * as React from "react";
import { useEffect, useState } from "react";
import { IReportItemInitInteractive,
         addGetReportItemAnswerListener,
         sendReportItemAnswer } from "../../../interactive-api-client";
import { getClient } from "../../../interactive-api-client/client";
import { MultipleAnswerSummaryComponent } from "./multiple-answer-summary";
import { SingleAnswerSummaryComponent } from "./single-answer-summary";

interface Props {
  initMessage: IReportItemInitInteractive;
}

export const ReportItemComponent: React.FC<Props> = (props) => {
  const {initMessage} = props;
  const {users, view} = initMessage;
  const [userAnswers, setUserAnswers] = useState<Record<string, any>>({});

  useEffect(() => {
    addGetReportItemAnswerListener((request) => {
      const {type, platformUserId, interactiveState, authoredState} = request;
      const interactiveStateSize = JSON.stringify(interactiveState).length;
      const authoredStateSize = JSON.stringify(authoredState).length;

      setUserAnswers(prev => ({...prev, [platformUserId]: interactiveState}));

      switch (type) {
        case "html":
          const html = `
            <div class="tall">
              <h1>TALL REPORT HERE...</h1>
              <p>
                <strong>Interactive State Size</strong>: ${interactiveStateSize}
              </p>
              <p>
                <strong>Authored State Size</strong>: ${authoredStateSize}
              </p>
            </div>
            <div class="wide">
              <h1>WIDE REPORT HERE...</h1>
              <p>
                <strong>Interactive State Size</strong>: ${interactiveStateSize}
              </p>
              <p>
                <strong>Authored State Size</strong>: ${authoredStateSize}
              </p>
            </div>
          `;
          sendReportItemAnswer({type: "html", platformUserId, html});
          break;
      }
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
