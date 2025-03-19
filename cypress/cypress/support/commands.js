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
Cypress.Commands.add("login", (email, password) => {
  email = email ?? Cypress.env('email');
  password = password ?? Cypress.env('password');
  cy.log(`Login user: ${email}`);
  cy.visit("/users/sign_in");
  cy.get('#user_email').type(email);
  cy.get('#user_password').type(password, { log: false });
  cy.get("input[type=submit]").click( {force: true} );
  cy.wait(500)
});
Cypress.Commands.add("logout", () => {
  cy.log("Logout");
  cy.get("[data-cy=header-menu] .icon").click();
  cy.wait(500);
  cy.get("[data-cy=header-menu] .header-menu-links.show a").last().click();
  cy.wait(500);
});
Cypress.Commands.add('getAccountOwnerName', () => {
  return cy.get('#header .account-owner-name');
});
