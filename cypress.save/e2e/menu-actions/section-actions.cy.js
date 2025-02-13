import AuthoringPage from "../../support/authoring-page.cy.js";
import MCQAuthoringPage from "../../support/mcq-authoring.cy.js";

const authoringPage = new AuthoringPage;
const mcqAuthoringPage = new MCQAuthoringPage;

context("Test Section Action Menus", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.launchActivity("Test Automation Section Menu Actions");
    cy.deleteItem();
    cy.deleteSection();
  });

  describe("LARA Item Action Menus", () => {
    it("Verifies the Page Title and saves changes", () => {
      // Verify the page title is as expected
      authoringPage.checkPageTitle('Test Automation Section Menu Actions');
    
      // Click the Page Settings button
      authoringPage.getPageSettingsButton().should('be.visible').click();
    
      // Change the title to "Test Automation Section Menu Actions Edit" and save
      authoringPage.enterPageTitle('Test Automation Section Menu Actions Edit');
      authoringPage.clickSaveAndClose();
    
      // Verify the page title was updated
      cy.wait(500);
      authoringPage.checkPageTitle('Test Automation Section Menu Actions Edit');
    
      // Revert the title back to "Test Automation Section Menu Actions" only if needed
      cy.get('header.editPageHeader h2').invoke('text').then((currentTitle) => {
        const expectedDefault = 'Page: Test Automation Section Menu Actions';
        if (currentTitle.trim() !== expectedDefault) {
          authoringPage.getPageSettingsButton().should('be.visible').click();
          authoringPage.enterPageTitle('Test Automation Section Menu Actions');
          authoringPage.clickSaveAndClose();
    
          // Verify the title is reverted back
          cy.wait(500);
          authoringPage.checkPageTitle('Test Automation Section Menu Actions');
        }
      });
    });
    it("Add MCQ Item", () => {
      cy.log("Add a Multiple Choice Question item");
      authoringPage.getAddItem().click();
      authoringPage.getItemPickerSearch().type("Multiple Choice");
      authoringPage.getItemPickerList().contains("Multiple Choice AWS S3").click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      cy.log('Fill in the item fields within the iFrame');
      authoringPage.getPromptField(" Multiple Choice Prompt");
      authoringPage.getHintField(" Multiple Choice Hint");
      mcqAuthoringPage.selectChoiceInEditForm(0);
      authoringPage.getSaveButton().click();
      // TODO: Add a data-testid to the item title
      // checks that the default item title is Untitled
      cy.contains("Untitled").should("exist");

      cy.log('Checks that title of the item was changed');
      authoringPage.getSectionMenuEdit().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type("Multiple Choice Question");
      authoringPage.getSaveButton().click();
      // TODO: Add a data-testid to the item title
      // Check if "Multiple Choice" exists anywhere on the page 
      cy.contains("Multiple Choice").should("exist");
    });
    it("Verify Section Level and Page Level Actions", () => {
      cy.wait(6000);
      cy.log("Verify the section level actions");
      // Verify and update section title to "Section Name Edit"
      authoringPage.verifyButton(0, 0, "Edit");
      authoringPage.clickButton(0, 0);
      authoringPage.getSectionNameTextBox(0).should("exist");
      authoringPage.getSectionNameTextBox(0).clear().type("Section Name Edit");
      authoringPage.clickButton(0, 0);
      cy.wait(4000);
      authoringPage.verifySectionName(0, "Section Name Edit");
    
      // Rename the section back to "Section 1" only if necessary
      authoringPage.checkAndReturnSectionName(0).then((sectionName) => {
        if (sectionName !== "Section 1") {
          authoringPage.verifyButton(0, 0, "Edit");
          authoringPage.clickButton(0, 0);
          authoringPage.getSectionNameTextBox(0).should("exist");
          authoringPage.getSectionNameTextBox(0).clear().type("Section 1");
          authoringPage.clickButton(0, 0);
          cy.wait(4000);
          authoringPage.verifySectionName(0, "Section 1");
        }
      });
    
      // Verify the move section modal can be opened and closed
      cy.log("Verify the move section modal can be opened and closed");
      authoringPage.getSectionMove().click();
      authoringPage.getMoveModel().should("exist");
      authoringPage.getMoveModelHeader("Move Section 1 to...");
      authoringPage.getMoveModelClose().click();
    
      // Verify hiding and showing a section
      authoringPage.getSectionHide().click();
      authoringPage.verfiySectionHidden();
      authoringPage.getSectionHide().click();
      authoringPage.verfiySectionShow();
    
      // Verify copying a section
      authoringPage.getSectionCopy().click();
      cy.wait(2000);
      authoringPage.getCopySectionHeader(1).should("contain", "Section 1");
      authoringPage.getCopySectionDelete(1).click();
      cy.wait(2000);
    });
    it("Delete Item", () => {
      cy.wait(6000);
      authoringPage.getSectionMenuDelete().click();
    });
  });
});
