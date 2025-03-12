class FillInTheBlankAuthoringPage {
  getEditItemDialog() {
    return cy.get(".modalContainer.itemEditDialog");
  }
  getEditItemForm() {
    return this.getEditItemDialog().find('#itemEditForm');
  }
//***************************************************************************************************************
  getEditItemPreview() {
    return this.getEditItemDialog().find('.itemEditPreview');
  }
  getPrompt(prompt) {
    this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.fill-in-the-blank').should("contain", prompt);
    });
  }
  getResponseTextArea() {
  return  this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-testid=response-textarea]');
    });
  }
  getAudioControls() {
  return  this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.runtime--audioControls--question-int');
    });
  }
  getFibTextArea() {
  return  this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.fill-in-the-blank input');
    });
  }
//***************************************************************************************************************

  selectRecordAudioResponseCheckBox() {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_audioEnabled').click();
    });
  }
  enterDeafultAnswer(answer) {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_defaultAnswer').type(answer);
    });
    cy.wait(6000);
  }
  //***************************************************************************************************************
  getInteractive() {
    return cy.get(".itemsContainer .sectionItemContainer");
  }
  getAuthoringPreviewPrompt(prompt) {
  return  this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.fill-in-the-blank').should("contain", prompt);
    });
  }
  getAuthoringPreviewFibTextArea() {
  return  this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.fill-in-the-blank input');
    });
  }

}
export default FillInTheBlankAuthoringPage;
