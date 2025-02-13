import AuthoringPage from "../../support/authoring-page.cy.js";
import ActivityPlayerPreview from "../../support/activity-player-preview.cy.js";
import DrawingAuthoringPage from "../../support/drawing-authoring.cy.js";

const authoringPage = new AuthoringPage;
const drawingAuthoringPage = new DrawingAuthoringPage;
const activityPlayerPreview = new ActivityPlayerPreview;

function previewTest() {
  cy.visit("");
  authoringPage.previewActivity("Test Automation Drawing Question Activity");
}

context("Test Background Source As URL", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.launchActivity("Test Automation Drawing Question Activity");
    cy.deleteItem();
  });

  describe("LARA Drawing Tool Question", () => {
    it("Add Drawing Tool Item", () => {
      authoringPage.getAddItem().click();
      authoringPage.getItemPickerSearch().type("Drawing Tool");
      authoringPage.getItemPickerList().contains("Drawing Tool (AWS)").click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type("Drawing Question");
      authoringPage.getPromptField(" Drawing Question Prompt");
      authoringPage.getHintField(" Drawing Question Hint");
      authoringPage.getHideToolbarButtonsField().should("exist");
      authoringPage.getHideToolbarButtonsField().parent().find('label').should("contain", "Hide Toolbar Buttons");
      authoringPage.getHideToolbarButtonsField().should("contain", "Check the boxes below to hide draw tool buttons from the toolbar");
      authoringPage.verifyHideToolbarButtons();
      authoringPage.selectHideToolbarButtons(0);
      authoringPage.selectHideToolbarButtons(1);
      authoringPage.selectHideToolbarButtons(2);
      cy.wait(5000);
      authoringPage.getSaveButton().click();
      cy.wait(5000);
    });
    it("Verify hidden draw tools are not displayed", () => {
      previewTest();
      activityPlayerPreview.getActivityTitle().should("contain", "Test Automation Drawing Question Activity");
      activityPlayerPreview.clickPageItem(0);
      cy.wait(10000);
      drawingAuthoringPage.verifyDrawToolNotDisplayed("Free hand drawing tool");
      drawingAuthoringPage.verifyDrawToolNotDisplayed("Line tool");
      drawingAuthoringPage.verifyDrawToolNotDisplayed("Basic shape tool");
      drawingAuthoringPage.verifyDrawToolDisplayed("Text tool");
      drawingAuthoringPage.verifyDrawToolDisplayed("Stroke color");
      drawingAuthoringPage.verifyDrawToolDisplayed("Fill color");
    });
    it("Delete Item", () => {
      cy.visit("");
      authoringPage.launchActivity("Test Automation Drawing Question Activity");
      cy.wait(6000);
      authoringPage.getSectionMenuDelete().click();
    });
  });
});
