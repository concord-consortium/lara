const { defineConfig } = require("cypress");

module.exports = defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
    baseUrl: "http://localhost:3000",
  },
  env: {
    baseUrl: "http://localhost:3000",
    email: "ci_test_user@test.email",
    password: "password",
  }
});
