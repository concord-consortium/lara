import AuthoringPage from "../../support/authoring-page.cy.js";
import MCQAuthoringPage from "../../support/mcq-authoring.cy.js";

const authoringPage = new AuthoringPage;
const mcqAuthoringPage = new MCQAuthoringPage;

context("Test Sharing Interactive Plugin", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.launchActivity("Test Automation Sharing Plugin Activity");
    cy.deleteItem();
  });

  describe("LARA MCQ Authoring Preview", () => {
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
    it("Verify Sharing Interactive Plugin", () => {
      cy.wait(6000);
      authoringPage.selectSharingPlugin();
      authoringPage.clickAddButton();
      cy.wait(6000);
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getPromptSharingPlugin("Multiple Choice Prompt");
      authoringPage.getCloseButton().click();
    });
    it("Delete Sharing Interactive Plugin", () => {
      cy.wait(2000);
      authoringPage.getPluginDelete().click();
    });
    it("Delete Item", () => {
      cy.wait(6000);
      authoringPage.getSectionMenuDelete().click();
    });
  });
});
