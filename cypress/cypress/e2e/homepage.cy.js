describe('homepage spec', () => {
  it('should render the homepage', () => {
    cy.visit("");
    cy.contains('Authoring');
  })

  it('should allow log in and out with an account', () => {
    const email = Cypress.env('email');
    cy.getAccountOwnerName().should('not.exist');
    cy.login(email);
    cy.getAccountOwnerName().should('contain', email);
    cy.logout();
    cy.getAccountOwnerName().should('not.exist');
  })
})