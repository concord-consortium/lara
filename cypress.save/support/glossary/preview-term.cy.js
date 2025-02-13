class PreviewTerm {
  getPreviewTermButton() {
    return cy.get("[class^=glossary-terms-definitions--glossaryTermsDefinitions] button").eq(1);
  }
  getModalCloseButton() {
    return cy.get("[class^=modal--header] [class^=icons--iconCross]");
  }
  getTermPopupPreview() {
    return cy.get("[class^=preview-modal--previewModal] [class^=term-popup-preview--termPopupPreview] [class^= term-popup-preview--outerPopup]");
  }
  getTermPopupPreviewHeader() {
    return this.getTermPopupPreview().find("[class^=term-popup-preview--header]");
  }
  getTermPopupPreviewInnerPopup() {
    return this.getTermPopupPreview().find("[class^=term-popup-preview--innerPopup]");
  }
  getTermPopupPreviewDefinition() {
    return this.getTermPopupPreviewInnerPopup().find("[class^=definition--disableSelect]");
  }
  getTermPopupPreviewDefinitionIcons() {
    return this.getTermPopupPreviewInnerPopup().find("[class^=definition--icons]");
  }
  getTermPopupPreviewDefinitionReadAloud() {
    return this.getTermPopupPreviewDefinitionIcons().find("[title^=Read]");
  }
  getTermPopupPreviewViewPhoto() {
    return this.getTermPopupPreviewDefinitionIcons().find("[title^='View photo']");
  }
  getTermPopupPreviewViewVideo() {
    return this.getTermPopupPreviewDefinitionIcons().find("[title^='View movie']");
  }
  getTermPopupPreviewDiggingDeeper() {
    return this.getTermPopupPreviewDefinitionIcons().find("[title^='View Digging Deeper']");
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

  getTermPopupPreviewVideoContainer() {
    return this.getTermPopupPreviewInnerPopup().find("[class^=video--videoContainer]");
  }
  getTermPopupPreviewVideoCaption() {
    return this.getTermPopupPreviewVideoContainer().find("[class^=video--caption]");
  }
  getTermPopupPreviewVideoCaptionReadAloud() {
    return this.getTermPopupPreviewVideoContainer().find("[title^=Read]");
  }

  getTermPopupPreviewAnswerTextArea() {
    return this.getTermPopupPreviewInnerPopup().find("[class^=glossary-popup--userDefinitionTextarea]");
  }
  getAnswerTextAreaReadAloud() {
    return this.getTermPopupPreviewInnerPopup().find("[class^=glossary-popup--answerTextareaIcons] [title^=Read]");
  }

  getTermPopupPreviewSubmitButton() {
    return this.getTermPopupPreviewInnerPopup().find("[data-cy=submit]");
  }
  getTermPopupPreviewIDontKnowYetButton() {
    return this.getTermPopupPreviewInnerPopup().find("[data-cy=cancel]");
  }
  getTermPopupPreviewUserDefinition() {
    return this.getTermPopupPreviewInnerPopup().find("[class^=user-definitions--userDefinition]");
  }

  getPreviousTermButton() {
    return cy.get("[class^=preview-modal--previewModal] [class^=preview-modal--previous]");
  }
  getNextTermButton() {
    return cy.get("[class^=preview-modal--previewModal] [class^=preview-modal--next]");
  }

  selectTerm(value) {
    cy.get('select').eq(1).select(value);
  }

}
export default PreviewTerm;
