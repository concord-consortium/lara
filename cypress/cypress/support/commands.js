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
Cypress.Commands.add("login", (options) => {
  let {email, username, password} = options || {};
  email = email ?? Cypress.env('email');
  username = username ?? Cypress.env('username');
  password = password ?? Cypress.env('password');

  const useSSO = Cypress.env('useSSO') || false;
  if (useSSO) {
    cy.log("Login using SSO as user : " + username);
    cy.get("[data-testid=header-menu] .login-link").click();
    cy.wait(2000);
    cy.get("[data-testid=header-menu] .header-menu-links.show a").eq(0).click();
    cy.wait(2000);
    cy.origin('https://learn.portal.staging.concord.org', { args: { username, password } }, ({ username, password }) => {
      cy.get('#username').type(username);
      cy.get('#password').type(password, { log: false });
      cy.get("#submit").click( {force: true} );
      cy.wait(500);
    });
    return;
  }

  cy.log(`Login via /users/sign_in as user: ${email}`);
  cy.visit("/users/sign_in");
  cy.get('#user_email').type(email);
  cy.get('#user_password').type(password, { log: false });
  cy.get("input[type=submit]").click( {force: true} );
  cy.wait(500)
});

Cypress.Commands.add("logout", () => {
  cy.log("Logout");
  cy.get("[data-testid=header-menu] .icon").click();
  cy.wait(500);
  cy.get("[data-testid=header-menu] .header-menu-links.show a").last().click();
  cy.wait(500);
});
Cypress.Commands.add('getAccountOwnerName', () => {
  return cy.get('[data-testid=account-owner] .account-owner-name');
});
