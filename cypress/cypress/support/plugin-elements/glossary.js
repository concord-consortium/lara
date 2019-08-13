class Glossary {

    //////////////////
    // Activity UI  //
    //////////////////

    getHighlightedWord() {
        return cy.get('.plugin-app--ccGlossaryWord--1GiEL8kF')
    }

    getGlossaryDialog() {
        return cy.get('.ui-dialog')
    }

    getGlossaryDialogContent() {
        return cy.get('.ui-dialog-content')
    }

    getPreviousDefinitions() {
        return cy.get()
    }

    closeDialogBox() {
        return cy.contains('Close').click({ force: true })
    }

    getSideBar() {
        return cy.get('.sidebar-hdr')
    }

    getSideBarBody() {
        return cy.get('.sidebar-bd')
    }

    getSideBarContent() {
        return cy.get('sidebar-content')
    }

    ///////////////////
    // Authoring UI  //
    ///////////////////

    fillOutFormAndLoad(awsGlossaryCredentials) {
        cy.get('table').eq(0)
            .within(() => {
                cy.get('input').eq(0)
                    .type('test-glossary')
                cy.get('input').eq(1)
                    .type('precipitating_change_glossary')
                cy.get('input').eq(2)
                    .type('AKIAIU2G5AF7UCXN6QEA')
                cy.get('input').eq(3)
                    .type('Y9xuA9CX3oBsHuvqfbgTmFCpCRsdjbhJYfCDv76i')
            })
        cy.get('span.button--label--C6DTEHCS').eq(1)
            .click({ force: true })
    }

    addGlossaryPluginToActivity() {
        cy.get('form.plugin-form').within(() => {
            cy.get('select#approved_script_id').select('Glossary: Activity')
            cy.get('input#add_plugin_button').click({ force: true })
        })
    }

    openGlossaryPluginEditForm() {
        cy.get('.wrapped_plugins').eq(0).within(() => {
            cy.get('a').eq(0).click({ force: true })
        })
    }

    getGlossaryAuthoringUI() {
        return cy.get('#plugin_authoring_output')
    }

    getSuccessStatus() {
        return cy.get('.authoring-app--s3Status--144g5b_-', { timeout: 10000 })
    }

    getAddANewDefinitionButton() {
        return cy.get('span.button--button--2NkWn1jH').last()
    }

    getEditWordButton(idx) {
        cy.get('table').eq(1)
            .within(() => {
                cy.get('.authoring-app--definitionButtons--1a-tUDnQ').eq(idx).contains('edit').click()
            })
    }

    // New Word Field

    getWordTextBox() {
        return cy.get('.definition-editor--editor--3175UrW1').find('input').eq(0)
    }
    getDefTextBox() {
        return cy.get('.plugin-output').find('textarea')
    }
    getImageTextBox() {
        return cy.get('.definition-editor--editor--3175UrW1').find('input').eq(1)
    }

    getImageCaptionTextBox() {
        return cy.get('.definition-editor--editor--3175UrW1').find('input').eq(3)
    }
    getVideoTextBox() {
        return cy.get('.definition-editor--editor--3175UrW1').find('input').eq(4)
    }
    getVideoCaptionTextBox() {
        return cy.get('.definition-editor--editor--3175UrW1').find('input').eq(6)
    }

    // Save buttons

    getSaveGlossaryWord() {
        return cy.get(':nth-child(3) > .button--label--C6DTEHCS')
    }

    getSaveToAWS() {
        return cy.get(':nth-child(1) > .button--label--C6DTEHCS').eq(0)
    }

    getSaveToLARA() {
        return cy.get('button.embeddable-save')
    }

}
export default Glossary;