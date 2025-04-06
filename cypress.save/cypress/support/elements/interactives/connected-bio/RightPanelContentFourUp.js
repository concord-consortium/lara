class RightPanelContentFourUp {

  getFourUp(position) {
    return cy.get('[data-test="four-up-' + position + '"]')
  }

  getRightHeaderTabs() {
    return cy.get('[data-test="right-header"] > div.button-holder')
  }

  getTitle() {
    return cy.get('[data-test="right-title"]')
  }

  getHighlightedTab() {
    return cy.get("[data-test=four-up-top] > [data-test=two-up-display] > .left-abutment > [data-test=right-header] > .active")
  }

  getContent() {
    return cy.get('[data-test=right-content]')
  }

}
export default RightPanelContentFourUp;
