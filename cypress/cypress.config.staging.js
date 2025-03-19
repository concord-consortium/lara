const { defineConfig } = require("cypress");

module.exports = defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
    baseUrl: "https://authoring.lara.staging.concord.org/",
  },
  env: {
    baseUrl: "https://authoring.lara.staging.concord.org/",
    email: "sara.teacher1@mailinator.com",
    // password should NOT be stored here!
    portalBaseUrl: "https://learn.portal.staging.concord.org"
  }
});
