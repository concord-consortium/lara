let iFrameSelector =  'div.embeddable:nth-child(1) div.managed-interactive iframe';

const getIframeBody = (iFrameSelector) => {
  // get the iframe > document > body
  // and retry until the body element is not empty
  return cy
      .get(iFrameSelector)
      .its('0.contentDocument.body').should('not.be.empty')
      // wraps "body" DOM element to allow
      // chaining more Cypress commands, like ".find(...)"
      // https://on.cypress.io/wrap
      .then(cy.wrap)
}

class DrawingAuthoringPage {

  //Activity Player Runtime Preview
  getDrawToolContainer() {
    return getIframeBody(iFrameSelector).find('.dt-container .dt-tools');
  }
  verifyDrawToolNotDisplayed(tool) {
    return this.getDrawToolContainer().find("[title^='"+tool+"']").should("not.exist");
  }
  verifyDrawToolDisplayed(tool) {
    return this.getDrawToolContainer().find("[title^='"+tool+"']").should("exist");
  }
}
export default DrawingAuthoringPage;
