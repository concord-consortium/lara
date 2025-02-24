class TESideTipAuthoringPage {
  getEditItemDialog() {
    return cy.get(".modalContainer.itemEditDialog");
  }

  getEditItemForm() {
    return this.getEditItemDialog().find('#itemEditForm');
  }

  selectMediaType(media) {
    this.getEditItemForm().find('.side-tip-form--section--TETipsPluginV1 select').select(media);
  }

  typeContent(content) {
    this.getEditItemForm().find('.side-tip-form--section--TETipsPluginV1 textArea').clear({ force: true }).type(content, { force: true })
  }

  typeMedia(content) {
    this.getEditItemForm().find('.side-tip-form--section--TETipsPluginV1 input').type(content)
  }

  clickSaveButton() {
    this.getEditItemForm().find('.submit-container .authoring-app--lineAdjust--TETipsPluginV1').eq(1).click();
    cy.wait(6000);
  }

  verifySideTipContent(content) {
    this.getEditItemForm().find('.authoring-app--preview--TETipsPluginV1 .side-tip--text--TETipsPluginV1').should("contain", content);
  }
//***************************************************************************************************************
  getInteractive() {
    return cy.get(".itemsContainer .sectionItemContainer");
  }

  getAuthoringPreview() {
    this.getInteractive().find('.plugin-preview-wrapper').should("contain", "Teacher Edition: Side Tip");
  }

  getSectionMenuDelete() {
    return this.getInteractive().find(".menuEnd button").eq(3);
  }

}
export default TESideTipAuthoringPage;
