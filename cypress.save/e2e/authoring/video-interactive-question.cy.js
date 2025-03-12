import AuthoringPage from "../../support/authoring-page.cy.js";
import VideoInteractiveAuthoringPage from "../../support/video-interactive-authoring.cy.js";

const authoringPage = new AuthoringPage;
const videoInteractiveAuthoringPage = new VideoInteractiveAuthoringPage;

context("Test Authoring Preview", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.launchActivity("Test Automation Video Interactive Activity");
    cy.deleteItem();
  });

  describe("LARA Video Interactive Authoring Preview", () => {
    it("Add Video Interactive Item", () => {
      authoringPage.getAddItem().click();
      authoringPage.getItemPickerSearch().type("Video Player");
      authoringPage.getItemPickerList().contains("Video Player AWS").click();
      authoringPage.getAddItemButton().click();
      authoringPage.getEditItemDialog().should("exist");
      authoringPage.getNameField().type("Video Player Question");
      videoInteractiveAuthoringPage.getVideoURLField("https://cc-project-resources.s3.amazonaws.com/waters/Glossary/movies/aquatic.mp4");
      videoInteractiveAuthoringPage.getVideoCaptionURLField("https://project-resources.concord.org/waters/Lesson1/Movies/L1USDAWatershedLearningVideo.vtt");
      videoInteractiveAuthoringPage.getDescriptionField("Video Description");
      videoInteractiveAuthoringPage.getCaptionField("Video Caption");
      videoInteractiveAuthoringPage.getCreditField("Video Credit");
      cy.wait(2000);
      authoringPage.getSaveButton().click();
    });
    it("Verify Added Video Interactive In Authoring Preview", () => {
      cy.wait(6000);
      authoringPage.getSectionItemHeader().should("contain", "Video Player Question");
      videoInteractiveAuthoringPage.verifyAuthoringPreviewVideo("https://cc-project-resources.s3.amazonaws.com/waters/Glossary/movies/aquatic.mp4");
      videoInteractiveAuthoringPage.getAuthoringPreviewPlayButton().should("exist");
      videoInteractiveAuthoringPage.verifyAuthoringPreviewDescription("Video Description");
      videoInteractiveAuthoringPage.verifyAuthoringPreviewCaption("Video Caption");
      videoInteractiveAuthoringPage.verifyAuthoringPreviewCredit("Video Credit");
      
    });
    it("Verify Added Video Interactive In Item Preview", () => {
      cy.wait(2000);
      authoringPage.getSectionMenuEdit().click();
      cy.wait(6000);
      videoInteractiveAuthoringPage.verifyEditItemPreviewVideo("https://cc-project-resources.s3.amazonaws.com/waters/Glossary/movies/aquatic.mp4");
      videoInteractiveAuthoringPage.getEditItemPreviewPlayButton().should("exist");
      videoInteractiveAuthoringPage.verifyEditItemPreviewDescription("Video Description");
      videoInteractiveAuthoringPage.verifyEditItemPreviewCaption("Video Caption");
      videoInteractiveAuthoringPage.verifyEditItemPreviewCredit("Video Credit");
      authoringPage.getSaveButton().click();
    });
    it("Delete Item", () => {
      cy.wait(6000);
      authoringPage.getSectionMenuDelete().click();
    });
  });
});
