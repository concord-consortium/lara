import { ILinkedInteractive } from "@concord-consortium/interactive-api-host";
import * as React from "react";
import { useEffect } from "react";

const dataSourceInteractiveLabel = "data_source_interactive";

interface Props {
  linked_interactives: ILinkedInteractive[];
}

export const DataSourceInteractive: React.FC<Props> = ({linked_interactives}) => {
  const [dataSourceInteractiveId, setDataSourceInteractiveId] = React.useState<string>("");

  useEffect(() => {
    const dataSourceInteractive = linked_interactives.find(li => li.label === dataSourceInteractiveLabel);
    if (dataSourceInteractive) {
      setDataSourceInteractiveId(dataSourceInteractive.id);
    }
  }, []);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value.trim();
    setDataSourceInteractiveId(value);

    const linkedInteractives = [...linked_interactives];
    const existingIndex = linkedInteractives.findIndex(li => li.label === dataSourceInteractiveLabel);
    if (existingIndex >= 0) {
      if (value) {
        linkedInteractives[existingIndex].id = value;
      } else {
        linkedInteractives.splice(existingIndex, 1);
      }
    } else if (value) {
      linkedInteractives.push({ id: value, label: dataSourceInteractiveLabel });
    }

    // NOTE: instead of using the host api to set linked interactives, we
    // directly write the linked interactives textarea in the authoring
    // form since the host api is meant to be used by the interactive's
    // iframed authoring UI, not by the authoring UI code.
    const textarea = document.getElementById("linked_interactives") as HTMLTextAreaElement | null;
    if (textarea) {
      textarea.value = JSON.stringify({linkedInteractives});
    }
  };

  return (
    <fieldset>
      <legend>Data Source Interactive</legend>
      <input
        type="text"
        value={dataSourceInteractiveId}
        placeholder="Enter optional data source interactive id (eg. interactive_123)"
        onChange={handleChange}
      />
    </fieldset>
  );
};
