import AuthoringPage from "../../support/authoring-page.cy.js";
import TextBlockAuthoringPage from "../../support/text-block-authoring.cy.js";
import NotebookLayout from "../../support/notebook-layout.cy.js";

const authoringPage = new AuthoringPage;
const textBlockAuthoringPage = new TextBlockAuthoringPage;
const notebookLayout = new NotebookLayout;

function previewTest() {
  cy.visit("");
  cy.previewNotebookActivty();
}

context("Test Section Action Menus", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    cy.launchNotebookActivty();
    cy.deleteSection();
  });

  describe("Section Edit", () => {
    it("Add Text Block", () => {
      authoringPage.addSection();
      authoringPage.clickAddItem(1);
      textBlockAuthoringPage.getTextBlockQuickAddButton().click();
      cy.wait(2000);
      authoringPage.getAddItemButton().click();
      cy.wait(4000);
      authoringPage.getEditItemDialog().should("exist");
      textBlockAuthoringPage.getHeadingField().type("Text Block Heading");
      textBlockAuthoringPage.getContentField("Text Block Content");
      authoringPage.getSaveButton().click();
    });
    it("Add second section and edit section name", () => {
      authoringPage.verifySectionName(1, "Section 2");
      authoringPage.verifyButton(1, 0, "Edit");
      authoringPage.clickButton(1, 0);
      authoringPage.getSectionNameTextBox(1).should("exist");
      authoringPage.getSectionNameTextBox(1).type("Section Name Edit");
      authoringPage.clickButton(1, 0);
      cy.wait(4000);
      authoringPage.verifySectionName(1, "Section Name Edit");
    });
    it("Verify edit section name cancel action", () => {
      authoringPage.clickButton(1, 0);
      authoringPage.getSectionNameTextBox(1).should("exist");
      authoringPage.getSectionNameTextBox(1).clear().type("Cancel Section Name");
      authoringPage.clickButton(1, 1);
      cy.wait(2000);
      authoringPage.verifySectionName(1, "Section Name Edit");
    });
    it("Verify activity is previewed in notebook layout", () => {
      previewTest();
      notebookLayout.getPreviousPageButton().should("not.exist");
      notebookLayout.getNextPageButton().should("not.exist");
      notebookLayout.getActivityNavHeader(0).should("exist");
      notebookLayout.getActivityNavHeader(1).should("not.exist");
      notebookLayout.getHomeButton().should("contain", "Home");
      notebookLayout.getNavPageButton(0).should("contain", "Section Edit");
      notebookLayout.verifyNotebookHeaderNotDisplayed();
      notebookLayout.getNavPageButton(0).click();
      cy.wait(2000);
      notebookLayout.getNotebookHeader().should("exist");
      notebookLayout.getSectionTab(0).should("contain", "Tab 1");
      notebookLayout.getSectionTab(1).should("contain", "Section Name Edit");
      notebookLayout.getSeparator().should("exist");
      notebookLayout.getSectionTab(0).invoke("attr", "class").should("contains", "selected");    
    });
  });   
});
