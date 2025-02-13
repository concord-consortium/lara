import Projects from "../../support/project.cy.js";

const projects = new Projects;

const data = {
  project: "Automation Project",
  user: "project.automationteacher2",
  siteAdmin_Activity: "Automation Site Admin Activity",
  projectAdmin_Activity: "Automation Project Admin Activity Assigned",
  author_Activity: "Automation Author Activity",
  siteAdmin_Sequence: "Automation Site Admin Sequence",
  projectAdmin_Sequence: "Automation Project Admin Sequence Assigned",
  author_Sequence: "Automation Author Sequence",
  siteAdmin_Glossary: "Automation Site Admin Glossary",
  projectAdmin_Glossary: "Automation Project Admin Glossary Assigned",
  author_Glossary: "Automation Author Glossary",
  projectAdmin_Project: "Project Admin Automation"
};

function beforeTest(user) {
  cy.visit("");
  cy.loginLARAWithSSO(user, Cypress.env("password"));
};

context("Test Admin User Role", () => {
  describe("LARA Project Edit Page", () => {
    it("Project Admin User Role", () => {
      cy.log("Verify no project admin emphasis");
      beforeTest(Cypress.config().site_admin);
      projects.deleteUser(data.project);
      projects.launchProjects();
      projects.getProjectEditButton(data.project).click();
      projects.verifyProjectAdminLabel();
      projects.verifyNoProjectAdminEmphasis();

      cy.log("Add project admin to the Project");
      projects.launchUserAdmin();
      projects.editUser(data.user);
      projects.verifyProjectLegend();
      projects.checkProject(data.project);
      projects.clickUpdateUser();

      cy.log("Verify added project admin is displayed in project");
      projects.launchProjects();
      projects.getProjectEditButton(data.project).click();
      projects.verifyProjectAdminUser(data.user);
      projects.verifyAddProjectAdminEmphasis();

      cy.log("Delete project admin");
      projects.deleteProjectAdmin();
      projects.verifyNoProjectAdminEmphasis();
      projects.clickSaveButton();
    });
  });

  describe("LARA Project Admin, Site Admin and Author Roles", () => {
    it("verify Site Admin user role", () => {
      cy.log("Verify all the project displayed for site admin");
      cy.visit("");
      projects.editResource(data.siteAdmin_Activity);
      projects.getProjectSectionActivity().should("exist");
      projects.verifyProjectLabelActivity();
      projects.verifyProjectDropDownActivity("SiteAdmin", "");
      cy.get('.breadcrumbs a').eq(0).click();
      cy.wait(1000);
      projects.editResource(data.siteAdmin_Sequence);
      projects.getProjectSectionSequence().should("exist");
      projects.verifyProjectLabelSequence();
      projects.verifyProjectDropDownSequence("SiteAdmin");
      cy.get('.breadcrumbs a').eq(0).click();
      cy.wait(1000);
      projects.editResource(data.siteAdmin_Glossary);
      projects.getProjectSectionGlossary().should("exist");
      projects.verifyProjectLabelGlossary();
      projects.clickEditProject();
      projects.verifyProjectDropDownGlossary("SiteAdmin", "");
    });
    it.skip("verify Project Admin user role", () => {
      cy.log("Verify only assigned project displayed for project admin");
      cy.logoutLARA(Cypress.config().site_admin);
      beforeTest(Cypress.config().project_admin);
      projects.editResource(data.projectAdmin_Activity);
      projects.getProjectSectionActivity().should("exist");
      projects.verifyProjectLabelActivity();
      projects.verifyProjectDropDownActivity("ProjectAdmin", data.projectAdmin_Project);
      cy.get('.breadcrumbs a').eq(0).click();
      cy.wait(1000);
      projects.editResource(data.projectAdmin_Sequence);
      projects.getProjectSectionSequence().should("exist");
      projects.verifyProjectLabelSequence();
      projects.verifyProjectDropDownSequence("ProjectAdmin", data.projectAdmin_Project);
      cy.get('.breadcrumbs a').eq(0).click();
      cy.wait(1000);
      projects.editResource(data.projectAdmin_Glossary);
      projects.getProjectSectionGlossary().should("exist");
      projects.verifyProjectLabelGlossary();
      projects.clickEditProject();
      projects.verifyProjectDropDownGlossary("ProjectAdmin", data.projectAdmin_Project);
    });
    it.skip("verify Author user role", () => {
      cy.log("Verify project is not displayed for author");
      cy.logoutLARA(Cypress.config().project_admin);
      beforeTest(Cypress.config().teacher);
      projects.editResource(data.author_Activity);
      projects.verifyProjectNotDisplayedInActivity();
      cy.get('.breadcrumbs a').eq(0).click();
      cy.wait(1000);
      projects.editResource(data.author_Sequence);
      projects.verifyProjectNotDisplayedInSequence();
      cy.get('.breadcrumbs a').eq(0).click();
      cy.wait(1000);
      projects.editResource(data.author_Glossary);
      projects.getProjectSectionGlossary().should("exist");
      projects.verifyProjectLabelGlossary();
      projects.clickEditProject();
      projects.verifyProjectDropDownGlossary("Author", "");
    });
  });
});
