import AuthoringPage from "../../support/authoring-page.cy.js";

const authoringPage = new AuthoringPage;

context("Test Sequence Action Menu", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    cy.deleteCopySequence("Copy of Test Automation Sequence Menu Actions");
    cy.searchSequence("Test Automation Sequence Menu Actions");
  });

  describe("Test Sequence Action Menu", () => {
    it("Verify Copy Actions", () => {
      authoringPage.getSequenceCopyMenu().click();
      cy.wait(2000);
      authoringPage.getSettingsPage().should("exist");
      authoringPage.getSettingsPageSave();
      authoringPage.clickHomePageLink();
    });
    it("Verify Publish Actions", () => {
      authoringPage.searchActivitySequence("Copy of Test Automation Sequence Menu Actions");
      authoringPage.getSequencePublishMenu().click();
      cy.wait(2000);
      authoringPage.getPublishModel().should("exist");
      authoringPage.getPublishLink().click();
      cy.wait(2000);
      authoringPage.getPublishStatus().should("contain", "published");
      authoringPage.getPublishModelClose().click();
      cy.wait(2000);
    });
    it("Verify Delete Actions", () => {
      authoringPage.searchActivitySequence("Copy of Test Automation Sequence Menu Actions");
      authoringPage.getSequenceDeleteMenu().click();
      cy.wait(2000);
      authoringPage.clickHomePageLink();
      authoringPage.searchActivitySequence("Copy of Test Automation Sequence Menu Actions");
      authoringPage.getSequence().should("not.exist");
    });
  });
});
