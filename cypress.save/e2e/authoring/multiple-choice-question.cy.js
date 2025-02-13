import AuthoringPage from "../../support/authoring-page.cy.js";
import MCQAuthoringPage from "../../support/mcq-authoring.cy.js";

const authoringPage = new AuthoringPage;
const mcqAuthoringPage = new MCQAuthoringPage;

context("Test Authoring Preview", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.launchActivity("Test Automation Multiple Choice Activity");
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
      mcqAuthoringPage.selectCheckAnswerCheckBox();
      mcqAuthoringPage.selectCustomFeedbackCheckBox();
      mcqAuthoringPage.enterCustomFeedback(0, "Correct Answer");
      mcqAuthoringPage.enterCustomFeedback(1, "Incorrect Answer");
      authoringPage.selectRequiredCheckBox();
      authoringPage.enterPostSubmissionFeedback(" Answer Submitted");
      authoringPage.getSaveButton().click();
    });
    it("Verify Added MCQ Item In Authoring Preview", () => {
      cy.wait(6000);
      authoringPage.getSectionItemHeader().should("contain", "Multiple Choice Question");
      authoringPage.getAuthoringPreviewPrompt("Multiple Choice Prompt");
      mcqAuthoringPage.getAuthoringPreviewChoice("Choice A");
      mcqAuthoringPage.getAuthoringPreviewChoice("Choice B");
      mcqAuthoringPage.getAuthoringPreviewChoice("Choice C");
    });
    it("Verify Custom Feedback In Authoring Preview", () => {
      mcqAuthoringPage.getAuthoringPreviewCheckAnswerButton().should("be.disabled");
      mcqAuthoringPage.selectAuthoringPreviewChoice("1");
      mcqAuthoringPage.getAuthoringPreviewCheckAnswerButton().should("be.enabled");
      mcqAuthoringPage.getAuthoringPreviewCheckAnswerButton().click();
      mcqAuthoringPage.getAuthoringPreviewCorrectFeedback().should("contain", "Correct Answer");
      mcqAuthoringPage.selectAuthoringPreviewChoice("2");
      mcqAuthoringPage.getAuthoringPreviewCheckAnswerButton().click();
      mcqAuthoringPage.getAuthoringPreviewIncorrectFeedback().should("contain", "Incorrect Answer");
    });
    it("Verify Required Answer In Authoring Preview", () => {
      authoringPage.getAuthoringPreviewSubmitButton().should("be.enabled");
      mcqAuthoringPage.selectAuthoringPreviewChoice("1");
      authoringPage.getAuthoringPreviewSubmitButton().click();
      authoringPage.getAuthoringPreviewLockedInfoHeader().should("contain", "Your answer has been submitted and is locked. ");
      authoringPage.getAuthoringPreviewLockedInfoFeedback().should("contain", "Answer Submitted");
      mcqAuthoringPage.getAuthoringPreviewChoiceDisabled();
    });
    it("Verify Added MCQ Item In Item Preview", () => {
      cy.wait(6000);
      authoringPage.getSectionMenuEdit().click();
      cy.wait(6000);
      authoringPage.getPrompt("Multiple Choice Prompt");
      mcqAuthoringPage.getChoice("Choice A");
      mcqAuthoringPage.getChoice("Choice B");
      mcqAuthoringPage.getChoice("Choice C");
    });
    it("Verify Custom Feedback In Item Preview", () => {
      mcqAuthoringPage.selectChoice("1");
      mcqAuthoringPage.getCheckAnswerButton().should("be.enabled");
      mcqAuthoringPage.getCheckAnswerButton().click();
      mcqAuthoringPage.getCorrectFeedback().should("contain", "Correct Answer");
      mcqAuthoringPage.selectChoice("2");
      mcqAuthoringPage.getCheckAnswerButton().click();
      mcqAuthoringPage.getIncorrectFeedback().should("contain", "Incorrect Answer");
    });
    it("Verify Default Feedback In Item Preview", () => {
      mcqAuthoringPage.selectCustomFeedbackCheckBox();
      mcqAuthoringPage.getCheckAnswerButton().should("be.disabled");
      mcqAuthoringPage.selectChoice("1");
      mcqAuthoringPage.getCheckAnswerButton().should("be.enabled");
      mcqAuthoringPage.getCheckAnswerButton().click();
      mcqAuthoringPage.getCorrectFeedback().should("contain", "Yes! You are correct.");
      mcqAuthoringPage.selectChoice("2");
      mcqAuthoringPage.getCheckAnswerButton().click();
      mcqAuthoringPage.getIncorrectFeedback().should("contain", "Sorry, that is incorrect.");
    });
    it("Verify Required Answer In Item Preview", () => {
      authoringPage.getSubmitButton().should("be.enabled");
      mcqAuthoringPage.selectChoice("1");
      authoringPage.getSubmitButton().click();
      authoringPage.getLockedInfoHeader().should("contain", "Your answer has been submitted and is locked. ");
      authoringPage.getLockedInfoFeedback().should("contain", "Answer Submitted");
      mcqAuthoringPage.getChoiceDisabled();
      authoringPage.getCancelButton().click();
    });
    it("Delete Item", () => {
      cy.wait(6000);
      authoringPage.getSectionMenuDelete().click();
    });
  });
});
