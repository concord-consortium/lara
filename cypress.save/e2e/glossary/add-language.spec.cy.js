import AddLanguage from "../../support/glossary/add-language.cy.js";
import AddEditDeleteTerm from "../../support/glossary/add-edit-delete-term.cy.js";

const addLanguage = new AddLanguage;
const addEditDeleteTerm = new AddEditDeleteTerm;

const langProperties = {
    term: "Translated Term",
    definition: "Translated Term Definition",
    diggingDeeper: "Translated Term Digging Deeper",
    imageAltText: "Translated Term Image Alt Text",
    imageCaption: "Translated Term Image Caption",
    videoAltText: "Translated Term Video Alt Text",
    videoCaption: "Translated Term Video Caption",
    chinese: "Language: Chinese (0/1)",
    hawaiian: "Language: Hawaiian (0/1)"
};

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

context("Test Additional Language", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    cy.deleteGlossary("Automation Glossary Language Setting Test");
    cy.createGlossary("Automation Glossary Language Setting Test");
  });

  describe("Verify Additional Language", () => {
    it("Add New Term", () => {
      addEditDeleteTerm.getAddNewTermButton().click();
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
      addEditDeleteTerm.getSaveCloseButton().click();
      cy.wait(2000);
    });
    it("Add Language", () => {
      addLanguage.selectLanguage('Chinese');
      addLanguage.getAddLanguageButton().click();
      addLanguage.getLanguagePanelHeader(1).should("contain", langProperties.chinese);
      addLanguage.selectLanguage('Hawaiian');
      addLanguage.getAddLanguageButton().click();
      addLanguage.getLanguagePanelHeader(2).should("contain", langProperties.hawaiian);
    });
    it("Delete Language", () => {
      addLanguage.getLanguagePanelDelete(1).click();
      addLanguage.getLanguagePanelHeader(1).should("not.contain", langProperties.chinese);
      addLanguage.getLanguagePanelHeader(1).should("contain", langProperties.hawaiian);
    });
    it("Edit Language", () => {
      addLanguage.getLanguageEditLink().click();
      addLanguage.getTermField().type(langProperties.term);
      addLanguage.getDefinitionField().type(langProperties.definition);
      addLanguage.getDiggingDeeperField().type(langProperties.diggingDeeper);
      addLanguage.getImageCaptionField().type(langProperties.imageCaption);
      addLanguage.getImageAltTextField().type(langProperties.imageAltText);
      addLanguage.getVideoCaptionField().type(langProperties.videoCaption);
      addLanguage.getVideoAltTextField().type(langProperties.videoAltText);
      addLanguage.getSaveButton().click();
    });
    it("Verify Preview For Edited Language", () => {
      addLanguage.getTermPopupPreviewDefinition().should("contain", langProperties.definition);
      addLanguage.getTermPopupPreviewDefinitionReadAloud().should("exist");
      addLanguage.getTermPopupPreviewViewPhoto().should("exist");
      addLanguage.getTermPopupPreviewViewVideo().should("exist");
      addLanguage.getTermPopupPreviewDiggingDeeper().should("exist");
      addLanguage.getSaveCloseButton().click({ force: true });
      cy.wait(2000);
    });
    it("Verify Edited Language In Table", () => {
      addLanguage.getLanguageFirstRow().should("contain", "Test Term");
      addLanguage.getLanguageFirstRow().should("contain", langProperties.term);
      addLanguage.getLanguageFirstRow().should("contain", langProperties.definition);
      addLanguage.getLanguageRowDiggingDeeper().should("contain", "✓");
      addLanguage.getLanguageRowImageCaption().should("contain", "✓");
      addLanguage.getLanguageRowVideoCaption().should("contain", "✓");
    });
    it("Verify Second Language In Glossary Terms & Definitions", () => {
      addEditDeleteTerm.getTermsDefinitionsTableEditLink().click();
      cy.wait(1000);
      addEditDeleteTerm.selectSecondLanguage('Hawaiian');
      addEditDeleteTerm.getLanguageSelector().should("exist");
      addEditDeleteTerm.selectLanguage("Hawaiian").click();
      addEditDeleteTerm.getTermPopupPreviewDefinition().should("contain", langProperties.definition);
      addLanguage.getTermPopupPreviewViewPhoto().click();
      addEditDeleteTerm.getTermPopupPreviewImageCaption().should("contain", langProperties.imageCaption);
      addEditDeleteTerm.getTermPopupPreviewImageZoomButton().click();
      addEditDeleteTerm.getTermPopupPreviewImageZoomCaption().should("contain", langProperties.imageCaption);
      addEditDeleteTerm.getTermPopupPreviewImageZoomClose().click();
      addLanguage.getTermPopupPreviewViewVideo().click();
      addEditDeleteTerm.getTermPopupPreviewVideoContainer().should("exist");
      addEditDeleteTerm.getTermPopupPreviewVideoCaption().should("contain", langProperties.videoCaption);
      addEditDeleteTerm.getSaveCloseButton().click();
    });
    it("Delete Translated Language Term", () => {
      addLanguage.getLanguageDeleteLink().click();
      addLanguage.getLanguageFirstRow().should("contain", "Test Term");
      addLanguage.getLanguageFirstRow().should("not.contain", langProperties.term);
      addLanguage.getLanguageFirstRow().should("not.contain", langProperties.definition);
      addLanguage.getLanguageRowDiggingDeeper().should("contain", "✗");
      addLanguage.getLanguageRowImageCaption().should("contain", "✗");
      addLanguage.getLanguageRowVideoCaption().should("contain", "✗");
      addLanguage.getLanguagePanelDelete(1).click();
    });
  });
});
