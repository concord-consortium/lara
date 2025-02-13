class OpenResponseAuthoringPage {
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
            cy.wrap($body).find('.runtime--prompt--question-int').should("contain", prompt);
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
            cy.wrap($body).find('[data-testid=audio-record-button]');
    });
  }
  getVoiceTypingControls() {
    return  this.getEditItemPreview().find('iframe').then($iframe => {
        const $body = $iframe.contents().find('#app')
              cy.wrap($body).find('[data-testid=voice-typing-button]');
      });
    }
//***************************************************************************************************************

  selectRecordAudioResponseCheckBox() {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_audioEnabled').click();
    });
    cy.wait(4000);
  }
  selectVoiceTypingResponseCheckBox() {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_voiceTypingEnabled').click();
    });
    cy.wait(4000);
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
  getAuthoringPreviewResponseTextArea() {
  return  this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-testid=response-textarea]');
    });
  }
  getAuthoringPreviewAudioControls() {
  return  this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-testid=audio-record-button]');
    });
  }
  getAuthoringPreviewVoiceTypingControls() {
    return  this.getInteractive().find('iframe').then($iframe => {
        const $body = $iframe.contents().find('#app')
              cy.wrap($body).find('[data-testid=voice-typing-button]');
      });
    }

}
export default OpenResponseAuthoringPage;
