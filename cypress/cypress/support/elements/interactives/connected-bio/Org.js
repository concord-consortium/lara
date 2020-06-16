class Org {

  getOrganismView(position) {
    return cy.get('.four-up-row.' + position + '-row [data-test=organism-view-container]')
  }

  getNucleusZoomTarget() {
    cy.get('.zoom-nucleus-target')
  }

  getHoverLabel() {
    return cy.get('[data-test=hover-label]')
  }

  triggerTargetZoom1() {
    return cy.get('.upper-canvas').click(200, 65, {force:true})
  }

  getEmptyButton(position) {
    return cy.get('[data-test=empty-button]')
  }

  getFullButton(position) {
    return cy.get('[data-test=stored-mouse-class]')
  }

  getOrgTool(tool) {
    switch (tool) {
      case ('zoom-in'):
        return cy.get('[data-test=zoom-in]')
      case ('zoom-out'):
        return cy.get('[data-test=zoom-out]')
      case ('measure'):
        return cy.get('[data-test=measure]')
      case ('inspect'):
        return cy.get('[data-test=inspect]')
      case ('add-substance'):
        return cy.get('[data-test=add-substance]')
      case ('substance-list'):
        return cy.get('[data-test=manipulations-panel] > .select')
      case ('mouse-empty'):
        return cy.get('.four-up-row.top-row [data-test=empty-button]')
      case ('mouse-full'):
        return cy.get('.four-up-row.top-row [data-test=stored-mouse-class]');
    }
  }
}
export default Org;
