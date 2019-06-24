'use strict'

context('Production Activity Data Migration', () => {

    const activityFixturePath = "../../lara/cypress/cypress/fixtures/activities/"
    const stagingUrl = "https://authoring.staging.concord.org/users/sign_in"

    //Enter username and password for admin staging user.
    const stagingAdminUsername = ""
    const stagingAdminPassword = ""
    //Enter activity ID for migrating from production to staging
    let activityID = ""

    const getUsernameTextBox = function () {
        return cy.get('#user_email')
    }

    const getPasswordTextBox = function () {
        return cy.get('#user_password')
    }

    const getSubmitButton = function () {
        return cy.get('input[name="commit"]')
    }

    function stagingLogin(stagingUrl, username, password) {
        cy.visit(stagingUrl)
        getUsernameTextBox().type(username)
        getPasswordTextBox().type(password)
        getSubmitButton().click()
    }

    String.prototype.escapeSpecialChars = function () {
        return this.replace(/\\n/g, "")
            .replace(/\\'/g, "")
            .replace(/\\"/g, '')
            .replace(/\\&/g, "")
            .replace(/\\r/g, "")
            .replace(/\\t/g, "")
            .replace(/\\b/g, "")
            .replace(/\\f/g, "")
            .replace(/\r?\n|\r/g, "");

    }

    it('Migrates the defined activity to staging', () => {

        const pathToActivity = "activities/" + activityID + ".json"

        let jsonString
        let escapedJSONString
        let jsonObject = {}
        let newJsonObject

        cy.login()

        if (activityID === "") {
            cy.log('Please enter valid LARA Activity ID Number')
        } else {
            cy.exportActivity(activityID)
                .then((response) => {
                    response.body.name = "[Cypress] " + response.body.name
                    jsonObject = response.body
                    jsonString = JSON.stringify(jsonObject);
                    escapedJSONString = jsonString.escapeSpecialChars();
                    cy.log(escapedJSONString)
                    newJsonObject = JSON.parse(escapedJSONString)
                    cy.log(newJsonObject)
                    cy.writeFile(activityFixturePath + activityID + ".json", newJsonObject);

                })
        }

        if (stagingAdminUsername === "" || !stagingAdminPassword === "") {
            cy.log('Please enter staging admin username and password for migrating to staging')
        } else {
            stagingLogin(stagingUrl, stagingAdminUsername, stagingAdminPassword)
            cy.migrateMaterialToStaging(pathToActivity)
        }
    })
})