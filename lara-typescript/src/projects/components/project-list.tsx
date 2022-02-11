import * as React from "react";
import { useEffect, useState} from "react";
import { ProjectListItem } from "./project-list-item";
import { IProject } from "../types";

import "./project-list.scss";

export const ProjectList: React.FC = () => {
  const [projects, setProjects] = useState<IProject[]>([]);
  const [projectsUpdated, setProjectsUpdated] = useState(false);
  const [alertMessage, setAlertMessage] = useState<string|undefined>(undefined);

  const urlParams = new URLSearchParams(window.location.search);
  const newProjectCreated = urlParams.get("newProjectCreated");

  useEffect(() => {
    getProjects();
    setProjectsUpdated(false);
    if (newProjectCreated) {
      setAlertMessage("Project created.");
    }
  }, [projectsUpdated]);

  const getProjects = () => {
    const apiUrl = `/api/v1/projects`;
    fetch(apiUrl, {
      method: "GET",
      headers: {"Content-Type": "application/json"},
      credentials: "include"
    })
    .then(response => response.json())
    .then(data => {
      setProjects(data);
    })
    .catch(error => {
      setAlertMessage(error);
    });
  };

  const handleCreateNewButtonClick = () => {
    window.location.href = "/projects/new";
  };

  const handleDeleteRequest = (projectId: number) => {
    if (confirm("Are you sure you want to delete this project?")) {
      const apiUrl = `/api/v1/delete_project/${projectId}`;
      fetch(apiUrl, {
        method: "POST",
        headers: { "Content-Type": "application/json"},
        credentials: "include",
        body: JSON.stringify({id: projectId})
      })
      .then(response => response.json())
      .then(data => {
        window.scrollTo(0, 0);
        if (data.success) {
          setAlertMessage("Project deleted.");
          const alertTimer = setTimeout(() => setAlertMessage(undefined), 5000);
          clearTimeout(alertTimer);
          setProjectsUpdated(true);
        }
      })
      .catch(error => {
        window.scrollTo(0, 0);
        setAlertMessage(error);
      });
    }
  };

  return (
    <div className="projectList">
      <nav>
        <div className="breadcrumbs">
          <ul>
            <li><a href="/">Home</a> </li>
            <li>&nbsp;/ All Projects</li>
          </ul>
        </div>
      </nav>
      <div className="buttons-menu">
        <button onClick={handleCreateNewButtonClick}>
          Create New Project
        </button>
      </div>
      <h1 className="title">Projects</h1>
      {alertMessage && <div className="alertMessage">{alertMessage}</div>}
      <ul>
        {projects.map((project, index) => (
          <ProjectListItem
            key={`project-${index}`}
            id={project.id}
            title={project.title}
            url={project.url}
            onDelete={handleDeleteRequest}
          />
        ))}
      </ul>
    </div>
  );
};
