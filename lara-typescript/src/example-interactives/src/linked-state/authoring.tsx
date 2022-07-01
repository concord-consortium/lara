import * as React from "react";
import { IAuthoringInitInteractive, useAuthoredState } from "../../../interactive-api-client";
import { IAuthoredState } from "./types";

interface Props {
  initMessage: IAuthoringInitInteractive<{}>;
}

export const AuthoringComponent: React.FC<Props> = ({initMessage}) => {
  const { authoredState, setAuthoredState } = useAuthoredState<IAuthoredState>();

  const handleChangeSaveTimeout = (e: React.ChangeEvent<HTMLInputElement>) => {
    setAuthoredState({
      onUnloadTimeout: parseInt(e.target.value, 10) || 0
    });
  };

  return (
    <div className="padded">

      <div className="padded">
        <strong>
          NOTE: there is nothing required to author for this interactive but there are optional authoring options.
          To use it do the following:
        </strong>
        <ol>
          <li>Create two interactives using this interactive's url.</li>
          <li>In the "Advanced Options" tab enable saving state in both interactives.</li>
          <li>In <strong>second</strong> of the two interactives
              fill in the "Link Saved Work From" input to use the first interactive's id
              (available at the top of this edit popup).</li>
          <li>Exit authoring mode and in runtime/preview mode use the textarea to set the
              interactive state of the first interactive.</li>
          <li>Go to the second interactive and then look to see if the linked state was updated.</li>
        </ol>
      </div>

      <div className="padded">
        <fieldset>
          <legend>Optional Authoring Options</legend>
          <label>
            OnUnload Save Timeout:&nbsp;
            <input type="number" value={authoredState?.onUnloadTimeout || 0} onChange={handleChangeSaveTimeout} />
          </label>
          <small className="padded">
            Set to 0 to disable, or a positive number of seconds to wait for save on a page change.
          </small>
        </fieldset>
      </div>

      <fieldset>
        <legend>Authoring Init Message</legend>
        <div className="padded monospace pre">{JSON.stringify(initMessage, null, 2)}</div>
      </fieldset>
    </div>
  );
};
