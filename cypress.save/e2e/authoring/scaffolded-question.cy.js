import AuthoringPage from "../../support/authoring-page.cy.js";
import ScaffoldedAuthoringPage from "../../support/scaffolded-authoring.cy.js";

const authoringPage = new AuthoringPage;
const scaffoldedAuthoringPage = new ScaffoldedAuthoringPage;

context.skip("Test Authoring Preview", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.launchActivity("Test Automation Scaffolded Activity");
    cy.deleteItem();
  });

  describe("LARA2 scaffolded Authoring Preview", () => {
    it("Add scaffolded Item", () => {
      authoringPage.getAddItem().click();
      authoringPage.getItemPickerSearch().type("Scaffolded");
      authoringPage.getItemPickerList().contains("Scaffolded Question (AWS)").click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type("Scaffolded Question");
      authoringPage.getPromptField(" Scaffolded Prompt");
      scaffoldedAuthoringPage.clickPlusButton();
      scaffoldedAuthoringPage.selectInteractive("Open response", 0);
      scaffoldedAuthoringPage.selectAuthoring(0);
      cy.wait(6000);
      scaffoldedAuthoringPage.getPrompt(" Open response Prompt", 0);
      scaffoldedAuthoringPage.clickPlusButton();
      scaffoldedAuthoringPage.selectInteractive("Multiple choice", 1);
      scaffoldedAuthoringPage.selectAuthoring(1);
      cy.wait(6000);
      scaffoldedAuthoringPage.getPrompt(" Multiple Choice Prompt", 1);
      scaffoldedAuthoringPage.selectChoice(0, 1);
      scaffoldedAuthoringPage.clickPlusButton();
      scaffoldedAuthoringPage.selectInteractive("Fill in the blank", 2);
      scaffoldedAuthoringPage.selectAuthoring(2);
      cy.wait(6000);
      scaffoldedAuthoringPage.getPrompt(" Enter the answer [blank-1]", 2);
      authoringPage.getSaveButton().click();
    });
    it("Verify Added scaffolded Item In Authoring Preview", () => {
      cy.wait(6000);
      authoringPage.getSectionItemHeader().should("contain", "Scaffolded Question");
      scaffoldedAuthoringPage.getAuthoringPreviewPrompt("Open response Prompt");
      scaffoldedAuthoringPage.getAuthoringPreviewResponseTextArea().should("exist");
      scaffoldedAuthoringPage.clickHintButton();
      cy.wait(6000);
      scaffoldedAuthoringPage.getAuthoringPreviewPrompt("Multiple Choice Prompt");
      scaffoldedAuthoringPage.getAuthoringPreviewChoice("Choice A");
      scaffoldedAuthoringPage.clickHintButton();
      cy.wait(6000);
      scaffoldedAuthoringPage.getAuthoringPreviewFibPrompt("Enter the answer ");
      scaffoldedAuthoringPage.getAuthoringPreviewFibTextArea().should("exist");
    });
    it("Verify Added scaffolded Item In Item Preview", () => {
      cy.wait(6000);
      authoringPage.getSectionMenuEdit().click();
      cy.wait(6000);
      scaffoldedAuthoringPage.getItemPreviewPrompt("Open response Prompt");
      scaffoldedAuthoringPage.getResponseTextArea().should("exist");
      scaffoldedAuthoringPage.clickItemPreviewHintButton();
      cy.wait(6000);
      scaffoldedAuthoringPage.getItemPreviewPrompt("Multiple Choice Prompt");
      scaffoldedAuthoringPage.getChoice("Choice A");
      scaffoldedAuthoringPage.clickItemPreviewHintButton();
      cy.wait(6000);
      scaffoldedAuthoringPage.getFibPrompt("Enter the answer ");
      scaffoldedAuthoringPage.getFibTextArea().should("exist");
    });
    it("Delete Item", () => {
      cy.wait(6000);
      authoringPage.getSectionMenuDelete().click();
    });
  });
});
