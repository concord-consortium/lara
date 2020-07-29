import * as React from "react";
import { useRef, useState } from "react";
import * as client from "../../../../interactive-api-client";
import { AuthoringApiProps } from "../authoring";
import { ILinkedInteractive } from "../../../../interactive-api-client";

export const SetLinkedInteractivesComponent: React.FC<AuthoringApiProps> = ({setError, setOutput}) => {
  const linkedInteractivesRef = useRef<HTMLTextAreaElement|null>(null);
  const linkedStateRef = useRef<HTMLInputElement|null>(null);

  const handleCall = async () => {
    setError(undefined);
    setOutput(undefined);

    let linkedInteractives: ILinkedInteractive[] | undefined;
    try {
      const linkedInteractivesValue = (linkedInteractivesRef.current?.value || "").trim();
      linkedInteractives = linkedInteractivesValue.length > 0 ? JSON.parse(linkedInteractivesValue) : undefined;
    } catch (e) {
      return setError(`Unable to parse linkedInteractives: ${e.toString()}`);
    }

    let linkedState: string | undefined;
    const linkedStateValue = (linkedStateRef.current?.value || "").trim();
    if (linkedStateValue.length > 0) {
      linkedState = linkedStateValue;
    }

    try {
      client.setLinkedInteractives({linkedInteractives, linkedState});
      setOutput("*** Request sent ***");
    } catch (err) {
      setError(err);
    }
  };

  const defaultLinkedInteractives = '[\n  {"id": "ID1", "label": "LABEL"},\n  {"id": "ID2", "label": "LABEL"}\n]';

  return (
    <div className="padded margin monospace">
      <div>
        <small>NOTE: each parameter can be set separately, to leave out a parameter clear the input.</small>
      </div>

      <div>
        linkedInteractives:
        <br />
        <textarea ref={linkedInteractivesRef} defaultValue={defaultLinkedInteractives} rows={10} cols={100}  />
      </div>

      <div>
        linkedState: <input ref={linkedStateRef} />
      </div>

      <div>
        <button onClick={handleCall}>Send</button> (no response)
      </div>
    </div>
  );
};
