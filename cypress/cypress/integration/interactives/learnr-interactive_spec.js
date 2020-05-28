import RInteractive from "../../support/elements/interactives/learnr_interactive"

context('Test Learn R Interactive Embedded In LARA', () => {

    let testUrl = "https://authoring.staging.concord.org/activities/20624/pages/307325/"
    let rinteractive = new RInteractive();

    const getIframeBody = () => {
        return cy.get('iframe')
            .its('0.contentDocument.body').should('not.be.empty')
            .then(cy.wrap)
    }

    before(() => {
        cy.visit(testUrl)
    })

    context('Test all 3 R Interactive types', () => {

        // Tutorial, Assessment, Explore types
        // For Details on R Interactive Type details visit link below
        // https://docs.google.com/document/d/1w9kVg3JCjNvYshqfOgs7_3C1CIk9x5sqpNxJlSq7GrQ/edit#heading=h.r2attgxdvyrt

        it('Verify Use and Explore Mode', () => {

            getIframeBody().find('div.pageContent').within(() => {
                rinteractive.getStartOverButton().should('be.visible')
                rinteractive.getRunCodeButton().should('be.visible')
                rinteractive.getRHelpButton().should('be.visible')
            })
        })

        it('Verify Assessment Mode', () => {
            getIframeBody().find('div.pageContent').within(() => {
                rinteractive.getStartOverButton().should('be.visible')
                rinteractive.getRunCodeButton().should('be.visible')
                rinteractive.getRHelpButton().should('be.visible')
            })
        })

        it('Verify Exercise Mode', () => {

            // Has default Start Over, Run Code, Submit, RHelp
            // Hints and Solutions are optional

            cy.visit('https://authoring.concord.org/activities/10482/pages/133077/')

            getIframeBody().find('div.pageContent').within(() => {
                rinteractive.getStartOverButton().should('be.visible')
                rinteractive.getHintsButton().should('be.visible')
                rinteractive.getRunCodeButton().should('be.visible')
                rinteractive.getSolutionButton().should('be.visible')
                rinteractive.getRHelpButton().should('be.visible')
            })
        })
    })

    context.only('Verify save-state in LARA', () => {

        let DEFAULT_TEXT = '# See the data set with the historical prices of the disposable utensils:'
        // assert authored state is loaded into code editor
        // Enter some code and leave page
        // Server disconnect?
        // Restart student data, assure default code is in textbox

        it('verifies default r interactive state loads in code editor', () => {
            cy.visit('https://authoring.concord.org/activities/10482/pages/133077/')
            getIframeBody().find('div.pageContent').within(() => {
                rinteractive.getCodeEditor().should('contain', DEFAULT_TEXT)
                rinteractive.getTextArea().clear({force:true})
                rinteractive.getCodeEditor().should('not.contain', DEFAULT_TEXT)
            })
        })

        it('verifies addition of student code and submission', () => {
            getIframeBody().find('div.pageContent').within(() => {
                rinteractive.getTextArea().type('plot(x^2) {enter}')
                rinteractive.getRunCodeButton().click({force:true})
            })
        })


        //     const baseHref = "" // Get from baseHref of interactive
        //     const url = 'https://concord.shinyapps.io/reus_histogram'
        //     let someJSON = {
        //         "version": 1,
        //         "exercises": {
        //             "view-reusable": {
        //                 "current": "Somethingg",
        //                 "submitted": ""
        //             }
        //         },
        //         "lara_options": {
        //             "reporting_url": "https://concord.shinyapps.io/reus_trays/"
        //         }
        //     }
        //     const payload = {
        //         contents: "1 + 2 =",
        //         label: "qplot-histogram"
        //     }
        //     it('Adds code to r interactive code editor', () => {
        //         cy.requestWithToken('PUT', url, payload)
        //             .then((response) => {
        //                 cy.log(response)
        //             })
        //     })
    })
})

