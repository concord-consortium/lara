import ExploreNav from "../../support/elements/interactives/connected-bio/ExploreNav"
import Backpack from "../../support/elements/interactives/connected-bio/Backpack"
import RightPanelContent from "../../support/elements/interactives/connected-bio/RightPanelContent"

context('Test Connected Bio Interactive Embedded In LARA', () => {

    let testUrl = "https://authoring.staging.concord.org/activities/20518/pages/306793/"
    
    let explore = new ExploreNav;
    let backpack = new Backpack;
    let rightPanel = new RightPanelContent;

    before(() => {
        cy.visit(testUrl)
    })

    context('Authored state persists on load', () => {
        it('tests initial backpack state', () => {
            cy.getInteractiveIframe(0).find('div.app-container').within(() => {
                backpack.getFullCollectButton().should('have.length', 2)
            })
        })
        it('verifies disabled explore level are not displaying', () => {
            cy.getInteractiveIframe(0).find('div.app-container').within(() => {
                explore.getExploreView('populations').should('exist')
                explore.getExploreView('organism').should('be.visible')
                explore.getExploreView('heredity').should('be.visible')
                explore.getExploreView('dna').should('not.be.visible')
            })
        })
        it('verifies instruction text on different explore levels display correctly', () => {
            // assert all text is visible in correct panes
            cy.getInteractiveIframe(0).find('div.app-container').within(() => {
                explore.clickExploreView('populations')
                rightPanel.getContent().should('contain', 'POPULATION instruction text')
                explore.clickExploreView('organism')
                rightPanel.getContent().should('contain', 'ORGANISM instruction text')
                explore.clickExploreView('heredity')
                rightPanel.getContent().should('contain', 'BREEDING instruction text')
            })
        })
    })

    context('Population save state in session', () => {
        it('should pause running model when switching views', () => {

        })
        it('tests organism zoom save state', () => {

        })

    })
})

