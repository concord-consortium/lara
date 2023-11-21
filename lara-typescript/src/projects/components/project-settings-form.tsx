import * as React from "react";
import { useEffect, useState } from "react";
import { SlateContainer, slateToHtml, htmlToSlate } from "@concord-consortium/slate-editor";
import { IProject, IProjectAdmin } from "../types";
import { camelToSnakeCaseKeys, snakeToCamelCaseKeys } from "../../shared/convert-keys";

import "@concord-consortium/slate-editor/build/index.css";
import "./project-settings-form.scss";

export interface IProjectSettingsFormProps {
  id: number | null;
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
    title: "",
    url: ""
  };

  const [alertMessage, setAlertMessage] = useState<string|undefined>(undefined);
  const [aboutValue, setAboutValue] = useState(htmlToSlate(""));
  const [collaboratorsValue, setCollaboratorsValue] = useState(htmlToSlate(""));
  const [copyrightValue, setCopyrightValue] = useState(htmlToSlate(""));
  const [pageTitle, setPageTitle] = useState("New Project");
  const [project, setProject] = useState(newProject);
  const [admins, setAdmins] = useState<IProjectAdmin[]>([]);
  const [projectLoaded, setProjectLoaded] = useState(false);
  const [isNewProject, setIsNewProject] = useState(false);
  const [projectSaved, setProjectSaved] = useState(false);

  useEffect(() => {
    if (id) {
      getProject();
    } else {
      setIsNewProject(true);
    }
  }, [projectSaved]);

  useEffect(() => {
    setAboutValue(htmlToSlate(project.about || ""));
    setCollaboratorsValue(htmlToSlate(project.collaborators || ""));
    setCopyrightValue(htmlToSlate(project.copyright || ""));
  }, [projectLoaded]);

  const getProject = async () => {
    const apiUrl = `/api/v1/projects/${id}`;
    const data = await fetch(apiUrl, {
      method: "GET",
      headers: {"Content-Type": "application/json"},
      credentials: "include"
    })
    .then(response => response.json())
    .catch(error => {
      setAlertMessage(error);
    });

    // remove protected attributes
    delete data.project.created_at;
    delete data.project.updated_at;
    setProject(snakeToCamelCaseKeys(data.project));
    setAdmins(data.admins || []);
    setProjectLoaded(true);
    setPageTitle(`Edit ${data.project.title}`);
  };

  const generateProjectKey = (title: string) => {
    // TODO: Check existing keys to make sure a unique value is generated
    if (title !== "") {
      return title.replace(/ /g, "-").toLowerCase();
    }
  };

  const handleTitleBlur = (e: React.FocusEvent<HTMLInputElement>) => {
    const title = e.target.value;
    if (project.projectKey === "" && title !== "") {
      const projectKey = generateProjectKey(e.target.value);
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

  const handleCollaboratorsImageUrlChange = handleTextInputChange("collaboratorsImageUrl");
  const handleContactEmailChange = handleTextInputChange("contactEmail");
  const handleCopyrightImageUrlChange = handleTextInputChange("copyrightImageUrl");
  const handleFundersImageUrlChange = handleTextInputChange("fundersImageUrl");
  const handleKeyChange = handleTextInputChange("projectKey");
  const handleLogoApChange = handleTextInputChange("logoAp");
  const handleTitleChange = handleTextInputChange("title");
  const handleUrlChange = handleTextInputChange("url");
  const handleAboutChange = handleSlateRteChange("about", setAboutValue);
  const handleCollaboratorsChange = handleSlateRteChange("collaborators", setCollaboratorsValue);
  const handleCopyrightChange = handleSlateRteChange("copyright", setCopyrightValue);

  const handleSaveProject = async () => {
    const apiUrl = id ? `/api/v1/projects/${id}` : `/api/v1/projects`;
    const projectData = camelToSnakeCaseKeys(project);
    projectData.admin_ids = admins.map(a => a.id);

    const data = await fetch(apiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json"},
      credentials: "include",
      body: JSON.stringify({project: projectData})
    })
    .then(response => response.json())
    .catch((error) => {
      window.scrollTo(0, 0);
      setAlertMessage(error);
    });

    if (data.success) {
      setProjectSaved(true);
      if (isNewProject) {
        window.location.assign("/projects?newProjectCreated=1");
      } else {
        setAlertMessage("Project saved.");
        const alertTimer = setTimeout(() => setAlertMessage(undefined), 5000);
        clearTimeout(alertTimer);
      }
    }
    window.scrollTo(0, 0);
  };

  const handleRemoveAdmin = (admin: IProjectAdmin) => (e: React.MouseEvent<HTMLButtonElement>) => {
    const title = project.title.trim().length > 0 ? project.title : "this project";
    if (confirm(`Are you sure you want to remove ${admin.email} as a Project Admin of ${title}?`)) {
      setAdmins(prev => prev.filter(a => a.id !== admin.id));
    }
  };

  const renderProjectAdmins = () => {
    if (!id) {
      return null;
    }

    const renderList = () => {
      if (!projectLoaded) {
        return <div className="emphasis">Loading the admin list ...</div>;
      }

      if (admins.length === 0) {
        return (
          <div className="emphasis">
            There are no project admins assigned to this project.
            Please contact a site admin to add project admins to this project.
          </div>
        );
      }

      return (
        <div>
          <table>
            <tbody>
              {admins.map(admin => (
                <tr key={admin.id}>
                  <td>{admin.email}</td>
                  <td>
                    <button
                      title="Remove this project admin from the project"
                      onClick={handleRemoveAdmin(admin)}>
                        DELETE
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="emphasis">Please contact a site admin to add additional project admins to this project.</div>
        </div>
      );
    };

    return (
      <div className="projectAdmins">
        <label>Project Admins</label>
        {renderList()}
      </div>
    );
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
      <div className="titleContainer">
        <h1>{pageTitle}</h1>
        <button className="save-button" onClick={handleSaveProject}>Save</button>
      </div>
      {alertMessage && <div className="alertMessage">{alertMessage}</div>}
      <div className="splitForm">
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
            <label htmlFor="project-logo-ap">Activity Header Logo URL</label>
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
        </dl>
        {renderProjectAdmins()}
      </div>
      <h2>Activity Homepage Footer</h2>
      <dl>
        <dt>
          <label>Copyright/Attribution Text</label>
        </dt>
        <dd>
          <div className="slateContainer">
            <SlateContainer value={copyrightValue} onValueChange={handleCopyrightChange} />
          </div>
        </dd>
        <dt>
          <label htmlFor="project-copyright-image-url">Copyright Image URL</label>
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
          <label>Funding Source(s) and Collaborator(s) Text</label>
        </dt>
        <dd>
          <div className="slateContainer">
            <SlateContainer value={collaboratorsValue} onValueChange={handleCollaboratorsChange} />
          </div>
        </dd>
        <dt>
          <label htmlFor="project-funders-image-url">Funding Source(s) Image URL</label>
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
          <label>About Text</label>
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
      </dl>
      <h2>Legacy LARA Fields</h2>
      <dl>
        <dd className="inputNote">
          These fields are no longer used but are shown here in case you need to see or copy their values.
        </dd>
        <dt>
          <label htmlFor="project-logo-lara">LARA Runtime Logo URL</label>
        </dt>
        <dd>
          <input
            id="project-logo-lara"
            name="project[logo_lara]"
            defaultValue={project.logoLara}
            disabled={true}
          />
        </dd>
        <dt>
          <label htmlFor="project-url">LARA Runtime Footer</label>
        </dt>
        <dd>
          <textarea
            id="project-footer"
            name="project[footer]"
            defaultValue={project.footer}
            disabled={true}
          />
        </dd>
      </dl>
      <button className="save-button" onClick={handleSaveProject}>Save</button>
    </div>
  );
};
