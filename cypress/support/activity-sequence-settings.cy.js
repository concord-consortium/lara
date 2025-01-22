class ActivitySequenceSettingsPage {
  // to-do: add data-testid tags to the elements (PT-#188775242)
  getCreateActivityButton() {
    return cy.get('#content .top-header .buttons-menu a').eq(0);
  }
  getNewActivityPage() {
    return cy.get('#new_lightweight_activity');
  }
  getActivityName() {
    return this.getNewActivityPage().find('#lightweight_activity_name');
  }
  getSaveButton() {
    return this.getNewActivityPage().find('[type=submit]');
  }
  getSettingsPage() {
    return cy.get('#leftcol .sequence_form');
  }
  getSettingsPageSave() {
    return this.getSettingsPage().find('#save-top');
  }
  getPublishToOtherPortalsButton() {
    return cy.get('[data-testid="publish-to-other-portals-btn"]');
  }
  getPublishToOtherPortalsModalTitle() {
    return cy.get('.modal .publication .header span.title').contains('Publish Test Automation Sequence Settings to portals:');
  }
  getPublishToOtherPortalsCloseButton() {
    return cy.get('[data-testid="close-publish-modal-btn"]');
  }
  getGlossaryDropDown() {
    return this.getSettingsPage().find('#lightweight_activity_glossary_id');
  }
  getBackgroundImageUrl() {
    return this.getSettingsPage().find('#lightweight_activity_background_image');
  }
  getPreviewImageUrl() {
    return this.getSettingsPage().find('#lightweight_activity_thumbnail_url');
  }
  clickThumbailPreview() {
    this.getSettingsPage().find('#toggle_thumbnail_preview').click();
  }
  getThumbailPreview(url) {
    this.getSettingsPage().find('#thumbnail_preview img').invoke("attr", "src").should("contain", url);
  }
  getIndexPageText() {
    return this.getSettingsPage().find('#lightweight_activity_description_ifr').then($iframe => {
      const $body = $iframe.contents().find('#tinymce')
            cy.wrap($body).find('p');
    });
  }
  clickInsertImage() {
    return this.getSettingsPage().find('#mceu_17-button').click();
  }
  getEditImageDialog() {
    return cy.get('.mce-floatpanel.mce-window.mce-in');
  }
  getSourceField() {
    return this.getEditImageDialog().find('.mce-first.mce-formitem input');
  }
  getInsertImageOkButton() {
    return this.getEditImageDialog().find('.mce-panel.mce-foot button').eq(0);
  }
  selectActivityLayout(value) {
    cy.get('#lightweight_activity_layout').select(value);
  }
  getHideQuestionNumbersCheckbox() {
    return cy.get('#lightweight_activity_hide_question_numbers');
  }
  verifyHideQuestionNumbersLabel(label) {
    this.getHideQuestionNumbersCheckbox().parent().find('label').should("contain", label);
  }
  verifyHideQuestionNumbersHint(hint) {
    this.getHideQuestionNumbersCheckbox().parent().find('.hint').should("contain", hint);
  }
  getSequenceHideQuestionNumbersCheckbox() {
    return cy.get('#sequence_hide_question_numbers');
  }
  verifySequenceHideQuestionNumbersLabel(label) {
    this.getSequenceHideQuestionNumbersCheckbox().parent().find('label').should("contain", label);
  }
  verifySequenceHideQuestionNumbersHint(hint) {
    this.getSequenceHideQuestionNumbersCheckbox().parent().find('.hint').should("contain", hint);
  }

  //*******************************

  getCreateSequenceButton() {
    return cy.get('#content .top-header .buttons-menu a').eq(1);
  }
  getSeqTitle() {
    return this.getSettingsPage().find('#sequence_title');
  }
  getSeqBackgroundImageUrl() {
    return this.getSettingsPage().find('#sequence_background_image');
  }
  getSeqPreviewImageUrl() {
    return this.getSettingsPage().find('#sequence_thumbnail_source');
  }
  getSeqIndexPageText() {
    return this.getSettingsPage().find('#sequence_description_ifr').then($iframe => {
      const $body = $iframe.contents().find('#tinymce')
            cy.wrap($body).find('p');
    });
  }
  selectActivityLayoutOverride(value) {
    cy.get('#sequence_layout_override').select(value);
  }
  addActivity() {
    cy.get('#activity_id_chosen').click();
    cy.get('#activity_id_chosen').contains("49. Authoring LARA Staging Question Interactives Master Branch").click();
    cy.wait(4000);
  }
  clickAddButton() {
    cy.get('#activities .btn-primary').click();
    cy.wait(4000);
  }

  //*******************************

  getCreateGlossaryButton() {
    return cy.get('#content .top-header .buttons-menu a').eq(2);
  }
  getCreateButton() {
    return cy.get('#content .top-header .buttons-menu a');
  }

  getEditActivityPage() {
    return cy.get('.edit_lightweight_activity');
  }
  getEditActivityName() {
    return this.getEditActivityPage().find('#lightweight_activity_name');
  }
  verifyEditActivityName(name) {
    return this.getEditActivityName().invoke("attr", "value").should("contain", name);;
  }
  getEditActivitySaveButton() {
    return this.getEditActivityPage().find('header [type=submit]');
  }

  getEditSequencePage() {
    return cy.get('.edit_sequence');
  }
  getEditSequenceName() {
    return this.getEditSequencePage().find('#sequence_title');
  }
  verifyEditSequenceName(name) {
    return this.getEditSequenceName().invoke("attr", "value").should("contain", name);;
  }
  getEditSequenceSaveButton() {
    return this.getEditSequencePage().find('header [type=submit]');
  }
}
export default ActivitySequenceSettingsPage;
