import activityUrl from './glossary_setup_spec'
import Glossary from '../../support/plugin-elements/glossary';

context('Glossary Definitions Test', function () {

  let stagingActivityUrlPath = 'https://authoring.staging.concord.org/activities/20001/'

  before(function () {
    cy.visit(stagingActivityUrlPath)
  })

  let glossary = new Glossary()

  let glossaryWordClass = 'plugin-app--ccGlossaryWord--1GiEL8kF'

  let testWord1 =
  {
    "word": "word",
    "definition": "this is a definition"
  }

  let testWord2 =
  {
    "word": "test",
    "definition": "test definition"
  }

  let studentDefs =
  {
    "def1": "definition 1",
    "def2": "definition 2",
    "def3": "definition 3",
    "def4": "definition 4"
  }

  it('Verify that sidebar appears and has only 1 tab', () => {
    
  })

  it('Verifies "Words I have defined" glossary is now visible', () => {

  })

  it('Verifies glossary word is identified and does not show correct def yet', () => {
    glossary.getPageButton().eq(1).click()
    glossary.getHighlightedWord().eq(0).should('exist').and('be.visible').and('contain', testWord1.word).click()
    glossary.getGlossaryDialogContent().should('not.contain', testWord1.definition)
    glossary.getGlossaryDialog().find('textarea').type(studentDefs.def1);
    cy.get('[data-cy=submit]').click()
    glossary.getGlossaryDialog().contains('Close').click()
  })

  it('Verifies that definition 1 persists after submitting', () => {
    glossary.getHighlightedWord().eq(0).click();
    glossary.getGlossaryDialogContent().contains(testWord1.definition)
    glossary.getGlossaryDialog().contains('Close').click()
  })

  it('Verifies that definition(1) persists in another location (multiple choice)', () => {
    glossary.getHighlightedWord().eq(2).click();
    glossary.getGlossaryDialogContent().contains(testWord1.definition)
    glossary.getGlossaryDialog().contains('Close').click()
  })

  it('Verifies that definition(1) persists in another location (open response)', () => {
    glossary.getHighlightedWord().eq(4).click();
    glossary.getGlossaryDialogContent().contains(testWord1.definition)
    glossary.getGlossaryDialog().contains('Close').click()
  })

  it("Verifies that glossary word is not highlighted in question answer options", () => {
    cy.get('.choice').eq(1).should('not.have.class', glossaryWordClass).and('contain', 'word')
  })
 

  it('Verifies that definition(1) persists in new page', () => {
    glossary.getPageButton(2).click()

  })

 
  it('Verifies "Words I have defined" glossary is now visible', () => {

  })

  it('Verifies student definition persists in "Words I have defined" glossary', () => {

  })

  it('Verifies student definition persists in "All Words" glossary', () => {

  })

  it('Verifies predefined definition persists in "All Words" glossary', () => {

  })

})
