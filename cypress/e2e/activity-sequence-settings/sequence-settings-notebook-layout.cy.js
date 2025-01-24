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
  authoringPage.previewSequence("Test Automation Create Sequence Notebook Layout");
}

context("Test Sequence Setting Notebook Layout", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    cy.deleteNewSequence();
  });

  describe("Test Sequence Setting Notebook Layout", () => {
    it("Create Sequence", () => {
      settingsPage.getCreateSequenceButton().click();
      settingsPage.getSettingsPage().should("exist");
      settingsPage.getSeqTitle().type("Test Automation Create Sequence Notebook Layout");
      settingsPage.getSettingsPageSave().click();
      cy.wait(2000);
    });
    it("Sequence Settings", () => {
      // authoringPage.searchActivitySequence("Test Automation Create Sequence Notebook Layout");
      // authoringPage.getSequenceEditMenu().click();
      settingsPage.selectActivityLayoutOverride("Notebook");
      settingsPage.getSeqPreviewImageUrl().type(url.imageUrl);
      settingsPage.getSeqIndexPageText().type("This Is Home Page Text");
      settingsPage.getSettingsPageSave().click();
      cy.wait(4000);
      settingsPage.addActivity();
      settingsPage.clickAddButton();
    });
    it("Verify activity is previewed in notebook layout", () => {
      previewTest();
      notebookLayout.getSequenceTitle().should("contain", "Test Automation Create Sequence Notebook Layout");
      notebookLayout.getNotebookHeader().should("exist");
      notebookLayout.clickSequenceThumb(1);
      notebookLayout.getActivityTitle().should("contain", "Authoring LARA Staging Question Interactives Master Branch");
      notebookLayout.getPreviousPageButton().should("not.exist");
      notebookLayout.getNextPageButton().should("not.exist");
      notebookLayout.getActivityNavHeader(0).should("exist");
      notebookLayout.getActivityNavHeader(1).should("not.exist");
      notebookLayout.getHomeButton().should("contain", "Home");
      notebookLayout.verifyNotebookHeaderNotDisplayed();   
    });
  });
});
