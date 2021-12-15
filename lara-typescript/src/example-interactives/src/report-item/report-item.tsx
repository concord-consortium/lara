import * as React from "react";
import { useEffect, useRef, useState } from "react";
import { IReportItemInitInteractive,
         addGetStudentHTMLListener,
         sendStudentHTML } from "../../../interactive-api-client";

interface Props {
  initMessage: IReportItemInitInteractive;
}

export const ReportItemComponent: React.FC<Props> = (props) => {
  const initMessage = useRef(props.initMessage);
  const {students, interactiveItemId, view, authoredState} = initMessage.current;
  const studentsIds = Object.keys(students);
  const numAnswersAtInit = studentsIds.reduce<number>((acc, studentId) => {
    return students[studentId].hasAnswer ? acc + 1 : acc;
  }, 0);
  const [studentAnswers, setStudentAnswers] = useState<Record<string, any>>({});
  const numCurrentAnswers = Object.keys(studentAnswers).length;

  useEffect(() => {
    addGetStudentHTMLListener((request) => {
      const {studentId, interactiveState} = request;
      const json = JSON.stringify(interactiveState);
      const html = `
        <div>
          <p>
            <strong>Interactive State Size</strong>: ${json.length}
          </p>
          <p>
            <strong>First 100 Bytes:</strong>: ${json.substr(0, 100)}
          </p>
        </div>`;
      setStudentAnswers(prev => ({...prev, [studentId]: interactiveState}));
      sendStudentHTML({studentId, html});
    });
  }, []);

  return (
    <div className="padded">
      <strong>Example Report Item Interactive</strong>

      <dl>
        <dt>View</dt>
        <dd>{view}</dd>

        <dt>Interactive Item Id</dt>
        <dd>{interactiveItemId}</dd>

        <dt>Number of Students in Init Message</dt>
        <dd>{studentsIds.length}</dd>

        <dt>Number of Answers In Init Message</dt>
        <dd>{numAnswersAtInit}</dd>

        <dt>Number of Answers Currently</dt>
        <dd>{numCurrentAnswers}</dd>

        <dt>Authored State</dt>
        <dd><pre>{JSON.stringify(authoredState, null, 2)}</pre></dd>
    </dl>
    </div>
  );
};
