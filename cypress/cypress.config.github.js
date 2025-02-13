const { defineConfig } = require("cypress");

module.exports = defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
  },
  env: {
    baseUrl: "http://localhost:3000",
    username: "dev_test_user@test.email",
    password: "password",
  }
});
