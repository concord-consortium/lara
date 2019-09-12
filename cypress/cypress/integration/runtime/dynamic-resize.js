context("Test Interactive Resizing in LARA", () => {

    function getActivityHeader() {
        return cy.get('h2').last()
    }
    
    const activityUrl = "https://authoring.staging.concord.org/activities/20502/pages/306781/"

    const activityName = "Testing Modes for CodeR4Math"
    const interactiveTextArea = "textarea"
    const interactiveCodeOutput = ".tutorial-exercise-output-frame"
    const testShortSubmission = "1+1"
    const testLongSubmission = "plot(1:100)"
    const assessmentBtns = {
        runCode: ".btn-tutorial-run",
        submit: ".btn-tutorial-submit",
        rHelp: ".btn-info",
        startOver: ".btn-tutorial-hint",
        hint: ".btn-tutorial-hint"
    }

    before(() => {
        cy.login()
        cy.visit(activityUrl)
    })

    context("Assessment", () => {

        it("Checks activity header", () => {
            cy.getIframe().should('exist')
            getActivityHeader().should('contain', activityName)
        })

        it("Checks for all Assessment Mode Buttons", () => {
            cy.getIframe().find(assessmentBtns.startOver).eq(0).should('be.visible')
            cy.getIframe().find(assessmentBtns.runCode).eq(0).should('be.visible')
            cy.getIframe().find(assessmentBtns.submit).eq(0).should('be.visible')
            cy.getIframe().find(assessmentBtns.rHelp).eq(0).should('be.visible')
        })

        it("Writes short code and runs", () => {
            cy.getIframe().find(interactiveTextArea).eq(0).clear({ force: true })
            cy.getIframe().find(interactiveTextArea).eq(0).type(testShortSubmission, { force: true })
            cy.getIframe().find(assessmentBtns.runCode).eq(0).should("be.visible").click({ force: true })
            cy.getIframe().find(interactiveCodeOutput).eq(0).should("contain", "2")
        })

        it("Writes longer code to test dynamic resize", () => {
            cy.getIframe().find(interactiveTextArea).eq(0).clear({ force: true })
            cy.getIframe().find(interactiveTextArea).eq(0).type(testLongSubmission, { force: true })
            cy.getIframe().find(assessmentBtns.runCode).eq(0).should("be.visible").click({ force: true })
            cy.getIframe().find("img").should('exist').and("be.visible")
        })
    })
})

