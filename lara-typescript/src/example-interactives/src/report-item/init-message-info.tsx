import * as React from "react";
import { useRef, useState } from "react";
import { IReportItemInitInteractive } from "../../../interactive-api-client";

interface Props {
  initMessage: IReportItemInitInteractive;
}

export const InitMessageInfoComponent: React.FC<Props> = (props) => {
  const initMessage = useRef(props.initMessage);
  const {users, interactiveItemId, view} = initMessage.current;
  const userIds = Object.keys(users);
  const numAnswersAtInit = userIds.reduce<number>((acc, studentId) => {
    return users[studentId].hasAnswer ? acc + 1 : acc;
  }, 0);
  const [userAnswers, setUserAnswers] = useState<Record<string, any>>({});
  const numCurrentAnswers = Object.keys(userAnswers).length;

  return (
    <div className="initMessageInfo">
      <dt>View</dt>
      <dd>{view}</dd>

      <dt>Interactive Item Id</dt>
      <dd>{interactiveItemId}</dd>

      <dt>Number of Users in Init Message</dt>
      <dd>{userIds.length}</dd>

      <dt>Number of Answers In Init Message</dt>
      <dd>{numAnswersAtInit}</dd>

      <dt>Number of Answers Currently</dt>
      <dd>{numCurrentAnswers}</dd>
  </div>
  );
};
