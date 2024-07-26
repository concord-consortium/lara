import * as React from "react";
import { useState } from "react";
import { RubricSettings, UpdateSettingsParams } from "./rubric-settings";
import { RubricGeneralOptions } from "./rubric-general-options";
import { RubricPanel } from "./rubric-panel";
import { RubricRatings } from "./rubric-ratings";

import "./rubric-form.scss";

export interface RubricProject {
  id: number;
  title: string;
}

export interface IRubricFormProps {
  name: string;
  updateSettingsUrl: string;
  project: RubricProject|null;
  projects: RubricProject[];
}

export const RubricForm = (props: IRubricFormProps) => {
  const [name, setName] = useState(props.name);
  const [project, setProject] = useState(props.project);
  const [showSettings, setShowSettings] = useState(false);

  const handleToggleShowSettings = () => {
    setShowSettings(prev => !prev);
  };

  const handleUpdateSettings = (saveSettings: UpdateSettingsParams) => {
    fetch(props.updateSettingsUrl, {
      method: "PUT",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(saveSettings)
    }).then((resp) => {
      if (resp.status === 200) {
        setName(saveSettings.name);
        setProject(saveSettings.project);
        handleToggleShowSettings();
      } else {
        alert("Something went wrong saving the settings");
      }
    }).catch(fetchError => {
      alert(fetchError.toString());
    });
  };

  return (
    <div className="rubric-form-container">
      <div className="rubric-header">
        <h1>Edit Rubric: {name}</h1>
        <div className="rubric-dev-note">Dev Note: Saving is not implemented yet.</div>
        <button className="rubric-edit-settings" onClick={handleToggleShowSettings}>Edit Settings</button>
      </div>

      {showSettings &&
        <RubricSettings
          name={name}
          project={project}
          projects={props.projects}
          update={handleUpdateSettings}
          cancel={handleToggleShowSettings}
        />
      }

      <RubricPanel title="Rubric Preview" backgroundColor={"#e2f4f8"}>
        TBD
      </RubricPanel>

      <RubricPanel title="General Options">
        <RubricGeneralOptions />
      </RubricPanel>

      <RubricPanel title="Ratings">
        <RubricRatings ratings={[]} /> {/* empty initial ratings for now, will change once save is added */}
      </RubricPanel>

      <RubricPanel title="Criteria">
        TBD
      </RubricPanel>

    </div>
  );
};
