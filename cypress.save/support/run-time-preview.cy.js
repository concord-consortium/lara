class RunTimePreview {

  getSequenceContent() {
    return cy.get('[data-cy=sequence-page-content]');
  }
  getSequenceTitle() {
    return this.getSequenceContent().find('.sequence-title');
  }
  getSequenceEstimated() {
    return this.getSequenceContent().find('.estimate').should("contain", "Estimated Time to Complete This Module:");
  }
  getSequenceEstimatedTime() {
    return this.getSequenceContent().find('.time').should("contain", "0 minutes");
  }
  getSequenceActivityName() {
    return this.getSequenceContent().find('.thumb-holder .name');
  }
  getSequenceHeaderTitle() {
    return cy.get('.in-sequence .activity-title');
  }

}
export default RunTimePreview;
