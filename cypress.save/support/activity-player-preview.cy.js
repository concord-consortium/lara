class ActivityPlayerPreview {
  getActivitySummary() {
    return cy.get('[data-testid=activity-summary]');
  }
  getActivityTitle() {
    return this.getActivitySummary().find('h1 div');
  }
  getActivityThumbnail(url) {
    return this.getActivitySummary().find('.activity-title img').invoke("attr", "src").should("contain", url);
  }
  getReadAloudToggle() {
    return this.getActivitySummary().find('#label-read_aloud_toggle');
  }
  getIntroText() {
    return this.getActivitySummary().find('.activity-content.intro-txt p');
  }
  getIntroTextImage(url) {
    return this.getActivitySummary().find('.activity-content.intro-txt img').invoke("attr", "src").should("contain", url);
  }
  getEstimatedTime() {
    return this.getActivitySummary().find('[data-testid=estimated-time] .estimate');
  }
  getPagesHeader() {
    return cy.get('[data-testid=activity-page-links] .pages div')
  }
  getPageItemNo() {
    return cy.get('[data-testid=activity-page-links] .page-item span').eq(0);
  }
  getPageItemLink() {
    return cy.get('[data-testid=activity-page-links] .page-item span').eq(1);
  }
  clickPageItem(index) {
    return cy.get('[data-testid=activity-page-links] .page-item').eq(index).click();
  }

  getPageContent() {
    return cy.get('[data-testid=page-content]');
  }
  getPageContentHeader() {
    return this.getPageContent().find('.name  div');
  }
  verifyPageContentHeader(header) {
    return this.getPageContent().find('.name  div').should("contain", header);
  }
  getInteractive() {
    return cy.get('[data-testid=managed-interactive]');
  }
  getQuestionHeader() {
    return this.getInteractive().find('.header div').eq(0);
  }
  verifyQuestionHeader(header) {
    this.getQuestionHeader().should("contain", header);
  }
  openHint() {
    this.getInteractive().find('[data-testid=open-hint]').eq(0).click();
  }
  getHintText() {
    return this.getInteractive().find('.hint.question-txt');
  }

  //Sequence Home Page
  getSequenceActivityTitle() {
    return cy.get('[data-testid=activity-title]');
  }
  getSequenceContent() {
    return cy.get('[data-testid=sequence-page-content]')
  }
  getSequenceTitle() {
    return this.getSequenceContent().find('.sequence-title div');
  }
  getSequenceDescription() {
    return this.getSequenceContent().find('.description');
  }
  getSequenceEstimate() {
    return this.getSequenceContent().find('.estimate');
  }
  getSequenceThumb() {
    return this.getSequenceContent().find('.name div').eq(1);
  }
  clickSequenceThumb(index) {
    return this.getSequenceContent().find('.name div').eq(index).click();
  }
  
}
export default ActivityPlayerPreview;
