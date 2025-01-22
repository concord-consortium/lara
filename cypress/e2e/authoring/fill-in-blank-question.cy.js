import AuthoringPage from "../../support/authoring-page.cy.js";
import FillInTheBlankAuthoringPage from "../../support/fill-in-the-blank-authoring.cy.js";

const authoringPage = new AuthoringPage;
const fibAuthoringPage = new FillInTheBlankAuthoringPage;

context("Test Authoring Preview", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.launchActivity("Test Automation FIB Question Activity");
    cy.deleteItem();
  });

  describe("LARA FIB Authoring Preview", () => {
    it("Add FIB Item", () => {
      authoringPage.getAddItem().click();
      authoringPage.getItemPickerSearch().type("Fill in the Blank");
      authoringPage.getItemPickerList().contains("Fill In The Blank (AWS)").click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type("Fill in the Blank Question");
      authoringPage.getPromptField(" Enter the answer [blank-1]");
      authoringPage.getHintField(" Fill in the Blank Hint");
      authoringPage.selectRequiredCheckBox();
      authoringPage.getSaveButton().click();
    });
    it("Verify Added FIB Item In Authoring Preview", () => {
      cy.wait(2000);
      authoringPage.getSectionItemHeader().should("contain", "Fill in the Blank Question");
      fibAuthoringPage.getAuthoringPreviewPrompt("Enter the answer ");
    });
    it("Verify Required Answer In Authoring Preview", () => {
      authoringPage.getAuthoringPreviewSubmitButton().should("be.disabled");
      fibAuthoringPage.getAuthoringPreviewFibTextArea().type("Fill in the Blank Answer");
      authoringPage.getAuthoringPreviewSubmitButton().should("be.enabled");
      authoringPage.getAuthoringPreviewSubmitButton().click();
      authoringPage.getAuthoringPreviewLockedInfoHeader().should("contain", "Your answer has been submitted and is locked. ");
    });
    it("Verify Added FIB Item In Item Preview", () => {
      cy.wait(6000);
      authoringPage.getSectionMenuEdit().click();
      cy.wait(6000);
      fibAuthoringPage.getPrompt("Enter the answer ");
    });
    it("Verify Required Answer In Item Preview", () => {
      authoringPage.getSubmitButton().should("be.disabled");
      fibAuthoringPage.getFibTextArea().type("Fill in the Blank Answer");
      authoringPage.getSubmitButton().should("be.enabled");
      authoringPage.getSubmitButton().click();
      authoringPage.getLockedInfoHeader().should("contain", "Your answer has been submitted and is locked. ");
      authoringPage.getCancelButton().click();
    });
    it("Delete Item", () => {
      cy.wait(6000);
      authoringPage.getSectionMenuDelete().click();
    });
  });
});
