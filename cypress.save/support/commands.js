Cypress.Commands.add("login", (username, password) => {
  cy.get('#username').type(username);
  cy.get('#password').type(password, { log: false });
  cy.get("#submit").click( {force: true} );
  cy.wait(500)
});

Cypress.Commands.add("loginLARAWithSSO", (username, password) => {
  cy.log("Logging in as user : " + username);
  cy.get("[data-cy=header-menu] .login-link").click();
  cy.wait(2000);
  cy.get("[data-cy=header-menu] .header-menu-links.show a").eq(0).click();
  cy.wait(2000);
  cy.login(username, password);
})

Cypress.Commands.add("loginLARA", (username) => {
  cy.log("Logging in as user : " + username);
  cy.get("[data-cy=header-menu] .login-link").click();
  cy.wait(1000);
  cy.get("[data-cy=header-menu] .header-menu-links.show a").eq(0).click();
  cy.wait(2000);
})

Cypress.Commands.add("launchActivty", () => {
  cy.log("Launch Test Activity : ");
  cy.get("#search input").eq(0).type("Automation Question Interactives Activity");
  cy.get("#search input").eq(1).click();
  cy.wait(500);
  cy.get("#item_lightweight_activity_212 .action_menu_header_right .edit a").click();
  cy.wait(500);
  cy.get('#rightcol #pages [id^=item_interactive_page] .edit').click();
  cy.wait(2000);
})

Cypress.Commands.add("searchActivity", (activity) => {
  cy.log("Launch Test Activity : ");
  cy.get("#search input").eq(0).type(activity);
  cy.get("#search input").eq(1).click();
  cy.wait(1000);
})

Cypress.Commands.add("searchSequence", (sequence) => {
  cy.log("Launch Test Activity : ");
  cy.get("#search input").eq(0).type(sequence);
  cy.get("#search input").eq(1).click();
  cy.wait(1000);
})

Cypress.Commands.add("deleteItem", () => {
  cy.get("body").then($body => {
    if ($body.find(".itemsContainer .sectionItemContainer").length > 0) {
      cy.log("Delete Item");
      cy.get('.itemsContainer .sectionItemContainer .menuEnd button').eq(4).click();
      cy.wait(2000);
    } else {
      cy.log("No Item To Delete");
    }
  });
})

Cypress.Commands.add("createGlossary", (glossary) => {
  cy.log("Create Test Glossary : ");
  cy.get("#sticky-header .buttons-menu a").eq(2).click();
  cy.wait(500);
  cy.get("#new_glossary").should("exist");
  cy.get("#glossary_name").type(glossary);
  cy.wait(500);
  cy.get("#save-top").click();
  cy.wait(2000);
})

Cypress.Commands.add("launchGlossary", (glossary) => {
  cy.log("Launch Test Glossary : ");
  cy.get("#search input").eq(0).type(glossary);
  cy.get("#search input").eq(1).click();
  cy.wait(500);
  cy.get("#item_glossary_20 .action_menu_header_right .edit a").click();
  cy.wait(2000);
})

Cypress.Commands.add("deleteGlossary", (glossary) => {
  cy.log("Launch Test Glossary : ");
  cy.get("#search input").eq(0).type(glossary);
  cy.get("#search input").eq(1).click();
  cy.wait(500);
  cy.get("body").then($body => {
    if ($body.find(".glossaries .item").length > 0) {
      cy.log("Delete Glossary");
      cy.get('.glossaries .item .action_menu_header_right .delete a').click();
      cy.wait(2000);
      cy.get('.breadcrumbs a').click();
      cy.wait(1000);
    } else {
      cy.log("No Glossary To Delete");
    }
  });
})

Cypress.Commands.add("deleteLanguage", () => {
  cy.log("Delete Language : ");
  cy.get("body").then($body => {
    if ($body.find("[class^=glossary-translations--glossaryTranslations]").length > 0) {
      cy.log("Delete Language");
      cy.get('[class^=glossary-translations--glossaryTranslations] [class^=shared-table--actions] span').eq(1).click();
      cy.wait(2000);
      cy.get('[class^=panel--panel] [class^=panel--header]').eq(1).find('button').eq(1).click();
      cy.wait(1000);
    } else {
      cy.log("No Language To Delete");
    }
  });
})

Cypress.Commands.add("deleteSection", () => {
  cy.get("body").then($body => {
    if ($body.find("#sections-container .sectionMenu").eq(1).length > 0) {
      cy.log("Delete Section");
      cy.get('#sections-container .sectionMenu').eq(1).find('.menuEnd button').eq(4).click();
      cy.wait(2000);
    } else {
      cy.log("No Section To Delete");
    }
  });
})

Cypress.Commands.add("sectionDelete", () => {
  cy.get("body").then($body => {
    if ($body.find("#sections-container .sectionMenu").length > 0) {
      cy.log("Delete Section");
      cy.get('#sections-container .sectionMenu .menuEnd button').eq(4).click();
      cy.wait(2000);
    } else {
      cy.log("No Section To Delete");
    }
  });
})

Cypress.Commands.add("deleteCopyActivity", (activity) => {
  cy.get("#search input").eq(0).type(activity);
  cy.get("#search input").eq(1).click();
  cy.wait(500);
  cy.get("body").then($body => {
    if ($body.find("[id^=item_lightweight_activity]").length > 0) {
      cy.log("Delete Copy Activity");
      cy.get('[id^=item_lightweight_activity] .action_menu_header_right .delete a').click();
      cy.wait(2000);
      cy.get('.breadcrumbs a').click();
      cy.wait(1000);
    } else {
      cy.log("No Activity To Delete");
    }
  });
})

Cypress.Commands.add("deleteNewActivity", () => {
  cy.get("#search input").eq(0).type("Test Automation Create Activity");
  cy.get("#search input").eq(1).click();
  cy.wait(500);
  cy.get("body").then($body => {
    if ($body.find("[id^=item_lightweight_activity]").length > 0) {
      cy.log("Delete Copy Activity");
      cy.get('[id^=item_lightweight_activity] .action_menu_header_right .delete a').click();
      cy.wait(2000);
      cy.get('.breadcrumbs a').click();
      cy.wait(1000);
    } else {
      cy.log("No Activity To Delete");
    }
  });
})

Cypress.Commands.add("deleteImportActivity", () => {
  cy.get("#search input").eq(0).type("Import Test Automation Activity");
  cy.get("#search input").eq(1).click();
  cy.wait(500);
  cy.get("body").then($body => {
    if ($body.find("[id^=item_lightweight_activity]").length > 0) {
      cy.log("Delete Import Activity");
      cy.get('[id^=item_lightweight_activity] .action_menu_header_right .delete a').click();
      cy.wait(2000);
      cy.get('.breadcrumbs a').click();
      cy.wait(1000);
    } else {
      cy.log("No Activity To Delete");
    }
  });
})

Cypress.Commands.add("deleteNewSequence", () => {
  cy.get("#search input").eq(0).type("Test Automation Create Sequence");
  cy.get("#search input").eq(1).click();
  cy.wait(500);
  cy.get("body").then($body => {
    if ($body.find("[id^=item_sequence]").length > 0) {
      cy.log("Delete Copy Sequence");
      cy.get('[id^=item_sequence] .action_menu_header_right .delete a').click();
      cy.wait(2000);
      cy.get('.breadcrumbs a').click();
      cy.wait(1000);
    } else {
      cy.log("No Sequence To Delete");
    }
  });
})

Cypress.Commands.add("deleteImportSequence", () => {
  cy.get("#search input").eq(0).type("Import Test Automation Sequence");
  cy.get("#search input").eq(1).click();
  cy.wait(500);
  cy.get("body").then($body => {
    if ($body.find("[id^=item_sequence]").length > 0) {
      cy.log("Delete Import Sequence");
      cy.get('[id^=item_sequence] .action_menu_header_right .delete a').click();
      cy.wait(2000);
      cy.get('.breadcrumbs a').click();
      cy.wait(1000);
    } else {
      cy.log("No Sequence To Delete");
    }
  });
})

Cypress.Commands.add("deleteCopySequence", (sequence) => {
  cy.get("#search input").eq(0).type(sequence);
  cy.get("#search input").eq(1).click();
  cy.wait(500);
  cy.get("body").then($body => {
    if ($body.find("[id^=item_sequence]").length > 0) {
      cy.log("Delete Copy Sequence");
      cy.get('[id^=item_sequence] .action_menu_header_right .delete a').click();
      cy.wait(2000);
      cy.get('.breadcrumbs a').click();
      cy.wait(1000);
    } else {
      cy.log("No Sequence To Delete");
    }
  });
})

Cypress.Commands.add("deleteImportGlossary", () => {
  cy.get("#search input").eq(0).type("Import Test Automation Glossary");
  cy.get("#search input").eq(1).click();
  cy.wait(500);
  cy.get("body").then($body => {
    if ($body.find(".glossaries .item").length > 0) {
      cy.log("Delete Import Glossary");
      cy.get('.glossaries .item .action_menu_header_right .delete a').click();
      cy.wait(2000);
      cy.get('.breadcrumbs a').click();
      cy.wait(1000);
    } else {
      cy.log("No Glossary To Delete");
    }
  });
})

Cypress.Commands.add("launchNotebookActivty", () => {
  cy.log("Launch Test Notebook Activity : ");
  cy.get("#search input").eq(0).type("Automation Notebook");
  cy.get("#search input").eq(1).click();
  cy.wait(500);
  cy.get("#item_lightweight_activity_199 .action_menu_header_right .edit a").click();
  cy.wait(500);
  cy.get('#rightcol #pages [id^=item_interactive_page] .edit').click();
  cy.wait(2000);
})

Cypress.Commands.add("previewNotebookActivty", () => {
  cy.log("Launch Test Activity : ");
  cy.get("#search input").eq(0).type("Automation Notebook");
  cy.get("#search input").eq(1).click();
  cy.wait(1000);
  cy.get("#item_lightweight_activity_199 .action_menu_header_left a").click();
  cy.wait(2000);
})

Cypress.Commands.add("logoutLARA", (username) => {
  cy.log("Logout user : " + username);
  cy.get("[data-cy=header-menu] .icon").click();
  cy.wait(2000);
  cy.get("[data-cy=header-menu] .header-menu-links.show a").last().click();
  cy.wait(2000);
})
