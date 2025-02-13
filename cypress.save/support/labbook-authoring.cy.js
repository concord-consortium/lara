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

class LabbookAuthoringPage {
  getEditItemDialog() {
    return cy.get(".modalContainer.itemEditDialog");
  }

  //***************************************************************************************************************

  getEditItemPreview() {
    return this.getEditItemDialog().find('.itemEditPreview');
  }

  getEditPreviewPrompt(prompt) {
    this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.base-app--runtime--question-int p').should("contain", prompt);
    });
  }
  getEditPreviewDrawingTool() {
    return this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-testid=draw-tool]');
    });
  }
  getEditPreviewUploadButton() {
    return this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-testid=upload-btn]');
    });
  }
  getEditPreviewCommentField() {
    return this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-testid=comment-field]');
    });
  }
  getEditPreviewThumbnailChooser() {
    return this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.thumbnail-chooser--thumbnail-chooser-list--question-int');
    });
  }
//***************************************************************************************************************

  getEditItemForm() {
    return this.getEditItemDialog().find('#itemEditForm');
  }
  selectBackgroundSource(value) {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_backgroundSource').select(value);
    });
  }
  enterBackgroundImageUrl(url) {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_backgroundImageUrl').type(url);
    });
  }
  getHideToolbarButtonsField() {
    return this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_drawingTools');
    });
  }
  verifyHideToolbarButtons() {
    this.getHideToolbarButtonsField()
    .should("contain", "Free hand drawing tool")
    .should("contain", "Basic shape tool")
    .should("contain", "Annotation tool");
  }

  selectHideToolbarButtons(id) {
    this.getHideToolbarButtonsField().find('#root_drawingTools-'+id).click();
  }

//***************************************************************************************************************
  getInteractive() {
    return cy.get(".itemsContainer .sectionItemContainer");
  }
  getAuthoringPreviewPrompt(prompt) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.base-app--runtime--question-int p').should("contain", prompt);
    });
  }
  getAuthoringPreviewDrawingTool() {
    return this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-testid=draw-tool]');
    });
  }
  getAuthoringPreviewUploadButton() {
    return this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-testid=upload-btn]');
    });
  }
  getAuthoringPreviewCommentField() {
    return this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-testid=comment-field]');
    });
  }
  getAuthoringPreviewThumbnailChooser() {
    return this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.thumbnail-chooser--thumbnail-chooser-list--question-int');
    });
  }

  //Activity Player Runtime Preview
  getDrawToolContainer() {
    return getIframeBody(iFrameSelector).find('[data-testid=draw-tool]');
  }
  verifyAnnotationToolNotDisplayed() {
    return this.getDrawToolContainer().find('.dt-palette.dt-vertical .dt-btn.dt-keep-text-edit-mode').should("not.exist");
  }
  verifyAnnotationToolDisplayed() {
    return this.getDrawToolContainer().find('.dt-palette.dt-vertical .dt-btn.dt-keep-text-edit-mode').should("exist");
  }
  verifyDrawToolNotDisplayed(tool) {
    return this.getDrawToolContainer().find("[title^='"+tool+"']").should("not.exist");
  }
  verifyDrawToolDisplayed(tool) {
    return this.getDrawToolContainer().find("[title^='"+tool+"']").should("exist");
  }
}
export default LabbookAuthoringPage;
