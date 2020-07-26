class RInteractive {

    getRHelpButton() {
        return cy.get('.btn-info')
    }
    getRunCodeButton() {
        return cy.get('.btn-tutorial-run')
    }
    getStartOverButton() {
        return cy.get('.btn-tutorial-hint').contains('Start Over')
    }
    getHintsButton() {
        return cy.get('.btn-tutorial-hint').contains('Hints')
    }
    getSolutionButton() {
        return cy.get('.btn-tutorial-solution')
    }
    getSubmitButton() {
        return cy.get('.btn-tutorial-submit')
    }
    // Contains default code/comments/text
    getCodeEditor() {
        return cy.get('.ace_content')
    }

    getTextArea() {
        return cy.get('textarea.ace_text-input')
    }

    getCodeEditorContent() {
        return cy.get('.ace_indentifier')
    }

    getCodeOutput() {
        return cy.get('.tutorial-exercise-output-frame')
    }

}

export default RInteractive;
