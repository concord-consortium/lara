import AuthoringPage from "../../support/authoring-page.cy.js";

const authoringPage = new AuthoringPage;

context("Test Activity Action Menu", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    cy.deleteCopyActivity("Copy of Test Automation Activity Menu Actions");
    cy.searchActivity("Test Automation Activity Menu Actions");
  });

  describe("Test Activity Action Menu", () => {
    it("Verify Copy Actions", () => {
      authoringPage.getActivityCopyMenu().click();
      cy.wait(2000);
      authoringPage.getSettingsPage().should("exist");
      authoringPage.getSettingsPageSave();
      authoringPage.clickHomePageLink();
    });
    it("Verify Publish Actions", () => {
      authoringPage.searchActivitySequence("Copy of Test Automation Activity Menu Actions");
      authoringPage.getActivityPublishMenu().click();
      cy.wait(2000);
      authoringPage.getPublishModel().should("exist");
      authoringPage.getPublishLink().click();
      cy.wait(2000);
      authoringPage.getPublishStatus().should("contain", "published");
      authoringPage.getPublishModelClose().click();
      authoringPage.searchActivitySequence("Copy of Test Automation Activity Menu Actions");
      authoringPage.getActivityDetailPublished().should("contain", "last published");
      cy.wait(2000);
    });
    it("Verify Delete Actions", () => {
      authoringPage.searchActivitySequence("Copy of Test Automation Activity Menu Actions");
      authoringPage.getActivityDeleteMenu().click();
      cy.wait(2000);
      authoringPage.clickHomePageLink();
      authoringPage.searchActivitySequence("Copy of Test Automation Activity Menu Actions");
      authoringPage.getActivity().should("not.exist");
    });
  });
});
