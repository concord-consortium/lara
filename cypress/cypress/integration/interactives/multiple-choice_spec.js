import LaraPage from "../../support/elements/lara-page"
import MultipleChoice from "../../support/elements/interactives/question-interactives/multiple-choice"


context('Test Multiple Choice Question-Interactive In LARA', () => {

    let testUrl = "https://authoring.staging.concord.org/activities/20515/pages/306789/"
    let laraPage = new LaraPage;
    let mc = new MultipleChoice;
    const questions = [
        {
            type: "vertical",
            mcPrompt: "MC Vertical Required with post submission feedback and a hint. Users can check answers for custom feedback with new icons for correct/incorrect responses.",
            mcPostSubText: "Testing post submission feedback",
            choiceA: {
                status: "right",
                index: 0,
                text: "Choice A [correct vertical]",
                custom_feedback: "Choice A is correct [custom feedback vertical]"
            },
            choiceB: {
                status: "wrong",
                index: 1,
                text: "Choice B [incorrect vertical]",
                custom_feedback: "Choice B is incorrect [custom feedback vertical]"
            }
        },
        {
            type: "dropdown",
            mcPrompt: "MC Dropdown can only have 1 answer. Users can check multiple answers. Custom feedback for answers here.",
            mcPostSubText: "Testing post submission feedback",
            choiceA: {
                status: "right",
                index: 0,
                text: "Choice A [correct dropdown]",
                custom_feedback: "Choice A is correct [custom feedback dropdown]"
            },
            choiceB: {
                status: "wrong",
                index: 1,
                text: "Choice B [incorrect dropdown]",
                custom_feedback: "Choice B is correct [custom feedback dropdown]"
            }
        }
    ]

    before(() => {
        cy.visit(testUrl)
    })

    context('Test Required MC question with hint and custom submission feedback', () => {

        it('Checks for multiple choice prompt content', () => {
            laraPage.getInfoAssessmentBlock().within(() => {
                cy.getInteractiveIframe(0).find('#app').within(() => {
                    mc.getPrompt(0).should('contain', questions[0].mcPrompt)
                })
            })
        })

        it('Checks for disabled check answer/submit buttons before selection', () => {
            laraPage.getInfoAssessmentBlock().within(() => {
                cy.getInteractiveIframe(0).find('#app').within(() => {
                    mc.getCheckAnswerButton().should('be.disabled').and('be.visible').click({ force: true })
                    mc.getLockAnswerButton().should('be.disabled').and('be.visible').click({ force: true })
                    mc.getLockAnswerButton().should('be.visible')
                })
            })
        })

        it('Checks for saving of state', () => {
            let choice = questions[0].choiceB
            let i = choice.index

            laraPage.getInfoAssessmentBlock().within(() => {
                cy.getInteractiveIframe(0).find('#app').within(() => {
                    mc.getAnswerOptions().eq(i).parent().should('contain', choice.text)
                    mc.getAnswerOptions().eq(i).click()
                    cy.wait(3000)
                })
            })
            cy.reload(true)
        })

        it('Selects option and checks wrong answer', () => {
            laraPage.getInfoAssessmentBlock().within(() => {
                cy.getInteractiveIframe(0).find('#app').within(() => {
                    let choice = questions[0].choiceB
                    let i = choice.index

                    mc.getAnswerOptions().eq(i).parent().should('contain', choice.text)
                    mc.getAnswerOptions().eq(i).click()
                    mc.getCheckAnswerButton().should('not.be.disabled')
                    mc.getLockAnswerButton().should('not.be.disabled')
                    mc.getCheckAnswerButton().click()
                    mc.getAnswerFeedback('false').should('contain', choice.custom_feedback)
                })
            })
        })

        it('Selects option and checks correct answer', () => {
            laraPage.getInfoAssessmentBlock().within(() => {
                cy.getInteractiveIframe(0).find('#app').within(() => {
                    let choice = questions[0].choiceA
                    let i = choice.index

                    mc.getAnswerOptions().eq(i).parent().should('contain', choice.text)
                    mc.getAnswerOptions().eq(i).click()
                    mc.getCheckAnswerButton().should('not.be.disabled')
                    mc.getLockAnswerButton().should('not.be.disabled')
                    mc.getCheckAnswerButton().click()
                    mc.getAnswerFeedback('true').should('contain', choice.custom_feedback)
                })
            })
        })

        it('Submits correct option', () => {
            laraPage.getInfoAssessmentBlock().within(() => {
                cy.getInteractiveIframe(0).find('#app').within(() => {
                    let choice = questions[0].choiceA
                    let i = choice.index

                    mc.getLockAnswerButton().click()
                    mc.getLockedInfo().should('contain', 'Your answer has been submitted and is locked').and('be.visible')

                    mc.getCheckAnswerButton().should('not.exist')
                    mc.getLockAnswerButton().should('not.exist')
                })
            })
        })

        it('Verifies custom post submission feedback for required question', () => {
            laraPage.getInfoAssessmentBlock().within(() => {
                cy.getInteractiveIframe(0).find('#app').within(() => {
                    mc.getLockedInfo().should('contain', questions[0].mcPostSubText).and('be.visible')
                })
            })
        })
    })
    context('Test drop', () => {
        // Question 2
        it('Verifies dropdown layout selection', () => {
            laraPage.getInfoAssessmentBlock().within(() => {
                cy.getInteractiveIframe(4).find('#app').within(() => {
                    let choice = questions[1].choiceA
                    let i = choice.index

                    mc.getDropdownAnswerOptions().eq(i).parent().should('contain', choice.text)
                    mc.getDropdownAnswerOptions().select(choice.text)
                    mc.getCheckAnswerButton().should('not.be.disabled')
                    mc.getCheckAnswerButton().click()
                    mc.getAnswerFeedback('true').should('contain', choice.custom_feedback)
                })
            })
        })
    })

})

