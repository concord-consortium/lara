class NotebookLayout {
  getPreviousPageButton() {
    return cy.get("[data-cy=previous-page-button");
  }
  getNextPageButton() {
    return cy.get("[data-cy=next-page-button");
  }
  getActivityNavHeader(index) {
    return cy.get("[data-cy=activity-nav-header]").eq(index);
  }
  getHomeButton() {
    return cy.get("[data-cy=home-button]");
  }
  getNavPageButton(index) {
    return cy.get('[data-cy=nav-pages-button]').eq(index);
  }
  verifyNotebookHeaderNotDisplayed() {
    cy.get('.notebookHeader').should("not.exist");
  }
  getNavPageButton(index) {
    return cy.get('[data-cy=nav-pages-button]').eq(index);
  }
  getNotebookHeader() {
    return cy.get('.notebookHeader');
  }
  getSectionTab(index) {
    return cy.get('.section-tabs .section-tab').eq(index);
  }
  getSeparator() {
    return cy.get('.sections .separator');
  }
  getNavPageButton(index) {
    return cy.get('[data-cy=nav-pages-button]').eq(index);
  }
  getSequenceContent() {
    return cy.get('[data-cy=sequence-page-content]')
  }
  getSequenceTitle() {
    return this.getSequenceContent().find('.sequence-title div');
  }
  clickSequenceThumb(index) {
    return this.getSequenceContent().find('.name div').eq(index).click();
  }
  getActivitySummary() {
    return cy.get('[data-cy=activity-summary]');
  }
  getActivityTitle() {
    return this.getActivitySummary().find('h1 div');
  }

  //Text Block
  getTextBlockName() {
    return cy.get('[data-cy=text-box] .text-name')
  }
  getTextBlockContent() {
    return cy.get('[data-cy=text-box] .content')
  }
  

}
export default NotebookLayout;
