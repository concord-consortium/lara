/**
 * Test cases:
 * 
 * 1.1 Test Width Layout status
 * 1.2 Test different layouts
 * 2.1 Test special rich text changes if possible (images)
 * 2.2 Student answers save
 * 3.  Check if required (submit button, post submission feedback)
 * 4.  Allow users to check answers
 * 5.  Hints have rich text and display in ? button
 * 6.  Multiple answers allowed
 * 7.  Custom feedback for individual questions
 * 
 */

class MultipleChoice {

    getHeaderHint() {
        return cy.get('.help-icon').should('not.have.attr', 'class', 'hidden')
    }

    getPrompt(i) {
        return cy.get('.runtime--prompt--question-int') // .list-unstyled ?
    }

    getAnswerOptions() {
        return cy.get('.runtime--choices--question-int').find('input')
    }

    getDropdownAnswerOptions() {
        return cy.get('.runtime--choices--question-int').find('select')
    }

    getCheckAnswerButton() {
        return cy.get('[data-cy="check-answer-button"]')
    }

    getLockAnswerButton() {
        return cy.get('[data-cy="lock-answer-button"]')
    }

    getLockedInfo() {
        return cy.get('[data-cy="locked-info"]')
    }

    getAnswerFeedback(status) {
        return cy.get('[data-cy="feedback-'+status+'"]')
    }

} export default MultipleChoice;