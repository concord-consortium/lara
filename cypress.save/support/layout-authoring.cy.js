class LayoutAuthoringPage {
  selectLayout(layout) {
    cy.get("#section_layout").select(layout);
  }

  getAddItem(layout, section) {
    return cy.get('.editPageContainer .section-'+layout+' .section-'+section+' .lineAdjust');
  }

  getSectionItemHeader(section) {
    return cy.get('.section-'+section+' .itemsContainer .sectionItemContainer').find(".menuStart");
  }

  getAuthoringPreviewPrompt(section, prompt) {
    cy.get('.section-'+section+' .itemsContainer .sectionItemContainer').find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.runtime--prompt--question-int').should("contain", prompt);
    });
  }
}
export default LayoutAuthoringPage;
