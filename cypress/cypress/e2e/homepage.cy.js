/// <reference types="Cypress" />
// context("Test Admin User Role", () => {
//   before(() => {
//     cy.visit("")
//     // cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
//   })

describe('homepage spec', () => {
  it('should log in and out with an account"', () => {
    const username = Cypress.env('username');
    const password = Cypress.env('password');
    const portalUrl = Cypress.env('portalBaseUrl');
    cy.log(`Username: ${username}`);
    cy.log(`Base URL: ${Cypress.env('baseUrl')}`);
    cy.visit("");
    cy.contains('Authoring');

    cy.get('.login-link').click();
    cy.get("[data-cy=header-menu] .login-link")
      .as('loginLink')
      .click();
    cy.wait(2000);
    cy.get("[data-cy=header-menu] .header-menu-links.show a").eq(0).click();
    cy.wait(2000);
    // Use dynamic origin from config
    cy.origin(portalUrl, () => {
      cy.get('form#login-form p')
      .should('contain', 'Log in with your');
      cy.get('#username').type(Cypress.env('username'));
      cy.get('#password').type(Cypress.env('password'), { log: false });
      cy.get("#submit").click({ force: true });
      cy.wait(500);
    });
    cy.url().should('include', Cypress.env('baseUrl'));
    cy.get('@loginLink').should('not.exist');

    cy.get('[data-cy="header-menu"]').click();
    cy.get('[data-testid="logout-link"]').should('be.visible').click();
    cy.get('@loginLink').should('be.visible');

  })
})