context('Reusable "login" custom command', function(){

  before(function() {
			cy.visit('https://authoring.staging.concord.org/activities/20001/pages/304604')
	})
    it('verifies whether glossary is used or not', () => {
        cy.get('.sidebar-hdr').should('be.visible');
    })

    it('verifies the glossary side car opens and closes', () => {
      cy.get('.sidebar-hdr').click()
      cy.get('.sidebar-bd').should('be.visible')
      cy.get('.sidebar-hdr').click()
      cy.get('.sidebar-bd').should('not.be.visible')
    })

    it('verifies user can open and close word definition pop-up', () => {
      cy.get('.plugin-app--ccGlossaryWord--1GiEL8kF').first().click();
      cy.get('.ui-dialog').contains('Close').click()
      cy.get('.ui-dialog').should('not.be.visible');
    })

    it('verifies a student can enter definition that saves', () => {
      //finds glossary identified words, clicks, enters word, then saves
      cy.get('.plugin-app--ccGlossaryWord--1GiEL8kF').first().click();
      cy.get('.ui-dialog').find('textarea').type('This is my definition');
      cy.get('[data-cy=submit]').click()
      cy.get('.ui-dialog').contains('Close').click()
      cy.get('.plugin-app--ccGlossaryWord--1GiEL8kF').last().click();
      cy.get('.ui-dialog-content').contains('This is my definition')
      cy.get('.ui-dialog').contains('Close').click()
    })

    it("verifies 'Words I have defined' glossary is now visible", () => {
      cy.get('.sidebar-hdr').click();
      cy.get('.sidebar-content').contains('Words I Have Defined');
    })

    it('verifies correct student definitions in glossary', () => {
      cy.contains('This is my definition');
    })

    it('verifies correct icon responses', () => {

    })

    it('checks to see student definition persists on next page', () => {
      cy.get('.activity-nav').eq(1).find('i').eq(1).click();
      cy.get('.plugin-app--ccGlossaryWord--1GiEL8kF').first().click()
      cy.get('.ui-dialog-content').contains('This is my definition');
    })



  })
