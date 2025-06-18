import AuthoringPage from "../../support/authoring-page.cy.js";
import ActivitySequenceSettingsPage from "../../support/activity-sequence-settings.cy.js";
import GlossarySettings from "../../support/glossary/glossary-settings.cy.js";

const authoringPage = new AuthoringPage;
const settingsPage = new ActivitySequenceSettingsPage;
const glossarySettings = new GlossarySettings;

const file = {
    activity: "cypress/fixtures/activities/test-automation-activity.json",
    sequence: "cypress/fixtures/sequences/test-automation-sequence.json",
    glossary: "cypress/fixtures/glossary/test-automation-glossary.json"
};

function beforeSequence() {
  cy.visit("");
  cy.deleteImportSequence();
}

function beforeGlossary() {
  cy.visit("");
  cy.deleteImportGlossary();
}

context("Test Import Activity, Sequence and Glossary", () => {
  beforeEach(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    // cy.deleteImportActivity();
  });

  describe("Import Activity, Sequence and Glossary", () => {
    it("Import Test Activity", () => {
      authoringPage.getImportButton().click();
      authoringPage.getImportModal().should("be.visible");
      authoringPage.getImportModalHeader("Import Activity/Sequence/Glossary");
      // This is currently not working as expected, logged as
      // https://concord-consortium.atlassian.net/browse/LARA-184
      // authoringPage.getImportFile(file.activity).should("be.visible");
      // authoringPage.getImportModalButton().should("be.visible").click();
      // settingsPage.getSettingsPage().should("be.visible");
      // settingsPage.verifyEditActivityName("Test Automation Activity");
      // settingsPage.getEditActivityName().should("be.visible").clear().type("Import Test Automation Activity");
      // settingsPage.getEditActivitySaveButton().should("be.visible").click();

      // This is temporay fix for LARA-184 as we need to close the modal
      // before clicking the import button again
      authoringPage.getImportModalClose().should("be.visible").click();
      
      cy.log("Verify Import Modal Cancel Button");
      authoringPage.getImportButton().should("be.visible").click();
      authoringPage.getImportModal().should("be.visible");
      authoringPage.getImportModalCancel().should("be.visible").click();
      // Wait for the modal to be removed from the DOM
      authoringPage.getImportModal().should("not.be.visible");
      
      cy.log("Verify Import Modal Close Button");
      authoringPage.getImportButton().should("be.visible").click();
      authoringPage.getImportModal().should("be.visible");
      authoringPage.getImportModalClose().should("be.visible").click();
      authoringPage.getImportModal().should("not.be.visible");
    });
    // Skipping this test due to LARA-184
    // TODO: Put this in the test above once LARA-184 is fixed
    // Segment the test with a cy.log() statement to make it easier to debug
    it.skip("Verify Delete Import Activity", () => {
      authoringPage.searchActivitySequence("Import Test Automation Activity");
      authoringPage.getActivityDeleteMenu().should("be.visible").click();
      authoringPage.clickHomePageLink();
      authoringPage.searchActivitySequence("Import Test Automation Activity");
      authoringPage.getActivity().should("not.exist");
    });

    // Skipping this test due to LARA-184
    it.skip("Import Test Sequence", () => {
      beforeSequence();
      authoringPage.getImportButton().should("be.visible").click();
      authoringPage.getImportModal().should("be.visible");
      authoringPage.getImportModalHeader("Import Activity/Sequence/Glossary");
      authoringPage.getImportFile(file.sequence).should("be.visible");
      authoringPage.getImportModalButton().should("be.visible").click();
      settingsPage.getSettingsPage().should("be.visible");
      settingsPage.verifyEditSequenceName("Test Automation Sequence");
      settingsPage.getEditSequenceName().should("be.visible").clear().type("Import Test Automation Sequence");
      settingsPage.getEditSequenceSaveButton().should("be.visible").click();
      settingsPage.getSettingsPage().should("not.exist");
    });

    // Skipping this test due to LARA-184
    it.skip("Verify Delete Import Sequence", () => {
      cy.visit("");
      authoringPage.searchActivitySequence("Import Test Automation Sequence");
      authoringPage.getSequenceDeleteMenu().should("be.visible").click();
      authoringPage.clickHomePageLink();
      authoringPage.searchActivitySequence("Import Test Automation Sequence");
      authoringPage.getSequence().should("not.exist");
    });

    it("Import Test Glossary", () => {
      beforeGlossary();
      authoringPage.getImportButton().should("be.visible").click();
      authoringPage.getImportModal().should("be.visible");
      authoringPage.getImportModalHeader("Import Activity/Sequence/Glossary");
      authoringPage.getImportFile(file.glossary).should("be.visible");
      authoringPage.getImportModalButton().should("be.visible").click();
      glossarySettings.getGlossaryNameField().should("be.visible").should('have.value', 'Test Automation Glossary');
      glossarySettings.getEditSaveButton().should("be.visible").click();
      glossarySettings.getGlossaryNameField().should("be.visible").clear().type("Import Test Automation Glossary");
      glossarySettings.getEditSaveButton().should("be.visible").click();
      glossarySettings.getGlossaryNameField().should("be.disabled");

      cy.log("Verify Delete Import Glossary")
      cy.visit("");
      authoringPage.searchActivitySequence("Import Test Automation Glossary");
      authoringPage.getGlossaryDeleteMenu().should("be.visible").click();
      authoringPage.clickHomePageLink();
      authoringPage.searchActivitySequence("Import Test Automation Glossary");
      authoringPage.getGlossary().should("not.exist");
    });
  });
});

