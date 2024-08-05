import * as React from "react";
import { useState } from "react";
import { RubricSettings, UpdateSettingsParams } from "./rubric-settings";
import { RubricGeneralOptions } from "./rubric-general-options";
import { RubricPanel } from "./rubric-panel";
import { RubricContext, useRubricValue } from "./use-rubric";
import { RubricPreview } from "./rubric-preview";
import { RubricRatings } from "./rubric-ratings";
import { RubricCriteria } from "./rubric-criteria";

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
  authoredContentUrl: string;
}

export const RubricForm = (props: IRubricFormProps) => {
  const [name, setName] = useState(props.name);
  const [project, setProject] = useState(props.project);
  const [showSettings, setShowSettings] = useState(false);
  const rubricContextValue = useRubricValue(props.authoredContentUrl);
  const {loadStatus, saveStatus, isDirty, rubric, saveRubric} = rubricContextValue;

  /* for use later for debugging
  useEffect(() => {
    console.log(rubricContextValue.rubric);
  }, [rubricContextValue.rubric]);
  */

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

  const handleSaveRubric = () => saveRubric();

  const renderRubricPanels = () => {
    if (loadStatus === "loading") {
      return <div>Loading...</div>;
    }

    if (loadStatus === "error") {
      return <div>Error loading rubric!</div>;
    }

    return (
      <>
        <RubricPanel title="Rubric Preview" backgroundColor={"#e2f4f8"}>
          <RubricPreview />
        </RubricPanel>

        <RubricPanel title="General Options">
          <RubricGeneralOptions />
        </RubricPanel>

        <RubricPanel title="Ratings">
          <RubricRatings />
        </RubricPanel>

        <RubricCriteria />
      </>
    );
  };

  return (
    <RubricContext.Provider value={rubricContextValue}>
      <div className="rubric-form-container">
        <div className="rubric-header">
          <h1>Edit Rubric: {name}</h1>
          <div className="rubric-save-status">
            {isDirty && saveStatus}
          </div>
          <div className="rubric-header-buttons">
            <button className="rubric-edit-settings" onClick={handleToggleShowSettings}>Edit Settings</button>
            <button className="rubric-save" onClick={handleSaveRubric} disabled={!isDirty}>Save</button>
          </div>
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

        {renderRubricPanels()}
      </div>
    </RubricContext.Provider>
  );
};
