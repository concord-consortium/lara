context('Header block section', function () {
  let activityUrl
  const activityPath = "activities/activity-with-deactivated-header-block.json"

  beforeEach(() => {
    cy.login()
    cy.importMaterial(activityPath).then(url => {
      activityUrl = url
    })
  })
  afterEach(() => {
    cy.deleteMaterial(activityUrl)
  })

  const enableHeaderBlock = () => {
    cy.visit(activityUrl + "/edit");
    cy.wait(500)
    cy.get("#sort-pages ul.menu li.edit a").click()
    cy.wait(500)
    cy.get("input#interactive_page_show_header").check()
  }

  describe('when first loaded', () => {
    it('Header block and associated embeddable should not be visible', () => {
      cy.visitActivityPage(activityUrl, 0)
      cy.wait(500)
      cy.get('.header-block-mod').should('not.exist')
      cy.contains('Galaxies birth vastness is bearable only through encyclopaedia galactica').should('not.exist')
    })
  })

  describe('after checking header block option', () => {
    it('Header block and associated embeddable should be visible', () => {
      enableHeaderBlock()
      cy.visitActivityPage(activityUrl, 0)
      cy.wait(500)
      cy.get('.header-block-mod')
      cy.contains('Galaxies birth vastness is bearable only through encyclopaedia galactica')
    })
  })

})
