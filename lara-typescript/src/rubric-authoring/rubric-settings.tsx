import * as React from "react";
import { useMemo, useRef, useState } from "react";
import { RubricProject } from "./rubric-form";

import "./rubric-settings.scss";

export interface UpdateSettingsParams {
  name: string;
  project: RubricProject|null;
}

export interface IRubricSettingsProps {
  name: string;
  project: RubricProject|null;
  projects: RubricProject[];
  update: (settings: UpdateSettingsParams) => void;
  cancel: () => void;
}

export const RubricSettings = (props: IRubricSettingsProps) => {
  const {project, projects, update, cancel} = props;
  const [name, setName] = useState(props.name);
  const settingsFormRef = useRef<HTMLFormElement|null>(null);
  const formDisabled = useMemo(() => name.trim().length === 0, [name]);

  const handleChangeName = (e: React.ChangeEvent<HTMLInputElement>) => {
    setName(e.target.value);
  };

  const handleUpdateSettings = (e: React.FormEvent) => {
    e.preventDefault();

    if (settingsFormRef.current && !formDisabled) {
      const formData = new FormData(settingsFormRef.current);
      const newName = formData.get("name")?.toString().trim() ?? "";
      const newProjectId = parseInt(formData.get("project")?.toString() ?? "", 10);
      const newProject = projects.find(p => p.id === newProjectId) ?? null;

      if (newName.length > 0) {
        update({
          name: newName,
          project: newProject
        });
      }
    }
  };

  return (
    <div className="rubric-settings">
      <div className="rubric-settings-header">Settings</div>
      <form className="rubric-settings-form" ref={settingsFormRef} onSubmit={handleUpdateSettings}>
        <div>
          <label htmlFor="name">Name:</label>
          <input type="text" name="name" value={name} onChange={handleChangeName} autoFocus={true}/>
        </div>
        <div>
          <label htmlFor="project">Project:</label>
          <select name="project" defaultValue={project?.id}>
            <option value="0" />
            {projects.map(({id, title}) => <option key={id} value={id}>{title}</option>)}
          </select>
        </div>
        <div className="rubric-settings-buttons">
          <input type="submit" value="Save Changes" disabled={formDisabled} />
          <button onClick={cancel}>Cancel</button>
        </div>
      </form>
    </div>
  );
};
