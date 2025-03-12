import GlossarySettings from "../../support/glossary/glossary-settings.cy.js";

const glossarySettings = new GlossarySettings;

context("Test Authoring Preview", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    cy.deleteGlossary("Automation Glossary Setting Test");
    cy.createGlossary("Automation Glossary Setting Test");
  });

  describe("Verify Various Glossary Settings", () => {
    it("Verify Require Student-Provided Definitions In Term Popup Preview", () => {
      glossarySettings.getDisplayIDontKnowCheckBox().should('be.disabled');
      glossarySettings.getStudentAudioRecordingCheckBox().should('be.disabled');
      glossarySettings.getTermPopupPreviewAnswerTextArea().should("not.exist");
      glossarySettings.getTermPopupPreviewSubmitButton().should("not.exist");
      glossarySettings.getStudentProvidedDefinitionsCheckBox().click();
      glossarySettings.getDisplayIDontKnowCheckBox().should('be.enabled');
      glossarySettings.getStudentAudioRecordingCheckBox().should('be.enabled');
      glossarySettings.getTermPopupPreviewAnswerTextArea().should("exist");
      glossarySettings.getTermPopupPreviewSubmitButton().should("exist");
      glossarySettings.getDisplayIDontKnowCheckBox().click();
      glossarySettings.getTermPopupPreviewIDontKnowYetButton().should("exist");
      glossarySettings.getStudentAudioRecordingCheckBox().click();
      glossarySettings.getAnswerTextAreaRecordButton().should("exist");
    });

    it("Verify Automatically Show Media In Term Popup Preview", () => {
      glossarySettings.getTermPopupPreviewImageContainer().should("not.exist");
      glossarySettings.getShowMediaCheckBox().click();
      glossarySettings.getTermPopupPreviewImageContainer().should("exist");
    });

    it("Verify Disable Read Aloud Buttons In Term Popup Preview", () => {
      glossarySettings.getDisableReadAloudCheckBox().click();
      glossarySettings.getTermPopupPreviewImageCaptionReadAloud().should("not.exist");
      glossarySettings.getTermPopupPreviewInnerPopupReadAloud().should("not.exist");
      glossarySettings.getAnswerTextAreaReadAloud().should("not.exist");
      glossarySettings.getTermPopupPreviewImageZoomButton().click();
      glossarySettings.getTermPopupPreviewImageZoomCaptionReadAloud().should("not.exist");
      glossarySettings.getTermPopupPreviewImageZoomClose().click();
      glossarySettings.getDisableReadAloudCheckBox().click();
      glossarySettings.getTermPopupPreviewImageCaptionReadAloud().should("exist");
      glossarySettings.getTermPopupPreviewInnerPopupReadAloud().should("exist");
      glossarySettings.getAnswerTextAreaReadAloud().should("exist");
      glossarySettings.getTermPopupPreviewImageZoomButton().click();
      glossarySettings.getTermPopupPreviewImageZoomCaptionReadAloud().should("exist");
      glossarySettings.getTermPopupPreviewImageZoomClose().click();
    });

    it("Verify Display Second Language First Option", () => {
      glossarySettings.getDisplaySecondLanguageFirstCheckBox().should("exist");
      glossarySettings.verifyDisplaySecondLanguageFirstLabel();
      glossarySettings.getDisplaySecondLanguageFirstCheckBox().click();
      glossarySettings.verifyDisplaySecondLanguageFirstHelpText();
    });

    it("Verify Reset Term Popup Preview", () => {
      glossarySettings.getTermPopupPreviewIDontKnowYetButton().click();
      glossarySettings.getTermPopupPreviewAnswerTextArea().should("not.exist");
      glossarySettings.getResetTermPopupPreview().click();
      glossarySettings.getTermPopupPreviewAnswerTextArea().should("exist");
    });

    it("Verify Glossary Name", () => {
      glossarySettings.getGlossaryNameField().should('be.disabled');
      glossarySettings.getGlossaryNameField().should('have.value', 'Automation Glossary Setting Test');
      glossarySettings.getEditSaveButton().click();
      glossarySettings.getGlossaryNameField().clear();
      glossarySettings.getEditSaveButton().click();
      glossarySettings.getEditNameErrorMessage().should("contain", "Glossary name cannot be empty");
      glossarySettings.getGlossaryNameField().type("Automation Glossary Setting Test 1");
      glossarySettings.getEditSaveButton().click();
      glossarySettings.getGlossaryNameField().should('have.value', 'Automation Glossary Setting Test 1');
    });

    it("Verify View Photo In Term Popup Preview", () => {
      glossarySettings.getStudentProvidedDefinitionsCheckBox().click();
      glossarySettings.getTermPopupPreviewInnerPopupViewPhoto().click();
      glossarySettings.getTermPopupPreviewImageContainer().should("not.exist");
      glossarySettings.getTermPopupPreviewInnerPopupViewPhoto().click();
      glossarySettings.getTermPopupPreviewImageContainer().should("exist");
    });

    it("Verify Digging Deeper In Term Popup Preview", () => {
      glossarySettings.getTermPopupPreviewInnerPopupDiggingDeeper().click();
      glossarySettings.getTermPopupPreviewDiggingDeeperContainer().should("exist");
      glossarySettings.getTermPopupPreviewInnerPopupDiggingDeeper().click();
      glossarySettings.getTermPopupPreviewDiggingDeeperContainer().should("not.exist");
    });
    it("Delete Glossary", () => {
      cy.visit("");
      cy.deleteGlossary("Automation Glossary Setting Test 1");
    });
  });
});
