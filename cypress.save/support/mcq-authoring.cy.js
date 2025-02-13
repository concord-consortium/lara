class MCQAuthoringPage {
  getEditItemDialog() {
    return cy.get(".modalContainer.itemEditDialog");
  }

  getEditItemForm() {
    return this.getEditItemDialog().find('#itemEditForm');
  }

  getEditItemPreview() {
    return this.getEditItemDialog().find('.itemEditPreview');
  }
  getCheckAnswerButton() {
  return  this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=check-answer-button]');
    });
  }
  getChoice(choice) {
    this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=choices-container]').should("contain", choice);
    });
  }
  getChoiceDisabled() {
    this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=choices-container] .radio-choice  input').eq(0).should("be.disabled");
    });
  }
  selectChoice(choice) {
    const option = [ "1", "2", "3", "4"];
    this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=choices-container] [type=radio]').eq(option.indexOf(choice)).click();
    });
  }
  getIncorrectFeedback() {
  return  this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=feedback-false]');
    });
  }
  getCorrectFeedback() {
  return  this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=feedback-true]');
    });
  }
//***************************************************************************************************************

  selectChoiceInEditForm(choice) {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_choices #root_choices_'+choice+'_correct').click();
    });
  }
  selectCheckAnswerCheckBox() {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_enableCheckAnswer').click();
    });
    cy.wait(6000);
  }
  selectCustomFeedbackCheckBox() {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_customFeedback').click();
    });
    cy.wait(6000);
  }
  enterCustomFeedback(choice, feedback) {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_choices #root_choices_'+choice+'_choiceFeedback').type(feedback);
    });
    cy.wait(6000);
  }
  //***************************************************************************************************************
  getInteractive() {
    return cy.get(".itemsContainer .sectionItemContainer");
  }
  getAuthoringPreviewChoice(choice) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=choices-container]').should("contain", choice);
    });
  }
  getAuthoringPreviewCheckAnswerButton() {
  return  this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=check-answer-button]');
    });
  }
  selectAuthoringPreviewChoice(choice) {
    const option = [ "1", "2", "3", "4"];
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=choices-container] [type=radio]').eq(option.indexOf(choice)).click();
    });
  }
  getAuthoringPreviewIncorrectFeedback() {
  return  this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=feedback-false]');
    });
  }
  getAuthoringPreviewCorrectFeedback() {
  return  this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=feedback-true]');
    });
  }
  getAuthoringPreviewChoiceDisabled() {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=choices-container] .radio-choice  input').eq(0).should("be.disabled");
    });
  }

}
export default MCQAuthoringPage;
