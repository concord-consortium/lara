import AuthoringPage from "../../support/authoring-page.cy.js";
import OpenResponseAuthoringPage from "../../support/open-response-authoring.cy.js";

const authoringPage = new AuthoringPage;
const orAuthoringPage = new OpenResponseAuthoringPage;

context("Test Authoring Preview", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.launchActivity("Test Automation Open Response Activity");
    cy.deleteItem();
  });

  describe("LARA OR Authoring Preview", () => {
    it("Add OR Item", () => {
      authoringPage.getAddItem().click();
      authoringPage.getItemPickerSearch().type("Open Response");
      authoringPage.getItemPickerList().contains("Open Response (AWS)").click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type("Open Response Question");
      authoringPage.getPromptField(" Open Response Prompt ");
      authoringPage.getHintField(" Open Response Hint ");
      authoringPage.selectRequiredCheckBox();
      authoringPage.enterPostSubmissionFeedback(" Answer Submitted");
      orAuthoringPage.selectRecordAudioResponseCheckBox();
      orAuthoringPage.selectVoiceTypingResponseCheckBox();
      authoringPage.getSaveButton().click();
      cy.wait(6000);
    });
    it("Verify Added OR Item In Authoring Preview", () => {
      cy.wait(2000);
      authoringPage.getSectionItemHeader().should("contain", "Open Response Question");
      authoringPage.getAuthoringPreviewPrompt("Open Response Prompt");
      orAuthoringPage.getAuthoringPreviewResponseTextArea().invoke("attr", "placeholder").should("contain", "Please type or voice type your answer here, or record your answer using the microphone.");
      orAuthoringPage.getAuthoringPreviewAudioControls().should("exist");
      orAuthoringPage.getAuthoringPreviewVoiceTypingControls().should("exist");
    });
    it("Verify Required Answer In Authoring Preview", () => {
      authoringPage.getAuthoringPreviewSubmitButton().should("be.disabled");
      orAuthoringPage.getAuthoringPreviewResponseTextArea().type("Open Response Answer");
      authoringPage.getAuthoringPreviewSubmitButton().should("be.enabled");
      authoringPage.getAuthoringPreviewSubmitButton().click();
      authoringPage.getAuthoringPreviewLockedInfoHeader().should("contain", "Your answer has been submitted and is locked. ");
      authoringPage.getAuthoringPreviewLockedInfoFeedback().should("contain", "Answer Submitted");
      orAuthoringPage.getAuthoringPreviewAudioControls().should("not.exist");
      orAuthoringPage.getAuthoringPreviewVoiceTypingControls().should("not.exist");
    });
    it("Verify Added OR Item In Item Preview", () => {
      cy.wait(6000);
      authoringPage.getSectionMenuEdit().click();
      cy.wait(6000);
      authoringPage.getPrompt("Open Response Prompt");
      orAuthoringPage.getResponseTextArea().invoke("attr", "placeholder").should("contain", "Please type or voice type your answer here, or record your answer using the microphone.");
      orAuthoringPage.getAudioControls().should("exist");
      orAuthoringPage.getVoiceTypingControls().should("exist");
    });
    it("Verify Default Answer In Item Preview", () => {
      orAuthoringPage.enterDeafultAnswer("Default OR Answer")
      orAuthoringPage.getResponseTextArea().should("contain", "Default OR Answer");
      cy.wait(6000);
      orAuthoringPage.getAudioControls().should("exist");
    });
    it("Verify Required Answer In Item Preview", () => {
      authoringPage.getSubmitButton().should("be.disabled");
      orAuthoringPage.getResponseTextArea().type("Open Response Answer");
      authoringPage.getSubmitButton().should("be.enabled");
      authoringPage.getSubmitButton().click();
      authoringPage.getLockedInfoHeader().should("contain", "Your answer has been submitted and is locked. ");
      authoringPage.getLockedInfoFeedback().should("contain", "Answer Submitted");
      orAuthoringPage.getAudioControls().should("not.exist");
      orAuthoringPage.getVoiceTypingControls().should("not.exist");
      authoringPage.getCancelButton().click();
    });
    it("Delete Item", () => {
      cy.wait(6000);
      authoringPage.getSectionMenuDelete().click();
    });
  });
});
