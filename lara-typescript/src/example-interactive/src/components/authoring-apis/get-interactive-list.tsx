import * as React from "react";
import { useRef } from "react";
import * as client from "../../../../interactive-api-client";
import { AuthoringApiProps } from "../authoring";

export const GetInteractiveListComponent: React.FC<AuthoringApiProps> = ({setError, setOutput}) => {
  const scopeRef = useRef<HTMLSelectElement|null>(null);
  const supportsSnapshotsRef = useRef<HTMLSelectElement|null>(null);

  const handleCall = async () => {
    const scope: any = scopeRef.current?.value || "page";
    const supportsSnapshotsValue = supportsSnapshotsRef.current?.value;
    const supportsSnapshots = supportsSnapshotsValue === "true"
      ? true : (supportsSnapshotsValue === "false" ? false : undefined);

    try {
      setOutput(await client.getInteractiveList({scope, supportsSnapshots}));
    } catch (err) {
      setError(err);
    }
  };

  return (
    <div className="padded margin monospace">
      <div>
        scope: <select ref={scopeRef}>
          <option value="page">page</option>
        </select>
      </div>

      <div>
        supportsSnapshots: <select ref={supportsSnapshotsRef}>
          <option value="skipped">skipped</option>
          <option value="false">false</option>
          <option value="true">true</option>
        </select>
      </div>

      <div>
        <button onClick={handleCall}>Call</button>
      </div>
    </div>
  );
};
