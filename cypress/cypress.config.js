const { defineConfig } = require("cypress");

const baseUrl = process.env.CYPRESS_BASE_URL || "http://localhost:3000";
const email = process.env.CYPRESS_EMAIL || "dev_test_user@test.email";
const password = process.env.CYPRESS_PASSWORD || "password";

module.exports = defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
    baseUrl,
  },
  env: {
    useSSO: false,
    baseUrl,
    email,
    password,
  }
});
