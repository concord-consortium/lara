import LaraPage from "../../support/elements/lara-page"
import OpenResponse from "../../support/elements/interactives/question-interactives/open-response"


context('Test Open Response Question-Interactive Embedded In LARA', () => {

    let testUrl = "https://authoring.staging.concord.org/activities/20515/pages/306789/"
    let laraPage = new LaraPage;
    let or = new OpenResponse;

    before(() => {
        cy.visit(testUrl)
    })

    context('Test Open Response with default text, hint, and is required', () => {
        let prompt = 'Here is a required OR prompt. Uses hint and default answer is empty.. should contain "Please type your answer here."'
        let defaultText = 'Please type your answer here.'
        const studentResponse = 'Student response here. Student response here. Student response here. Student response here. Student response here. '
        const postSubmissionFeedback = 'Testing post submission feedback'

        it('checks for prompt', () => {
            laraPage.getInfoAssessmentBlock().within(() => {
                cy.getInteractiveIframe(5).find('#app').within(() => {
                    or.getPrompt().should('contain', prompt).and('be.visible')
                })
            })
        })

        it('checks for default placeholder text then clears', () => {
            laraPage.getInfoAssessmentBlock().within(() => {
                cy.getInteractiveIframe(5).find('#app').within(() => {
                    or.getTextArea().should('have.attr', 'placeholder', defaultText)
                        .and('be.visible')
                    or.getTextArea().clear().should('be.empty').and('have.attr', 'placeholder', defaultText)
                })
            })
        })


        it('types student response', () => {
            laraPage.getInfoAssessmentBlock().within(() => {
                cy.getInteractiveIframe(5).find('#app').within(() => {
                    or.getLockAnswerButton().should('be.disabled').and('be.visible').click({ force: true })
                    or.getLockAnswerButton().should('be.disabled').and('be.visible')
                    or.getTextArea().type(studentResponse)
                    or.getLockAnswerButton().should('not.be.disabled').and('be.visible').click()
                    or.getLockedInfo().should('contain', postSubmissionFeedback)
                    or.getLockAnswerButton().should('not.exist')
                })
            })
        })

        it('attempts to clear student response', () => {
            laraPage.getInfoAssessmentBlock().within(() => {
                cy.getInteractiveIframe(5).find('#app').within(() => {
                    or.getTextArea().clear({force:true})
                    or.getTextArea().should('contain', studentResponse)
                })
            })
        })
    })

    context('OR question not required. has a custom default answer', () => {
        let prompt = 'OR question not required. Has a custom default answer of "Testing default answer"'
        let defaultText = 'Testing default answer'
        const studentResponse = 'Student response here. Student response here. Student response here. Student response here. Student response here. '
        const postSubmissionFeedback = 'Testing post submission feedback'

        it('checks for prompt', () => {
            laraPage.getInfoAssessmentBlock().within(() => {
                cy.getInteractiveIframe(6).find('#app').within(() => {
                    or.getPrompt().should('contain', prompt).and('be.visible')
                    or.getLockAnswerButton().should('not.exist')
                })
            })
        })

        it('types student response with custom placeholder text', () => {
            laraPage.getInfoAssessmentBlock().within(() => {
                cy.getInteractiveIframe(6).find('#app').within(() => {
                    or.getTextArea().should('have.attr','placeholder',defaultText)
                    or.getTextArea().type(studentResponse)
                    or.getTextArea().should('contain', studentResponse).and('be.visible')
                    cy.wait(2000)
                    or.getTextArea().clear({force:true})
                    or.getTextArea().should('be.empty').and('have.attr','placeholder',defaultText)
                    or.getTextArea().type(studentResponse)
                })
            })
        })

    })

})