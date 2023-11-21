import * as React from "react";
import * as ReactDOM from "react-dom";
import * as fetch from "jest-fetch-mock";
import { ProjectSettingsForm } from "./project-settings-form";
import { act } from "react-dom/test-utils";
import { fireEvent } from "@testing-library/dom";
(global as any).fetch = fetch;

describe("ProjectSettingsForm", () => {
  const pageLocation = global.location;
  const project1Id = 1;
  const project1Key = "project1";
  const project1Title = "Test Project 1";
  const project1Url = "https://concord.org/test-project-1";
  const project = {
    about: "",
    collaborators: "",
    collaboratorsImageUrl: "",
    contactEmail: "",
    copyright: "",
    copyrightImageUrl: "",
    footer: "",
    fundersImageUrl: "",
    id: project1Id,
    logoLara: "",
    logoAp: "",
    projectKey: project1Key,
    title: project1Title,
    url: project1Url
  };
  let container: HTMLDivElement;

  beforeEach(() => {
    fetch.resetMocks();
    container = document.createElement("div");
    document.body.appendChild(container);
    global.scrollTo = jest.fn(() => true) as jest.Mock<any>;
    delete (global as any).location;
    (global as any).location = Object.defineProperties(
      {},
      {
        ...Object.getOwnPropertyDescriptors(pageLocation),
        assign: {
          configurable: true,
          value: jest.fn()
        }
      }
    );
  });

  afterAll(() => {
    jest.restoreAllMocks();
    global.location = pageLocation;
  });

  it("should exist", () => {
    expect(ProjectSettingsForm).toBeDefined();
  });

  it("renders a form with options for project settings", async () => {
    fetch.mockResponse(JSON.stringify({project, admins: []}));
    await act(async () => {
      ReactDOM.render(<ProjectSettingsForm id={project1Id} />, container);
    });
    const pageHeading = container.querySelector("h1") as HTMLHeadingElement;
    const collaboratorsImageUrlInput = container.querySelector("#project-collaborators-image-url") as HTMLInputElement;
    const contactEmailInput = container.querySelector("#project-contact-email") as HTMLInputElement;
    const copyrightImageUrlInput = container.querySelector("#project-copyright-image-url") as HTMLInputElement;
    const footerInput = container.querySelector("#project-logo-lara") as HTMLTextAreaElement;
    const fundersImageUrlInput = container.querySelector("#project-funders-image-url") as HTMLInputElement;
    const keyInput = container.querySelector("#project-key") as HTMLInputElement;
    const logoApInput = container.querySelector("#project-logo-ap") as HTMLInputElement;
    const logoLaraInput = container.querySelector("#project-logo-lara") as HTMLInputElement;
    const titleInput = container.querySelector("#project-title") as HTMLInputElement;
    const urlInput = container.querySelector("#project-url") as HTMLInputElement;
    expect(fetch).toHaveBeenCalledTimes(1);
    expect(pageHeading.textContent).toBe(`Edit ${project1Title}`);
    expect(collaboratorsImageUrlInput).toBeTruthy();
    expect(contactEmailInput).toBeTruthy();
    expect(copyrightImageUrlInput).toBeTruthy();
    expect(footerInput).toBeTruthy();
    expect(fundersImageUrlInput).toBeTruthy();
    expect(keyInput.defaultValue).toBe(project1Key);
    expect(logoApInput).toBeTruthy();
    expect(logoLaraInput).toBeTruthy();
    expect(titleInput).toBeTruthy();
    expect(titleInput.defaultValue).toBe(project1Title);
    expect(urlInput).toBeTruthy();
    expect(urlInput.defaultValue).toBe(project1Url);
  });

  it("saves changes to project settings", async () => {
    fetch.mockResponse(JSON.stringify({project, admins: []}));
    await act(async () => {
      ReactDOM.render(<ProjectSettingsForm id={project1Id} />, container);
    });
    const titleInput = container.querySelector("#project-title") as HTMLInputElement;
    const urlInput = container.querySelector("#project-url") as HTMLInputElement;
    const saveButton = container.querySelector(".save-button") as HTMLButtonElement;
    const updatedProject = {...project, title: "Test Project A", url: "https://concord.org/new-path"};
    fetch.mockResponse(JSON.stringify({project: updatedProject, admins: [], success: true}));
    await act(async () => {
      fireEvent.change(titleInput, { target: { value: "Test Project A"} });
      fireEvent.change(urlInput, { target: { value: "https://concord.org/new-path"} });
      saveButton.dispatchEvent(new MouseEvent("click", {bubbles: true}));
    });
    const alertMessage = container.querySelector(".alertMessage") as HTMLDivElement;
    expect(fetch).toHaveBeenCalledTimes(3);
    expect(alertMessage.textContent).toBe("Project saved.");
    expect(titleInput.defaultValue).toBe("Test Project A");
    expect(urlInput.defaultValue).toBe("https://concord.org/new-path");
  });

  it("generates a project key automatically for new projects", async () => {
    await act(async () => {
      ReactDOM.render(<ProjectSettingsForm id={null} />, container);
    });
    const titleInput = container.querySelector("#project-title") as HTMLInputElement;
    const keyInput = container.querySelector("#project-key") as HTMLInputElement;
    act(() => {
      fireEvent.focus(titleInput);
      fireEvent.change(titleInput, { target: { value: "New Project Title"} });
      fireEvent.blur(titleInput);
      fireEvent.focus(keyInput);
    });
    expect(keyInput.defaultValue).toBe("new-project-title");
  });

  it("saves new project and redirects", async () => {
    fetch.mockResponse(JSON.stringify({success: true}));
    await act(async () => {
      ReactDOM.render(<ProjectSettingsForm id={null} />, container);
    });
    const titleInput = container.querySelector("#project-title") as HTMLInputElement;
    const saveButton = container.querySelector(".save-button") as HTMLButtonElement;
    await act(async () => {
      fireEvent.change(titleInput, { target: { value: "New Project Title"} });
      fireEvent.blur(titleInput);
      saveButton.dispatchEvent(new MouseEvent("click", {bubbles: true}));
    });
    expect(fetch).toHaveBeenCalledTimes(1);
    // when saving a new project is successful, the page redirects to the main projects list
    expect(global.location.assign).toHaveBeenCalledTimes(1);
  });
});
