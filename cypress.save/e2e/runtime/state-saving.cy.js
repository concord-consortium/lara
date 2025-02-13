context.skip('Runtime state saving', function () {
  let activityUrl
  beforeEach(() => {
    cy.login()
    cy.importMaterial("activities/open-response-simple.json").then(url =>
      activityUrl = url
    )
  })
  afterEach(() => {
    cy.deleteMaterial(activityUrl)
  })

  const openResponseInput = () => cy.get("[name='embeddable_open_response_answer[answer_text]']")

  it('preserves state after page is reloaded', () => {
    cy.visitActivityPage(activityUrl, 0)
    openResponseInput().type("test answer").blur()
    cy.wait(200)
    // Test 1: check if answer is there after we reload a page. Note that it will preserver the run key in the URL.
    cy.reload()
    openResponseInput().should("have.text", "test answer")
    // Test 2: do the same, but instead of reloading, open activity again. It's a bit different, as
    // LARA will need to obtain a correct run key, and redirect you to the same page.
    cy.visit(activityUrl)
    openResponseInput().should("have.text", "test answer")
  })
})
