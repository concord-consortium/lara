import AuthoringPage from "../../support/authoring-page.cy.js";
import LayoutAuthoringPage from "../../support/layout-authoring.cy.js";
import MCQAuthoringPage from "../../support/mcq-authoring.cy.js";

const authoringPage = new AuthoringPage;
const layoutAuthoringPage = new LayoutAuthoringPage;
const mcqAuthoringPage = new MCQAuthoringPage;

const mcq = {
    itemSearch: "Multiple Choice",
    itemList: "Multiple Choice AWS S3",
    name: "Multiple Choice Question",
    prompt: " Multiple Choice Prompt",
    promptAuthoring: "Multiple Choice Prompt"
};

function beforeTest() {
  cy.visit("");
  authoringPage.launchActivity("Test Automation Layout Activity");
  cy.sectionDelete();
}

context("Test LARA Layouts", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.launchActivity("Test Automation Layout Activity");
    cy.sectionDelete();
  });

  describe("LARA Layouts", () => {
    it("Verify 60-40 Layout", () => {
      authoringPage.addSection();
      layoutAuthoringPage.selectLayout("60-40");
      layoutAuthoringPage.getAddItem("60-40", "60").click();
      authoringPage.getItemPickerSearch().type(mcq.itemSearch);
      authoringPage.getItemPickerList().contains(mcq.itemList).click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type(mcq.name);
      authoringPage.getPromptField(mcq.prompt);
      mcqAuthoringPage.selectChoiceInEditForm(0);
      authoringPage.getSaveButton().click();
      cy.wait(6000);
      layoutAuthoringPage.getAddItem("60-40", "40").click();
      authoringPage.getItemPickerSearch().type(mcq.itemSearch);
      authoringPage.getItemPickerList().contains(mcq.itemList).click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type(mcq.name);
      authoringPage.getPromptField(mcq.prompt);
      mcqAuthoringPage.selectChoiceInEditForm(0);
      authoringPage.getSaveButton().click();
    });
    it("Verify Added MCQ Item In Authoring Preview", () => {
      cy.wait(6000);
      layoutAuthoringPage.getSectionItemHeader(60).should("contain", mcq.name);
      layoutAuthoringPage.getAuthoringPreviewPrompt(60, mcq.promptAuthoring);
      layoutAuthoringPage.getSectionItemHeader(40).should("contain", mcq.name);
      layoutAuthoringPage.getAuthoringPreviewPrompt(40, mcq.promptAuthoring);
    });
    it("Verify 40-60 Layout", () => {
      beforeTest();
      authoringPage.addSection();
      layoutAuthoringPage.selectLayout("40-60");
      layoutAuthoringPage.getAddItem("40-60", "40").click();
      authoringPage.getItemPickerSearch().type(mcq.itemSearch);
      authoringPage.getItemPickerList().contains(mcq.itemList).click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type(mcq.name);
      authoringPage.getPromptField(mcq.prompt);
      mcqAuthoringPage.selectChoiceInEditForm(0);
      authoringPage.getSaveButton().click();
      cy.wait(6000);
      layoutAuthoringPage.getAddItem("40-60", "60").click();
      authoringPage.getItemPickerSearch().type(mcq.itemSearch);
      authoringPage.getItemPickerList().contains(mcq.itemList).click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type(mcq.name);
      authoringPage.getPromptField(mcq.prompt);
      mcqAuthoringPage.selectChoiceInEditForm(0);
      authoringPage.getSaveButton().click();
      cy.wait(6000);
    });
    it("Verify Added MCQ Item In Authoring Preview", () => {
      cy.wait(6000);
      layoutAuthoringPage.getSectionItemHeader(60).should("contain", mcq.name);
      layoutAuthoringPage.getAuthoringPreviewPrompt(60, mcq.promptAuthoring);
      layoutAuthoringPage.getSectionItemHeader(40).should("contain", mcq.name);
      layoutAuthoringPage.getAuthoringPreviewPrompt(40, mcq.promptAuthoring);
    });
    it("Verify 70-30 Layout", () => {
      beforeTest();
      authoringPage.addSection();
      layoutAuthoringPage.selectLayout("70-30");
      layoutAuthoringPage.getAddItem("70-30", "70").click();
      authoringPage.getItemPickerSearch().type(mcq.itemSearch);
      authoringPage.getItemPickerList().contains(mcq.itemList).click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type(mcq.name);
      authoringPage.getPromptField(mcq.prompt);
      mcqAuthoringPage.selectChoiceInEditForm(0);
      authoringPage.getSaveButton().click();
      cy.wait(6000);
      layoutAuthoringPage.getAddItem("70-30", "30").click();
      authoringPage.getItemPickerSearch().type(mcq.itemSearch);
      authoringPage.getItemPickerList().contains(mcq.itemList).click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type(mcq.name);
      authoringPage.getPromptField(mcq.prompt);
      mcqAuthoringPage.selectChoiceInEditForm(0);
      authoringPage.getSaveButton().click();
    });
    it("Verify Added MCQ Item In Authoring Preview", () => {
      cy.wait(6000);
      layoutAuthoringPage.getSectionItemHeader(70).should("contain", mcq.name);
      layoutAuthoringPage.getAuthoringPreviewPrompt(70, mcq.promptAuthoring);
      layoutAuthoringPage.getSectionItemHeader(30).should("contain", mcq.name);
      layoutAuthoringPage.getAuthoringPreviewPrompt(30, mcq.promptAuthoring);
    });
    it("Verify 30-70 Layout", () => {
      beforeTest();
      authoringPage.addSection();
      layoutAuthoringPage.selectLayout("30-70");
      layoutAuthoringPage.getAddItem("30-70", "30").click();
      authoringPage.getItemPickerSearch().type(mcq.itemSearch);
      authoringPage.getItemPickerList().contains(mcq.itemList).click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type(mcq.name);
      authoringPage.getPromptField(mcq.prompt);
      mcqAuthoringPage.selectChoiceInEditForm(0);
      authoringPage.getSaveButton().click();
      cy.wait(6000);
      layoutAuthoringPage.getAddItem("30-70", "70").click();
      authoringPage.getItemPickerSearch().type(mcq.itemSearch);
      authoringPage.getItemPickerList().contains(mcq.itemList).click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type(mcq.name);
      authoringPage.getPromptField(mcq.prompt);
      mcqAuthoringPage.selectChoiceInEditForm(0);
      authoringPage.getSaveButton().click();
    });
    it("Verify Added MCQ Item In Authoring Preview", () => {
      cy.wait(6000);
      layoutAuthoringPage.getSectionItemHeader(30).should("contain", mcq.name);
      layoutAuthoringPage.getAuthoringPreviewPrompt(30, mcq.promptAuthoring);
      layoutAuthoringPage.getSectionItemHeader(70).should("contain", mcq.name);
      layoutAuthoringPage.getAuthoringPreviewPrompt(70, mcq.promptAuthoring);
    });
    it("Verify responsive-2-columns Layout", () => {
      beforeTest();
      authoringPage.addSection();
      layoutAuthoringPage.selectLayout("responsive-2-columns");
      layoutAuthoringPage.getAddItem("responsive-2-columns", "responsive-static").click();
      authoringPage.getItemPickerSearch().type(mcq.itemSearch);
      authoringPage.getItemPickerList().contains(mcq.itemList).click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type(mcq.name);
      authoringPage.getPromptField(mcq.prompt);
      mcqAuthoringPage.selectChoiceInEditForm(0);
      authoringPage.getSaveButton().click();
      cy.wait(6000);
      layoutAuthoringPage.getAddItem("responsive-2-columns", "responsive-fluid").click();
      authoringPage.getItemPickerSearch().type(mcq.itemSearch);
      authoringPage.getItemPickerList().contains(mcq.itemList).click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type(mcq.name);
      authoringPage.getPromptField(mcq.prompt);
      mcqAuthoringPage.selectChoiceInEditForm(0);
      authoringPage.getSaveButton().click();
    });
    it("Verify Added MCQ Item In Authoring Preview", () => {
      cy.wait(6000);
      layoutAuthoringPage.getSectionItemHeader("responsive-static").should("contain", mcq.name);
      layoutAuthoringPage.getAuthoringPreviewPrompt("responsive-static", mcq.promptAuthoring);
      layoutAuthoringPage.getSectionItemHeader("responsive-fluid").should("contain", mcq.name);
      layoutAuthoringPage.getAuthoringPreviewPrompt("responsive-fluid", mcq.promptAuthoring);
    });
    it("Verify responsive-full-width Layout", () => {
      beforeTest();
      authoringPage.addSection();
      layoutAuthoringPage.selectLayout("responsive-full-width");
      authoringPage.getAddItem().click();
      authoringPage.getItemPickerSearch().type(mcq.itemSearch);
      authoringPage.getItemPickerList().contains(mcq.itemList).click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type(mcq.name);
      authoringPage.getPromptField(mcq.prompt);
      mcqAuthoringPage.selectChoiceInEditForm(0);
      authoringPage.getSaveButton().click();
      cy.wait(6000);
    });
    it("Verify Added MCQ Item In Authoring Preview", () => {
      cy.wait(6000);
      authoringPage.getSectionItemHeader().should("contain", mcq.name);
      authoringPage.getAuthoringPreviewPrompt(mcq.promptAuthoring);
    });
    it("Add Full Width Layout Section", () => {
      beforeTest();
      authoringPage.addSection();
      cy.wait(6000);
    });
  });
});
