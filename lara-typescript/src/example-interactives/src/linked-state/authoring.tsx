import * as React from "react";
import { IAuthoringInitInteractive } from "../../../interactive-api-client";

interface Props {
  initMessage: IAuthoringInitInteractive<{}>;
}

export const AuthoringComponent: React.FC<Props> = ({initMessage}) => {
  return (
    <div className="padded">

      <div className="padded">
        <strong>NOTE: there is nothing to author for this interactive.  To use it do the following:</strong>
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

      <fieldset>
        <legend>Authoring Init Message</legend>
        <div className="padded monospace pre">{JSON.stringify(initMessage, null, 2)}</div>
      </fieldset>
    </div>
  );
};
