
/* global context, cy, expect, afterEach, beforeEach, it, describe */
/* eslint-disable no-unused-expressions */

context('Arg block sections', function () {
  let activityUrl
  beforeEach(() => {
    cy.login()
    cy.importMaterial('activities/activity_with_empty_plugin.json').then(url => {
      activityUrl = url
    })
  })
  afterEach(() => {
    cy.deleteMaterial(activityUrl)
  })

  const openResponseInput = () => cy.get("[name='embeddable_open_response_answer[answer_text]']")

  describe('when first loaded', () => {
    it('The page contents should be visible', () => {
      cy.visitActivityPage(activityUrl, 1)
      cy.wait(500)
      openResponseInput.should("exist")
    })
  })

})
