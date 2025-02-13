class FourUpView{

  getFourUpDisplay() {
    return cy.get('[data-test="four-up-display"]')
  }

  getFourUp(position) {
    return cy.get('[data-test="four-up-' + position + '"]')
  }

}
export default FourUpView;
