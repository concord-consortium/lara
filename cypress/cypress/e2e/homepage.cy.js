describe('homepage spec', () => {
  it('contains the text "Authoring"', () => {
    cy.visit('http://localhost:3000')
    cy.contains('Authoring')
  })
})