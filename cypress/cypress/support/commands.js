// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
Cypress.Commands.add("loginLARAWithSSO", (username, password) => {
    cy.log("Logging in as user : " + username);
    cy.get("[data-cy=header-menu] .login-link").click();
    cy.wait(2000);
    cy.get("[data-cy=header-menu] .header-menu-links.show a").eq(0).click();
    cy.wait(2000);
    cy.login(username, password);
  })
// -- This is a child command --
// Cypress.Commands.add('drag', { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add('dismiss', { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite('visit', (originalFn, url, options) => { ... })