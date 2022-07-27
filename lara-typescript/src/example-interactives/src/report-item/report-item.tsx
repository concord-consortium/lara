import * as React from "react";
import { useEffect, useState } from "react";
import * as semver from "semver";
import { IReportItemInitInteractive,
         addGetReportItemAnswerListener,
         sendReportItemAnswer,
         IReportItemAnswerItem} from "../../../interactive-api-client";
import { getClient } from "../../../interactive-api-client/client";
import { MultipleAnswerSummaryComponent } from "./multiple-answer-summary";
import { SingleAnswerSummaryComponent } from "./single-answer-summary";

interface Props {
  initMessage: IReportItemInitInteractive;
}

// not used here, but could be used if this used as an example for other interactives
interface IInteractiveState {}
interface IAuthoredState {}

export const ReportItemComponent: React.FC<Props> = (props) => {
  const {initMessage} = props;
  const {users, view} = initMessage;
  const [userAnswers, setUserAnswers] = useState<Record<string, any>>({});

  useEffect(() => {
    addGetReportItemAnswerListener<IInteractiveState, IAuthoredState>((request) => {
      const {version, platformUserId, interactiveState, authoredState} = request;

      if (!version) {
        // for hosts sending older, unversioned requests
        // tslint:disable-next-line:no-console
        console.error("Example Report Item Interactive: Missing version in getReportItemAnswer request.");
      }
      else if (semver.satisfies(version, "2.x")) {
        const interactiveStateSize = JSON.stringify(interactiveState).length;
        const authoredStateSize = JSON.stringify(authoredState).length;

        setUserAnswers(prev => ({...prev, [platformUserId]: interactiveState}));

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

        const items: IReportItemAnswerItem[] = [{type: "html", html}];

        sendReportItemAnswer({version, platformUserId, items, itemsType: "fullAnswer"});
      } else {
        // tslint:disable-next-line:no-console
        console.error("Example Report Item Interactive: Unsupported version in getReportItemAnswer request:", version);
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
