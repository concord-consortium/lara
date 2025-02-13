class GlossarySettings {
  getStudentProvidedDefinitionsCheckBox() {
    return cy.get("[class^=model-authoring-app--rightColumn] [class^=glossary-settings]:nth-child(3) input");
  }
  getDisplayIDontKnowCheckBox() {
    return cy.get("[class^=model-authoring-app--rightColumn] [class^=glossary-settings]:nth-child(4) input");
  }
  getStudentAudioRecordingCheckBox() {
    return cy.get("[class^=model-authoring-app--rightColumn] [class^=glossary-settings]:nth-child(5) input");
  }
  getShowMediaCheckBox() {
    return cy.get("[class^=model-authoring-app--rightColumn] [class^=glossary-settings]:nth-child(6) input");
  }
  getDisableReadAloudCheckBox() {
    return cy.get("[class^=model-authoring-app--rightColumn] [class^=glossary-settings]:nth-child(7) input");
  }
  getShowGlossarySidebarCheckBox() {
    return cy.get("[class^=model-authoring-app--rightColumn] [class^=glossary-settings]:nth-child(8) input");
  }
  getDisplaySecondLanguageFirstCheckBox() {
    return cy.get("[class^=model-authoring-app--rightColumn] [class^=glossary-settings]:nth-child(9) input");
  }

  getTermPopup() {
    return cy.get("[class^=term-popup-preview--termPopupPreview]");
  }
  getTermPopupPreview() {
    return cy.get("[class^=term-popup-preview--termPopupPreview] [class^= term-popup-preview--outerPopup]");
  }
  getTermPopupPreviewHeader() {
    return this.getTermPopupPreview().find("[class^=term-popup-preview--header]");
  }
  getTermPopupPreviewInnerPopup() {
    return this.getTermPopupPreview().find("[class^=term-popup-preview--innerPopup]");
  }
  getTermPopupPreviewInnerPopupReadAloud() {
    return this.getTermPopupPreviewInnerPopup().find("span[title^=Read]:nth-child(2)");
  }
  getTermPopupPreviewInnerPopupViewPhoto() {
    return this.getTermPopupPreviewInnerPopup().find("[title^='View photo']");
  }
  getTermPopupPreviewInnerPopupDiggingDeeper() {
    return this.getTermPopupPreviewInnerPopup().find("[title^='View Digging Deeper']");
  }
  getTermPopupPreviewDiggingDeeperContainer() {
    return this.getTermPopupPreviewInnerPopup().find("[class^=digging-deeper--container]");
  }

  getTermPopupPreviewImageContainer() {
    return this.getTermPopupPreviewInnerPopup().find("[class^=image--imageContainer]");
  }
  getTermPopupPreviewImageCaption() {
    return this.getTermPopupPreviewImageContainer().find("[class^=image--caption]");
  }
  getTermPopupPreviewImageCaptionReadAloud() {
    return this.getTermPopupPreviewImageCaption().find("[title^=Read]");
  }
  getTermPopupPreviewImageZoomButton() {
    return this.getTermPopupPreviewImageContainer().find("[class^=image--zoomButton]");
  }

  getTermPopupPreviewImageZoomContainer() {
    return this.getTermPopupPreviewInnerPopup().find("[class^=image--zoomContainer]");
  }
  getTermPopupPreviewImageZoomCaption() {
    return this.getTermPopupPreviewImageZoomContainer().find("[class^=image--zoomCaption]");
  }
  getTermPopupPreviewImageZoomCaptionReadAloud() {
    return this.getTermPopupPreviewImageZoomCaption().find("[title^=Read]");
  }
  getTermPopupPreviewImageZoomClose() {
    return this.getTermPopupPreviewImageZoomContainer().find("[class^=icons--iconCross]");
  }

  getTermPopupPreviewAnswerTextArea() {
    return this.getTermPopupPreviewInnerPopup().find("[class^=glossary-popup--answerTextarea]");
  }
  getAnswerTextAreaRecordButton() {
    return this.getTermPopupPreviewAnswerTextArea().find("[data-cy=recordButton]");
  }
  getAnswerTextAreaReadAloud() {
    return this.getTermPopupPreviewAnswerTextArea().find("[title^=Read]");
  }

  getTermPopupPreviewSubmitButton() {
    return this.getTermPopupPreviewInnerPopup().find("[data-cy=submit]");
  }
  getTermPopupPreviewIDontKnowYetButton() {
    return this.getTermPopupPreviewInnerPopup().find("[data-cy=cancel]");
  }

  getTermPopupLanguageSelector() {
    return cy.get("[class^=term-popup-preview--termPopupPreview] [class^= term-popup-preview--languageSelector]");
  }
  selectSecondLanguage() {
    cy.get('[class^=term-popup-preview--languageSelector] select').select('Spanish');
  }
  selectNoLanguage() {
    cy.get('[class^=term-popup-preview--languageSelector] select').select('No second language');
  }
  getLanguageSelector() {
    return this.getTermPopupPreviewInnerPopup().find("[class^=language-selector--languageSelector]");
  }
  selectLanguage(language) {
    const option = [ "English", "Spanish"];
    return this.getLanguageSelector().find("[class^=button--button]").eq(option.indexOf(language));
  }

  getResetTermPopupPreview() {
    return cy.get("[class^=term-popup-preview--termPopupPreview] button");
  }

  getGlossaryNameField() {
    return cy.get("[class^=edit-name--editName] input");
  }
  getEditSaveButton() {
    return cy.get("[class^=edit-name--editName] button").eq(0);
  }
  getCancelButton() {
    return cy.get("[class^=edit-name--editName] button").eq(1);
  }
  getEditNameErrorMessage() {
    return cy.get("[class^=edit-name--editName] [class^=edit-name--error]");
  }

  verifyDisplaySecondLanguageFirstLabel() {
    cy.get("[class^=model-authoring-app--rightColumn] [class^=glossary-settings]:nth-child(9) label").should("contain", "Display Second Language First");
  }
  verifyDisplaySecondLanguageFirstHelpText() {
    cy.get("[class^=model-authoring-app--rightColumn] [class^=glossary-settings]:nth-child(9) [class^=glossary-settings--help]").should("contain", "When this option is enabled, students will see their assigned second language first in the term popup. Second language is set per student by the teacher via the Glossary Dashboard in the Portal.")
  }
}
export default GlossarySettings;
