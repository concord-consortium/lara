import activityUrl from './glossary_setup_spec'
import Glossary from '../../support/plugin-elements/glossary';

context('Glossary Definitions Test', function(){

  let stagingActivityUrlPath = '/activities/20001/pages/304617/'

  before(function() {
    cy.visit(activityUrl+stagingActivityUrlPath)
  })
  
  let glossary = new Glossary()

  let studentDefs =
    {
      "def1":"definition 1",
      "def2":"definition 2",
      "def3":"definition 3",
      "def4":"definition 4"
    }

  it('Verifies glossary word is identified and does not show correct def yet', () => {
    glossary.getHighlightedWord().first().should('exist').and('be.visible').click()
    glossary.getGlossaryDialogContent().should('not.contain', 'test definition 1')
    glossary.getGlossaryDialog().find('textarea').type(studentDefs.def1);
    cy.get('[data-cy=submit]').click()
    glossary.getGlossaryDialog.contains('Close').click()
  })

  it('Verifies that definition 1 persists', () => {
    glossary.getHighlightedWord().first().click();
    glossary.getGlossaryDialogContent().contains('This is my first definition')
    glossary.getGlossaryDialog().contains('Close').click()
  })

  it('Verifies that definition(1) persists (MC-Q)', () => {
    glossary.getHighlightedWord().eq(2).click();
    glossary.getGlossaryDialogContent().contains('This is my first definition')
    glossary.getGlossaryDialog().contains('Close').click()
  })
//Check if word persists in a new highlighted word on the same pages
  it("Verifies that glossary word is not highlighted in question answers", () => {
    cy.get('.choice').eq(0).should('not.have.class', 'plugin-app--ccGlossaryWord--1GiEL8kF');
  })
//Check if word persists in a long answer question on same page
  it('Verifies that definition(1) persists (LA-Q)', () => {
    cy.contains('Next').click()
    glossary.getHighlightedWord().eq(3).click();
    glossary.getGlossaryDialogContent().contains('This is my first definition')
    glossary.getGlossaryDialog().contains('Close').click()
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
