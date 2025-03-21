describe('homepage spec', () => {
  beforeEach(() => {
    cy.visit("");
  });

  it('should render the homepage', () => {
    cy.contains('Authoring');
    // check the header
    cy.get('[data-cy="authoring-header"]')
      .should('exist')
      .and('be.visible')
      .within(() => {
        cy.get('.project-logo').should('exist');
        cy.get('.login-link').should('exist');
      });
    
    // Check the bottom header section
    cy.get('.bottom-header').should('exist').within(() => {
      cy.get('[data-testid="jump-to-label"]').should('have.text', 'Jump to:');
      cy.get('[data-testid="jump-to-sequences"]').should('have.text', 'Sequences');
      cy.get('[data-testid="jump-to-glossaries"]').should('have.text', 'Glossaries');
      cy.get('[data-testid="jump-to-rubrics"]').should('have.text', 'Rubrics');
    });
  });

  it('should allow log in and out with an account', () => {
    cy.getAccountOwnerName().should('not.exist');
    cy.login();
    cy.getAccountOwnerName().should('contain', Cypress.env('email'));
    cy.logout();
    cy.getAccountOwnerName().should('not.exist');
  })
})