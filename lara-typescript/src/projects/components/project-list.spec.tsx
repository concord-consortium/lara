import * as React from "react";
import * as ReactDOM from "react-dom";
import * as fetch from "jest-fetch-mock";
import { ProjectList } from "./project-list";
import { act } from "react-dom/test-utils";
(global as any).fetch = fetch;

describe("Project list component", () => {
  const project1 = {
    about: "",
    collaborators: "",
    collaborators_image_url: "",
    contact_email: "",
    copyright: "",
    copyright_image_url: "",
    footer: "",
    funders_image_url: "",
    id: 1,
    logo_ap: "",
    logo_lara: "",
    project_key: "project1",
    theme_id: undefined,
    title: "Test Project 1",
    url: "https://concord.org/project1"
  };
  const project2 = {
    about: "",
    collaborators: "",
    collaborators_image_url: "",
    contact_email: "",
    copyright: "",
    copyright_image_url: "",
    footer: "",
    funders_image_url: "",
    id: 2,
    logo_ap: "",
    logo_lara: "",
    project_key: "project2",
    theme_id: undefined,
    title: "Test Project 2",
    url: "https://concord.org/project2"
  };
  let container: HTMLDivElement;

  beforeEach(() => {
    fetch.resetMocks();
    container = document.createElement("div");
    document.body.appendChild(container);
    global.scrollTo = jest.fn() as jest.Mock<any>;
    global.confirm = jest.fn(() => true) as jest.Mock<any>;
  });

  afterAll(() => {
    jest.restoreAllMocks();
  });

  it("should exist", () => {
    expect(ProjectList).toBeDefined();
  });

  it("renders a list of projects", async () => {
    fetch.mockResponseOnce(JSON.stringify({projects: [project1, project2]}));
    await act(async () => {
      ReactDOM.render(<ProjectList />, container);
    });
    const pageTitle = container.querySelector("h1") as HTMLHeadingElement;
    const projectList = container.querySelector(".projectList") as HTMLUListElement;
    expect(fetch).toHaveBeenCalledTimes(1);
    expect(pageTitle.textContent).toBe("Projects");
    expect(projectList.children).toHaveLength(2);
    const projectListItem1 = projectList.children[0] as HTMLLIElement;
    const projectListItem2 = projectList.children[1] as HTMLLIElement;
    expect(projectListItem1.innerHTML).toContain("Test Project 1");
    expect(projectListItem2.innerHTML).toContain("Test Project 2");
  });

  it("renders an updated projects list after a project is deleted", async () => {
    fetch.mockResponseOnce(JSON.stringify({projects: [project1, project2]}));
    await act(async () => {
      ReactDOM.render(<ProjectList />, container);
    });
    const projectList = container.querySelector(".projectList") as HTMLUListElement;
    expect(projectList.children).toHaveLength(2);
    const deleteButtons = container.querySelectorAll(".deleteButton");
    const project1DeleteButton = deleteButtons[0] as HTMLButtonElement;
    fetch.mockResponse(JSON.stringify({success: true, projects: [project2]}));
    await act(async () => {
      project1DeleteButton.dispatchEvent(new MouseEvent("click", {bubbles: true}));
    });
    expect(global.confirm).toHaveBeenCalledTimes(1);
    expect(fetch).toHaveBeenCalledTimes(4);
    expect(projectList.children).toHaveLength(1);
  });
});
