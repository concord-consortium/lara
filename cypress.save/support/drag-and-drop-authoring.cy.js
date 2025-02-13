class DragAndDropAuthoringPage {
  getEditItemDialog() {
    return cy.get(".modalContainer.itemEditDialog");
  }
  getEditItemForm() {
    return this.getEditItemDialog().find('#itemEditForm');
  }

  getBackgroundImageUrl() {
    return  this.getEditItemForm().find('iframe').then($iframe => {
        const $body = $iframe.contents().find('#app')
              cy.wrap($body).find('#root_backgroundImageUrl');
      });
  }
  clickPlusButton() {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.glyphicon-plus').eq(0).click();
    });
  }
  getImageUrl(index) {
    return  this.getEditItemForm().find('iframe').then($iframe => {
        const $body = $iframe.contents().find('#app')
              cy.wrap($body).find('#root_draggableItems_'+index+'_imageUrl');
      });
  }
//***************************************************************************************************************
  getEditItemPreview() {
    return this.getEditItemDialog().find('.itemEditPreview');
  }
  getItemPreviewDraggableItem(index, item) {
    this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.draggable-item--draggableItem--question-int img').eq(index).invoke("attr", "src").should("contain", item);
    });
  }

//***************************************************************************************************************
  getInteractive() {
    return cy.get(".itemsContainer .sectionItemContainer");
  }
  getDraggableItem(index, item) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.draggable-item--draggableItem--question-int img').eq(index).invoke("attr", "src").should("contain", item);
    });
  }
}
export default DragAndDropAuthoringPage;
