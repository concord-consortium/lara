context('Hints', function () {
  let activityUrl
  beforeEach(() => {
    cy.login()
    cy.importMaterial("activities/hints.json").then(url =>
      activityUrl = url
    )
  })
  afterEach(() => {
    cy.deleteMaterial(activityUrl)
  })

  const getQuestionNum = (num) => cy.get(`.embeddables .question:nth-child(${num})`)
  
  it('the first question has a help icon that works', () => {
    cy.visitActivityPage(activityUrl, 0)
      
    // help icon exists
    getQuestionNum(1).find(".help-icon").should("exist")
    
    // but the help content should be initially hidden
    getQuestionNum(1).find(".help-content").should("exist")
    getQuestionNum(1).find(".help-content").should("not.be.visible")
    
    // clicking the help icon should show the help content
    getQuestionNum(1).find(".help-icon").first().click()
    getQuestionNum(1).find(".help-content").should("be.visible")
    getQuestionNum(1).find(".help-content").contains("Think about it!")

    // clicking the help icon again should hide the help content
    getQuestionNum(1).find(".help-icon").first().click()
    getQuestionNum(1).find(".help-content").should("not.be.visible")
  })

  it('the second question does not have a help icon', () => {
    cy.visitActivityPage(activityUrl, 0)
    getQuestionNum(2).find(".help-icon").should("not.exist")
  })
})
