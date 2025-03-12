context.skip('Multiple choice question', function () {
  let activityUrl
  beforeEach(() => {
    cy.login()
    cy.importMaterial("activities/multiple-choice-simple.json").then(url =>
      activityUrl = url
    )
  })
  afterEach(() => {
    cy.deleteMaterial(activityUrl)
  })

  it('respects correct answer settings', () => {
    cy.visitActivityPage(activityUrl, 0)
    cy.get(".choice-container .choice input").first().click()
    cy.get(".check_answer_button").click()
    cy.get(".ui-dialog .ui-dialog-content").should("have.text", "Yes! You are correct.")
    cy.get(".ui-dialog-titlebar-close").click()

    cy.get(".choice-container .choice input").eq(2).click()
    cy.get(".check_answer_button").click()
    cy.get(".ui-dialog .ui-dialog-content").should("have.text", "Sorry, that is incorrect.")
    cy.get(".ui-dialog-titlebar-close").click()
  })
})
