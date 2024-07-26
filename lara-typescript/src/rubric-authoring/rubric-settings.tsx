import * as React from "react";
import { useCallback, useMemo, useRef, useState } from "react";
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
  const {projects, update, cancel} = props;
  const [name, setName] = useState(props.name);
  const [project, setProject] = useState(props.project);

  const formDisabled = useMemo(() => name.trim().length === 0, [name]);

  const handleChangeName = (e: React.ChangeEvent<HTMLInputElement>) => {
    setName(e.target.value);
  };

  const handleChangeProject = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const newProjectId = parseInt(e.target.value, 10);
    const newProject = projects.find(p => p.id === newProjectId) ?? null;
    setProject(newProject);
  };

  const handleUpdateSettings = useCallback((e: React.FormEvent) => {
    e.preventDefault();

    if (!formDisabled) {
      update({name, project});
    }
  }, [update, formDisabled, name, project]);

  return (
    <div className="rubric-settings">
      <div className="rubric-settings-header">Settings</div>
      <form className="rubric-settings-form" onSubmit={handleUpdateSettings}>
        <div>
          <label htmlFor="name">Name:</label>
          <input type="text" name="name" value={name} onChange={handleChangeName} autoFocus={true}/>
        </div>
        <div>
          <label htmlFor="project">Project:</label>
          <select name="project" value={project?.id} onChange={handleChangeProject}>
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
