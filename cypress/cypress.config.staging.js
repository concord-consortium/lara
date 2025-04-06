const { defineConfig } = require("cypress");

const password = process.env.CYPRESS_PASSWORD || "password";

module.exports = defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
    baseUrl: "https://authoring.lara.staging.concord.org/",
  },
  env: {
    useSSO: true,
    baseUrl: "https://authoring.lara.staging.concord.org/",
    username: "sara_teacher1",
    email: "sara.teacher1@mailinator.com",
    password,
    portalBaseUrl: "https://learn.portal.staging.concord.org"
  }
});
