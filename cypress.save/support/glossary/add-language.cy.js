class AddLanguage {

  selectLanguage(value) {
    cy.get('select').eq(1).select(value);;
  }
  getModelLeftColumn() {
    return cy.get("[class^=model-authoring-app--leftColumn]")
  }
  getAddLanguageButton() {
    return this.getModelLeftColumn().find("[class^=add-translation--addTranslation] button");
  }
  getLanguagePanelHeader(index) {
    return this.getModelLeftColumn().find("[class^=panel--panel] [class^=panel--header]").eq(index);
  }
  getLanguagePanelDelete(index) {
    return this.getModelLeftColumn().find("[class^=panel--panel] [class^=panel--header]").eq(index).find('button').eq(1);
  }

  getFirstLanguageSection() {
    return cy.get("[class^=glossary-translations--glossaryTranslations]").eq(0);
  }
  getEditLanguageTranslationLeftModel() {
    return cy.get("[class^=shared-modal-form--left]");
  }
  getEditLanguageTranslationRightModel() {
    return cy.get("[class^=shared-modal-form--right]");
  }
  getEditLanguageTranslationClose() {
    return this.getEditLanguageTranslationLeftModel().find("[class^=icons--iconCross]");
  }
  getPreviewModel() {
    return this.getGlossaryTermsDefinitions().find("[class^=modal--container]");
  }
  getLanguageFirstRow() {
    return this.getFirstLanguageSection().find("[class^=shared-table--sharedTable] tbody tr").eq(0);
  }
  getLanguageEditLink() {
    return this.getLanguageFirstRow().find("[class^=shared-table--actions] span").eq(0);
  }
  getLanguageDeleteLink() {
    return this.getLanguageFirstRow().find("[class^=shared-table--actions] span").eq(1);
  }
  getLanguageRowDiggingDeeper() {
    return this.getLanguageFirstRow().find('td').eq(3);
  }
  getLanguageRowImageCaption() {
    return this.getLanguageFirstRow().find('td').eq(4);
  }
  getLanguageRowVideoCaption() {
    return this.getLanguageFirstRow().find('td').eq(5);
  }

  getTermField() {
    return this.getEditLanguageTranslationLeftModel().find("[name='translatedWord']");
  }
  getDefinitionField() {
    return this.getEditLanguageTranslationLeftModel().find("[name='translatedDefinition']");
  }
  getDiggingDeeperField() {
    return this.getEditLanguageTranslationLeftModel().find("[name='translatedDiggingDeeper']");
  }
  getImageAltTextField() {
    return this.getEditLanguageTranslationLeftModel().find("[name='translatedImageAltText']");
  }
  getImageCaptionField() {
    return this.getEditLanguageTranslationLeftModel().find("[name='translatedImageCaption']");
  }
  getVideoAltTextField() {
    return this.getEditLanguageTranslationLeftModel().find("[name='translatedVideoAltText']");
  }
  getVideoCaptionField() {
    return this.getEditLanguageTranslationLeftModel().find("[name='translatedVideoCaption']");
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
    return this.getTermPopupPreviewDefinitionIcons().find("[class^=icons--iconButton]").eq(0);
  }
  getTermPopupPreviewViewPhoto() {
    return this.getTermPopupPreviewDefinitionIcons().find("[class^=icons--iconButton]").eq(1);
  }
  getTermPopupPreviewViewVideo() {
    return this.getTermPopupPreviewDefinitionIcons().find("[class^=icons--iconButton]").eq(2);
  }
  getTermPopupPreviewDiggingDeeper() {
    return this.getTermPopupPreviewDefinitionIcons().find("[class^=icons--iconButton]").eq(3);
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
    return this.getTermPopupPreviewImageCaption().find("[class^=icons--iconButton]");
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
    return this.getTermPopupPreviewImageZoomCaption().find("[class^=icons--iconButton]");
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
    return this.getTermPopupPreviewVideoContainer().find("[class^=icons--iconButton]");
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
    return this.getEditLanguageTranslationLeftModel().find("[class^=shared-modal-form--buttons] button").eq(1);
  }
  getSaveButton() {
    return this.getEditLanguageTranslationLeftModel().find("[class^=shared-modal-form--buttons] button").eq(2);
  }
  getSaveCloseButton() {
    return this.getEditLanguageTranslationLeftModel().find("[class^=shared-modal-form--buttons] button").eq(3);
  }
  getSaveNextButton() {
    return this.getEditLanguageTranslationLeftModel().find("[class^=shared-modal-form--buttons] button").eq(4);
  }

  selectSoryBy(value) {
    cy.get('select').eq(2).select(value);
  }
}
export default AddLanguage;
