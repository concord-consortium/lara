import * as React from "react";
const { useEffect, useState } = React;
import {
  IRuntimeInitInteractive, getFirebaseJwt, useCustomMessages, ICustomMessage, getInteractiveSnapshot,
  postDecoratedContentEvent, useDecorateContent } from "../../../interactive-api-client";
import { IAuthoredState } from "./types";
import * as TextDecorator from "@concord-consortium/text-decorator";

interface Props {
  initMessage: IRuntimeInitInteractive<{}, IAuthoredState>;
}

export const RuntimeComponent: React.FC<Props> = ({initMessage}) => {
  const [rawFirebaseJwt, setRawFirebaseJWT] = useState<string>();
  const [snapshotSourceId, setSnapshotSourceId] = useState<string>("interactive_123");
  const [snapshotUrl, setSnapshotUrl] = useState<string>();
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
  }, { "*": true });

  useDecorateContent((msg: any) => {
    const domClasses = ["text-decorate"];
    const options = {
      words: msg.words,
      replace: msg.replace,
    };

    const decoratedContentClickListener = {
      type: "click",
      listener: (evt: Event) => {
        const wordElement = evt.srcElement as HTMLElement;
        if (!wordElement) {
          return;
        }
        const clickedWord = (wordElement.textContent || "").toLowerCase();
        postDecoratedContentEvent({type: "click", text: clickedWord, bounds: wordElement.getBoundingClientRect()});
      }
    };
    TextDecorator.decorateDOMClasses(domClasses, options, msg.wordClass, decoratedContentClickListener);
  });

  const handleSnapshotTargetChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setSnapshotSourceId(event.target.value);
  };

  const handleTakeSnapshot = () => {
    setSnapshotUrl("");
    getInteractiveSnapshot({ interactiveItemId: snapshotSourceId }).then((response) => {
      if (response.success) {
        setSnapshotUrl(response.snapshotUrl);
      } else {
        window.alert("Snapshot has failed");
      }
    });
  };

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
      <fieldset>
        <legend>Snapshot API</legend>
        <div>Interactive ID: <input type="text" value={snapshotSourceId} onChange={handleSnapshotTargetChange}/></div>
        <div><button onClick={handleTakeSnapshot}>Take a snapshot</button></div>
        {
          snapshotUrl &&
          <div>Snapshot URL: <a href={snapshotUrl} target="_blank" style={{fontSize: 10}}>{snapshotUrl}</a></div>
        }
      </fieldset>
      <fieldset>
        <legend>Text Decoration</legend>
        <div className="text-decorate">
          This text decoration example is designed to work with a glossary containing the terms "test" and "page."
          In the Activity Player, the sample activity "sample-activity-glossary-plugin-example-interactive" contains
          embeddables that use this example-interactive and a glossary plugin linked to a glossary with the necessary
          terms. When the "sample-activity-glossary-plugin-example-interactive" activity is run in the Activity Player,
          both "test" and "page" should appear decorated and be clickable.
        </div>
      </fieldset>
    </div>
  );
};
