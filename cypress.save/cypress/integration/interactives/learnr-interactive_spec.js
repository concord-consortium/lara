import RInteractive from "../../support/elements/interactives/learnrlara/learnr_interactive"

context('Test Learn R Interactive Embedded In LARA', () => {

    let testUrl = "https://authoring.staging.concord.org/activities/20624/pages/307325/"
    let rinteractive = new RInteractive();

    before(() => {
        cy.visit(testUrl)
    })

    context('Test all 3 R Interactive types', () => {

        // Tutorial, Assessment, Explore types
        // For Details on R Interactive Type details visit link below
        // https://docs.google.com/document/d/1w9kVg3JCjNvYshqfOgs7_3C1CIk9x5sqpNxJlSq7GrQ/edit#heading=h.r2attgxdvyrt

        it('Verify Use and Explore Mode', () => {

            cy.getInteractiveIframe(0).find('div.pageContent').within(() => {
                rinteractive.getStartOverButton().should('be.visible')
                rinteractive.getRunCodeButton().should('be.visible')
                rinteractive.getRHelpButton().should('be.visible')
            })
        })

        it('Verify Assessment Mode', () => {
            cy.getInteractiveIframe(0).find('div.pageContent').within(() => {
                rinteractive.getStartOverButton().should('be.visible')
                rinteractive.getRunCodeButton().should('be.visible')
                rinteractive.getRHelpButton().should('be.visible')
            })
        })

        it('Verify Exercise Mode', () => {

            // Has default Start Over, Run Code, Submit, RHelp
            // Hints and Solutions are optional

            cy.visit('https://authoring.concord.org/activities/10482/pages/133077/')

            cy.getInteractiveIframe(0).find('div.pageContent').within(() => {
                rinteractive.getStartOverButton().should('be.visible')
                rinteractive.getHintsButton().should('be.visible')
                rinteractive.getRunCodeButton().should('be.visible')
                rinteractive.getSolutionButton().should('be.visible')
                rinteractive.getRHelpButton().should('be.visible')
            })
        })
    })

    context('Verify save-state in LARA', () => {

        let DEFAULT_TEXT = '# See the data set with the historical prices of the disposable utensils:'
        let TEST_CODE_1 = ['5+5','10']

        it('verifies default r interactive state loads in code editor', () => {
            cy.visit('https://authoring.concord.org/activities/10482/pages/133077/')
            cy.getInteractiveIframe(0).find('div.pageContent').within(() => {
                rinteractive.getCodeEditor().should('contain', DEFAULT_TEXT)
                rinteractive.getTextArea().clear({force:true})
                rinteractive.getCodeEditor().should('not.contain', DEFAULT_TEXT)
            })
        })

        it('verifies addition of student code and submission', () => {
            cy.getInteractiveIframe(0).find('div.pageContent').within(() => {
                rinteractive.getTextArea().clear({force:true})
                rinteractive.getTextArea().type(TEST_CODE_1[0], {force:true})
                rinteractive.getRunCodeButton().click({force:true})
                rinteractive.getCodeOutput().should('contain', TEST_CODE_1[1])
            })
        })
    })
})
