import * as React from "react";
import { useState } from "react";
import { IAuthoringInitInteractive, IAuthoringClientMessage } from "../../../interactive-api-client";
import { GetInteractiveListComponent } from "./authoring-apis/get-interactive-list";
import { SetLinkedInteractivesComponent } from "./authoring-apis/set-linked-interactives";

interface Props {
  initMessage: IAuthoringInitInteractive;
}

export interface AuthoringApiProps {
  setOutput: (output: any) => void;
  setError: (error: any) => void;
}

export const AuthoringComponent: React.FC<Props> = ({initMessage}) => {
  const [selectedAuthoringApi, setSelectedAuthoringApi] = useState<IAuthoringClientMessage>("getInteractiveList");
  const [authoringApiError, setAuthoringApiError] = useState<any>();
  const [authoringApiOutput, setAuthoringApiOutput] = useState<any>();

  const handleClearAuthoringApiError = () => setAuthoringApiError(undefined);
  const handleClearAuthoringApiOutput = () => setAuthoringApiOutput(undefined);

  const handleAuthoringApiChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedAuthoringApi(e.target.value as IAuthoringClientMessage);
  };

  const renderAuthoringApiComponent = () => {
    switch (selectedAuthoringApi) {
      case "getInteractiveList":
        return <GetInteractiveListComponent setError={setAuthoringApiError} setOutput={setAuthoringApiOutput} />;
      case "setLinkedInteractives":
        return <SetLinkedInteractivesComponent setError={setAuthoringApiError} setOutput={setAuthoringApiOutput} />;
      default:
        return undefined;
    }
  };

  return (
    <div className="padded">

      <fieldset>
        <legend>Authoring APIs</legend>

        {authoringApiError ? <div className="padded margined error">{authoringApiError.toString()}</div> : undefined}

        <select value={selectedAuthoringApi} onChange={handleAuthoringApiChange}>
          <option value="getInteractiveList">getInteractiveList</option>
          <option value="setLinkedInteractives">setLinkedInteractives</option>
        </select>

        {authoringApiError
          ? <button className="margined-left" onClick={handleClearAuthoringApiError}>Clear Error</button>
          : undefined
        }
        {authoringApiOutput
          ? <button className="margined-left" onClick={handleClearAuthoringApiOutput}>Clear Output</button>
          : undefined
        }

        {renderAuthoringApiComponent()}

        {authoringApiOutput
          ? <div className="padded margined monospace pre">{JSON.stringify(authoringApiOutput, null, 2)}</div>
          : undefined
        }
      </fieldset>

      <fieldset>
        <legend>Authoring Init Message</legend>
        <div className="padded monospace pre">{JSON.stringify(initMessage, null, 2)}</div>
      </fieldset>

    </div>
  );
};
