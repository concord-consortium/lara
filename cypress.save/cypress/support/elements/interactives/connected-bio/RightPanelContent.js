class RightPanelContent {

  getInstructionsTab() {
    return cy.get("[data-test=right-header] > :nth-child(1)");
  }

  getDataTab() {
    return cy.get("[data-test=right-header] > :nth-child(2)");
  }

  getInformationTabDisabled() {
    return cy.get('[data-test=right-header] > .disabled')
  }

  getHighlightedTab() {
    return cy.get("[data-test=two-up-display] > .left-abutment > [data-test=right-header] > .active")
  }

  getTitle() {
    return cy.get("[data-test=two-up-display] > .left-abutment > [data-test=right-header] > [data-test=right-title]")
  }

  getContent() {
    return cy.get("[data-test=two-up-display] > .left-abutment > [data-test=right-content]")
  }

  getDataContent() {
    return cy.get('.chartjs-render-monitor')
  }

}
export default RightPanelContent;
