class SideBySideAuthoringPage {
  getEditItemDialog() {
    return cy.get(".modalContainer.itemEditDialog");
  }

//***************************************************************************************************************

  getEditItemPreview() {
    return this.getEditItemDialog().find('.itemEditPreview');
  }

  getItemPreviewPrompt(prompt, index) {
    this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
      cy.get($iframe.contents()).find('.runtime--split--question-int div').eq(index).find('iframe').then($iframe1 => {
        const $body1 = $iframe1.contents().find('#app')
            cy.wrap($body1).find('.runtime--prompt--question-int').should("contain", prompt);
      })
    });
  }

//***************************************************************************************************************
  getEditItemForm() {
    return this.getEditItemDialog().find('#itemEditForm');
  }
  selectInteractive(value, index) {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=select-subquestion]').eq(index).select(value);
    });
  }
  selectAuthoring(index) {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=subquestion-authoring]').eq(index).click();
    });
  }
  getPrompt(prompt, index) {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
      cy.get($iframe.contents()).find('.iframe-authoring--iframeContainer--question-int').eq(index).find('iframe').then($iframe1 => {
        const $body1 = $iframe1.contents().find('#app')
            cy.wrap($body1).find('#root_prompt').type(prompt);
          })
    });
  }
  getResponseTextArea() {
  return  this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-testid=response-textarea]');
    });
  }

  selectChoice(choice, index) {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
      cy.get($iframe.contents()).find('.iframe-authoring--iframeContainer--question-int').eq(index).find('iframe').then($iframe1 => {
        const $body1 = $iframe1.contents().find('#app')
            cy.wrap($body1).find('#root_choices #root_choices_'+choice+'_correct').click();
          })
    });
  }

//***************************************************************************************************************

  getInteractive() {
    return cy.get(".itemsContainer .sectionItemContainer");
  }

  getAuthoringPreviewPrompt(prompt, index) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
    cy.get($iframe.contents()).find('.runtime--split--question-int div').eq(index).find('iframe').then($iframe1 => {
      const $body1 = $iframe1.contents().find('#app')
            cy.wrap($body1).find('.runtime--prompt--question-int').should("contain", prompt);
          })
    });
  }
}
export default SideBySideAuthoringPage;
