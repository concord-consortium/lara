import AuthoringPage from "../../support/authoring-page.cy.js";
import ActivitySequenceSettingsPage from "../../support/activity-sequence-settings.cy.js";
import GlossarySettings from "../../support/glossary/glossary-settings.cy.js";

const authoringPage = new AuthoringPage;
const settingsPage = new ActivitySequenceSettingsPage;
const glossarySettings = new GlossarySettings;

const file = {
    activity: "cypress/downloads/Test Automation Activity Export_version_2.json",
    sequence: "cypress/downloads/Test Automation Sequence Export_version_2.json",
    glossary: "cypress/downloads/Test Automation Glossary Export_version_2.json",
    activityName: "Test Automation Activity Export",
    sequenceName: "Test Automation Sequence Export",
    glossaryName: "Test Automation Glossary Export"
};

context("Test Export Activity", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
  });

  describe("Export Activity", () => {
    it("Export Test Activity", () => {
      authoringPage.searchActivitySequence(file.activityName);
      authoringPage.getActivityExportMenu().click();
      authoringPage.getExportModel().should("exist");
      authoringPage.getExportModelHeader("Export Activity");
      authoringPage.getExportModelInfo(file.activityName);
      authoringPage.clickExportButton();
      authoringPage.readJsonFile(file.activity, file.activityName);
      cy.wait(4000);
    });
    it("Export Test Sequence", () => {
      cy.visit("");
      cy.wait(4000);
      authoringPage.searchActivitySequence(file.sequenceName);
      authoringPage.getSequenceExportMenu().click();
      authoringPage.getExportModel().should("exist");
      authoringPage.getExportModelHeader("Export Sequence");
      authoringPage.getExportModelInfo(file.sequenceName);
      authoringPage.clickExportButton();
      authoringPage.readSequenceJsonFile(file.sequence, file.sequenceName);
      cy.wait(4000);
    });
    it("Export Test Glossary", () => {
      cy.visit("");
      cy.wait(4000);
      authoringPage.searchActivitySequence(file.glossaryName);
      authoringPage.clickGlossaryExportButton();
      authoringPage.readJsonFile(file.glossary, file.glossaryName);
      cy.wait(4000);
    });
  });
});
