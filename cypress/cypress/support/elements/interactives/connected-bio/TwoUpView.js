class TwoUpView{

  getTwoUpView() {
    return cy.get("[data-test=two-up-display]");
  }

  getLeftTitle() {
    return cy.get("[data-test=left-title]");
  }

  getRightTitle() {
    //is right title still detected in different tabs?
    return cy.get("[data-test=right-title]");
  }
}
export default TwoUpView;
