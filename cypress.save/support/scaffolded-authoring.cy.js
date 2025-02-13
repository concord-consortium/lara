class ScaffoldedAuthoringPage {
  getEditItemDialog() {
    return cy.get(".modalContainer.itemEditDialog");
  }

//***************************************************************************************************************

  getEditItemPreview() {
    return this.getEditItemDialog().find('.itemEditPreview');
  }

  getItemPreviewPrompt(prompt) {
    this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
      cy.get($iframe.contents()).find('.runtime--runtime--question-int').find('iframe').then($iframe1 => {
        const $body1 = $iframe1.contents().find('#app')
            cy.wrap($body1).find('.runtime--prompt--question-int').should("contain", prompt);
      })
    });
  }
  getResponseTextArea() {
  return  this.getEditItemPreview().find('iframe').then($iframe => {
    const $body = $iframe.contents().find('#app')
    cy.get($iframe.contents()).find('.runtime--runtime--question-int').find('iframe').then($iframe1 => {
      const $body1 = $iframe1.contents().find('#app')
            cy.wrap($body1).find('[data-testid=response-textarea]');
          })
    });
  }
  clickItemPreviewHintButton() {
  return  this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.runtime--buttons--question-int button').click();
    });
  }
  getChoice(choice) {
    this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
      cy.get($iframe.contents()).find('.runtime--runtime--question-int').find('iframe').then($iframe1 => {
        const $body1 = $iframe1.contents().find('#app')
            cy.wrap($body1).find('[data-cy=choices-container]').should("contain", choice);
          })
    });
  }
  getFibPrompt(prompt) {
    this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
      cy.get($iframe.contents()).find('.runtime--runtime--question-int').find('iframe').then($iframe1 => {
        const $body1 = $iframe1.contents().find('#app')
            cy.wrap($body1).find('.fill-in-the-blank').should("contain", prompt);
          })
    });
  }
  getFibTextArea() {
  return  this.getEditItemPreview().find('iframe').then($iframe => {
    const $body = $iframe.contents().find('#app')
    cy.get($iframe.contents()).find('.runtime--runtime--question-int').find('iframe').then($iframe1 => {
      const $body1 = $iframe1.contents().find('#app')
            cy.wrap($body1).find('.fill-in-the-blank input');
          })
    });
  }

//***************************************************************************************************************
  getEditItemForm() {
    return this.getEditItemDialog().find('#itemEditForm');
  }
  clickPlusButton() {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.glyphicon-plus').click();
    });
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

  clickHintButton() {
  return  this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.runtime--buttons--question-int button').click();
    });
  }
  getAuthoringPreviewPrompt(prompt) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
    cy.get($iframe.contents()).find('.runtime--runtime--question-int').find('iframe').then($iframe1 => {
      const $body1 = $iframe1.contents().find('#app')
            cy.wrap($body1).find('.runtime--prompt--question-int').should("contain", prompt);
          })
    });
  }
  getAuthoringPreviewResponseTextArea() {
    return this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
    cy.get($iframe.contents()).find('.runtime--runtime--question-int').find('iframe').then($iframe1 => {
      const $body1 = $iframe1.contents().find('#app')
            cy.wrap($body1).find('[data-testid=response-textarea]');
          })
    });
  }
  getAuthoringPreviewChoice(choice) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
    cy.get($iframe.contents()).find('.runtime--runtime--question-int').find('iframe').then($iframe1 => {
      const $body1 = $iframe1.contents().find('#app')
            cy.wrap($body1).find('[data-cy=choices-container]').should("contain", choice);
          })
    });
  }
  getAuthoringPreviewFibPrompt(prompt) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
    cy.get($iframe.contents()).find('.runtime--runtime--question-int').find('iframe').then($iframe1 => {
      const $body1 = $iframe1.contents().find('#app')
            cy.wrap($body1).find('.fill-in-the-blank').should("contain", prompt);
          })
    });
  }
  getAuthoringPreviewFibTextArea() {
    return this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
    cy.get($iframe.contents()).find('.runtime--runtime--question-int').find('iframe').then($iframe1 => {
      const $body1 = $iframe1.contents().find('#app')
            cy.wrap($body1).find('.fill-in-the-blank input');
          })
    });
  }
}
export default ScaffoldedAuthoringPage;
