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
  authoringPage.previewSequence("Test Automation Sequence Settings");
}

context("Test Sequence Settings", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.deleteSequence("Test Automation Sequence Settings");
  });

  describe("Test Sequence Settings", () => {
    it("Create Sequence", () => {
      settingsPage.getCreateSequenceButton().click();
      settingsPage.getSettingsPage().should("exist");
      settingsPage.getSeqTitle().type("Test Automation Sequence Settings");
      settingsPage.getSettingsPageSave().click();
      cy.wait(2000);
    });
    it("Sequence Settings", () => {
      settingsPage.getPublishToOtherPortalsButton().should("exist").click();
      settingsPage.getPublishToOtherPortalsModalTitle().should('be.visible');
      settingsPage.getPublishToOtherPortalsCloseButton().click();
      settingsPage.getPublishToOtherPortalsModalTitle().should('not.be.visible');
      settingsPage.getGlossaryDropDown().should("not.exist");
      settingsPage.getSeqBackgroundImageUrl().type(url.imageUrl);
      settingsPage.getSeqPreviewImageUrl().type(url.imageUrl);
      settingsPage.clickThumbailPreview();
      settingsPage.getThumbailPreview(url.imageUrl);
      settingsPage.getSeqIndexPageText().type("This Is Home Page Text");
      settingsPage.clickInsertImage();
      settingsPage.getEditImageDialog().should("exist");
      settingsPage.getSourceField().type(url.imageUrl);
      settingsPage.getInsertImageOkButton().click();
      settingsPage.getSettingsPageSave().click();
      cy.wait(2000);
      settingsPage.addActivity();
      settingsPage.clickAddButton();
    });
    it("Sequence Settings In Authoring Home Page", () => {
      cy.visit("");
      authoringPage.searchActivitySequence("Test Automation Sequence Settings");
      authoringPage.getSequenceDetails().should("contain", "This Is Home Page Text");
      authoringPage.getSequenceDetailImage(url.imageUrl);
    });
    it("Verify Sequence Preview In Activity Player Runtime", () => {
      previewTest();
      activityPreview.getSequenceActivityTitle().should("contain", "Test Automation Sequence Settings");
      activityPreview.getSequenceTitle().should("contain", "Test Automation Sequence Settings");
      activityPreview.getSequenceDescription().should("contain", "This Is Home Page Text");
      activityPreview.getSequenceEstimate().should("contain", "Estimated Time to Complete This Module:");
    });
  });
});
