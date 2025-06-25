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
    // Instead of arbitrary wait, wait for the iframe to be loaded
    this.getEditItemForm().find('iframe').should('be.visible').then($iframe => {
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
    return cy.get('.sectionItem')
      .should('exist')
      .first();
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
    return this.getInteractive().within(() => {
      return cy.get('[data-testid^=section-move-button]');
    });
  }
  getSectionMenuCopy() {
    return cy.get('[data-testid^=section-copy-button]');
  }
  getSectionMenuDelete() {
    return this.getInteractive().within(() => {
      return cy.get('[data-testid^=section-delete-button]');
    });
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
            cy.wrap($body).find('[data-testid=lock-answer-button]');
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
  // todo: replace selector with data-testid="section-item-move-dialog"
  // once available in staging
  getMoveModal() {
    // Look for any element containing the move dialog text
    return cy.contains('Move this item to...');
  }
  getMoveModalHeader(header) {
    this.getMoveModal().find('[data-testid=move-modal-header]').should("contain", header);
  }
  getMoveModalClose() {
    return this.getMoveModal().find('[data-testid=move-modal-close]');
  }
  getCopySectionItemHeader(index) {
    return this.getInteractive().eq(index).find(".menuStart");
  }
  getCopySectionMenuDelete(index) {
    return this.getInteractive().eq(index).find(".menuEnd button").eq(4);
  }

  //***************************************************************************************************************
  getAdvancedOptions(){
    //to-do: replace selector with `data-testid` once available in staging
    return cy.get('li.react-tabs__tab[role="tab"][data-rttab="true"]').contains('Advanced Options')
  }
  selectHideQuestionNumber = () => {
    cy.get('input[type="radio"][id="inherit-hide-question-number"]').first().check();
  };
  
  selectCustomizeHideQuestionNumber = () => {
    cy.get('input[type="radio"][id="inherit-hide-question-number"]').last().check();
  };
  //***************************************************************************************************************


  addSection() {
    cy.get('.bigButton .lineAdjust').click();
    // Instead of arbitrary wait, wait for the section to be added
    cy.get("#sections-container .sectionMenu").should('exist');
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
    return this.getActivityActionMenu().find('[data-testid="export-activity-button"] a');
  }
  getActivityConvertMenu() {
    return this.getActivityActionMenu().find('[data-testid="convert-activity-button"] a');
  }
  getActivityCopyMenu() {
    return this.getActivityActionMenu().find('[data-testid="duplicate-activity-button"] a');
  }
  getActivityEditMenu() {
    return this.getActivityActionMenu().find('[data-testid="edit-activity-button"] a');
  }
  getActivityDeleteMenu() {
    return this.getActivityActionMenu().find('[data-testid="delete-activity-button"] a');
  }
  getActivityPublishMenu() {
    return this.getActivityActionMenu().find('[data-testid="publish-activity-button"] a');
  }
  getActivityPrintMenu() {
    return this.getActivityActionMenu().find('[data-testid="print-activity-button"] a');
  }
  getActivityRunMenu() {
    return this.getActivityActionMenu().find('[data-testid="run-activity-button"] a');
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
    // TODO: Update to use data-testid="breadcrumbs-navigation" once it's available on staging
    cy.get('.breadcrumbs a').eq(0).click();
    // Instead of arbitrary wait, wait for the home page to be loaded
    cy.url().should('include', '/');
  }
  searchActivitySequence(name) {
    cy.get('[data-testid="authoring-search-bar"]').type(name);
    cy.get('[data-testid="authoring-search-button"]').click();
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

  getPublishModal() {
    return cy.get('#modal .publication');
  }
  getPublishLink() {
    return this.getPublishModal().find('.info a');
  }
  getPublishStatus(){
    return this.getPublishModal().find('.info .disabled');
  }
  getPublishModelClose() {
    return this.getPublishModal().find('.header .close_link');
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

  // TODO: Update to use data-testid="import-button" once available on staging
  getImportButton() {
    return cy.get('[data-testid="import-button"]');
  }
  
  // TODO: Update to use data-testid="import-modal" once available on staging
  getImportModal() {
    return cy.get('#modal .import_activity_sequence');
  }
  
  // TODO: Update to use data-testid="import-modal-header" once available on staging
  getImportModalHeader(expectedText) {
    return this.getImportModal().find('span.title').should("contain", expectedText);
  }
  
  // TODO: Update to use data-testid="import-file-input" once available on staging
  getImportFile(file) {
    return this.getImportModal().find('#import_import').selectFile(file);
  }
  
  // TODO: Update to use data-testid="import-confirm-button" once available on staging
  getImportModalButton() {
    return this.getImportModal().find('.import');
  }
  
  // TODO: Update to use data-testid="import-modal-close" once available on staging
  getImportModalClose() {
    return this.getImportModal().find('.close_link');
  }
  
  // TODO: Update to use data-testid="import-modal-cancel" once available on staging
  getImportModalCancel() {
    return this.getImportModal().find('a.btn.btn-primary.close');
  }
  
  // TODO: Update to use data-testid="import-modal-message" once available on staging
  getImportModalMessage() {
    return this.getImportModal().find('.message');
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
    // Using data-testid for search functionality
    cy.get('[data-testid="authoring-search-bar"]').type(name);
    cy.get('[data-testid="authoring-search-button"]').click();
    // Instead of arbitrary wait, wait for the search results
    cy.get(".item.community").should('exist');
    // Using data-testid for activity preview link
    cy.get('[data-testid="activity-preview-link"]').click();
    // Instead of arbitrary wait, wait for the preview page to load
    cy.url().should('include', '/preview');
  }
  previewSequence(name) {
    cy.log("Launch Test Sequence : ");
    // Using data-testid for search functionality
    cy.get('[data-testid="authoring-search-bar"]').type(name);
    cy.get('[data-testid="authoring-search-button"]').click();
    // Instead of arbitrary wait, wait for the search results
    cy.get(".quiet_list.sequences").should('exist');
    // TODO: Update to use data-testid="sequence-preview-link" once available in staging
    cy.get(".quiet_list.sequences .action_menu_header_left a").click();
    // Instead of arbitrary wait, wait for the preview page to load
    cy.url().should('include', '/preview');
  }
  launchActivity(name) {
    cy.log("Launch Test Activity : ");
    // Using data-testid for search functionality
    cy.get('[data-testid="authoring-search-bar"]').type(name);
    cy.get('[data-testid="authoring-search-button"]').click();
    // Instead of arbitrary wait, wait for the search results
    cy.get("[id^=item_lightweight_activity]").should('exist');
    // Using data-testid for edit button
    cy.get('[data-testid="edit-activity-button"] a').first().click();
    // Wait for the page to load and verify we're on the edit page
    cy.url().should('include', '/edit');
    // Wait for the page content to load
    cy.get('#rightcol #pages [id^=item_interactive_page]').should('exist');
    // Wait for the add item button to be available and click it
    cy.get('.bigButton .lineAdjust').should('exist').click();
  }
  deleteActivity(name) {
    cy.log("Delete Test Activity : ");
    // Using data-testid for search functionality
    cy.get('[data-testid="authoring-search-bar"]').type(name);
    cy.get('[data-testid="authoring-search-button"]').click();
    // Instead of arbitrary wait, wait for the search results
    cy.get("body").then($body => {
      if ($body.find("[id^=item_lightweight_activity]").length > 0) {
        cy.log("Delete Copy Activity");
        // Using data-testid for delete button
        cy.get('[data-testid="delete-activity-button"]').click();
        // Instead of arbitrary wait, wait for the home page to load
        cy.url().should('include', '/');
      } else {
        cy.log("No Activity To Delete");
      }
    });
  }
  deleteSequence(name) {
    cy.log("Delete Test Sequence : ");
    // TODO: Update to use data-testid="delete-sequence-button" once available in staging
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
