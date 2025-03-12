describe('homepage spec', () => {
  it('contains the text "Authoring"', () => {
    cy.visit('/')
    cy.contains('Authoring')
  })
})