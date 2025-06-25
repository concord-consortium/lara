class TextBlockAuthoringPage {
  getTextBlockQuickAddButton() {
    return cy.get("#quickAddMenu .assessmentItemOption").eq(1);
  }
  getEditItemDialog() {
    return cy.get(".modalContainer.itemEditDialog");
  }
  getEditItemForm() {
    return this.getEditItemDialog().find('#itemEditForm');
  }
  getHeadingField() {
    return this.getEditItemForm().find('#name');
  }
  getContentField(content) {
    cy.wait(6000);
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents()
            cy.wrap($body).find('#tinymce').type(content);
    });
  }
//***************************************************************************************************************
  getEditItemPreview() {
    return this.getEditItemDialog().find('.itemEditPreview');
  }
  getTextBlock() {
    return this.getEditItemPreview().find(".textBlock.callout");
  }
  getTextBlockName() {
    return this.getTextBlock().find(".textBlockName");
  }
  getTextBlockContent() {
    return this.getTextBlock().find(".textBlockContent");
  }

//***************************************************************************************************************
  getInteractive() {
    return cy.get(".itemsContainer .sectionItemContainer");
  }
  getAuthoringPreviewTextBlock() {
    return this.getInteractive().find(".textBlock.callout");
  }
  getAuthoringPreviewTextBlockName() {
    return this.getAuthoringPreviewTextBlock().find(".textBlockName");
  }
  getAuthoringPreviewTextBlockContent() {
    return this.getAuthoringPreviewTextBlock().find(".textBlockContent");
  }

}
export default TextBlockAuthoringPage;
