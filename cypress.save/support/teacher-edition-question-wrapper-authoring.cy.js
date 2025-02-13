class TEQuestionWrapperAuthoringPage {
  getEditItemDialog() {
    return cy.get(".modalContainer.itemEditDialog");
  }

  getEditItemForm() {
    return this.getEditItemDialog().find('#itemEditForm');
  }

  getFormSection(form) {
    const option = [ "Correct", "Distractor", "Teacher Tip", "Exemplar"];
    this.getEditItemForm().find('.authoring-app--authoringFormContainer--TETipsPluginV1 .question-wrapper-form--section--TETipsPluginV1 textarea')
    .eq(option.indexOf(form)).type(form);
  }

  clickSaveButton() {
    this.getEditItemForm().find('.submit-container .authoring-app--lineAdjust--TETipsPluginV1').eq(1).click();
    cy.wait(6000);
  }

  clickHeader(form) {
    this.getEditItemForm().find('.authoring-app--preview--TETipsPluginV1 [data-cy='+form+']').click();
  }

  verifyQuestionWrapperContent(content) {
    this.getEditItemForm().find('.authoring-app--preview--TETipsPluginV1 .question-wrapper--questionWrapperText--TETipsPluginV1').should("contain", content);
  }
//***************************************************************************************************************
  getInteractive() {
    return cy.get(".itemsContainer .sectionItemContainer");
  }
  selectQuestionWrapper() {
    this.getInteractive().find('.availablePlugins [name=embeddable_type]').select("Teacher Edition: Question Wrapper");
  }
  clickAddButton() {
    this.getInteractive().find('.availablePlugins button').click();
    cy.wait(6000);
  }

  selectChoiceInEditForm(choice) {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_choices #root_choices_'+choice+'_correct').click();
    });
  }
}
export default TEQuestionWrapperAuthoringPage;
