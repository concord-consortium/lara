import AuthoringPage from "../../support/authoring-page.cy.js";

const authoringPage = new AuthoringPage;

context("Test Activity Action Menu", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    cy.searchActivity("Test Automation Activity Menu Actions");
  });

  describe("Test Activity Action Menu", () => {
    it("Verify Copy Actions", () => {
      authoringPage.getActivityCopyMenu().click();
      cy.wait(2000);
      authoringPage.getSettingsPage().should("exist");
      authoringPage.getSettingsPageSave();
      authoringPage.clickHomePageLink();
    
      cy.log("Verify the copied activity");
      cy.searchActivity("Copy of Test Automation Activity Menu Actions");
      authoringPage.getActivity().should("exist");

      // We skip the Publish action to avoid creating clutter
      // in the Portal Staging environment.

      // authoringPage.getActivityPublishMenu().click();
      // cy.wait(2000);
      // authoringPage.getPublishModal().should("exist");
      // authoringPage.getPublishLink().click();
      // cy.wait(2000);
      // authoringPage.getPublishStatus().should("contain", "published");
      // authoringPage.getPublishModalClose().click();
      // authoringPage.searchActivitySequence("Copy of Test Automation Activity Menu Actions");
      // authoringPage.getActivityDetailPublished().should("contain", "last published");
      // cy.wait(2000);
    
      cy.log("Verify the delete actions");
      cy.searchActivity("Copy of Test Automation Activity Menu Actions");
      authoringPage.getActivity().should("have.length", 1);
      authoringPage.getActivityDeleteMenu().click();
      authoringPage.clickHomePageLink();
      cy.searchActivity("Copy of Test Automation Activity Menu Actions");
      authoringPage.getActivity().should("not.exist");

      cy.searchActivity("Test Automation Activity Menu Actions");
      authoringPage.getActivity().should("have.length", 1);
    });
  });
});
