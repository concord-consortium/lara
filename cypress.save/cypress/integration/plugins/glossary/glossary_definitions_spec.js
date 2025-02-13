context('Glossary Definitions Test', function(){
//Prior to any of the test cases, visit the activity 'Testing - Glossary'
  before(function() {
    cy.visit('https://authoring.staging.concord.org/activities/20001/pages/304604/')
	})

//Enters a definition as a student, clicks submit button. Then closes the
//window. Finds the same word elsewhere on the page to check if definition carried
//over.
  it('Verifies that a student submits definition(1)', () => {
    cy.get('.plugin-app--ccGlossaryWord--1GiEL8kF').first().click();
    cy.get('.ui-dialog').find('textarea').type('This is my first definition');
    cy.get('[data-cy=submit]').click()
    cy.get('.ui-dialog').contains('Close').click()
  })
//Checks the same highlighted word after submitting definitions
  it('Verifies that definition(1) persists (intro)', () => {
    cy.get('.plugin-app--ccGlossaryWord--1GiEL8kF').first().click();
    cy.get('.ui-dialog-content').contains('This is my first definition')
    cy.get('.ui-dialog').contains('Close').click()
  })
//Check if word persists in a new highlighted word on the same pages
  it('Verifies that definition(1) persists (MC-Q)', () => {
    cy.get('.plugin-app--ccGlossaryWord--1GiEL8kF').eq(2).click();
    cy.get('.ui-dialog-content').contains('This is my first definition')
    cy.get('.ui-dialog').contains('Close').click()
  })
//Check if word persists in a new highlighted word on the same pages
  it("Verifies that definition(1) doesn't persists (MC-A)", () => {
    cy.get('.choice').eq(0).should('not.have.class', 'plugin-app--ccGlossaryWord--1GiEL8kF');
  })
//Check if word persists in a long answer question on same page
  it('Verifies that definition(1) persists (LA-Q)', () => {
    cy.contains('Next').click()
    cy.get('.plugin-app--ccGlossaryWord--1GiEL8kF').eq(3).click();
    cy.get('.ui-dialog-content').contains('This is my first definition')
    cy.get('.ui-dialog').contains('Close').click()
  })
//Try the previous 3 steps with another word
  it('Verifies that a student submits definition(2)', () => {
    cy.get('.plugin-app--ccGlossaryWord--1GiEL8kF').eq(1).click();
    cy.get('.ui-dialog').find('textarea').type('This is my second definition');
    cy.get('[data-cy=submit]').click()
    cy.get('.ui-dialog').contains('Close').click()
  })
  it('Verifies that definition(2) persists in intro', () => {
    cy.get('.plugin-app--ccGlossaryWord--1GiEL8kF').last().click();
    cy.get('.ui-dialog-content').contains('This is my second definition')
    cy.get('.ui-dialog').contains('Close').click()
  })
//Opens the next page of an activity, checks to see if the definitions submitted
//by the student persists.
  it('Verifies that definition(1) persists in new page', () => {
    cy.get('.activity-nav').eq(1).find('i').eq(1).click();
    cy.get('.plugin-app--ccGlossaryWord--1GiEL8kF').first().click()
    cy.get('.ui-dialog-content').contains('This is my first definition');
    cy.get('.ui-dialog').contains('Close').click()
  })
//Opens the next page of an activity, checks to see if the definitions submitted
//by the student persists.
  it('Verifies that definition(2) persists in new page', () => {
    cy.get('.plugin-app--ccGlossaryWord--1GiEL8kF').last().click()
    cy.get('.ui-dialog-content').contains('This is my second definition');
    cy.get('.ui-dialog').contains('Close').click()
  })
//Opens glossary, student sub-glossary should have been instantiated after
//submission of first student definition.
  it('Verifies "Words I have defined" glossary is now visible', () => {
    cy.get('.sidebar-hdr').click();
    cy.get('.sidebar-content').contains('Words I Have Defined');
    cy.get('.sidebar-hdr').click()
    cy.get('.sidebar-content')
  })
//Verifies that the definition that the student had submitted is saved in the
//side bar glossary as well.
  it('Verifies student definition persists in "Words I have defined" glossary', () => {
    cy.get('.sidebar-hdr').click()
    cy.get('.sidebar-content').contains('This is my first definition')
    cy.get('.sidebar-content').contains('This is my second definition')
  })
//Verifies the definition that the student had submitted is saved in the
//side bar glossary as well.
  it('Verifies student definition persists in "All Words" glossary', () => {
    cy.get('[data-cy=all-words-filter]').click();
    cy.get('.sidebar-content').contains('This is my first definition').should('be.visible');
    cy.get('.sidebar-content').contains('This is my second definition');
  })
//Verifies the definition that the student had submitted is saved in the
//side bar glossary as well.
  it('Verifies predefined definition persists in "All Words" glossary', () => {

    cy.get('.sidebar-content').contains('An eardrum is a membrane, or thin piece of skin, stretched tight like a drum.')
      .should('be.visible');
    cy.get('.sidebar-content').contains('A visible mass of condensed watery vapour floating in the atmosphere, typically high above the general level of the ground.')
      .should('be.visible');
    cy.get('.sidebar-content').contains('activity involving mental or physical effort done in order to achieve a purpose or result..');
  })

})
