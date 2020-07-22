import * as React from "react";
import { useState } from "react";
import { IFrameSaverClientMessage, IAuthoringInitInteractive } from "../../../interactive-api-client";
import { GetInteractiveListComponent } from "./authoring-apis/get-interactive-list";

interface Props {
  initMessage: IAuthoringInitInteractive;
}

export interface AuthoringApiProps {
  setOutput: (output: any) => void;
  setError: (error: any) => void;
}

export const AuthoringComponent: React.FC<Props> = ({initMessage}) => {
  const [selectedAuthoringApi, setSelectedAuthoringApi] = useState<IFrameSaverClientMessage>("getInteractiveList");
  const [authoringApiError, setAuthoringApiError] = useState<any>();
  const [authoringApiOutput, setAuthoringApiOutput] = useState<any>();

  const handleClearAuthoringApiError = () => setAuthoringApiError(undefined);
  const handleClearAuthoringApiOutput = () => setAuthoringApiOutput(undefined);

  const handleAuthoringApiChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedAuthoringApi(e.target.value as IFrameSaverClientMessage);
  };

  const renderAuthoringApiComponent = () => {
    switch (selectedAuthoringApi) {
      case "getInteractiveList":
        return <GetInteractiveListComponent setError={setAuthoringApiError} setOutput={setAuthoringApiOutput} />;
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
