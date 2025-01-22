class AuthoringPage {
  getAddItem() {
    return cy.get(".editPageContainer .edit-items-container.full-row .lineAdjust");
  }
  getItemPickerSearch() {
    return cy.get("#modalContent #itemPickerSearch input");
  }
  getItemPickerList() {
    return cy.get("#modalContent #itemPickerList li button");
  }
  getAddItemButton() {
    return cy.get("#modalContent .actionButtons .lineAdjust");
  }
  clickAddItem(index) {
    return cy.get(".editPageContainer .edit-items-container.full-row .lineAdjust").eq(index).click();
  }
//*******************************************************************************************
  // NOTE: for the next two helper functions, we will need to add data-testids once the 
  // tags are on staging. For now we will use the HTML in the DOM.
  getPageSettingsButton() {
    return cy.get('header.editPageHeader button').contains('Page Settings');
  }
  checkPageTitle(expectedTitle) {
    return cy.get('header.editPageHeader h2')
      .invoke('text')
      .then((text) => {
        expect(text.trim()).to.eq(`Page: ${expectedTitle}`);
      });
  }
  enterPageTitle(title) {
    return cy.get('.pageSettingsDialog input#pageTitle') // Select the Page Title input
      .clear() // Clear any existing text
      .type(title); // Enter the new title
  }
  clickSaveAndClose() {
    return cy.get('.pageSettingsDialog button.copy') // Select the Save & Close button
      .should('be.visible') // Ensure it's visible
      .click(); // Click the button
  }
  clickCancel() {
    return cy.get('.pageSettingsDialog button.cancel') // Select the Cancel button
      .should('be.visible') // Ensure it's visible
      .click(); // Click the button
  }
//*******************************************************************************************

  getEditItemDialog() {
    return cy.get(".modalContainer.itemEditDialog");
  }
  getCloseButton() {
    return this.getEditItemDialog().find(".modalClose");
  }
  getEditItemForm() {
    return this.getEditItemDialog().find('#itemEditForm');
  }
  getSaveButton() {
    return this.getEditItemForm().find(".actionButtons .save .lineAdjust");
  }
  getCancelButton() {
    return this.getEditItemForm().find(".actionButtons .cancel");
  }
  getNameField() {
    return this.getEditItemForm().find('#name');
  }
  getPromptField(prompt) {
    cy.wait(6000);
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_prompt').type(prompt);
    });
  }
  getHintField(hint) {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_hint').type(hint);
    });
  }
  selectRequiredCheckBox() {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_required').click();
    });
  }
  enterPostSubmissionFeedback(feedback) {
    this.getEditItemForm().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('#root_predictionFeedback').type(feedback);
    });
    // cy.wait(6000);
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
    .should("contain", "Line tool")
    .should("contain", "Basic shape tool")
    .should("contain", "Text tool")
    .should("contain", "Stroke color")
    .should("contain", "Fill color")
    .should("contain", "Stroke width")
    .should("contain", "Clone tool")
    .should("contain", "Send selected objects to back")
    .should("contain", "Send selected objects to front");
  }

  selectHideToolbarButtons(id) {
    this.getHideToolbarButtonsField().find('#root_drawingTools-'+id).click();
  }

//*******************************************************************************************

  getEditItemPreview() {
    return this.getEditItemDialog().find('.itemEditPreview');
  }
  getPrompt(prompt) {
    this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.runtime--prompt--question-int').should("contain", prompt);
    });
  }
  getSubmitButton() {
  return  this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=lock-answer-button]');
    });
  }
  getLockedInfoHeader() {
    return this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.locked-info--header--question-int');
    });
  }
  getLockedInfoFeedback() {
    return this.getEditItemPreview().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.locked-info--feedback--question-int');
    });
  }

  //***************************************************************************************************************

  getInteractive() {
    return cy.get(".itemsContainer .sectionItemContainer");
  }
  getSectionItemHeader() {
    return this.getInteractive().find(".menuStart");
  }
  getSectionMenuCollapse() {
    return this.getInteractive().find(".menuEnd button").eq(0);
  }
  getSectionMenuEdit() {
    return this.getInteractive().find(".menuEnd button").eq(1);
  }
  getSectionMenuMove() {
    return this.getInteractive().find(".menuEnd button").eq(2);
  }
  getSectionMenuCopy() {
    return this.getInteractive().find(".menuEnd button").eq(3);
  }
  getSectionMenuDelete() {
    return this.getInteractive().find(".menuEnd button").eq(4);
  }
  getAuthoringPreviewPrompt(prompt) {
    this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.runtime--prompt--question-int').should("contain", prompt);
    });
  }
  getAuthoringPreviewSubmitButton() {
  return  this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('[data-cy=lock-answer-button]');
    });
  }
  getAuthoringPreviewLockedInfoHeader() {
    return this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.locked-info--header--question-int');
    });
  }
  getAuthoringPreviewLockedInfoFeedback() {
    return this.getInteractive().find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.locked-info--feedback--question-int');
    });
  }
  getMoveModel() {
    return cy.get("#sections-container #modal");
  }
  getMoveModelHeader(header) {
    this.getMoveModel().find('header').should("contain", header);
  }
  getMoveModelClose() {
    return this.getMoveModel().find('.modalClose');
    cy.wait(1000);
  }
  getCopySectionItemHeader() {
    return this.getInteractive().eq(1).find(".menuStart");
  }
  getCopySectionMenuDelete() {
    return this.getInteractive().eq(1).find(".menuEnd button").eq(4);
  }

  //***************************************************************************************************************

  addSection() {
  cy.get('.bigButton .lineAdjust').click();
  cy.wait(4000);
  }
  getSection() {
    return cy.get("#sections-container .sectionMenu");
  }
  getSectionHeader() {
    return this.getSection().find(".menuStart");
  }
  getSectionCollapse() {
    return this.getSection().find(".menuEnd button").eq(0);
  }
  getSectionMove() {
    return this.getSection().find(".menuEnd button").eq(1);
  }
  getSectionCopy() {
    return this.getSection().find(".menuEnd button").eq(2);
  }
  getSectionHide() {
    return this.getSection().find(".menuEnd button").eq(3);
  }
  verfiySectionHidden() {
    cy.get("#sections-container .editPageContainer .edit-page-grid-container.sectionContainer").invoke("attr", "class").should("contain", "hidden");
  }
  verfiySectionShow() {
    cy.get("#sections-container .editPageContainer .edit-page-grid-container.sectionContainer").invoke("attr", "class").should("not.contain", "hidden");
  }
  getSectionDelete() {
    return this.getSection().find(".menuEnd button").eq(4);
  }
  getCopySectionHeader() {
    return this.getSection().eq(1).find(".menuStart");
  }
  getCopySectionDelete() {
    return this.getSection().eq(1).find(".menuEnd button").eq(4);
  }
  getSectionName(index) {
    return this.getSectionHeader().find('.sectionName').eq(index);
  }
  verifySectionName(index, name) {
    this.getSectionName(index).find('h3').should("contain", name);
  }
  checkAndReturnSectionName(index) {
    return this.getSectionName(index)
      .find('h3')
      .invoke('text')
      .then((text) => text.trim()); // Retrieve and return the trimmed text
  }
  clickButton(sectionIndex, buttonIndex) {
    this.getSectionName(sectionIndex).find('button').eq(buttonIndex).click();
  }
  verifyButton(sectionIndex, buttonIndex, name) {
    this.getSectionName(sectionIndex).find('button').eq(buttonIndex).should("contain", name);
  }
  getSectionNameTextBox(index) {
    return this.getSectionName(index).find('input');
  }
  verifyPlaceHolderText(index) {
    this.getSectionNameTextBox(index).invoke("attr", "placeholder").should("contain", "Section name...");
  }


  //***************************************************************************************************************

  getActivity() {
    return cy.get('[id^=item_lightweight_activity]');
  }
  getActivityActionMenu() {
    return this.getActivity().find('.action_menu_header_right');
  }
  getActivityExportMenu() {
    return this.getActivityActionMenu().find('.export a');
  }
  getActivityConvertMenu() {
    return this.getActivityActionMenu().find('.convert a');
  }
  getActivityCopyMenu() {
    return this.getActivityActionMenu().find('.copy a');
  }
  getActivityEditMenu() {
    return this.getActivityActionMenu().find('.edit a');
  }
  getActivityDeleteMenu() {
    return this.getActivityActionMenu().find('.delete a');
  }
  getActivityPublishMenu() {
    return this.getActivityActionMenu().find('.publish a');
  }
  getActivityPrintMenu() {
    return this.getActivityActionMenu().find('.print a');
  }
  getActivityRunMenu() {
    return this.getActivityActionMenu().find('.run a');
  }

  getSequence() {
    return cy.get('[id^=item_sequence]');
  }
  getSequenceActionMenu() {
    return this.getSequence().find('.action_menu_header_right');
  }
  getSequenceExportMenu() {
    return this.getSequenceActionMenu().find('.export a');
  }
  getSequenceConvertMenu() {
    return this.getSequenceActionMenu().find('.convert a');
  }
  getSequenceCopyMenu() {
    return this.getSequenceActionMenu().find('.copy a');
  }
  getSequenceEditMenu() {
    return this.getSequenceActionMenu().find('.edit a');
  }
  getSequenceDeleteMenu() {
    return this.getSequenceActionMenu().find('.delete a');
  }
  getSequencePublishMenu() {
    return this.getSequenceActionMenu().find('.publish a');
  }
  getSequencePrintMenu() {
    return this.getSequenceActionMenu().find('.print a');
  }
  getSequenceRunMenu() {
    return this.getSequenceActionMenu().find('.run a');
  }

  getGlossary() {
    return cy.get('[id^=item_glossary]');
  }
  getGlossaryActionMenu() {
    return this.getGlossary().find('.action_menu_header_right');
  }
  getGlossaryExportMenu() {
    return this.getGlossaryActionMenu().find('.copy a').eq(0);
  }
  getGlossaryCopyMenu() {
    return this.getGlossaryActionMenu().find('.copy a').eq(1);
  }
  getGlossaryEditMenu() {
    return this.getGlossaryActionMenu().find('.edit a');
  }
  getGlossaryDeleteMenu() {
    return this.getGlossaryActionMenu().find('.delete a');
  }

  //***************************************************************************************************************
  clickHomePageLink() {
    cy.get('.breadcrumbs a').eq(0).click();
    cy.wait(2000);
  }
  searchActivitySequence(name) {
    cy.get("#search input").eq(0).type(name);
    cy.get("#search input").eq(1).click();
  }
  getActivityDetails() {
    return this.getActivity().find('[id^=details_lightweight_activity]');
  }
  getActivityDetailAuthor() {
    return this.getActivityDetails().find('.author');
  }
  getActivityDetailUpdated() {
    return this.getActivityDetails().find('.updated');
  }
  getActivityDetailPublished() {
    return this.getActivityDetails().find('.published');
  }
  getActivityDetailPublished() {
    return this.getActivityDetails().find('.published');
  }
  getActivityDetailImage(url) {
    this.getActivityDetails().find('img').invoke("attr", "src").should("contain", url);
  }

  getSequenceDetails() {
    return this.getSequence().find('[id^=details_sequence]');
  }
  getSequenceDetailImage(url) {
    this.getSequenceDetails().find('img').invoke("attr", "src").should("contain", url);
  }

  getPublishModel() {
    return cy.get('#modal .publication');
  }
  getPublishLink() {
    return this.getPublishModel().find('.info a');
  }
  getPublishStatus(){
    return this.getPublishModel().find('.info .disabled');
  }
  getPublishModelClose() {
    return this.getPublishModel().find('.header .close_link');
  }
  //***************************************************************************************************************
  getSettingsPage() {
    return cy.get('#leftcol .sequence_form');
  }
  getSettingsPageSave() {
    return this.getSettingsPage().find('#save-top');
  }
  //***************************************************************************************************************
  selectPreviewIn(value) {
    cy.get('#preview-links-select').select(value);
  }
  getPreviewInButton() {
    return cy.get('#preview-links button');
  }
  getActivityPlayerPreview() {
    cy.get('#preview-links-select option').eq(1).invoke("attr", "value")
    .should("contain", "https://activity-player.concord.org/branch/master/?activity=https%3A%2F%2Fauthoring.lara.staging.concord.org%2Fapi%2Fv1%2Factivities%2F414.json&page=page_1753");
  }
  getActivityPlayerTEPreview() {
    cy.get('#preview-links-select option').eq(2).invoke("attr", "value")
    .should("contain", "https://activity-player.concord.org/branch/master/?activity=https%3A%2F%2Fauthoring.lara.staging.concord.org%2Fapi%2Fv1%2Factivities%2F414.json&page=page_1753&mode=teacher-edition");
  }
  getActivityPlayerRuntimePreview() {
    cy.get('#preview-links-select option').eq(1).invoke("attr", "value")
    .should("contain", "https://activity-player.concord.org/branch/master/?activity=https%3A%2F%2Fauthoring.lara.staging.concord.org%2Fapi%2Fv1%2Factivities%2F212.json&page=page_1372");
  }
  getActivityPlayerRuntimeTEPreview() {
    cy.get('#preview-links-select option').eq(2).invoke("attr", "value")
    .should("contain", "https://activity-player.concord.org/branch/master/?activity=https%3A%2F%2Fauthoring.lara.staging.concord.org%2Fapi%2Fv1%2Factivities%2F212.json&page=page_1372&mode=teacher-edition");
  }
  getActivityLevelPreview() {
    cy.get('#preview-links-select option').eq(1).invoke("attr", "value")
    .should("contain", "https://activity-player.concord.org/branch/master/?activity=https%3A%2F%2Fauthoring.lara.staging.concord.org%2Fapi%2Fv1%2Factivities%2F212.json");
  }
  getActivityLevelTEPreview() {
    cy.get('#preview-links-select option').eq(2).invoke("attr", "value")
    .should("contain", "https://activity-player.concord.org/branch/master/?activity=https%3A%2F%2Fauthoring.lara.staging.concord.org%2Fapi%2Fv1%2Factivities%2F212.json&mode=teacher-edition");
  }
  getActivityRunLinkPreview() {
    this.getActivityRunMenu().invoke("attr", "href")
    .should("contain", "https://activity-player.concord.org/branch/master/?activity=https%3A%2F%2Fauthoring.lara.staging.concord.org%2Fapi%2Fv1%2Factivities%2F212.json&preview");
  }
  getSequenceRunLinkPreview() {
    this.getSequenceRunMenu().invoke("attr", "href")
    .should("contain", "https://activity-player.concord.org/branch/master/?sequence=https%3A%2F%2Fauthoring.lara.staging.concord.org%2Fapi%2Fv1%2Fsequences%2F158.json&preview");
  }

  clickActivityPageLink() {
    cy.get('.breadcrumbs a').eq(2).click();
    cy.wait(2000);
  }

  //***************************************************************************************************************

  selectSharingPlugin() {
    this.getInteractive().find('.availablePlugins [name=embeddable_type]').select("Sharing: Interactives");
  }
  clickAddButton() {
    this.getInteractive().find('.availablePlugins button').click();
    cy.wait(2000);
  }
  getPromptSharingPlugin(prompt) {
    cy.get('.modalContainer.itemEditDialog .authoring-interactive-preview').find('iframe').then($iframe => {
      const $body = $iframe.contents().find('#app')
            cy.wrap($body).find('.runtime--prompt--question-int').should("contain", prompt);
    });
  }
  getPluginDelete() {
    return this.getInteractive().find('.pluginsList button').eq(1);
    cy.wait(2000);
  }

  //***************************************************************************************************************

  getImportButton() {
    return cy.get('#content .top-header .buttons-menu a').eq(3);
  }
  getImportModel() {
    return cy.get('#modal .import_activity_sequence');
  }
  getImportModelHeader() {
    return this.getImportModel().find('.title').should("contain", "Import Activity/Sequence/Glossary");
  }
  getImportFile(file) {
    return this.getImportModel().find('#import_import').selectFile(file);
  }
  getImportModelButton() {
    return this.getImportModel().find('.import');
  }

  getExportModel() {
    return cy.get('#modal .export');
  }
  getExportModelHeader(title) {
    return this.getExportModel().find('.title').should("contain", title);
  }
  getExportModelInfo(info) {
    return this.getExportModel().find('.info').should("contain", info);
  }
  clickExportButton() {
    cy.window().document().then(function (doc) {
    doc.addEventListener('click', () => {
      setTimeout(function () { doc.location.reload() }, 5000)
      })
    cy.get('#modal .export #export').click();
    })
  }
  getExportModelCloseButton() {
    return this.getExportModel().find('.close_link');
  }
  readJsonFile(file, name) {
    cy.readFile(file).its('name').should('eq', name)
  }
  readSequenceJsonFile(file, name) {
    cy.readFile(file).its('title').should('eq', name)
  }
  clickGlossaryExportButton() {
    cy.window().document().then(function (doc) {
    doc.addEventListener('click', () => {
      setTimeout(function () { doc.location.reload() }, 5000)
      })
    cy.get('[id^=item_glossary] .action_menu_header_right .copy a').eq(0).click();
    })
  }

  //***************************************************************************************************************
  previewActivity(name) {
    cy.log("Launch Test Activity : ");
    // to-do: add data-test ID once on staging PT-#188775242
    cy.get("#search input").eq(0).type(name);
    cy.get("#search input").eq(1).click();
    cy.wait(1000);
    cy.get(".item.community .action_menu_header_left a").click();
    cy.wait(2000);
  }
  previewSequence(name) {
    cy.log("Launch Test Sequence : ");
    // to-do: add data-test ID once on staging PT-#188775242
    cy.get("#search input").eq(0).type(name);
    cy.get("#search input").eq(1).click();
    cy.wait(1000);
    cy.get(".quiet_list.sequences .action_menu_header_left a").click();
    cy.wait(2000);
  }
  launchActivity(name) {
    cy.log("Launch Test Activity : ");
    // to-do: add data-test ID once on staging PT-#188775242
    cy.get("#search input").eq(0).type(name); // Type the activity name in the search bar
    cy.get("#search input").eq(1).click(); // Click the search button
    cy.wait(500);
    cy.get(".action_menu_header_right .edit a").click(); // Click "Edit" link in the action menu
    cy.wait(500);
    cy.get('#rightcol #pages [id^=item_interactive_page] .edit').click(); // Open the interactive page for editing
    cy.wait(2000);
  
    // Assert that the activity title exists and matches the provided name
    cy.get('.activity-title') 
      .should('exist') // Ensure the title exists
      .and('be.visible') // Ensure the title is visible
      .and('have.text', name); // Check that the title text matches the activity name passed in
  
    // Additional assertion example for finding text directly using the variable
    cy.contains('div', name) 
      .should('be.visible'); // Ensures the div containing the text is visible
  
    // to-do: replace selectors with `data-testid` once available in staging
  }
  deleteActivity(name) {
    cy.log("Delete Test Activity : ");
    // to-do: add data-test ID once on staging PT-#188775242
    cy.get("#search input").eq(0).type(name);
    cy.get("#search input").eq(1).click();
    cy.wait(1000);
    cy.get("body").then($body => {
      if ($body.find("[id^=item_lightweight_activity]").length > 0) {
        cy.log("Delete Copy Activity");
        cy.get('[id^=item_lightweight_activity] .action_menu_header_right .delete a').click();
        cy.wait(2000);
        cy.get('.breadcrumbs a').click();
        cy.wait(1000);
      } else {
        cy.log("No Activity To Delete");
      }
    });
  }
  deleteSequence(name) {
    cy.log("Delete Test Sequence : ");
    // to-do: add data-test ID once on staging PT-#188775242
    cy.get("#search input").eq(0).type(name);
    cy.get("#search input").eq(1).click();
    cy.wait(1000);
    cy.get("body").then($body => {
      if ($body.find("[id^=item_sequence]").length > 0) {
        cy.log("Delete Copy Sequence");
        cy.get('[id^=item_sequence] .action_menu_header_right .delete a').click();
        cy.wait(2000);
        cy.get('.breadcrumbs a').click();
        cy.wait(1000);
      } else {
        cy.log("No Sequence To Delete");
      }
    });
  }

  //Export to Media
  getEditItemDialog() {
    return cy.get(".modalContainer.itemEditDialog");
  }
  getEditItemForm() {
    return this.getEditItemDialog().find('#itemEditForm');
  }
  getExportToMediaLibrary() {
    return  this.getEditItemForm().find('iframe').then($iframe => {
        const $body = $iframe.contents().find('#app')
              cy.wrap($body).find('#root_exportToMediaLibrary__help').parent();
      });
  }
  verifyExportToMediaLibraryLabel() {
    this.getExportToMediaLibrary().find('.control-label').should("contain", "Export To Media Library");
  }
  getExportToMediaLibraryCheckbox() {
    return this.getExportToMediaLibrary().find('#root_exportToMediaLibrary');
  }
  verifyExportToMediaLibraryCheckboxLabel() {
    this.getExportToMediaLibrary().find('.checkbox label').should("contain", "Export Background Image URL To Media Library");
  }
  verifyExportToMediaLibraryHelpContent() {
    this.getExportToMediaLibrary().find('#root_exportToMediaLibrary__help').should("contain", "Check this option to allow students to select this image in interactives that support image upload");
  }
  verifyExportToMediaLibraryCheckboxChecked() {
    this.getExportToMediaLibraryCheckbox().invoke("attr", "checked").should("exist");
  }
  getUploadFromMediaLibrary() {
    return  this.getEditItemForm().find('iframe').then($iframe => {
        const $body = $iframe.contents().find('#app')
              cy.wrap($body).find('#root_allowUploadFromMediaLibrary__help').parent();
      });
  }
  verifyUploadFromLibraryLabel() {
    this.getUploadFromMediaLibrary().find('.control-label').should("contain", "Upload From Media Library");
  }
  getUploadFromMediaLibraryCheckbox() {
    return this.getUploadFromMediaLibrary().find('#root_allowUploadFromMediaLibrary');
  }
  verifyUploadFromMediaLibraryCheckboxLabel() {
    this.getUploadFromMediaLibrary().find('.checkbox label').should("contain", "Allow Student to Upload from Media Library");
  }
  verifyUploadFromMediaLibraryHelpContent() {
    this.getUploadFromMediaLibrary().find('#root_allowUploadFromMediaLibrary__help').should("contain", "Check this option to allow students to upload images from this activity's Media Library");
  }
  verifyUploadFromMediaLibraryCheckboxChecked() {
    this.getUploadFromMediaLibraryCheckbox().invoke("attr", "checked").should("exist");
  }
  getHideAnnotationTool() {
    return  this.getEditItemForm().find('iframe').then($iframe => {
        const $body = $iframe.contents().find('#app')
              cy.wrap($body).find('#root_hideAnnotationTool').parent().parent().parent();
      });
  }
  verifyHideAnnotationToolLabel() {
    this.getHideAnnotationTool().find('.control-label').should("contain", "Toolbar Modifications");
  }
  getHideAnnotationToolCheckbox() {
    return this.getHideAnnotationTool().find('#root_hideAnnotationTool');
  }
  verifyHideAnnotationToolCheckboxLabel() {
    this.getHideAnnotationTool().find('.checkbox label').should("contain", "Hide Annotation Tool");
  }

}
export default AuthoringPage;
