import AuthoringPage from "../../support/authoring-page.cy.js";
import ActivityPlayerPreview from "../../support/activity-player-preview.cy.js";
import LabbookAuthoringPage from "../../support/labbook-authoring.cy.js";

const authoringPage = new AuthoringPage;
const labbookAuthoringPage = new LabbookAuthoringPage;
const activityPlayerPreview = new ActivityPlayerPreview;

function beforeTest() {
  cy.visit("");
  authoringPage.previewActivity("Test Automation Labbook Activity");
}

context("Test Background Source As URL", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.launchActivity("Test Automation Labbook Activity");
    cy.deleteItem();
  });

  describe("LARA Labbook With Background Source As URL", () => {
    it("Add Labbook Item", () => {
      authoringPage.getAddItem().click();
      authoringPage.getItemPickerSearch().type("Lab Book");
      authoringPage.getItemPickerList().contains("Lab Book (AWS)").click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type("Labbook Question");
      authoringPage.getPromptField(" Labbook Question Prompt");
      authoringPage.getHintField(" Labbook Question Hint");
      labbookAuthoringPage.selectBackgroundSource("URL");
      labbookAuthoringPage.enterBackgroundImageUrl("https://learn-resources.concord.org/tutorials/images/brogan-acadia.jpg");
      labbookAuthoringPage.getHideToolbarButtonsField().should("exist");
      labbookAuthoringPage.getHideToolbarButtonsField().parent().find('label').should("contain", "Hide Toolbar Buttons");
      labbookAuthoringPage.getHideToolbarButtonsField().should("contain", "Check the boxes below to hide draw tool buttons from the toolbar.");
      labbookAuthoringPage.verifyHideToolbarButtons();
      labbookAuthoringPage.selectHideToolbarButtons(2);
      authoringPage.verifyExportToMediaLibraryLabel();
      authoringPage.verifyExportToMediaLibraryCheckboxLabel();
      authoringPage.verifyExportToMediaLibraryHelpContent();
      authoringPage.getExportToMediaLibraryCheckbox().click();
      authoringPage.verifyUploadFromLibraryLabel();
      authoringPage.verifyUploadFromMediaLibraryCheckboxLabel();
      authoringPage.verifyUploadFromMediaLibraryHelpContent();
      authoringPage.getUploadFromMediaLibraryCheckbox().click();
      cy.wait(2000);
      authoringPage.getSaveButton().click();
      cy.wait(6000);
    });
    it("Verify Added Labbook Item In Authoring Preview", () => {
      cy.wait(6000);
      authoringPage.getSectionItemHeader().should("contain", "Labbook Question");
      labbookAuthoringPage.getAuthoringPreviewPrompt("Labbook Question Prompt");
      labbookAuthoringPage.getAuthoringPreviewDrawingTool().should("exist");
      labbookAuthoringPage.getAuthoringPreviewUploadButton().should("exist");
      labbookAuthoringPage.getAuthoringPreviewCommentField().should("exist");
      labbookAuthoringPage.getAuthoringPreviewThumbnailChooser().should("exist");
    });
    it("Verify Added Labbook Item In Item Preview", () => {
      cy.wait(6000);
      authoringPage.getSectionMenuEdit().click();
      cy.wait(6000);
      authoringPage.getSectionItemHeader().should("contain", "Labbook Question");
      labbookAuthoringPage.getEditPreviewPrompt("Labbook Question Prompt");
      labbookAuthoringPage.getEditPreviewDrawingTool().should("exist");
      labbookAuthoringPage.getEditPreviewUploadButton().should("exist");
      labbookAuthoringPage.getEditPreviewCommentField().should("exist");
      labbookAuthoringPage.getEditPreviewThumbnailChooser().should("exist");
      authoringPage.verifyExportToMediaLibraryCheckboxChecked();
      authoringPage.verifyUploadFromMediaLibraryCheckboxChecked();
    });
    it("Verify hidden draw tool is not displayed", () => {
      beforeTest();
      activityPlayerPreview.getActivityTitle().should("contain", "Test Automation Labbook Activity");
      activityPlayerPreview.clickPageItem(0);
      cy.wait(10000);
      labbookAuthoringPage.verifyDrawToolDisplayed("Free hand drawing tool");
      labbookAuthoringPage.verifyDrawToolDisplayed("Basic shape tool");
      labbookAuthoringPage.verifyDrawToolNotDisplayed("Annotation tool");
    });
    it("Delete Item", () => {
      cy.visit("");
      authoringPage.launchActivity("Test Automation Labbook Activity");
      cy.wait(6000);
      authoringPage.getSectionMenuDelete().click();
    });
  });
});
