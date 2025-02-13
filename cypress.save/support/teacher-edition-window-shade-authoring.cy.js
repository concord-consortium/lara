class TEWindowShadeAuthoringPage {
  getEditItemDialog() {
    return cy.get(".modalContainer.itemEditDialog");
  }

  getEditItemForm() {
    return this.getEditItemDialog().find('#itemEditForm');
  }

  selectTipType(tip) {
    this.getEditItemForm().find('.window-shade-form--section--TETipsPluginV1 select').eq(0).select(tip);
  }

  selectMediaType(media) {
    this.getEditItemForm().find('.window-shade-form--section--TETipsPluginV1 select').eq(1).select(media);
  }

  typeContent(content) {
    this.getEditItemForm().find('.window-shade-form--section--TETipsPluginV1').eq(6).clear().type(content)
  }

  typeMedia(content) {
    this.getEditItemForm().find('.window-shade-form--section--TETipsPluginV1 input').eq(1).type(content)
  }

  clickSaveButton() {
    this.getEditItemForm().find('.submit-container .authoring-app--lineAdjust--TETipsPluginV1').eq(1).click();
    cy.wait(6000);
  }

  getButtonTitle(tip) {
    this.getEditItemForm().find('.authoring-app--preview--TETipsPluginV1 .button-title--buttonTitle--TETipsPluginV1').should("contain", tip);
  }

  verifyWindowShadeContent(content) {
    this.getEditItemForm().find('.authoring-app--preview--TETipsPluginV1 .window-shade-content--windowShadeContent--TETipsPluginV1').should("contain", content);
  }
//***************************************************************************************************************
  getInteractive() {
    return cy.get(".itemsContainer .sectionItemContainer");
  }
  getAuthoringPreviewButtonTitle(tip) {
    this.getInteractive().find('.button-title--buttonTitle--TETipsPluginV1').should("contain", tip);
  }

  verifyAuthoringPreviewWindowShadeContent(content) {
    this.getInteractive().find('.window-shade-content--windowShadeContent--TETipsPluginV1').should("contain", content);
  }

  verifyAuthoringPreviewImageUrl(url) {
    this.getInteractive().find('.window-shade-content--offline--TETipsPluginV1').invoke("attr", "src").should("contain", url);
  }

}
export default TEWindowShadeAuthoringPage;
