class SensorInteractiveAuthoringPage {
  getEditItemDialog() {
    return cy.get(".modalContainer.itemEditDialog");
  }
  getEditItemForm() {
    return this.getEditItemDialog().find('#itemEditForm');
  }

  getPromptField(prompt) {
    cy.wait(6000);
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#prompt').type(prompt);
    });
  }

  clickFakeSensorCheckbox() {
    return  this.getEditItemForm().find('iframe').then($iframe => {
        const $body = $iframe.contents().find('#app')
              cy.wrap($body).find('.authoring [type="checkbox"]').eq(1).click();
      });
  }

  clickPredictDataCheckbox() {
    return  this.getEditItemForm().find('iframe').then($iframe => {
        const $body = $iframe.contents().find('#app')
              cy.wrap($body).find('.authoring [type="checkbox"]').eq(5).click();
      });
  }

//***************************************************************************************************************
  getEditItemPreview() {
    return this.getEditItemDialog().find('.itemEditPreview');
  }
  getItemPreviewSensorGraph() {
    this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#sensor-graph-graph1').should("exist");
    });
  }
  getItemPreviewRescaleButton() {
    this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.graph-rescale-button').should("exist");
    });
  }

//***************************************************************************************************************
  getInteractive() {
    return cy.get(".itemsContainer .sectionItemContainer");
  }
  getSensorGraph() {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#sensor-graph-graph1').should("exist");
    });
  }
  getRescaleButton() {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.graph-rescale-button').should("exist");
    });
  }
}
export default SensorInteractiveAuthoringPage;
