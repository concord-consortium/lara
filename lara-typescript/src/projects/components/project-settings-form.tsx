import * as React from "react";
import { useEffect, useState } from "react";
import { SlateContainer, slateToHtml, htmlToSlate } from "@concord-consortium/slate-editor";
import { IProject, IProjectTheme } from "../types";
import { camelToSnakeCaseKeys, snakeToCamelCaseKeys } from "../../shared/convert-keys";

import "@concord-consortium/slate-editor/build/index.css";
import "./project-settings-form.scss";

export interface IProjectSettingsFormProps {
  id: number;
}

export const ProjectSettingsForm: React.FC<IProjectSettingsFormProps> = ({id}: IProjectSettingsFormProps) => {
  const newProject: IProject = {
    about: "",
    collaborators: "",
    collaboratorsImageUrl: "",
    contactEmail: "",
    copyright: "",
    copyrightImageUrl: "",
    footer: "",
    fundersImageUrl: "",
    id: undefined,
    logoLara: "",
    logoAp: "",
    projectKey: "",
    themeId: undefined,
    title: "",
    url: ""
  };

  const [alertMessage, setAlertMessage] = useState<string|undefined>(undefined);
  const [aboutValue, setAboutValue] = useState(htmlToSlate(""));
  const [collaboratorsValue, setCollaboratorsValue] = useState(htmlToSlate(""));
  const [copyrightValue, setCopyrightValue] = useState(htmlToSlate(""));
  const [pageTitle, setPageTitle] = useState("New Project");
  const [project, setProject] = useState(newProject);
  const [projectLoaded, setProjectLoaded] = useState(false);
  const [isNewProject, setIsNewProject] = useState(false);
  const [projectSaved, setProjectSaved] = useState(false);
  const [themeList, setThemeList] = useState<IProjectTheme[]>([]);

  useEffect(() => {
    if (id) {
      getProject();
    } else {
      setIsNewProject(true);
    }
  }, [projectSaved]);

  useEffect(() => {
    getThemes();
  }, []);

  useEffect(() => {
    setAboutValue(htmlToSlate(project.about || ""));
    setCollaboratorsValue(htmlToSlate(project.collaborators || ""));
    setCopyrightValue(htmlToSlate(project.copyright || ""));
  }, [projectLoaded]);

  const getProject = () => {
    const apiUrl = `/api/v1/projects/${id}`;
    fetch(apiUrl, {
      method: "GET",
      headers: {"Content-Type": "application/json"},
      credentials: "include"
    })
    .then(response => response.json())
    .then(data => {
      // remove protected attributes
      delete data.created_at;
      delete data.updated_at;
      setProject(snakeToCamelCaseKeys(data));
      setProjectLoaded(true);
      setPageTitle(`Edit ${data.title}`);
    })
    .catch(error => {
      setAlertMessage(error);
    });
  };

  const getThemes = () => {
    const apiUrl = "/api/v1/themes";
    fetch(apiUrl, {
      method: "GET",
      headers: {"Content-Type": "application/json"},
      credentials: "include"
    })
    .then(response => response.json())
    .then(data => {
      const themes = data.map((t: any) => ({id: t.id, name: t.name}));
      setThemeList(themes);
    })
    .catch(error => {
      setAlertMessage(error);
    });
  };

  const generateProjectKey = (title: string) => {
    // TODO: Check existing keys to make sure a unique value is generated
    if (title !== "") {
      return title.replace(/ /g, "-").toLowerCase();
    }
  };

  const handleTitleBlur = () => {
    if (project.projectKey === "") {
      const projectKey = generateProjectKey(project.title);
      setProject({...project, projectKey});
    }
  };

  const handleTextInputChange = (key: string) => {
    return (e: React.ChangeEvent<HTMLInputElement>) => {
      setProject({...project, [key]: e.target.value});
    };
  };

  const handleTextareaChange = (key: string) => {
    return (e: React.ChangeEvent<HTMLTextAreaElement>) => {
      setProject({...project, [key]: e.target.value});
    };
  };

  const handleSlateRteChange = (key: string, setter: (value: any) => void) => {
    return (value: any) => {
      setter(value);
      setProject({...project, [key]: slateToHtml(value)});
    };
  };

  const handleSelectMenuChange = (key: string) => {
    return (e: React.ChangeEvent<HTMLSelectElement>) => {
      setProject({...project, [key]: e.target.value});
    };
  };

  const handleCollaboratorsImageUrlChange = handleTextInputChange("collaboratorsImageUrl");
  const handleContactEmailChange = handleTextInputChange("contactEmail");
  const handleCopyrightImageUrlChange = handleTextInputChange("copyrightImageUrl");
  const handleFooterChange = handleTextareaChange("footer");
  const handleFundersImageUrlChange = handleTextInputChange("fundersImageUrl");
  const handleKeyChange = handleTextInputChange("projectKey");
  const handleLogoApChange = handleTextInputChange("logoAp");
  const handleLogoLaraChange = handleTextInputChange("logoLara");
  const handleThemeChange = handleSelectMenuChange("themeId");
  const handleTitleChange = handleTextInputChange("title");
  const handleUrlChange = handleTextInputChange("url");
  const handleAboutChange = handleSlateRteChange("about", setAboutValue);
  const handleCollaboratorsChange = handleSlateRteChange("collaborators", setCollaboratorsValue);
  const handleCopyrightChange = handleSlateRteChange("copyright", setCopyrightValue);

  const handleSaveProject = () => {
    const apiUrl = id ? `/api/v1/projects/${id}` : `/api/v1/projects`;
    const projectData = camelToSnakeCaseKeys(project);

    fetch(apiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json"},
      credentials: "include",
      body: JSON.stringify({project: projectData})
    })
    .then(response => response.json())
    .then(data => {
      window.scrollTo(0, 0);
      if (data.success) {
        setProjectSaved(true);
        if (isNewProject) {
          window.location.href = "/projects?newProjectCreated=1";
        } else {
          setAlertMessage("Project saved.");
          const alertTimer = setTimeout(() => setAlertMessage(undefined), 5000);
          clearTimeout(alertTimer);
        }
      }
    })
    .catch((error) => {
      window.scrollTo(0, 0);
      setAlertMessage(error);
    });
  };

  if (isNewProject && projectSaved) {
    return(null);
  }

  return (
    <div className="projectSettingsForm">
      <nav>
        <div className="breadcrumbs">
          <ul>
            <li><a href="/">Home</a> </li>
            <li>&nbsp;/ <a href="/projects">Projects</a> </li>
            <li>&nbsp;/ {pageTitle}</li>
          </ul>
        </div>
      </nav>
      <h1 className="title">{pageTitle}</h1>
      {alertMessage && <div className="alertMessage">{alertMessage}</div>}
      <dl>
        <dt>
          <label htmlFor="project-title">Title</label>
        </dt>
        <dd>
          <input
            id="project-title"
            name="project[title]"
            defaultValue={project.title}
            onChange={handleTitleChange}
            onBlur={handleTitleBlur}
          />
        </dd>
        <dt>
          <label htmlFor="project-key">Project Key</label>
        </dt>
        <dd className="hasNote">
          <input
            id="project-key"
            name="project[projectKey]"
            defaultValue={project.projectKey}
            onChange={handleKeyChange}
          />
        </dd>
        <dd className="inputNote">
          The project key is used across sites to synchronise project information. It must be a unique value.
        </dd>
        <dt>
          <label htmlFor="project-title">LARA Runtime Logo URL</label>
        </dt>
        <dd className="hasNote">
          <input
            id="project-logo-lara"
            name="project[logo_lara]"
            defaultValue={project.logoLara}
            onChange={handleLogoLaraChange}
          />
        </dd>
        <dd className="inputNote">
          Image should be 228 pixels wide by 70 pixels high. If left blank, the Concord Consortium
          logo will be used by default.
        </dd>
        <dt>
          <label htmlFor="project-logo-ap">Activity Player Logo URL</label>
        </dt>
        <dd className="hasNote">
          <input
            id="project-logo-ap"
            name="project[logo_ap]"
            defaultValue={project.logoAp}
            onChange={handleLogoApChange}
          />
        </dd>
        <dd className="inputNote">
          Image should be 250 pixels wide by 78 pixels high. If left blank, the Concord Consortium
          logo will be used by default.
        </dd>
        <dt>
          <label htmlFor="project-url">Project Page URL</label>
        </dt>
        <dd className="hasNote">
          <input
            id="project-url"
            name="project[url]"
            defaultValue={project.url}
            onChange={handleUrlChange}
          />
        </dd>
        <dd className="inputNote">
          When logo image is clicked, this is URL will launch in a new browser tab.
        </dd>
        <dt>
          <label htmlFor="project-url">LARA Runtime Footer</label>
        </dt>
        <dd className="hasNote">
          <textarea
            id="project-footer"
            name="project[footer]"
            defaultValue={project.footer}
            onChange={handleFooterChange}
          />
        </dd>
        <dd className="inputNote">
          Raw HTML can be entered into this legacy field.
        </dd>
      </dl>
      <h2>Activity Player Footer</h2>
      <dl>
        <dt>
          <label htmlFor="project-copyright">Copyright/Attribution Text</label>
        </dt>
        <dd>
          <div className="slateContainer">
            <SlateContainer value={copyrightValue} onValueChange={handleCopyrightChange} />
          </div>
        </dd>
        <dt>
          <label htmlFor="project-logo-ap">Copyright Image URL</label>
        </dt>
        <dd className="hasNote">
          <input
            id="project-copyright-image-url"
            name="project[copyrightImageUrl]"
            defaultValue={project.copyrightImageUrl}
            onChange={handleCopyrightImageUrlChange}
          />
        </dd>
        <dd className="inputNote">
          Image is displayed at top left of copyright text. Image file should be 240 pixels wide by 84
          pixels high. If left blank, no image will be displayed.
        </dd>
        <dt>
          <label htmlFor="project-collaborators">Funding Source(s) and Collaborator(s) Text</label>
        </dt>
        <dd>
          <div className="slateContainer">
            <SlateContainer value={collaboratorsValue} onValueChange={handleCollaboratorsChange} />
          </div>
        </dd>
        <dt>
          <label htmlFor="project-logo-ap">Funding Source(s) Image URL</label>
        </dt>
        <dd className="hasNote">
          <input
            id="project-funders-image-url"
            name="project[fundersImageUrl]"
            defaultValue={project.fundersImageUrl}
            onChange={handleFundersImageUrlChange}
          />
        </dd>
        <dd className="inputNote">
          If multiple funding sources, please create a single image with all logos. Image is displayed
          at top left of funder(s)/collaborator(s) text. Image should be 240 pixels wide by 100 pixels
          high, or 100 pixels wide by 100 pixels high. If left blank, no image will be displayed.
        </dd>
        <dt>
          <label htmlFor="project-collaborators-image-url">Collaborator(s) Image URL</label>
        </dt>
        <dd className="hasNote">
          <input
            id="project-collaborators-image-url"
            name="project[collaboratorsImageUrl]"
            defaultValue={project.collaboratorsImageUrl}
            onChange={handleCollaboratorsImageUrlChange}
          />
        </dd>
        <dd className="inputNote">
          If multiple collaborators, please create a single image with all logos. Image should be a
          maximum of 1800 pixels wide by 100 pixels high. If left blank, no image will be displayed.
        </dd>
        <dt>
          <label htmlFor="project-about">About Text</label>
        </dt>
        <dd>
          <div className="slateContainer">
            <SlateContainer value={aboutValue} onValueChange={handleAboutChange} />
          </div>
        </dd>
        <dt>
          <label htmlFor="project-contact-email">Project Contact Email</label>
        </dt>
        <dd className="hasNote">
          <input
            id="project-contact-email"
            type="email"
            name="project[contactEmail]"
            defaultValue={project.contactEmail}
            onChange={handleContactEmailChange}
          />
        </dd>
        <dd className="inputNote">
          Provide a valid email address for users to contact your project team. When this is provided,
          your contact email will be displayed in the footer.
        </dd>
        <dt>
          <label htmlFor="project-theme-id">LARA Runtime Default Theme</label>
        </dt>
        <dd className="hasNote">
          <select id="project-theme-id" name="project[theme_id]" onChange={handleThemeChange}>
            <option value="" selected={typeof project.themeId === "undefined"}>None (use default)</option>
            {themeList.map(theme => (
              <option key={`theme-${id}`} value={theme.id} selected={project.themeId === theme.id}>{theme.name}</option>
            ))}
          </select>
        </dd>
        <dd className="inputNote">
          When LARA Runtime is the selected Runtime Environment, activities will use this theme by
          default. Themes can be changed in the activity settings.
        </dd>
      </dl>
      <button onClick={handleSaveProject}>Save</button>
    </div>
  );
};
