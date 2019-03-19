
/* global context, cy, expect, afterEach, beforeEach, it, describe */
/* eslint-disable no-unused-expressions */
const ENABLED = true
const SHOWN = true
const DISABLED = false
const HIDDEN = false
const DEFAULT_SUBMIT_PROMPT = 'Please answer all questions in the argumentation block.'

const submitButtonShouldBe = (enabledOrDisabled) => {
  cy.get('.ab-submit.button').should(($p) => {
    enabledOrDisabled
      ? expect($p).to.not.have.class('disabled')
      : expect($p).to.have.class('disabled')
  })
}

const submitPromptShouldBe = (shownOrHidden, text=DEFAULT_SUBMIT_PROMPT) => {
  cy.get('.ab-submit-prompt').should(($p) => {
    shownOrHidden
      ? expect($p).to.exist
      : expect($p).to.exist
  })
}

const navButtonShouldBe = (enabledOrDisabled) => {
  cy.get('.button.next').should(($p) => {
    enabledOrDisabled
      ? expect($p).to.not.have.class('disabled')
      : expect($p).to.have.class('disabled')
  })
}

const feedbackShouldBe = (shownOrHidden) => {
  cy.get('.ab-feedback').should(($p) => {
    shownOrHidden
      ? expect($p).to.not.be.hidden
      : expect($p).to.be.hidden
  })
  cy.get('.ab-feedback-header').should(($p) => {
    shownOrHidden
      ? expect($p).to.not.be.hidden
      : expect($p).to.be.hidden
  })
}

const answerOpenResponse = (number = 1, answer = 'some answer') => {
  cy.get('textarea').eq(number).type(answer)
}

const answerRadioButton = (choice = 1) => {
  const index = choice - 1
  cy.get('.choice-container').first().find('.choice input').eq(index).click()
}

const answerPullDown = (choiceNo = 2) => {
  const choices = [
    '(1) Not at all certain',
    '(2)', '(3)', '(4)',
    '(5) Very certain'
  ]
  const choice = choices[choiceNo - 1]
  cy.get('select').select(choice)
  // cy.get('select').select(choice)
}

context('Arg block sections', function () {
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
  // 5: When the answers are changed we need to see something about 'feedback …'
  // xx: Forward navigation should be disbled.
  // 6: Check the text of the submit button
  // 8: Click the 'submit' button
  // 9: Check for feedback on open respones
  // 10:  Forward navigation should be enabled.
  describe('when first loaded', () => {
    it('Navigation and sumbit buttons should be disabled', () => {
      cy.visitActivityPage(activityUrl, 1)
      cy.wait(500)
      submitButtonShouldBe(DISABLED)
      submitPromptShouldBe(SHOWN)
      navButtonShouldBe(DISABLED)
      feedbackShouldBe(HIDDEN)
    })
  })
  describe('after answering all one question', () => {
    beforeEach(() => {
      cy.visitActivityPage(activityUrl, 1)
      answerOpenResponse(1, 'This is my answer')
      cy.wait(500)
    })
    it('Navigation should still be disabled', () => {
      submitButtonShouldBe(DISABLED)
      submitPromptShouldBe(SHOWN)
      navButtonShouldBe(DISABLED)
      feedbackShouldBe(HIDDEN)
    })
  })
  describe('after all the questions are answered', () => {
    beforeEach(() => {
      cy.visitActivityPage(activityUrl, 1)
      answerRadioButton(1)
      answerOpenResponse(1, 'This is my answer')
      answerPullDown(1)
      answerOpenResponse(2, 'This is my other answer')
      cy.wait(5000)
    })

    describe('The submit button', () => {
      it('should be enabled', () => {
        submitButtonShouldBe(ENABLED)
      })
    })

    describe('The submit prompt', () => {
      it('should be hidden', () => {
        submitPromptShouldBe(HIDDEN)
      })
    })

    describe('The navigation button', () => {
      it('should be disabled', () => {
        navButtonShouldBe(DISABLED)
      })
    })

    describe('The navigation button', () => {
      it('should be disabled', () => {
        navButtonShouldBe(DISABLED)
      })
    })
    //   navButtonShouldBe(DISABLED)
    //   feedbackShouldBe(HIDDEN)
    // })
  })
})

// cy.get('.choice-container').first().find('.choice input').eq(1).click()
// cy.get('textarea').eq(1).first().type('first answer')
// cy.get('textarea').eq(2).type('second answer')
// cy.get('select').select('(2)')
// submitShouldBe(enabled)
// cy.wait(2000)
// buttonAndFeedbackAssert()
// cy.wait(300)
// cy.get('.sequence_title').click()
// cy.get('.embeddables div:nth-child(2) .interactive-container').should('exist')
// cy.get('.embeddables div:nth-child(2) .question-hdr').should(($p) => {
//   expect($p.length).to.equal(1)
//   const text = $p[0].innerText.trim();
//   expect(text).to.equal('Question #2');
// })

// the first interactive saves state so it should have a header
// cy.get('.interactive-mod div:nth-child(1) .interactive-container').should('exist')
// cy.get('.interactive-mod div:nth-child(1) .question-hdr').should('contain', 'Question #4: Saves state #1')