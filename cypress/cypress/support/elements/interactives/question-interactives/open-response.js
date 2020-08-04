/**
 * Test cases:
 * 
 * 1.  Test Width Layout status
 * 2.1 Test special rich text changes if possible (images)
 * 2.2 Student answers save
 * 3.  Check if required (submit button, post submission feedback)
 * 4.  Hints have rich text and display in ? button
 * 5.  Default text which shows greyed out in the textbox for OR questions
 */
class OpenResponse {

    getPrompt(i) {
        return cy.get('.runtime--prompt--question-int') // .list-unstyled ?
    }

    getTextArea() {
        return cy.get('textarea')
    }

    getLockAnswerButton() {
        return cy.get('[data-cy="lock-answer-button"]')
    }

    getLockedInfo() {
        return cy.get('[data-cy="locked-info"]')
    }

} export default OpenResponse;