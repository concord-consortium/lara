context('multiple iframes experiment',()=>{
    it('get specific iframe when there are multiples',()=>{
        cy.visit('https://authoring.staging.concord.org/activities/20624/pages/307325/')
        cy.getInteractiveIframe(2);
    })
})