import AuthoringPage from "../../support/authoring-page.cy.js";
import RunTimePreview from "../../support/run-time-preview.cy.js";

const authoringPage = new AuthoringPage;
const runTimePreview = new RunTimePreview;

function searchActivity() {
  cy.visit("");
  cy.searchActivity("Automation Question Interactives Activity");
}

function searchSequence() {
  cy.visit("");
  cy.searchSequence("Automation Question Interactives Sequence");
}

context("Test Authoring Runtime Preview", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    cy.launchActivty();
  });

  describe("LARA Activity Player Runtime Preview", () => {
    it("Verify Activity Player Runtime Preview", () => {
      authoringPage.selectPreviewIn("Activity Player");
      authoringPage.getActivityPlayerRuntimePreview();
      authoringPage.getActivityPlayerRuntimeTEPreview();
      authoringPage.clickActivityPageLink();
      authoringPage.getActivityLevelPreview();
      authoringPage.getActivityLevelTEPreview();
    });
    it("Verify Activity Run Link ", () => {
      searchActivity();
      authoringPage.getActivityRunLinkPreview();
    });
    it("Verify Sequence Run Link", () => {
      searchSequence();
      authoringPage.getSequenceRunLinkPreview();
      authoringPage.getSequenceRunMenu().click();
      runTimePreview.getSequenceContent().should("exist");
      runTimePreview.getSequenceHeaderTitle().should("contain", "Sequence: Automation Question Interactives Sequence");
      runTimePreview.getSequenceTitle().should("contain", "Automation Question Interactives Sequence");
      runTimePreview.getSequenceEstimated().should("contain", "Estimated Time to Complete This Module:");
      runTimePreview.getSequenceEstimatedTime().should("contain", "0 minutes");
      runTimePreview.getSequenceActivityName().should("contain", "Automation Question Interactives Activity");
    });
  });
});
