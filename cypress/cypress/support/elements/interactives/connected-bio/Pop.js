class Pop {

  getPopToolBar() {
    return cy.get('[data-test=pop-toolbar]')
  }

  getInspectInfo() {
    return cy.get('.bubble')
  }

  getLineChart() {
    return cy.get('data-test=line-chart')
  }

  getLineChartScroll() {
    return cy.get('#line-chart-controls')
  }

  getPopTool(tool) {
    switch(tool){
      case('run'):
        return cy.get('[data-test=pop-toolbar]').find('button').eq(0)
      case('pause'):
        return cy.get('[data-test=pop-toolbar]').find('button').eq(0)
      case('addHawks'):
        return cy.get('[data-test=pop-toolbar]').find('button').eq(1)
      case('changeEnv'):
        return cy.get('[data-test=pop-toolbar]').find('button').eq(2)
      case('inspect'):
        return cy.get('[data-test=pop-toolbar]').find('button').eq(3)
      case('collect'):
        return cy.get('[data-test=pop-toolbar]').find('button').eq(4)
      case('reset'):
        return cy.get('[data-test=pop-toolbar]').find('button').eq(5)
      case('canvas'):
        return cy.get('.populations-environment').find('canvas').eq(0)
    }
  }
}
export default Pop;
