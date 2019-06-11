'use strict'

context('Production Activity Data Migration', () => {
    
    const activityFixturePath = "../../lara/cypress/cypress/fixtures/activities/"
    const stagingUrl = "https://authoring.staging.concord.org/users/sign_in"

    const stagingUsername = "ksantos+ksantosadmin@concord.org"
    const stagingPassword = "password"

    const usernameTextBox = '#user_email'
    const passwordTextBox = '#user_password'
    const submitButton = 'input[name="commit"]'

    //Enter LARA Production Activity ID# For Migration
    //Get an activity for each plugin to figure out what is breaking it
    let activityID = '9384'

    function stagingLogin(stagingUrl, username, password) {
        cy.visit(stagingUrl)
        cy.get(usernameTextBox).type(username)
        cy.get(passwordTextBox).type(password)
        cy.get(submitButton).click()
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

    it('exports the defined activity', () => {

        const pathToActivity = "activities/" + activityID + ".json"

        let jsonString
        let escapedJSONString
        let jsonObject = {}
        let newJsonObject

        cy.login()
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

        stagingLogin(stagingUrl, stagingUsername, stagingPassword)
        cy.migrateMaterialToStaging(pathToActivity)

    })
})