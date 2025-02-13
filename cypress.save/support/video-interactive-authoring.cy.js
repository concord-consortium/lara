class VideoInteractiveAuthoringPage {
  getEditItemDialog() {
    return cy.get(".modalContainer.itemEditDialog");
  }

  getEditItemForm() {
    return this.getEditItemDialog().find('#itemEditForm');
  }

  getEditItemPreview() {
    return this.getEditItemDialog().find('.itemEditPreview');
  }
  getVideoURLField(url) {
    cy.wait(500);
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_videoUrl').type(url);
    });
  }
  getVideoCaptionURLField(url) {
    cy.wait(500);
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_captionUrl').type(url);
    });
  }
  getDescriptionField(altText) {
    cy.wait(500);
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_prompt').type(altText);
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
  
//***************************************************************************************************************

  getInteractive() {
    return cy.get(".itemsContainer .sectionItemContainer");
  }
  verifyAuthoringPreviewVideo(video) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.base-app--runtime--question-int video').invoke("attr", "src").should("contain", video)
    });
  }
  getAuthoringPreviewPlayButton() {
    return this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.base-app--runtime--question-int .vjs-big-play-button');
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
  verifyAuthoringPreviewDescription(description) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.runtime--prompt--question-int').should("contain", description);
    });
  }
  
  //***************************************************************************************************************

  getEditItemPreview() {
    return this.getEditItemDialog().find('.itemEditPreview');
  }

  verifyEditItemPreviewVideo(video) {
    this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.base-app--runtime--question-int video').invoke("attr", "src").should("contain", video)
    });
  }
  getEditItemPreviewPlayButton() {
    return this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.base-app--runtime--question-int .vjs-big-play-button');
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
  verifyEditItemPreviewDescription(description) {
    this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.runtime--prompt--question-int').should("contain", description);
    });
  }
  

}
export default VideoInteractiveAuthoringPage;
