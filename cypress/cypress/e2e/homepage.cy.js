describe('homepage spec', () => {
  beforeEach(() => {
    cy.visit("");
  });

  it('should render the homepage', () => {
    cy.contains('Authoring');
  })

  it('should allow log in and out with an account', () => {
    cy.getAccountOwnerName().should('not.exist');
    cy.login();
    cy.getAccountOwnerName().should('contain', Cypress.env('email'));
    cy.logout();
    cy.getAccountOwnerName().should('not.exist');
  })
})