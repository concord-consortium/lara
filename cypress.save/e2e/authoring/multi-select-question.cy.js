import AuthoringPage from "../../support/authoring-page.cy.js";
import MultiSelectAuthoringPage from "../../support/multi-select-authoring.cy.js";

const authoringPage = new AuthoringPage;
const multiSelectAuthoringPage = new MultiSelectAuthoringPage;

context("Test Authoring Preview", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.launchActivity("Test Automation MultiSelect Activity");
    cy.deleteItem();
  });

  describe("LARA Multi Select Authoring Preview", () => {
    it("Add Multi Select Item", () => {
      authoringPage.getAddItem().click();
      authoringPage.getItemPickerSearch().type("Multiple Choice");
      authoringPage.getItemPickerList().contains("Multiple Choice AWS S3").click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type("Multi Select Question");
      authoringPage.getPromptField(" Multi Select Prompt");
      authoringPage.getHintField(" Multi Select Hint");
      multiSelectAuthoringPage.selectMultipleAnswerCheckBox();
      multiSelectAuthoringPage.selectChoiceInEditForm(0);
      multiSelectAuthoringPage.selectChoiceInEditForm(1);
      multiSelectAuthoringPage.selectCheckAnswerCheckBox();
      multiSelectAuthoringPage.selectCustomFeedbackCheckBox();
      multiSelectAuthoringPage.enterCustomFeedback(0, "Correct Answer");
      multiSelectAuthoringPage.enterCustomFeedback(1, "Correct Answer");
      multiSelectAuthoringPage.enterCustomFeedback(2, "Incorrect Answer");
      authoringPage.selectRequiredCheckBox();
      authoringPage.enterPostSubmissionFeedback(" Answer Submitted");
      authoringPage.getSaveButton().click();
    });
    it("Verify Added Multi Select Item In Authoring Preview", () => {
      cy.wait(6000);
      authoringPage.getSectionItemHeader().should("contain", "Multi Select Question");
      authoringPage.getAuthoringPreviewPrompt("Multi Select Prompt");
      multiSelectAuthoringPage.getAuthoringPreviewChoice("Choice A");
      multiSelectAuthoringPage.getAuthoringPreviewChoice("Choice B");
      multiSelectAuthoringPage.getAuthoringPreviewChoice("Choice C");
      multiSelectAuthoringPage.getAuthoringPreviewChoiceType();
    });
    it("Verify Custom Feedback In Authoring Preview", () => {
      multiSelectAuthoringPage.getAuthoringPreviewCheckAnswerButton().should("be.disabled");
      multiSelectAuthoringPage.selectAuthoringPreviewChoice("1");
      multiSelectAuthoringPage.selectAuthoringPreviewChoice("2");
      multiSelectAuthoringPage.getAuthoringPreviewCheckAnswerButton().should("be.enabled");
      multiSelectAuthoringPage.getAuthoringPreviewCheckAnswerButton().click();
      multiSelectAuthoringPage.getAuthoringPreviewCorrectFeedback().should("contain", "Yes! You are correct.");
      multiSelectAuthoringPage.selectAuthoringPreviewChoice("3");
      multiSelectAuthoringPage.getAuthoringPreviewCheckAnswerButton().click();
      multiSelectAuthoringPage.getAuthoringPreviewIncorrectFeedback().should("contain", "Incorrect Answer");
    });
    it("Verify Required Answer In Authoring Preview", () => {
      authoringPage.getAuthoringPreviewSubmitButton().should("be.enabled");
      authoringPage.getAuthoringPreviewSubmitButton().click();
      authoringPage.getAuthoringPreviewLockedInfoHeader().should("contain", "Your answer has been submitted and is locked. ");
      authoringPage.getAuthoringPreviewLockedInfoFeedback().should("contain", "Answer Submitted");
      multiSelectAuthoringPage.getAuthoringPreviewChoiceDisabled();
    });
    it("Verify Added Multi Select Item In Item Preview", () => {
      cy.wait(6000);
      authoringPage.getSectionMenuEdit().click();
      cy.wait(6000);
      authoringPage.getPrompt("Multi Select Prompt");
      multiSelectAuthoringPage.getChoice("Choice A");
      multiSelectAuthoringPage.getChoice("Choice B");
      multiSelectAuthoringPage.getChoice("Choice C");
      multiSelectAuthoringPage.getChoiceType();
    });
    it("Verify Custom Feedback In Item Preview", () => {
      multiSelectAuthoringPage.selectChoice("1");
      multiSelectAuthoringPage.selectChoice("2");
      multiSelectAuthoringPage.getCheckAnswerButton().should("be.enabled");
      multiSelectAuthoringPage.getCheckAnswerButton().click();
      multiSelectAuthoringPage.getCorrectFeedback().should("contain", "Yes! You are correct.");
      multiSelectAuthoringPage.selectChoice("3");
      multiSelectAuthoringPage.getCheckAnswerButton().click();
      multiSelectAuthoringPage.getIncorrectFeedback().should("contain", "Incorrect Answer");
    });
    it("Verify Default Feedback In Item Preview", () => {
      multiSelectAuthoringPage.selectCustomFeedbackCheckBox();
      multiSelectAuthoringPage.getCheckAnswerButton().should("be.disabled");
      multiSelectAuthoringPage.selectChoice("1");
      multiSelectAuthoringPage.selectChoice("2");
      multiSelectAuthoringPage.getCheckAnswerButton().should("be.enabled");
      multiSelectAuthoringPage.getCheckAnswerButton().click();
      multiSelectAuthoringPage.getCorrectFeedback().should("contain", "Yes! You are correct.");
      multiSelectAuthoringPage.selectChoice("3");
      multiSelectAuthoringPage.getCheckAnswerButton().click();
      multiSelectAuthoringPage.getIncorrectFeedback().should("contain", "Sorry, that is incorrect.");
    });
    it("Verify Required Answer In Item Preview", () => {
      authoringPage.getSubmitButton().should("be.enabled");
      authoringPage.getSubmitButton().click();
      authoringPage.getLockedInfoHeader().should("contain", "Your answer has been submitted and is locked. ");
      authoringPage.getLockedInfoFeedback().should("contain", "Answer Submitted");
      multiSelectAuthoringPage.getChoiceDisabled();
      authoringPage.getCancelButton().click();
    });
    it("Delete Item", () => {
      cy.wait(6000);
      authoringPage.getSectionMenuDelete().click();
    });
  });
});
