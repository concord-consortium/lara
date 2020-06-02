class Backpack{

  getBackpackContainer() {
    return cy.get('[data-test=backpack-items]')
  }

  getEmptyCollectButton() {
    return cy.get(this.emptyCollectionButton());
  }

  emptyCollectionButton() {
    return ('.left-nav-panel  [data-test=empty-button]')
  }

  getFullCollectButton() {
    return cy.get('.left-nav-panel  [data-test=stored-mouse-class]')
  }

  getLegendComponents() {
    return cy.get('.left-nav-panel .grid-item')
  }

  findXClose(index){
    return cy.get('.left-nav-panel  [data-test=x-close-backpack]').eq(index)
  }

}
export default Backpack;
