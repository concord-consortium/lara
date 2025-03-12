import AuthoringPage from "../../support/authoring-page.cy.js";
import ImageInteractiveAuthoringPage from "../../support/image-interactive-authoring.cy.js";

const authoringPage = new AuthoringPage;
const imageInteractiveAuthoringPage = new ImageInteractiveAuthoringPage;

context("Test Authoring Preview", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.launchActivity("Test Automation Image Interactive Activity");
    cy.deleteItem();
  });

  describe("LARA Image Interactive Authoring Preview", () => {
    it("Add Image Interactive Item", () => {
      authoringPage.getAddItem().click();
      authoringPage.getItemPickerSearch().type("Image Interactive");
      authoringPage.getItemPickerList().contains("Image Interactive AWS").click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type("Image Interactive Question");
      imageInteractiveAuthoringPage.getURLField("https://learn-resources.concord.org/tutorials/images/brogan-acadia.jpg");
      imageInteractiveAuthoringPage.getAltTextField("Image Alt Text");
      imageInteractiveAuthoringPage.getCaptionField("Image Caption");
      imageInteractiveAuthoringPage.getCreditField("Image Credit");
      imageInteractiveAuthoringPage.getExportToMediaLibraryCheckbox().should("exist");
      cy.wait(2000);
      authoringPage.getSaveButton().click();
    });
    it("Verify Added Image Interactive In Authoring Preview", () => {
      cy.wait(6000);
      authoringPage.getSectionItemHeader().should("contain", "Image Interactive Question");
      imageInteractiveAuthoringPage.verifyAuthoringPreviewImage("https://learn-resources.concord.org/tutorials/images/brogan-acadia.jpg");
      imageInteractiveAuthoringPage.verifyAuthoringPreviewImageAltText("Image Alt Text");
      imageInteractiveAuthoringPage.verifyAuthoringPreviewCaption("Image Caption");
      imageInteractiveAuthoringPage.verifyAuthoringPreviewCredit("Image Credit");
      imageInteractiveAuthoringPage.getZoomInIcon().should("exist");
      
    });
    it("Verify Added Image Interactive In Item Preview", () => {
      cy.wait(2000);
      authoringPage.getSectionMenuEdit().click();
      cy.wait(6000);
      imageInteractiveAuthoringPage.verifyEditItemPreviewImage("https://learn-resources.concord.org/tutorials/images/brogan-acadia.jpg");
      imageInteractiveAuthoringPage.verifyEditItemPreviewImageAltText("Image Alt Text");
      imageInteractiveAuthoringPage.verifyEditItemPreviewCaption("Image Caption");
      imageInteractiveAuthoringPage.verifyEditItemPreviewCredit("Image Credit");
      imageInteractiveAuthoringPage.getEditItemZoomInIcon().should("exist");
      authoringPage.getSaveButton().click();
    });
    it("Delete Item", () => {
      cy.wait(6000);
      authoringPage.getSectionMenuDelete().click();
    });
  });
});
