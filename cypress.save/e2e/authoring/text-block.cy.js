import AuthoringPage from "../../support/authoring-page.cy.js";
import TextBlockAuthoringPage from "../../support/text-block-authoring.cy.js";

const authoringPage = new AuthoringPage;
const textBlockAuthoringPage = new TextBlockAuthoringPage;

function beforeTest() {
  cy.visit("");
  cy.wait(2000);
  authoringPage.launchActivity("Test Automation TextBlock Activity");
}

context("Test Authoring Preview", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.launchActivity("Test Automation TextBlock Activity");
    cy.deleteItem();
  });

  describe("LARA Text Block In Authoring Preview", () => {
    it("Add Text Block", () => {
      authoringPage.getAddItem().click();
      textBlockAuthoringPage.getTextBlockQuickAddButton().click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      textBlockAuthoringPage.getHeadingField().type("Text Block Heading");
      textBlockAuthoringPage.getContentField("Text Block Content");
      authoringPage.getSaveButton().click();
    });
    it("Verify Added Text Block In Item Preview In Authoring Preview", () => {
      cy.wait(6000);
      textBlockAuthoringPage.getAuthoringPreviewTextBlockName().should("contain", "Text Block Heading");
      textBlockAuthoringPage.getAuthoringPreviewTextBlockContent().should("contain", "Text Block Content");
    });
    it("Verify Activity Player Runtime Preview", () => {
      authoringPage.selectPreviewIn("Activity Player");
      authoringPage.getActivityPlayerPreview();
      authoringPage.getActivityPlayerTEPreview();
      authoringPage.getPreviewInButton().click();
    });
    it("Verify Added Text Block In Item Preview", () => {
      cy.wait(6000);
      authoringPage.getSectionMenuEdit().click();
      cy.wait(6000);
      textBlockAuthoringPage.getTextBlockName().should("contain", "Text Block Heading");
      textBlockAuthoringPage.getTextBlockContent().should("contain", "Text Block Content");
    });
    it("Delete Text Block", () => {
      beforeTest();
      cy.wait(6000);
      authoringPage.getSectionMenuDelete().click();
    });
  });
});
