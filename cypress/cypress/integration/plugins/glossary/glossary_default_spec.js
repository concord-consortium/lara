context('Glossary default test', function() {
//Prior to any of the test cases, visit the activity 'Testing - Glossary'
  before(function () {
    cy.visit('https://authoring.staging.concord.org/activities/20001/pages/304604/')
  })
//Checks that the side bar is visible
  it('Verifies that the side bar is visible', () => {
    cy.get('.sidebar-hdr').should('be.visible')
  })
//Checks that the sidebar opens and closes correctly
  it('Verifies that the sidebar opens and closes correctly', () => {
    cy.get('.sidebar-hdr').click()
    cy.get('.sidebar-bd').should('be.visible')
    cy.get('.sidebar-hdr').click()
    cy.get('.sidebar-bd').should('not.be.visible')
  })
//Clicks on a highlighted word to assure correct definition functionality
//Then closes the definition window.
  it('Verifies a user can click a highlighted word', () => {
    cy.get('.plugin-app--ccGlossaryWord--1GiEL8kF').first().click();
    cy.get('.ui-dialog').contains('Close').click()
    cy.get('.ui-dialog').should('not.be.visible');
  })
//Verifies that clicking on a non-underlined word will result in no glossary actions *    \\
//Check manually, as you can not assert a lack of change in state in Cypress.        *    \\
  it('Verifies that clicking on non-underlined words will result in no actions', () => {
    cy.get('h2').contains('Testing').click(15, 35)
    //Check for no reaction?
  })
//Verifies that the sidebar glossary does not have a "Words I Have Defined"
//sub-glossary.
  it('Verifies student glossary has not yet been instantiated', () => {
    cy.get('.sidebar-hdr').click();
    cy.get('.sidebar-content').should('not.have.value', 'Words I Have Defined');
  })
//Verifies that the sidebar glossary does not have a "Words I Have Defined"
//sub-glossary.
  it('Verifies that predefined words are visible in glossary', () => {
    cy.get('.sidebar-content').should('not.have.value', 'Words I Have Defined');
  })
})
