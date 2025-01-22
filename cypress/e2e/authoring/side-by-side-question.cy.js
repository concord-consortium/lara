import AuthoringPage from "../../support/authoring-page.cy.js";
import SideBySideAuthoringPage from "../../support/side-by-side-authoring.cy.js";

const authoringPage = new AuthoringPage;
const sideBySideAuthoringPage = new SideBySideAuthoringPage;

context.skip("Test Authoring Preview", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.launchActivity("Test Automation SideBySide Activity");
    cy.deleteItem();
  });

  describe("LARA2 Side By Side Authoring Preview", () => {
    it("Add Side By Side Item", () => {
      authoringPage.getAddItem().click();
      authoringPage.getItemPickerSearch().type("Side-by-Side");
      authoringPage.getItemPickerList().contains("Side-by-Side (AWS)").click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type("Side by Side Question");
      authoringPage.getPromptField(" Side by Side Prompt");
      sideBySideAuthoringPage.selectInteractive("Open response", 0);
      sideBySideAuthoringPage.selectAuthoring(0);
      cy.wait(6000);
      sideBySideAuthoringPage.getPrompt(" Open response Prompt", 0);
      sideBySideAuthoringPage.selectInteractive("Multiple choice", 1);
      sideBySideAuthoringPage.selectAuthoring(1);
      cy.wait(6000);
      sideBySideAuthoringPage.getPrompt(" Multiple Choice Prompt", 1);
      sideBySideAuthoringPage.selectChoice(0, 1);
      authoringPage.getSaveButton().click();
    });
    it("Verify Added Side By Side Item In Authoring Preview", () => {
      cy.wait(6000);
      authoringPage.getSectionItemHeader().should("contain", "Side by Side Question");
      sideBySideAuthoringPage.getAuthoringPreviewPrompt("Open response Prompt", 0);
      sideBySideAuthoringPage.getAuthoringPreviewPrompt("Multiple Choice Prompt", 1);
    });
    it("Verify Added Side By Side Item In Item Preview", () => {
      cy.wait(3000);
      authoringPage.getSectionMenuEdit().click();
      cy.wait(6000);
      sideBySideAuthoringPage.getItemPreviewPrompt("Open response Prompt", 0);
      sideBySideAuthoringPage.getItemPreviewPrompt("Multiple Choice Prompt", 1);
      authoringPage.getCancelButton().click();
    });
    it("Delete Item", () => {
      cy.wait(6000);
      authoringPage.getSectionMenuDelete().click();
    });
  });
});
