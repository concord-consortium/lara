import AuthoringPage from "../../support/authoring-page.cy.js";
import MCQAuthoringPage from "../../support/mcq-authoring.cy.js";
import TEQuestionWrapperAuthoringPage from "../../support/teacher-edition-question-wrapper-authoring.cy.js";

const authoringPage = new AuthoringPage;
const mcqAuthoringPage = new MCQAuthoringPage;
const teQuestionWrapperAuthoringPage = new TEQuestionWrapperAuthoringPage;

context("Test Authoring Preview", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.launchActivity("Test Automation TEQuestionWrapper Activity");
    cy.deleteItem();
  });

  describe("LARA TE Question Wrapper", () => {
    it("Add MCQ Item", () => {
      authoringPage.getAddItem().click();
      authoringPage.getItemPickerSearch().type("Multiple Choice");
      authoringPage.getItemPickerList().contains("Multiple Choice AWS S3").click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type("Multiple Choice Question");
      authoringPage.getPromptField(" Multiple Choice Prompt");
      mcqAuthoringPage.selectChoiceInEditForm(0);
      authoringPage.getSaveButton().click();
    });
    it("Add TE Question Wrapper", () => {
      cy.wait(4000);
      teQuestionWrapperAuthoringPage.selectQuestionWrapper();
      teQuestionWrapperAuthoringPage.clickAddButton();
      authoringPage.getEditItemDialog().should("exist");
      teQuestionWrapperAuthoringPage.getFormSection("Correct");
      teQuestionWrapperAuthoringPage.getFormSection("Distractor");
      teQuestionWrapperAuthoringPage.getFormSection("Teacher Tip");
      teQuestionWrapperAuthoringPage.getFormSection("Exemplar");
    });
    it("Verify TE Question Wrapper", () => {
      cy.wait(4000);
      teQuestionWrapperAuthoringPage.clickHeader("correct");
      teQuestionWrapperAuthoringPage.verifyQuestionWrapperContent("Correct");
      teQuestionWrapperAuthoringPage.clickHeader("distractors");
      teQuestionWrapperAuthoringPage.verifyQuestionWrapperContent("Distractor");
      teQuestionWrapperAuthoringPage.clickHeader("teacherTip");
      teQuestionWrapperAuthoringPage.verifyQuestionWrapperContent("Teacher Tip");
      teQuestionWrapperAuthoringPage.clickHeader("exemplar");
      teQuestionWrapperAuthoringPage.verifyQuestionWrapperContent("Exemplar");
      teQuestionWrapperAuthoringPage.clickSaveButton();
    });
    it("Delete Item", () => {
      cy.wait(4000);
      authoringPage.getSectionMenuDelete().click();
    });
  });
});
