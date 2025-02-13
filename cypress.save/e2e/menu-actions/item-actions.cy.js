import AuthoringPage from "../../support/authoring-page.cy.js";
import MCQAuthoringPage from "../../support/mcq-authoring.cy.js";

const authoringPage = new AuthoringPage;
const mcqAuthoringPage = new MCQAuthoringPage;

context("Test Item Action Menus", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.launchActivity("Test Automation Item Menu Actions");
    cy.deleteItem();
  });

  describe("LARA Item Action Menus", () => {
    it("Add MCQ Item", () => {
      authoringPage.getAddItem().click();
      authoringPage.getItemPickerSearch().type("Multiple Choice");
      authoringPage.getItemPickerList().contains("Multiple Choice AWS S3").click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type("Multiple Choice Question");
      authoringPage.getPromptField(" Multiple Choice Prompt");
      authoringPage.getHintField(" Multiple Choice Hint");
      mcqAuthoringPage.selectChoiceInEditForm(0);
      authoringPage.getSaveButton().click();
    });
    it("Verify Item Level Actions", () => {
      cy.wait(6000);
      authoringPage.getSectionMenuMove().click();
      authoringPage.getMoveModel().should("exist");
      authoringPage.getMoveModel().click();
      authoringPage.getMoveModelHeader("Move this item to...");
      authoringPage.getMoveModelClose().click();
      authoringPage.getSectionMenuCopy().click();
      cy.wait(2000);
      authoringPage.getCopySectionItemHeader(1).should("contain", "Multiple Choice Question");
      authoringPage.getCopySectionMenuDelete(1).click();
      cy.wait(2000);
    });
    it("Delete Item", () => {
      cy.wait(6000);
      authoringPage.getSectionMenuDelete().click();
    });
  });
});
