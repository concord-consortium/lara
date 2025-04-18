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

  describe("LARA Item Action Menus", () => {
    it("Add MCQ Item with default configuration", () => {
      mcqAuthoringPage.addMCQItem(); // Uses default configuration
    });

    it("Add MCQ Item with custom configuration", () => {
      mcqAuthoringPage.addMCQItem('custom');
    });

    it("Verify Item Level Actions", () => {
      // Add the MCQ item first since we're in a clean state
      mcqAuthoringPage.addMCQItem();

      // Now verify the actions
      authoringPage.getSectionMenuMove().click();
      authoringPage.getMoveModel().should("exist");
      authoringPage.getMoveModel().click();
      authoringPage.getMoveModelHeader("Move this item to...");
      authoringPage.getMoveModelClose().click();
      
      // Click copy and wait for the new item to appear
      authoringPage.getSectionMenuCopy().click();
      
      // Wait for and verify that we have two items
      cy.get(".itemsContainer .sectionItemContainer").should("have.length", 2).then(() => {
        // Get all items and verify the second one has the expected menu
        cy.get(".itemsContainer .sectionItemContainer").eq(1).within(() => {
          cy.get(".menuEnd button").eq(4).click(); // Click delete on the second item
        });
      });
    });

    it("Delete Item", () => {
      // Add the MCQ item first since we're in a clean state
      mcqAuthoringPage.addMCQItem();

      // Now delete it
      authoringPage.getSectionMenuDelete().click();
    });
  });
});
