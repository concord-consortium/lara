class ImageInteractiveAuthoringPage {
  getEditItemDialog() {
    return cy.get(".modalContainer.itemEditDialog");
  }

  getEditItemForm() {
    return this.getEditItemDialog().find('#itemEditForm');
  }

  getEditItemPreview() {
    return this.getEditItemDialog().find('.itemEditPreview');
  }
  getURLField(url) {
    cy.wait(500);
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_url').type(url);
    });
  }
  getAltTextField(altText) {
    cy.wait(500);
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_altText').type(altText);
    });
  }
  getCaptionField(caption) {
    cy.wait(500);
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_caption').type(caption);
    });
  }
  getCreditField(credit) {
    cy.wait(500);
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_credit').type(credit);
    });
  }
  getExportToMediaLibraryCheckbox() {
    cy.wait(500);
    return this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_exportToMediaLibrary');
    });
  }
  
//***************************************************************************************************************

  getInteractive() {
    return cy.get(".itemsContainer .sectionItemContainer");
  }
  verifyAuthoringPreviewImage(image) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.base-app--runtime--question-int img').invoke("attr", "src").should("contain", image)
    });
  }
  verifyAuthoringPreviewImageAltText(altText) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.base-app--runtime--question-int img').invoke("attr", "title").should("contain", altText)
    });
  }
  verifyAuthoringPreviewCaption(caption) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.runtime--caption--question-int').should("contain", caption);
    });
  }
  verifyAuthoringPreviewCredit(credit) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.runtime--credit--question-int').should("contain", credit);
    });
  }
  getZoomInIcon() {
    return this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.runtime--viewHighRes--question-int');
    });
  }
  
  //***************************************************************************************************************

  getEditItemPreview() {
    return this.getEditItemDialog().find('.itemEditPreview');
  }

  verifyEditItemPreviewImage(image) {
    this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.base-app--runtime--question-int img').invoke("attr", "src").should("contain", image)
    });
  }
  verifyEditItemPreviewImageAltText(altText) {
    this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.base-app--runtime--question-int img').invoke("attr", "title").should("contain", altText)
    });
  }
  verifyEditItemPreviewCaption(caption) {
    this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.runtime--caption--question-int').should("contain", caption);
    });
  }
  verifyEditItemPreviewCredit(credit) {
    this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.runtime--credit--question-int').should("contain", credit);
    });
  }
  getEditItemZoomInIcon() {
    return this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.runtime--viewHighRes--question-int');
    });
  }
  

}
export default ImageInteractiveAuthoringPage;
