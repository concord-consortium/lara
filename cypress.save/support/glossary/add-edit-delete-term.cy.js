class AddEditDeleteTerm {

  getGlossaryTermsDefinitions() {
    return cy.get("[class^=glossary-terms-definitions--glossaryTermsDefinitions]");
  }
  getAddNewTermButton() {
    return cy.get("[class^=glossary-terms-definitions--addTermButton]");
  }
  getAddNewTermLeftModel() {
    return cy.get("[class^=shared-modal-form--left]");
  }
  getAddNewTermRightModel() {
    return cy.get("[class^=shared-modal-form--right]");
  }
  getAddNewTermClose() {
    return this.getAddNewTermLeftModel().find("[class^=icons--iconCross]");
  }
  getPreviewModel() {
    return this.getGlossaryTermsDefinitions().find("[class^=modal--container]");
  }

  getTermField() {
    return this.getAddNewTermLeftModel().find("[name='word']");
  }
  getTermFieldError() {
    return this.getAddNewTermLeftModel().find("[class^=shared-modal-form--error]").eq(0);
  }
  getDefinitionField() {
    return this.getAddNewTermLeftModel().find("[name='definition']");
  }
  getDefinitionFieldError() {
    return this.getAddNewTermLeftModel().find("[class^=shared-modal-form--error]").eq(1);
  }
  getDiggingDeeperField() {
    return this.getAddNewTermLeftModel().find("[name='diggingDeeper']");
  }
  getImageUrlField() {
    return this.getAddNewTermLeftModel().find("[class^=uploadable-input--uploadableInput] input").eq(0);
  }
  getImageAltTextField() {
    return this.getAddNewTermLeftModel().find("[name='imageAltText']");
  }
  getZoomImageUrlField() {
    return this.getAddNewTermLeftModel().find("[class^=uploadable-input--uploadableInput] input").eq(2);
  }
  getImageCaptionField() {
    return this.getAddNewTermLeftModel().find("[name='imageCaption']");
  }
  getVideoUrlField() {
    return this.getAddNewTermLeftModel().find("[class^=uploadable-input--uploadableInput] input").eq(4);
  }
  getVideoAltTextField() {
    return this.getAddNewTermLeftModel().find("[name='videoAltText']");
  }
  getVideoCaptionField() {
    return this.getAddNewTermLeftModel().find("[name='videoCaption']");
  }
  getClosedCaptionUrlField() {
    return this.getAddNewTermLeftModel().find("[class^=uploadable-input--uploadableInput] input").eq(6);
  }

  getTermPopupPreview() {
    return cy.get("[class^=shared-modal-form--right] [class^=term-popup-preview--termPopupPreview] [class^= term-popup-preview--outerPopup]");
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

  getTermPopupLanguageSelector() {
    return cy.get("[class^=term-popup-preview--termPopupPreview] [class^= term-popup-preview--languageSelector]");
  }

  getModelPreviewImageContainer() {
    return this.getPreviewModel().find("[class^=image--imageContainer]");
  }
  getModelPreviewImageCaption() {
    return this.getPreviewModel().find("[class^=image--caption]");
  }
  getModelPreviewVideoContainer() {
    return this.getPreviewModel().find("[class^=video--videoContainer]");
  }
  getModelPreviewVideoCaption() {
    return this.getPreviewModel().find("[class^=video--caption]");
  }
  getModelPreviewClose() {
    return this.getPreviewModel().find("[class^=icons--iconCross]");
  }

  getCancelButton() {
    return this.getAddNewTermLeftModel().find("[class^=shared-modal-form--buttons] button").eq(0);
  }
  getSaveCloseButton() {
    return this.getAddNewTermLeftModel().find("[class^=shared-modal-form--buttons] button").eq(1);
  }
  getEditSaveCloseButton() {
    return this.getAddNewTermLeftModel().find("[class^=shared-modal-form--buttons] button").eq(2);
  }
  getSaveAddAnotherButton() {
    return this.getAddNewTermLeftModel().find("[class^=shared-modal-form--buttons] button").eq(2);
  }

  getGlossaryTermsDefinitionsTabel() {
    return this.getGlossaryTermsDefinitions().find("[class^=shared-table--sharedTable]");
  }
  getTermsDefinitionsTableFirstRow() {
    return this.getGlossaryTermsDefinitions().find("[class^=shared-table--sharedTable] tbody tr").eq(0);
  }
  getTermsDefinitionsTablePreviewImageIcon() {
    return this.getTermsDefinitionsTableFirstRow().find("[class^=shared-table--centered]").eq(1).find("[data-name='Image icon']");
  }
  getTermsDefinitionsTablePreviewVideoIcon() {
    return this.getTermsDefinitionsTableFirstRow().find("[class^=shared-table--centered]").eq(2).find("[data-name='Video icon']");
  }
  getTermsDefinitionsTableEditLink() {
    return this.getTermsDefinitionsTableFirstRow().find("[class^=shared-table--actions] span").eq(0);
  }
  getTermsDefinitionsTableDeleteLink() {
    return this.getTermsDefinitionsTableFirstRow().find("[class^=shared-table--actions] span").eq(1);
  }

  selectSoryBy(value) {
    cy.get('select').eq(0).select(value);
  }

  selectSecondLanguage(value) {
    cy.get('select').eq(1).select(value);
  }
  getLanguageSelector() {
    return this.getTermPopupPreviewInnerPopup().find("[class^=language-selector--languageSelector]");
  }
  selectLanguage(language) {
    const option = [ "English", "Hawaiian"];
    return this.getLanguageSelector().find("[class^=button--button]").eq(option.indexOf(language));
  }

  getGlossaryNotice() {
    cy.get('#glossary_authoring_form').find("[class^=model-authoring-app--readonlyGlossaryNotice]").should("contain", "You are not the author of this glossary so any changes you make will not be reflected in the UI or saved.");
  }

  getSaveIndicator() {
    cy.get('#glossary_authoring_form').find("[class^=save-indicator--saveIndicator]").should("contain", "Saving is disabled!");
  }

}
export default AddEditDeleteTerm;
