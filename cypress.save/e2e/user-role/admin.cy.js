import AuthoringPage from "../../support/authoring-page.cy.js";
import ActivitySequenceSettingsPage from "../../support/activity-sequence-settings.cy.js";

const authoringPage = new AuthoringPage;
const settingsPage = new ActivitySequenceSettingsPage;

context("Test Admin User Role", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
  });

  describe("LARA2 Admin User Role", () => {
    it("Admin User Role", () => {
      settingsPage.getCreateActivityButton().should("exist");
      settingsPage.getCreateSequenceButton().should("exist");
      settingsPage.getCreateGlossaryButton().should("exist");
      authoringPage.searchActivitySequence("Test Automation Activity Settings");
      authoringPage.getActivityEditMenu().should("exist");
      authoringPage.getActivityDeleteMenu().should("exist");
      authoringPage.getActivityPublishMenu().should("exist");
      authoringPage.searchActivitySequence("Test Automation Sequence Settings");
      authoringPage.getSequenceEditMenu().should("exist");
      authoringPage.getSequenceDeleteMenu().should("exist");
      authoringPage.getSequencePublishMenu().should("exist");
      authoringPage.searchActivitySequence("Test Automation Glossary Settings 1");
      authoringPage.getGlossaryEditMenu().should("exist");
      authoringPage.getGlossaryDeleteMenu().should("exist");
    });
  });
});
