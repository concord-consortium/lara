import AddEditDeleteTerm from "../../support/glossary/add-edit-delete-term.cy.js";
import PreviewTerm from "../../support/glossary/preview-term.cy.js";

const addEditDeleteTerm = new AddEditDeleteTerm;
const previewTerm = new PreviewTerm;

const termProperties = {
    term: "New Test Term",
    definition: "New Test Term Definition",
    diggingDeeper: "New Test Term Digging Deeper",
    imageUrl: "https://learn-resources.concord.org/tutorials/images/brogan-acadia.jpg",
    imageAltText: "New Test Term Image Alt Text",
    zoomImageUrl: "https://learn-resources.concord.org/tutorials/images/brogan-acadia.jpg",
    imageCaption: "New Test Term Image Caption",
    videoUrl: "https://cc-project-resources.s3.amazonaws.com/waters/Glossary/movies/AmbientTemperature.mp4",
    videoAltText: "New Test Term Video Alt Text",
    videoCaption: "New Test Term Video Caption",
    closedCaptionUrl: "https://project-resources.concord.org/waters/Lesson1/Movies/L1USDAWatershedLearningVideo.vtt",
    editTerm: "Edit Test Term",
    editDefinition: "Edit Test Term Definition",
    editDiggingDeeper: "Edit Test Term Digging Deeper"
};

context("Test Authoring Preview", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    cy.deleteGlossary("Automation Glossary Term Settings Test");
    cy.createGlossary("Automation Glossary Term Setting Test");
  });

  describe("Verify Add New Term", () => {
    it("Add New Term Error Message", () => {
      addEditDeleteTerm.getAddNewTermButton().click();
      addEditDeleteTerm.getSaveCloseButton().click();
      addEditDeleteTerm.getTermFieldError().should("contain", "Term is required");
      addEditDeleteTerm.getDefinitionFieldError().should("contain", "Definition is required");
    });
    it("Add New Term", () => {
      addEditDeleteTerm.getTermField().type(termProperties.term);
      addEditDeleteTerm.getDefinitionField().type(termProperties.definition);
      addEditDeleteTerm.getDiggingDeeperField().type(termProperties.diggingDeeper);
      addEditDeleteTerm.getImageUrlField().type(termProperties.imageUrl);
      addEditDeleteTerm.getImageAltTextField().type(termProperties.imageAltText);
      addEditDeleteTerm.getZoomImageUrlField().type(termProperties.zoomImageUrl);
      addEditDeleteTerm.getImageCaptionField().type(termProperties.imageCaption);
      addEditDeleteTerm.getVideoUrlField().type(termProperties.videoUrl);
      addEditDeleteTerm.getVideoAltTextField().type(termProperties.videoAltText);
      addEditDeleteTerm.getVideoCaptionField().type(termProperties.videoCaption);
      addEditDeleteTerm.getClosedCaptionUrlField().type(termProperties.closedCaptionUrl);
    });
    it("Verify Preview For Added New Term", () => {
      addEditDeleteTerm.getTermPopupPreviewHeader().should("contain", termProperties.term);
      addEditDeleteTerm.getTermPopupPreviewDefinition().should("contain", termProperties.definition);
      addEditDeleteTerm.getTermPopupPreviewDefinitionReadAloud().should("exist");
      addEditDeleteTerm.getTermPopupPreviewViewPhoto().should("exist");
      addEditDeleteTerm.getTermPopupPreviewViewVideo().should("exist");
      addEditDeleteTerm.getTermPopupPreviewDiggingDeeper().should("exist");
      addEditDeleteTerm.getTermPopupPreviewImageContainer().should("not.exist");
      addEditDeleteTerm.getTermPopupPreviewViewPhoto().click();
      addEditDeleteTerm.getTermPopupPreviewImageContainer().should("exist");
      addEditDeleteTerm.getTermPopupPreviewImageCaption().should("contain", termProperties.imageCaption);
      addEditDeleteTerm.getTermPopupPreviewImageCaptionReadAloud().should("exist");
      addEditDeleteTerm.getTermPopupPreviewImageZoomButton().click();
      addEditDeleteTerm.getTermPopupPreviewImageZoomCaption().should("contain", termProperties.imageCaption);
      addEditDeleteTerm.getTermPopupPreviewImageZoomCaptionReadAloud().should("exist");
      addEditDeleteTerm.getTermPopupPreviewImageZoomClose().click();
      addEditDeleteTerm.getTermPopupPreviewViewVideo().click();
      addEditDeleteTerm.getTermPopupPreviewVideoContainer().should("exist");
      addEditDeleteTerm.getTermPopupPreviewVideoCaption().should("contain", termProperties.videoCaption);
      addEditDeleteTerm.getTermPopupPreviewVideoCaptionReadAloud().should("exist");
      addEditDeleteTerm.getTermPopupPreviewDiggingDeeper().click();
      addEditDeleteTerm.getTermPopupPreviewDiggingDeeperContainer().should("contain", termProperties.diggingDeeper);
      addEditDeleteTerm.getSaveCloseButton().click();
    });
    it("Verify Added New Term", () => {
      addEditDeleteTerm.getTermsDefinitionsTableFirstRow().should("contain", termProperties.term);
      addEditDeleteTerm.getTermsDefinitionsTableFirstRow().should("contain", termProperties.definition);
      addEditDeleteTerm.getTermsDefinitionsTableFirstRow().should("contain", "✓");
      addEditDeleteTerm.getTermsDefinitionsTablePreviewImageIcon().should("exist");
      addEditDeleteTerm.getTermsDefinitionsTablePreviewVideoIcon().should("exist");
    });
    it("Verify Edit Term", () => {
      addEditDeleteTerm.getTermsDefinitionsTableEditLink().click();
      addEditDeleteTerm.getTermField().clear().type(termProperties.editTerm);
      addEditDeleteTerm.getDefinitionField().clear().type(termProperties.editDefinition);
      addEditDeleteTerm.getDiggingDeeperField().clear().type(termProperties.editDiggingDeeper);
      addEditDeleteTerm.getTermPopupPreviewHeader().should("contain", termProperties.editTerm);
      addEditDeleteTerm.getTermPopupPreviewDefinition().should("contain", termProperties.editDefinition);
      addEditDeleteTerm.getTermPopupPreviewDiggingDeeper().click();
      addEditDeleteTerm.getTermPopupPreviewDiggingDeeperContainer().should("contain", termProperties.editDiggingDeeper);
      addEditDeleteTerm.getEditSaveCloseButton().click();
    });
    it("Verify Edited Term", () => {
      addEditDeleteTerm.getTermsDefinitionsTableFirstRow().should("contain", termProperties.editTerm);
      addEditDeleteTerm.getTermsDefinitionsTableFirstRow().should("contain", termProperties.editDefinition);
      addEditDeleteTerm.getTermsDefinitionsTableFirstRow().should("contain", "✓");
    });
    it("Verify Preview Image", () => {
      addEditDeleteTerm.getTermsDefinitionsTablePreviewImageIcon().click();
      addEditDeleteTerm.getModelPreviewImageContainer().should("exist");
      addEditDeleteTerm.getModelPreviewImageCaption().should("contain", termProperties.imageCaption);
      addEditDeleteTerm.getModelPreviewClose().click();
    });
    it("Verify Preview Video", () => {
      addEditDeleteTerm.getTermsDefinitionsTablePreviewVideoIcon().click();
      addEditDeleteTerm.getModelPreviewVideoContainer().should("exist");
      addEditDeleteTerm.getModelPreviewVideoCaption().should("contain", termProperties.videoCaption);
      addEditDeleteTerm.getModelPreviewClose().click();
    });
    it("Verify Preview For First Term", () => {
      previewTerm.getPreviewTermButton().click();
      previewTerm.getTermPopupPreviewHeader().should("contain", termProperties.editTerm);
      previewTerm.getTermPopupPreviewViewPhoto().click();
      previewTerm.getTermPopupPreviewImageContainer().should("exist");
      previewTerm.getTermPopupPreviewImageCaption().should("contain", termProperties.imageCaption);
      previewTerm.getTermPopupPreviewImageCaptionReadAloud().should("exist");
      previewTerm.getTermPopupPreviewImageZoomButton().click();
      previewTerm.getTermPopupPreviewImageZoomCaption().should("contain", termProperties.imageCaption);
      previewTerm.getTermPopupPreviewImageZoomCaptionReadAloud().should("exist");
      previewTerm.getTermPopupPreviewImageZoomClose().click();
      previewTerm.getTermPopupPreviewViewPhoto().click();
      previewTerm.getTermPopupPreviewImageContainer().should("not.exist");
      previewTerm.getTermPopupPreviewViewVideo().click();
      previewTerm.getTermPopupPreviewVideoContainer().should("exist");
      previewTerm.getTermPopupPreviewVideoCaption().should("contain", termProperties.videoCaption);
      previewTerm.getTermPopupPreviewVideoCaptionReadAloud().should("exist");
      previewTerm.getTermPopupPreviewViewVideo().click();
      previewTerm.getTermPopupPreviewVideoContainer().should("not.exist");
    });
    it("Verify Next And Previous Term", () => {
      previewTerm.getNextTermButton().click();
      previewTerm.getTermPopupPreviewHeader().should("contain", "Test Term");
      previewTerm.getPreviousTermButton().click();
      previewTerm.getTermPopupPreviewHeader().should("contain", termProperties.editTerm);
      previewTerm.getModalCloseButton().click();
    });
    it("Verify Delete Term", () => {
      addEditDeleteTerm.getTermsDefinitionsTableDeleteLink().click();
    });
  });
});
