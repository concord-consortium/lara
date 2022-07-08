import * as React from "react";
import { useEffect, useState } from "react";
import * as semver from "semver";
import { IReportItemInitInteractive,
         addGetReportItemAnswerListener,
         sendReportItemAnswer,
         IReportItemAnswerItem} from "../../../interactive-api-client";
import { getClient } from "../../../interactive-api-client/client";
import { IAuthoredState, IInteractiveState } from "./types";

interface Props {
  initMessage: IReportItemInitInteractive;
}

export const ReportItemComponent: React.FC<Props> = (props) => {
  const {initMessage} = props;
  const {view} = initMessage;

  useEffect(() => {
    addGetReportItemAnswerListener<IInteractiveState, IAuthoredState>((request) => {
      const {version, platformUserId} = request;

      if (!version) {
        // for hosts sending older, unversioned requests
        // tslint:disable-next-line:no-console
        console.error("Example Attachments Report Item Interactive: Missing version in getReportItemAnswer request.");
      }
      else if (semver.satisfies(version, "2.x")) {
        const items: IReportItemAnswerItem[] = Object.keys(initMessage.attachments || {}).map(name => {
          return ({
            type: "attachment",
            name
          });
        });

        sendReportItemAnswer({version, platformUserId, items, itemsType: "fullAnswer"});
      } else {
        // tslint:disable-next-line:no-console
        console.error(
          "Example Attachments Report Item Interactive: Unsupported version in getReportItemAnswer request:",
          version
        );
      }
    });

    // tell the portal-report we are ready for messages
    getClient().post("reportItemClientReady");
  }, []);

  const uploadedAttachments = Object.keys(initMessage.attachments || {}).length > 0;

  return (
    <div className={`reportItem ${view}`}>
      Uploaded attachments: {uploadedAttachments ? "Yes" : "No"}
    </div>
  );
};
