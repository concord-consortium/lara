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
          <li>Create an interactive using this interactive's url.</li>
          <li>In the "Advanced Options" tab enable saving state.</li>
          <li>Exit authoring mode and in runtime/preview mode use the upload button to upload an attachment</li>
          <li>Go to the report verify you see the uploaded attachment.</li>
        </ol>
      </div>

      <fieldset>
        <legend>Authoring Init Message</legend>
        <div className="padded monospace pre">{JSON.stringify(initMessage, null, 2)}</div>
      </fieldset>
    </div>
  );
};
