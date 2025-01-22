import AuthoringPage from "../../support/authoring-page.cy.js";
import ActivitySequenceSettingsPage from "../../support/activity-sequence-settings.cy.js";
import NotebookLayout from "../../support/notebook-layout.cy.js";

const authoringPage = new AuthoringPage;
const settingsPage = new ActivitySequenceSettingsPage;
const notebookLayout = new NotebookLayout;

const url = {
    imageUrl: "https://learn-resources.concord.org/tutorials/images/brogan-acadia.jpg"
};

function previewTest() {
  cy.visit("");
  authoringPage.previewActivity("Test Automation Create Activity Notebook Layout");
  // to-do: add the data-testid='activity-title' attribute once on staging
  cy.contains('div', 'Test Automation Create Activity Notebook Layout') // Finds a div containing the exact text
      .should('be.visible'); // Ensures the element is visible
}

context("Test Activity Setting Notebook Layout", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.deleteActivity("Test Automation Create Activity Notebook Layout");
  });

  describe("Test Activity Setting Notebook Layout", () => {
    it("Create Activity", () => {
      settingsPage.getCreateActivityButton().click();
      settingsPage.getNewActivityPage().should("exist");
      settingsPage.getActivityName().type("Test Automation Create Activity Notebook Layout");
      settingsPage.getSaveButton().click();
      settingsPage.getSettingsPage().should("exist");
    });
    it("Set activity layout to notebook", () => {
      settingsPage.selectActivityLayout("Notebook");
      settingsPage.getPreviewImageUrl().type(url.imageUrl);
      settingsPage.getIndexPageText().type("This Is Home Page Text");
      settingsPage.getSettingsPageSave().click();
      cy.wait(4000);
    });
    it("Verify activity is previewed in notebook layout", () => {
      previewTest();
      notebookLayout.getPreviousPageButton().should("not.exist");
      notebookLayout.getNextPageButton().should("not.exist");
      notebookLayout.getActivityNavHeader(0).should("exist");
      notebookLayout.getActivityNavHeader(1).should("not.exist");
      notebookLayout.getHomeButton().should("contain", "Home");
      notebookLayout.verifyNotebookHeaderNotDisplayed();   
    });

  });
});
