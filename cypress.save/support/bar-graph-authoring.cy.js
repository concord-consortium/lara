class BarGraphAuthoringPage {
  getEditItemDialog() {
    return cy.get(".modalContainer.itemEditDialog");
  }

  getEditItemForm() {
    return this.getEditItemDialog().find('#itemEditForm');
  }

  getEditItemPreview() {
    return this.getEditItemDialog().find('.itemEditPreview');
  }
  getGraphTitleField(title) {
    cy.wait(500);
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_title').type(title);
    });
  }
  getXAxisLabelField(label) {
    cy.wait(500);
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_xAxisLabel').type(label);
    });
  }
  getYAxisLabelField(label) {
    cy.wait(500);
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_yAxisLabel').type(label);
    });
  }
  getShowValuesAboveBarsCheckbox() {
    cy.wait(500);
    return this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_showValuesAboveBars');
    });
  }
  getBarsAddButton() {
    cy.wait(500);
    return this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_bars .btn-add');
    });
  }
  getBarLabel(index, label) {
    cy.wait(500);
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_bars_'+index+'_label').type(label);
    });
  }
  getBarValue(index, value) {
    cy.wait(500);
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_bars_'+index+'_value').type(value);
    });
  }
  
//***************************************************************************************************************

  getInteractive() {
    return cy.get(".itemsContainer .sectionItemContainer");
  }
  verifyAuthoringPreviewPrompt(prompt) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.base-app--runtime--question-int').should("contain", prompt);
    });
  }
  verifyAuthoringPreviewTitle(title) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=title]').should("contain", title);
    });
  }
  verifyAuthoringPreviewXAxisLabel(label) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=xAxisLabel]').should("contain", label);
    });
  }
  verifyAuthoringPreviewYAxisLabel(label) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=yAxisLabel]').should("contain", label);
    });
  }
  verifyAuthoringPreviewBarValue(index, value) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=barValue'+index+']').should("contain", value);
    });
  }
  
  //***************************************************************************************************************

  getEditItemPreview() {
    return this.getEditItemDialog().find('.itemEditPreview');
  }

  verifyEditItemPreviewPrompt(prompt) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.base-app--runtime--question-int').should("contain", prompt);
    });
  }
  verifyEditItemPreviewTitle(title) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=title]').should("contain", title);
    });
  }
  verifyEditItemPreviewXAxisLabel(label) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=xAxisLabel]').should("contain", label);
    });
  }
  verifyEditItemPreviewYAxisLabel(label) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=yAxisLabel]').should("contain", label);
    });
  }
  verifyEditItemPreviewBarValue(index, value) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=barValue'+index+']').should("contain", value);
    });
  }
  

}
export default BarGraphAuthoringPage;
