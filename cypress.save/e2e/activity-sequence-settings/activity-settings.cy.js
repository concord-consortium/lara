import AuthoringPage from "../../support/authoring-page.cy.js";
import ActivitySequenceSettingsPage from "../../support/activity-sequence-settings.cy.js";
import ActivityPlayerPreview from "../../support/activity-player-preview.cy.js";

const authoringPage = new AuthoringPage;
const settingsPage = new ActivitySequenceSettingsPage;
const activityPreview = new ActivityPlayerPreview;

const url = {
    imageUrl: "https://learn-resources.concord.org/tutorials/images/brogan-acadia.jpg"
};

function previewTest() {
  cy.visit("");
  authoringPage.previewActivity("Test Automation Activity Settings");
}

context("Test Activity Settings", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.deleteActivity("Test Automation Activity Settings");
  });

  describe("Test Activity Settings", () => {
    it("Create Activity", () => {
      settingsPage.getCreateActivityButton().click();
      settingsPage.getNewActivityPage().should("exist");
      settingsPage.getActivityName().type("Test Automation Activity Settings");
      settingsPage.getSaveButton().click();
      cy.wait(2000);
      settingsPage.getSettingsPage().should("exist");
      //to-do: add more thorough check with data-testid tags (PT-#188775242)
      cy.get('h1').contains('Edit Activity: Test Automation Activity Settings').should('exist');
    });
    it("Activity Settings", () => {
      cy.get('h1').contains('Edit Activity: Test Automation Activity Settings').should('exist');
      settingsPage.getGlossaryDropDown().should("be.enabled");
      settingsPage.getBackgroundImageUrl().type(url.imageUrl);
      settingsPage.getPreviewImageUrl().type(url.imageUrl);
      settingsPage.clickThumbailPreview();
      settingsPage.getThumbailPreview(url.imageUrl);
      settingsPage.getIndexPageText().type("This Is Home Page Text");
      settingsPage.clickInsertImage();
      settingsPage.getEditImageDialog().should("exist");
      settingsPage.getSourceField().type(url.imageUrl);
      settingsPage.getInsertImageOkButton().click();
      settingsPage.getSettingsPageSave().click();
      cy.wait(2000);
    });
    it("Activity Settings In Authoring Home Page", () => {
      cy.visit("");
      authoringPage.searchActivitySequence("Test Automation Activity Settings");
      authoringPage.getActivityDetails().should("contain", "This Is Home Page Text");
      authoringPage.getActivityDetailImage(url.imageUrl);
    });
    it("Verify Activity Preview In Activity Player Runtime", () => {
      previewTest();
      activityPreview.getActivityTitle().should("contain", "Test Automation Activity Settings");
      activityPreview.getReadAloudToggle().should("exist");
      activityPreview.getIntroText().should("contain", "This Is Home Page Text");
      activityPreview.getIntroTextImage(url.imageUrl);
      activityPreview.getActivityThumbnail(url.imageUrl);
      activityPreview.getPagesHeader().should("contain", "Pages in this Activity");
    });

  });
});
