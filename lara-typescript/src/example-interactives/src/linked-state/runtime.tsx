import * as React from "react";
import { useEffect } from "react";
import { IRuntimeInitInteractive, useInteractiveState, setOnUnload, useAuthoredState, IGetInteractiveState } from "../../../interactive-api-client";
import { IAuthoredState } from "./types";

interface Props {
  initMessage: IRuntimeInitInteractive<any, {}>;
}

export const RuntimeComponent: React.FC<Props> = ({initMessage}) => {
  const {interactiveState, setInteractiveState} = useInteractiveState<any>();
  const { authoredState } = useAuthoredState<IAuthoredState>();
  const saveTimeoutRef = React.useRef(0);

  const handleInteractiveStateValueChange = (event: React.ChangeEvent<HTMLTextAreaElement>) => {
    setInteractiveState(event.target.value);
  };

  useEffect(() => {
    if (authoredState?.onUnloadTimeout) {
      setOnUnload((options: IGetInteractiveState) => {
        return new Promise<{}>((resolve) => {
          if (options.unloading) {
            if (authoredState?.onUnloadTimeout) {
              clearTimeout(saveTimeoutRef.current);
              saveTimeoutRef.current = window.setTimeout(() => {
                resolve(interactiveState);
              }, authoredState.onUnloadTimeout);
            } else {
              resolve(interactiveState);
            }
          }
        });
      });
    }
  }, [interactiveState, authoredState]);

  return (
    <div className="padded">
      <fieldset>
        <legend>Runtime Init Message</legend>
        <div className="padded monospace pre">{JSON.stringify(initMessage, null, 2)}</div>
      </fieldset>

      <fieldset>
        <legend>Interactive State</legend>
        <textarea
          className="textarea"
          value={interactiveState || ""}
          onChange={handleInteractiveStateValueChange}
        />
      </fieldset>
    </div>
  );
};
