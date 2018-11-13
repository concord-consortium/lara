context('Glossary Icon Test', function() {
//Prior to any of the test cases, visit the activity 'Testing - Glossary'
  before(function () {
    cy.visit('https://authoring.staging.concord.org/activities/20001/pages/304604/')
  })
//Verifies that the sound icon works correctly
  it('Verifies the sound icon functionality', () => {
    cy.get('span.definition--icons--vqzZ5z1B').eq(0).children().eq(0).click()
  })
//Verifies that the image icon works correctly
  it('Verifies the image icon functionality', () => {
    cy.get('span.definition--icons--vqzZ5z1B').eq(0).children().eq(1).click()
  })
//Verifies that the image caption shows correctly
  it('Verifies image caption is visible', () => {
    cy.get('.definition--caption--2GD2UvrL').should('be.visible')
  })
//Verifies that the video icon works correctly
  it('Verifies the video icon functionality', () => {
    cy.get('span.definition--icons--vqzZ5z1B').eq(0).children().eq(2).click()
  })
//Verifies that the video caption shows correctly
  it('Verifies video caption is visible', () => {
    cy.get('.definition--caption--2GD2UvrL').should('be.visible');
    cy.get('.sidebar-hdr').click()
  })
})
