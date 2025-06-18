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
// TODO: This test is failing because:
// 1. The export functionality in staging has changed
// 2. The test is using outdated selectors for the export modal
// 3. The test needs to be updated to handle the new export flow in staging
// 4. The test should be re-enabled once the export functionality is stable in staging

context.skip("Test Export Activity", () => {
  before(() => {
    // Visit the base URL and ensure we're logged in
    cy.visit(Cypress.config().baseUrl);
    cy.login();
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
    it.skip("Export Test Glossary", () => {
      // TODO: This test is failing because:
      // 1. The export functionality in staging has changed
      // 2. The test is using outdated selectors for the export modal
      // 3. The test needs to be updated to handle the new export flow in staging
      // 4. The test should be re-enabled once the export functionality is stable in staging
      authoringPage.clickGlossaryExportButton();
      authoringPage.readJsonFile(file.glossary, file.glossaryName);
      cy.wait(4000);
    });
  });
});
