
/* global context, cy, afterEach, beforeEach, it */
const enabled = true;
const disabled = false;

const submitShouldBe = (enabledOrDisabled) => {
  cy.get(".ab-submit.button").should( ($p) => {
    enabledOrDisabled ? expect($p).to.not.have.class('disabled')
    : expect($p).to.have.class('disabled')
  })
}

const buttonAndFeedbackAssert = () => {
  cy.get(".ab-submit-prompt").should( ($p) => {
    expect($p).to.exist
  })
  cy.get(".button.next").should( ($p) => {
    expect($p).to.have.class('disabled')
  })
  cy.get(".ab-submit.button").should( ($p) => {
    expect($p).to.have.class('disabled')
    expect($p).to.have.value('Submit')
  })
  cy.get(".ab-feedback").should( ($p) => {
    expect($p).to.be.hidden
  })
  cy.get(".ab-feedback-header").should(($p) => {
    expect($p).to.be.hidden
  })
}

context('Interactive embeddables', function () {
  let activityUrl
  beforeEach(() => {
    cy.login()
    cy.importMaterial('activities/activity_with_arg_block_section.json').then(url => {
      activityUrl = url
    })
  })
  afterEach(() => {
    cy.deleteMaterial(activityUrl)
  })

  // 1: Visit the page
  // 2: Fill in our text boxes
  // 3: Change the pulldown / multiple choice answers
  // 4: Check our messages:
  // 5: When the answers are changed we need to see something about "feedback …"
  // xx: Forward navigation should be disbled.
  // 6: Check the text of the submit button
  // 8: Click the "submit" button
  // 9: Check for feedback on open respones
  // 10:  Forward navigation should be enabled.

  it('should add headers to interactive questions that save state', () => {
    cy.visitActivityPage(activityUrl, 1)
    cy.wait(300)
    buttonAndFeedbackAssert()

    cy.get(".choice-container").first().find(".choice input").eq(1).click()
    cy.get("textarea").eq(1).first().type("first answer");
    cy.get("textarea").eq(2).type("second answer");
    cy.get("select").select("(2)");
    submitShouldBe(enabled);
    // cy.wait(2000)
    // buttonAndFeedbackAssert()
    // cy.wait(300)
    // cy.get(".sequence_title").click()
    // cy.get(".embeddables div:nth-child(2) .interactive-container").should("exist")
    // cy.get(".embeddables div:nth-child(2) .question-hdr").should(($p) => {
    //   expect($p.length).to.equal(1)
    //   const text = $p[0].innerText.trim();
    //   expect(text).to.equal("Question #2");
    // })

    // the first interactive saves state so it should have a header
    // cy.get(".interactive-mod div:nth-child(1) .interactive-container").should("exist")
    // cy.get(".interactive-mod div:nth-child(1) .question-hdr").should("contain", "Question #4: Saves state #1")
  })
})
