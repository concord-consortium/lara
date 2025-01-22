context.skip('Rubric Test Feature', () => {

// Visits the student report (maxScore set to 0)
  it('gets the first student report', function() {
    cy.visit('https://portal-report.concord.org/version/v1.7.1/?reportUrl=https%3A%2F%2Flearn.staging.concord.org%2Fapi%2Fv1%2Freports%2F1044&token=8288165b8a347ae85550f5d872802170')
    cy.get('.avg-score > .label').eq(1).find('.value').should('have.value','10');
// cy.contains('the').click();
  })

})
