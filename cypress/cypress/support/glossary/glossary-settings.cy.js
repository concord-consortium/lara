class GlossarySettings {
  // TODO: Update to use data-testid="student-provided-definitions-checkbox" once available on staging
  getStudentProvidedDefinitionsCheckBox() {
    return cy.get("[class^=model-authoring-app--rightColumn] [class^=glossary-settings]:nth-child(3) input");
  }
  // TODO: Update to use data-testid="display-i-dont-know-checkbox" once available on staging
  getDisplayIDontKnowCheckBox() {
    return cy.get("[class^=model-authoring-app--rightColumn] [class^=glossary-settings]:nth-child(4) input");
  }
  // TODO: Update to use data-testid="student-audio-recording-checkbox" once available on staging
  getStudentAudioRecordingCheckBox() {
    return cy.get("[class^=model-authoring-app--rightColumn] [class^=glossary-settings]:nth-child(5) input");
  }
  // TODO: Update to use data-testid="show-media-checkbox" once available on staging
  getShowMediaCheckBox() {
    return cy.get("[class^=model-authoring-app--rightColumn] [class^=glossary-settings]:nth-child(6) input");
  }
  // TODO: Update to use data-testid="disable-read-aloud-checkbox" once available on staging
  getDisableReadAloudCheckBox() {
    return cy.get("[class^=model-authoring-app--rightColumn] [class^=glossary-settings]:nth-child(7) input");
  }
  // TODO: Update to use data-testid="show-glossary-sidebar-checkbox" once available on staging
  getShowGlossarySidebarCheckBox() {
    return cy.get("[class^=model-authoring-app--rightColumn] [class^=glossary-settings]:nth-child(8) input");
  }
  // TODO: Update to use data-testid="display-second-language-first-checkbox" once available on staging
  getDisplaySecondLanguageFirstCheckBox() {
    return cy.get("[class^=model-authoring-app--rightColumn] [class^=glossary-settings]:nth-child(9) input");
  }

  // TODO: Update to use data-testid="term-popup" once available on staging
  getTermPopup() {
    return cy.get("[class^=term-popup-preview--termPopupPreview]");
  }
  // TODO: Update to use data-testid="term-popup-preview" once available on staging
  getTermPopupPreview() {
    return cy.get("[class^=term-popup-preview--termPopupPreview] [class^= term-popup-preview--outerPopup]");
  }
  // TODO: Update to use data-testid="term-popup-preview-header" once available on staging
  getTermPopupPreviewHeader() {
    return this.getTermPopupPreview().find("[class^=term-popup-preview--header]");
  }
  // TODO: Update to use data-testid="term-popup-preview-inner" once available on staging
  getTermPopupPreviewInnerPopup() {
    return this.getTermPopupPreview().find("[class^=term-popup-preview--innerPopup]");
  }
  // TODO: Update to use data-testid="term-popup-preview-read-aloud" once available on staging
  getTermPopupPreviewInnerPopupReadAloud() {
    return this.getTermPopupPreviewInnerPopup().find("span[title^=Read]:nth-child(2)");
  }
  // TODO: Update to use data-testid="term-popup-preview-view-photo" once available on staging
  getTermPopupPreviewInnerPopupViewPhoto() {
    return this.getTermPopupPreviewInnerPopup().find("[title^='View photo']");
  }
  // TODO: Update to use data-testid="term-popup-preview-digging-deeper" once available on staging
  getTermPopupPreviewInnerPopupDiggingDeeper() {
    return this.getTermPopupPreviewInnerPopup().find("[title^='View Digging Deeper']");
  }
  // TODO: Update to use data-testid="term-popup-preview-digging-deeper-container" once available on staging
  getTermPopupPreviewDiggingDeeperContainer() {
    return this.getTermPopupPreviewInnerPopup().find("[class^=digging-deeper--container]");
  }

  // TODO: Update to use data-testid="term-popup-preview-image-container" once available on staging
  getTermPopupPreviewImageContainer() {
    return this.getTermPopupPreviewInnerPopup().find("[class^=image--imageContainer]");
  }
  // TODO: Update to use data-testid="term-popup-preview-image-caption" once available on staging
  getTermPopupPreviewImageCaption() {
    return this.getTermPopupPreviewImageContainer().find("[class^=image--caption]");
  }
  // TODO: Update to use data-testid="term-popup-preview-image-caption-read-aloud" once available on staging
  getTermPopupPreviewImageCaptionReadAloud() {
    return this.getTermPopupPreviewImageCaption().find("[title^=Read]");
  }
  // TODO: Update to use data-testid="term-popup-preview-image-zoom-button" once available on staging
  getTermPopupPreviewImageZoomButton() {
    return this.getTermPopupPreviewImageContainer().find("[class^=image--zoomButton]");
  }

  // TODO: Update to use data-testid="term-popup-preview-image-zoom-container" once available on staging
  getTermPopupPreviewImageZoomContainer() {
    return this.getTermPopupPreviewInnerPopup().find("[class^=image--zoomContainer]");
  }
  // TODO: Update to use data-testid="term-popup-preview-image-zoom-caption" once available on staging
  getTermPopupPreviewImageZoomCaption() {
    return this.getTermPopupPreviewImageZoomContainer().find("[class^=image--zoomCaption]");
  }
  // TODO: Update to use data-testid="term-popup-preview-image-zoom-caption-read-aloud" once available on staging
  getTermPopupPreviewImageZoomCaptionReadAloud() {
    return this.getTermPopupPreviewImageZoomCaption().find("[title^=Read]");
  }
  // TODO: Update to use data-testid="term-popup-preview-image-zoom-close" once available on staging
  getTermPopupPreviewImageZoomClose() {
    return this.getTermPopupPreviewImageZoomContainer().find("[class^=icons--iconCross]");
  }

  // TODO: Update to use data-testid="term-popup-preview-answer-textarea" once available on staging
  getTermPopupPreviewAnswerTextArea() {
    return this.getTermPopupPreviewInnerPopup().find("[class^=glossary-popup--answerTextarea]");
  }
  // TODO: Update to use data-testid="record-button" once available on staging
  getAnswerTextAreaRecordButton() {
    return this.getTermPopupPreviewAnswerTextArea().find("[data-cy=recordButton]");
  }
  // TODO: Update to use data-testid="answer-textarea-read-aloud" once available on staging
  getAnswerTextAreaReadAloud() {
    return this.getTermPopupPreviewAnswerTextArea().find("[title^=Read]");
  }

  // TODO: Update to use data-testid="term-popup-preview-submit-button" once available on staging
  getTermPopupPreviewSubmitButton() {
    return this.getTermPopupPreviewInnerPopup().find("[data-cy=submit]");
  }
  // TODO: Update to use data-testid="tcancel" once available on staging
  getTermPopupPreviewIDontKnowYetButton() {
    return this.getTermPopupPreviewInnerPopup().find("[data-cy=cancel]");
  }

  // TODO: Update to use data-testid="term-popup-language-selector" once available on staging
  getTermPopupLanguageSelector() {
    return cy.get("[class^=term-popup-preview--termPopupPreview] [class^= term-popup-preview--languageSelector]");
  }
  // TODO: Update to use data-testid="language-selector" once available on staging
  selectSecondLanguage() {
    cy.get('[class^=term-popup-preview--languageSelector] select').select('Spanish');
  }
  // TODO: Update to use data-testid="language-selector" once available on staging
  selectNoLanguage() {
    cy.get('[class^=term-popup-preview--languageSelector] select').select('No second language');
  }
  // TODO: Update to use data-testid="language-selector" once available on staging
  getLanguageSelector() {
    return this.getTermPopupPreviewInnerPopup().find("[class^=language-selector--languageSelector]");
  }
  // TODO: Update to use data-testid="language-selector" once available on staging
  selectLanguage(language) {
    const option = [ "English", "Spanish"];
    return this.getLanguageSelector().find("[class^=button--button]").eq(option.indexOf(language));
  }

  // TODO: Update to use data-testid="reset-term-popup-preview" once available on staging
  getResetTermPopupPreview() {
    return cy.get("[class^=term-popup-preview--termPopupPreview] button");
  }

  // TODO: Update to use data-testid="glossary-name-field" once available on staging
  getGlossaryNameField() {
    return cy.get("[class^=edit-name--editName] input");
  }
  // TODO: Update to use data-testid="edit-save-button" once available on staging
  getEditSaveButton() {
    return cy.get("[class^=edit-name--editName] button").eq(0);
  }
  // TODO: Update to use data-testid="edit-cancel-button" once available on staging
  getCancelButton() {
    return cy.get("[class^=edit-name--editName] button").eq(1);
  }
  // TODO: Update to use data-testid="edit-name-error-message" once available on staging
  getEditNameErrorMessage() {
    return cy.get("[class^=edit-name--editName] [class^=edit-name--error]");
  }

  // TODO: Update to use data-testid="display-second-language-first-label" once available on staging
  verifyDisplaySecondLanguageFirstLabel() {
    cy.get("[class^=model-authoring-app--rightColumn] [class^=glossary-settings]:nth-child(9) label").should("contain", "Display Second Language First");
  }
  // TODO: Update to use data-testid="display-second-language-first-help-text" once available on staging
  verifyDisplaySecondLanguageFirstHelpText() {
    cy.get("[class^=model-authoring-app--rightColumn] [class^=glossary-settings]:nth-child(9) [class^=glossary-settings--help]").should("contain", "When this option is enabled, students will see their assigned second language first in the term popup. Second language is set per student by the teacher via the Glossary Dashboard in the Portal.")
  }
}
export default GlossarySettings;
