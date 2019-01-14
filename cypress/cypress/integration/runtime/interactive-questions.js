context('Interactive embeddables', function () {
    let activityUrl
    beforeEach(() => {
      cy.login()
      cy.importMaterial("activities/interactive-questions.json").then(url =>
        activityUrl = url
      )
    })
    afterEach(() => {
      cy.deleteMaterial(activityUrl)
    })
  
    it('should add headers to interactive questions that save state', () => {
      cy.visitActivityPage(activityUrl, 0)

      // the second embeddable is an interactive that saves state so it should have a header
      cy.get(".embeddables div:nth-child(2) .interactive-container").should("exist")
      cy.get(".embeddables div:nth-child(2) .question-hdr").should("contain", "Question #2")

      // the fourth embeddable is an interactive that does not save state so it should not have a header
      cy.get(".embeddables div:nth-child(4) .interactive-container").should("exist")
      cy.get(".embeddables div:nth-child(4) .question-hdr").should("not.exist")

      // the first interactive saves state so it should have a header
      cy.get(".interactive-mod div:nth-child(1) .interactive-container").should("exist")
      cy.get(".interactive-mod div:nth-child(1) .question-hdr").should("contain", "Question #4")
      
      // the second interactive does not save state so it should not have a header
      cy.get(".interactive-mod div:nth-child(2) .interactive-container").should("exist")
      cy.get(".interactive-mod div:nth-child(2) .question-hdr").should("not.exist")
      
      // the third interactive saves state so it should have a header
      cy.get(".interactive-mod div:nth-child(3) .interactive-container").should("exist")
      cy.get(".interactive-mod div:nth-child(3) .question-hdr").should("contain", "Question #5")
    })
  })
  