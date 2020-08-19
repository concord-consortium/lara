import LaraPage from "../../support/elements/lara-page"
import FITB from "../../support/elements/interactives/question-interactives/fill-in-the-blank"


context('Test Open Response Question-Interactive Embedded In LARA', () => {

    let testUrl = "https://authoring.staging.concord.org/activities/20515/pages/306789/"
    let laraPage = new LaraPage;
    let fitb = new FITB;
    const prompt = ['Fill in the blank 1','and fill in the blank 2']
    const id1 = '[blank-1]'
    const id2 = '[blank-2]'
    let response1 = 'student answer 1'
    let response2 = 'student answer 2'

    before(() => {
        cy.visit(testUrl)
    })

    context('Test FITB ', () => {

        it('checks for prompt', () => {
            laraPage.getInfoAssessmentBlock().within(() => {
                cy.getInteractiveIframe(7).find('#app').within(() => {
                    fitb.getFITBContent().should('contain', prompt[0])
                    fitb.getFITBContent().should('contain', prompt[1])
                })
            })
        })

        it('checks fitb input IDs and empty default state', () => {
            laraPage.getInfoAssessmentBlock().within(() => {
                cy.getInteractiveIframe(7).find('#app').within(() => {
                    fitb.getFITBInput().should('have.length', 2)
                    fitb.getFITBInput().eq(0).should('have.attr','id',id1).and('be.visible').and('be.empty')
                    fitb.getFITBInput().eq(1).should('have.attr','id',id2).and('be.visible').and('be.empty')
                })
            })
        })

        it.only('types student response', () => {
            laraPage.getInfoAssessmentBlock().within(() => {
                cy.getInteractiveIframe(7).find('#app').within(() => {
                    fitb.getFITBInput().eq(0).type(response1)
                    fitb.getFITBInput().eq(0).should('have.attr', 'value', response1)
                    fitb.getFITBInput().eq(1).type(response2, {force:true})
                    fitb.getFITBInput().eq(1).should('have.attr', 'value', response2)
                })
            })
        })

        it('attempts to clear student response', () => {
            laraPage.getInfoAssessmentBlock().within(() => {
                cy.getInteractiveIframe(5).find('#app').within(() => {

                })
            })
        })
    })
})