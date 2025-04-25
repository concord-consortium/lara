import AuthoringPage from "../../support/authoring-page.cy.js";
import MCQAuthoringPage from "../../support/mcq-authoring.cy.js";

const authoringPage = new AuthoringPage;
const mcqAuthoringPage = new MCQAuthoringPage;

context("Test Item Action Menus", () => {
  beforeEach(() => {
    // Visit the base URL and ensure we're logged in
    cy.visit(Cypress.config().baseUrl);
    cy.login();
    
    // Launch the activity and ensure it's in a clean state
    authoringPage.launchActivity("Test Automation Item Menu Actions");
    cy.deleteItem();
  });

  afterEach(() => {
    // TODO: The cleanup using cy.deleteItem() is not working as expected.
    // The delete buttons remain visible after the tests complete.
    // This needs to be investigated and fixed.
    cy.deleteItem();
  });

  describe("LARA Item Action Menus", () => {
    it("Add MCQ Item with default configuration", () => {
      mcqAuthoringPage.addMCQItem(); // Uses default configuration
    });

    it("Add MCQ Item with custom configuration", () => {
      mcqAuthoringPage.addMCQItem('custom');
    });

    it.skip("Verify Item Level Actions", () => {
      // TODO: This test is skipped because it relies on a data-testid that is not yet in the repository.
      // Once the data-testid is added to the repository, this test should be re-enabled and updated
      // to use the correct selector.
      
      cy.wait(6000);
      authoringPage.getSectionMenuMove().click();
      authoringPage.getMoveModal().should("exist");
      authoringPage.getMoveModal().click();
      authoringPage.getMoveModalHeader("Move this item to...");
      authoringPage.getMoveModalClose().click();
      authoringPage.getSectionMenuCopy().click();
      cy.wait(2000);
      authoringPage.getCopySectionItemHeader(1).should("exist");
      authoringPage.getCopySectionMenuDelete(1).click();
      cy.wait(2000);
    });

    it("Delete Item", () => {
      // Add the MCQ item first since we're in a clean state
      mcqAuthoringPage.addMCQItem();

      // Now delete it
      authoringPage.getSectionMenuDelete().click();
    });
  });
});
