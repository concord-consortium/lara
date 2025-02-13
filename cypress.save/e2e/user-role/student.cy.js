import AuthoringPage from "../../support/authoring-page.cy.js";
import ActivitySequenceSettingsPage from "../../support/activity-sequence-settings.cy.js";
import AddEditDeleteTerm from "../../support/glossary/add-edit-delete-term.cy.js";

const authoringPage = new AuthoringPage;
const settingsPage = new ActivitySequenceSettingsPage;
const glossary = new AddEditDeleteTerm;

context("Test Student User Role", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().student, Cypress.env("password"));
  });

  describe("LARA2 Student User Role", () => {
    it("Student User Role", () => {
      settingsPage.getCreateButton().should("not.exist");
      authoringPage.searchActivitySequence("Teacher 2 Activity");
      authoringPage.getActivityEditMenu().should("not.exist");
      authoringPage.getActivityDeleteMenu().should("not.exist");
      authoringPage.getActivityPublishMenu().should("not.exist");
      authoringPage.getActivityPrintMenu().should("exist");
      authoringPage.getActivityRunMenu().should("exist");
      authoringPage.searchActivitySequence("Author Sequence");
      authoringPage.getSequenceEditMenu().should("not.exist");
      authoringPage.getSequenceDeleteMenu().should("not.exist");
      authoringPage.getSequencePublishMenu().should("not.exist");
      authoringPage.getSequencePrintMenu().should("exist");
      authoringPage.getSequenceRunMenu().should("exist");
      authoringPage.searchActivitySequence("Test Automation Glossary Settings 1");
      authoringPage.getGlossaryDeleteMenu().should("not.exist");
      authoringPage.getGlossaryEditMenu().click();
      cy.wait(2000);
      glossary.getGlossaryNotice();
      glossary.getSaveIndicator();

    });
  });
});
