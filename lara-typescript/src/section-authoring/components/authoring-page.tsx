import * as React from "react";
import { useState } from "react";
import { usePageAPI } from "../hooks/use-api-provider";
import { useTitle } from "../hooks/use-title";
import { PageNavContainer } from "../containers/page-nav-container";
import { PageSettingsDialog } from "../../page-settings/components/page-settings-dialog";
import { AuthoringSection } from "./authoring-section";
import { SectionMoveDialog } from "./section-move-dialog";
import { ICreatePageItem, IPage, ISection, ISectionItem, ISectionItemType, SectionColumns, SectionLayouts } from "../api/api-types";
import { SectionItemMoveDialog } from "./section-item-move-dialog";
import { ItemEditDialog } from "./item-edit-dialog";
import { DragDropContext, Droppable, Draggable, DropResult } from "react-beautiful-dnd";
import { CompletionPage } from "./completion-page/completion-page";
import { Add } from "../../shared/components/icons/add-icon";
import { Cog } from "../../shared/components/icons/cog-icon";
import { HiddenIcon } from "../../shared/components/icons/hidden-icon";
import { UserInterfaceContext} from "../containers/user-interface-provider";
import { PreviewLinksContainer } from "../containers/preview-links-container";
import { Sidebar } from "./page-sidebar/sidebar";

import "./authoring-page.scss";

export interface IPageProps extends IPage {

  /**
   * Is page hidden from students?
   */
  isHidden?: boolean;

  /**
   * Does page have a student sidebar?
   */
  showSidebar?: boolean;

  /**
   *  Update page when page settings or sections change
   */
  updatePage?: (changes: Partial<IPage>) => void;

  /**
   * Callback to invoke when section has been added
   */
  addSection?: () => void;

  /**
   * Callback to invoke when section has changed
   */
  changeSection?: (changes: {section: Partial<ISection>, sectionID: string}) => void;

  /*
   * Callback to invoke when sections have been rearranged or deleted
   */
  setSections?: (pageData: {id: string, sections: ISection[]}) => void;

  /*
   * Callback to invoke when items have been rearranged or deleted
   */
  setPageItems?: (items: ISectionItem[]) => void;

  /**
   * how to add a new page item
   */
  addPageItem?: (pageItem: ICreatePageItem) => void;
}

/**
 * Primary UI component for user interaction
 */
export const AuthoringPage: React.FC<IPageProps> = ({
  id,
  isNew = false,
  name,
  sections = [],
  addSection,
  changeSection,
  setSections,
  addPageItem,
  isCompletion = false,
  isHidden = false,
  showSidebar = false,
  sidebar = "(content here)",
  sidebarTitle = "Did you know?"
  }: IPageProps) => {

  const [showSettings, setShowSettings] = useState(isNew);
  const { getPages, getItems, updatePage, moveSection } = usePageAPI();
  const updateSettings = (changes: Partial<IPage>) => {
    setShowSettings(false);
    updatePage({ id, ...changes});
  };

 /*
  * Returns reason for disabling completion page checkbox, false otherwise
  */
  const disableCompletionPageSetting = () => {
    if (isCompletion) {
      // Never block authors from turning off the completion page option.
      return false;
    }
    const pages = getPages.data;
    const hasCompletionPage = pages?.find(p => p.isCompletion === true);
    if (hasCompletionPage) {
      return "An activity can only have one completion page";
    }

    const items = getItems();
    if (items.length > 0) {
      return "A completion page has to be empty";
    }

    return false;
  };

  /*
   * Return a new array with array[a] and array[b] swapped.
   */
  const swapIndexes = (array: any[], a: number, b: number) => {
    const bItem = array[b];
    array[b] = array[a];
    array[a] = bItem;
    return [...array];
  };

  /*
   * When a new section is dragged somewhere else:
   */
  const onDragEnd = (e: DropResult) => {
    if (e.destination && e.destination.index !== e.source.index) {
      const nextSections = swapIndexes(sections, e.source.index, e.destination.index);
      if (setSections) {
        setSections({id, sections: nextSections});
      }
    }
  };

  const handleCloseDialog = () => {
    setShowSettings(false);
  };

  const pageSettingsClickHandler = () => { setShowSettings(true); };
  const trimmedName = name?.trim() || "";
  const hasName = trimmedName.length > 0;
  const pageName = hasName ? trimmedName : "(title not set)";
  const displayTitle = hasName ? pageName : <em>{pageName}</em>;
  useTitle("Edit " + pageName);
  return (
    <>
      <PageNavContainer />
      <header className="editPageHeader">
        <h2 data-testid="page-title">Page: {displayTitle}</h2>
        <button
          data-testid="page-settings-button"
          onClick={pageSettingsClickHandler}
        >
          <Cog height="16" width="16" /> Page Settings
        </button>
        <PreviewLinksContainer />
      </header>
      {isHidden &&
        <div className="hiddenPageAlert">
          <HiddenIcon height="20" width="20" /> This page is hidden and will not appear in runtime.
        </div>
      }
      {isCompletion
        ? <CompletionPage />
        : <>
            <DragDropContext onDragEnd={onDragEnd}>
              <Droppable droppableId="droppable">
                {(droppableProvided, snapshot) => (
                <div ref={droppableProvided.innerRef}
                  className="editPageContainer"
                  {...droppableProvided.droppableProps}>
                  {
                    sections.map( (sProps, index) => (
                      <Draggable
                        key={`section-${sProps.id}-${index}-draggable`}
                        draggableId={`section-${sProps.id}-${index}`}
                        index={index}>
                      {
                        (draggableProvided) => (
                          <div
                            {...draggableProvided.draggableProps}
                            ref={draggableProvided.innerRef}>
                              <AuthoringSection {...sProps}
                                draggableProvided={draggableProvided}
                                key={`section-${sProps.id}-${index}`}
                                updateFunction={changeSection}
                                addPageItem={addPageItem}
                              />
                            </div>
                          )
                      }
                      </Draggable>
                    ))
                  }
                  { droppableProvided.placeholder }
                  <button className="bigButton" data-testid="add-section-button" onClick={addSection}>
                    <Add height="16" width="16" /> <span className="lineAdjust">Add Section</span>
                  </button>
                </div>
                )}
              </Droppable>
            </DragDropContext>
            <SectionMoveDialog />
            <SectionItemMoveDialog />
            <ItemEditDialog />
          </>
        }
        {showSettings &&
          <PageSettingsDialog
            name={name}
            isCompletion={isCompletion}
            isHidden={isHidden}
            hasStudentSidebar={showSidebar}
            updateSettingsFunction={updateSettings}
            closeDialogFunction={handleCloseDialog}
            disableCompletionPageSetting={disableCompletionPageSetting()}
          />
        }
        { showSidebar &&
          <Sidebar
            index={1}
            content={sidebar}
            updateSettingsFunction={updateSettings}
            title={sidebarTitle}
          />
        }
    </>
  );
};

export const AuthoringPageUsingAPI = () => {
  const api  = usePageAPI();
  const { addSection, changeSection, updateSections, currentPage, addPageItem } = api;
  const { getPages } = api;
  const { error } = getPages;
  return (
    <>
      {error &&
        <div className="error">
          <h1>
            {error}
          </h1>
        </div>
      }
      { !getPages &&
        <div className="loading">
          <h1>
            Loading ...
          </h1>
        </div>
      }
      { currentPage &&
        <AuthoringPage
          sections={currentPage.sections || []}
          addSection={addSection }
          setSections={updateSections}
          id={currentPage?.id || "none"}
          name={currentPage?.name}
          isCompletion={currentPage?.isCompletion}
          isHidden={currentPage?.isHidden}
          showSidebar={currentPage?.showSidebar}
          sidebar={currentPage?.sidebar}
          sidebarTitle={currentPage?.sidebarTitle}
          changeSection={changeSection}
          addPageItem={addPageItem}
        />
      }
    </>
  );
};
