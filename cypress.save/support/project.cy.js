class Projects {
  getHeaderMenu() {
    return cy.get("[data-cy='header-menu']");
  }
  clickHeaderMenu() {
    this.getHeaderMenu().click();
    cy.wait(1000);
  }
  launchUserAdmin() {
    this.clickHeaderMenu();
    cy.get("[data-cy=header-menu] .header-menu-links.show a").contains("User Admin").click();
  }
  launchProjects() {
    this.clickHeaderMenu();
    cy.get("[data-cy=header-menu] .header-menu-links.show a").contains("Projects").click();
  }

// Projects
  getProject(project) {
  return cy.get("#projectList .projectListItem .projectListItem__title").contains(project);
  }
  getProjectEditButton(project) {
    return this.getProject(project).parent().find("menu .editButton");
  }
  getProjectDeleteButton(project) {
    return this.getProject(project).parent().find("menu .deleteButton");
  }
  getProjectAdminSection() {
    return cy.get("#projectEditForm .projectAdmins");
  }
  verifyProjectAdminLabel() {
    this.getProjectAdminSection().find("label").should("have.text", "Project Admins");
  }
  verifyNoProjectAdminEmphasis() {
    this.getProjectAdminSection().find(".emphasis").should("contain", "There are no project admins assigned to this project. Please contact a site admin to add project admins to this project.");
  }
  clickSaveButton() {
    cy.get("#projectEditForm .titleContainer .save-button").click();
    cy.wait(2000);
    cy.get("#projectEditForm .alertMessage").should("contain", "Project saved.");
  }
  getProjectAdminList() {
    return this.getProjectAdminSection().find(".projectAdminsList");
  }
  verifyProjectAdminUser(user) {
    this.getProjectAdminList().find(".projectAdminsListItem").should("contain", user);
  }
  verifyAddProjectAdminEmphasis() {
    this.getProjectAdminList().find(".emphasis").should("contain", "Please contact a site admin to add additional project admins to this project.");
  }
  deleteProjectAdmin() {
    this.getProjectAdminList().find(".projectAdminsListItem button").click();
  }
  deleteUser(project) {
    this.launchProjects();
    this.getProjectEditButton(project).click();
    cy.wait(2000);
    cy.get("body").then($body => {
      if ($body.find(".projectAdminsList .projectAdminsListItem").length > 0) {
        cy.log("Delete User");
        this.deleteProjectAdmin();
        this.clickSaveButton();
        cy.wait(2000);
        cy.get('.breadcrumbs a').eq(0).click();
        cy.wait(1000);
      } else {
        cy.log("No user To Delete");
        cy.get('.breadcrumbs a').eq(0).click();
        cy.wait(1000);
      }
    });
  }
  editResource(resource) {
    cy.log("Launch Test Activity : ");
    cy.get("#search input").eq(0).type(resource);
    cy.get("#search input").eq(1).click();
    cy.wait(1000);
    cy.get(".action_menu_header_right .edit a").click();
    cy.wait(1000);
  }
  getProjectSectionActivity() {
    return cy.get("#lightweight_activity_project_id").parent();
  }
  verifyProjectLabelActivity() {
    this.getProjectSectionActivity().find('label').should("contain", "Project");
  }
  verifyProjectDropDownActivity(user, project) {
    switch (user) {
      case "SiteAdmin":
        this.getProjectSectionActivity().find("select option").should('have.length.greaterThan', 5)
        break;
      case "ProjectAdmin": 
        this.getProjectSectionActivity().find("select option").should('have.length',2);
        this.getProjectSectionActivity().find("select").should("contain", project)
        break;
    }
  }
  getProjectSectionSequence() {
    return cy.get("#sequence_project_id").parent();
  }
  verifyProjectLabelSequence() {
    this.getProjectSectionSequence().find('label').should("contain", "Project");
  }
  verifyProjectDropDownSequence(user, project) {
    switch (user) {
      case "SiteAdmin":
        this.getProjectSectionSequence().find("select option").should('have.length.greaterThan', 5)
        break;
      case "ProjectAdmin": 
        this.getProjectSectionSequence().find("select option").should('have.length',2);
        this.getProjectSectionSequence().find("select").should("contain", project)
        break;
    }
  }
  verifyProjectNotDisplayedInActivity() {
    cy.get(".edit_lightweight_activity").find("#lightweight_activity_project_id").should("not.exist");
  }
  verifyProjectNotDisplayedInSequence() {
    cy.get(".edit_sequence").find("#sequence_project_id").should("not.exist");
  }
  getProjectSectionGlossary() {
    return cy.get("#glossary_authoring_form [class^='edit-project--editProject']").parent();
  }
  verifyProjectLabelGlossary() {
    this.getProjectSectionGlossary().find('h2').should("contain", "Project");
  }
  clickEditProject() {
    this.getProjectSectionGlossary().find("button").click();
  }
  verifyProjectDropDownGlossary(user, project) {
    switch (user) {
      case "SiteAdmin":
        this.getProjectSectionGlossary().find("select option").should('have.length.greaterThan', 5)
        break;
      case "ProjectAdmin": 
        this.getProjectSectionGlossary().find("select option").should('have.length',2);
        this.getProjectSectionGlossary().find("select").should("contain", project)
        break;
      case "Author": 
        this.getProjectSectionGlossary().find("select option").should('have.length',1);
        break;
    }
  }

// User Admin
  searchUser(user) {
    cy.get("#content .search #q").type(user);
    cy.get("#content .search input").eq(1).click();
    cy.wait(1000);
  }
  editUser(user) {
    cy.get("#content .users tr td").contains(user).parent().find('a').contains("Edit").click();
    cy.wait(1000);
  }
  getProjectAdminForProjects() {
    return cy.get(".edit_user fieldset").eq(1);
  }
  verifyProjectLegend() {
    this.getProjectAdminForProjects().find("legend").should("contain", "Project Admin for Projects");
  }
  checkProject(project) {
    this.getProjectAdminForProjects().find(".normal").contains(project).parent().find("input").check();
    cy.wait(1000);
  }
  clickUpdateUser() {
    cy.get(".edit_user [value='Update User']").click();
    cy.wait(1000);
    cy.get("#content .notice").should("exist").and("contain", "User was successfully updated.");
  }
}
export default Projects;
