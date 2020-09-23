import * as React from "react";
const { useEffect, useState } = React;
import { IRuntimeInitInteractive, getFirebaseJwt, useCustomMessages, ICustomMessage } from "../../../interactive-api-client";
import { IAuthoredState } from "./types";

interface Props {
  initMessage: IRuntimeInitInteractive<{}, IAuthoredState>;
}

export const RuntimeComponent: React.FC<Props> = ({initMessage}) => {
  const [rawFirebaseJwt, setRawFirebaseJWT] = useState<string>();
  const { authoredState } = initMessage;
  useEffect(() => {
    if (authoredState?.firebaseApp) {
      getFirebaseJwt(authoredState.firebaseApp)
        .then(response => {
          setRawFirebaseJWT(response.token);
        })
        .catch(e => {
          setRawFirebaseJWT(`ERROR: ${e.toString()}`);
        });
    }
  }, [authoredState]);

  const [customMessages, setCustomMessages] = useState<ICustomMessage[]>([]);
  useCustomMessages((msg: ICustomMessage) => {
    setCustomMessages(messages => [...messages, msg]);
  });

  return (
    <div className="padded">
      <fieldset>
        <legend>Runtime Init Message</legend>
        <div className="padded monospace pre">{JSON.stringify(initMessage, null, 2)}</div>
      </fieldset>
      <fieldset>
        <legend>FirebaseJWT Response</legend>
        <div className="padded monospace pre">{rawFirebaseJwt}</div>
      </fieldset>
      <fieldset>
        <legend>Custom Messages Received</legend>
        <div className="padded monospace pre">
          <table>
            <thead>
              <th>Type</th>
              <th>Content</th>
            </thead>
            <tbody>
              {customMessages.map((msg, i) => (
                <tr key={`${i}-${msg.type}`}>
                  <td>{msg.type}</td>
                  <td>{msg.content}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </fieldset>
    </div>
  );
};
