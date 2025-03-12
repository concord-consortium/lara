context.skip("Test Authoring Preview", () => {
    describe("Test Preview", () => {
        beforeEach(() => {
            cy.visit("https://activity-player.concord.org/branch/master/?activity=https%3A%2F%2Fauthoring-migrate.concord.org%2Fapi%2Fv1%2Factivities%2F13056.json");
        });
        it("Verify MCQ", () => {
            cy.get("[data-cy=activity-nav-header] [data-cy=nav-pages-button]").contains("1").eq(0).click();
            cy.get(".page-content .name").should("contain", "MCQ");
            cy.pause();
        })
        it("Verify CODAP", () => {
            
            cy.get("[data-cy=activity-nav-header] [data-cy=nav-pages-button]").contains("2").eq(0).click();
            cy.get(".page-content .name").should("contain", "CODAP");
            cy.pause();
        })
        it("Verify Sage Modeler", () => {
            cy.get("[data-cy=activity-nav-header] [data-cy=nav-pages-button]").contains("3").eq(0).click();
            cy.get(".page-content .name").should("contain", "Sage Modeler");
            cy.pause();
        })
    });
});
