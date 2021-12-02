import * as React from "react";
import { useState } from "react";
import { usePageAPI } from "../hooks/use-api-provider";
import { PageNavContainer } from "../containers/page-nav-container";
import { PageSettingsDialog } from "../../page-settings/components/page-settings-dialog";
import { AuthoringSection } from "./authoring-section";
import { SectionMoveDialog } from "./section-move-dialog";
import { ICreatePageItem, IPage, ISection, ISectionItem, ISectionItemType, SectionColumns } from "../api/api-types";
import { SectionItemMoveDialog } from "./section-item-move-dialog";
import { ItemEditDialog } from "./item-edit-dialog";
import { DragDropContext, Droppable, Draggable, DropResult } from "react-beautiful-dnd";
import { CompletionPage } from "./completion-page/completion-page";
import { Add } from "../../shared/components/icons/add-icon";
import { Cog } from "../../shared/components/icons/cog-icon";

import "./authoring-page.scss";
import { UserInterfaceContext} from "../containers/user-interface-provider";
import { PreviewLinksContainer } from "../containers/preview-links-container";

export interface IPageProps extends IPage {

  /**
   * Is page hidden from students?
   */
  isHidden?: boolean;

  /**
   * Does page have an argumentation block?
   */
  hasArgBlock?: boolean;

  /**
   * Does page have a student sidebar?
   */
  hasStudentSidebar?: boolean;

  /**
   * Does page have a Teacher Edition sidebar?
   */
  hasTESidebar?: boolean;

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
   * Move an item
   */
  itemToMove?: ISectionItem;

  /**
   * Edit an item
   */
  itemToEdit?: ISectionItem;

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
  itemToMove: initItemToMove,
  itemToEdit: initItemToEdit,
  addPageItem,
  isCompletion = false,
  isHidden = false,
  hasArgBlock = false,
  hasStudentSidebar = false,
  hasTESidebar = false
  }: IPageProps) => {

  const [itemToEdit, setItemToEdit] = useState(initItemToEdit);
  const [showSettings, setShowSettings] = useState(isNew);

  const { getItems, updatePage, moveSection } = usePageAPI();

  const updateSettings = (
    updatedTitle: string | undefined,
    updatedIsCompletion: boolean,
    updatedIsHidden: boolean,
    updatedHasArgBlock: boolean,
    updatedHasStudentSidebar: boolean,
    updatedHasTESidebar: boolean
  ) => {
    setShowSettings(false);

    updatePage({ id,
                 name: updatedTitle,
                 isCompletion: updatedIsCompletion,
                 isHidden: updatedIsHidden,
               });
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

  const handleEditItemInit = (itemId: string) => {
    const items = getItems();
    const item = items[items.length - 1];
    if (item) {
      setItemToEdit(item);
    }
  };

  const handleCloseDialog = () => {
    setShowSettings(false);
    setItemToEdit(undefined);
  };

  const pageSettingsClickHandler = () => { setShowSettings(true); };
  const displayTitle = name && name !== "" ? name : <em>(title not set)</em>;

  return (
    <>
      <PageNavContainer />
      <PreviewLinksContainer />
      <header className="editPageHeader">
        <h2>Page: {displayTitle}</h2>
        <button onClick={pageSettingsClickHandler}><Cog height="16" width="16" /> Page Settings</button>
      </header>
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
                                editItemFunction={handleEditItemInit}
                              />
                            </div>
                          )
                      }
                      </Draggable>
                    ))
                  }
                  { droppableProvided.placeholder }
                  <button className="bigButton" onClick={addSection}>
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
            // hasArgBlock={pageHasArgBlock}
            // hasStudentSidebar={pageHasStudentSidebar}
            // hasTESidebar={pageHasTESidebar}
            updateSettingsFunction={updateSettings}
            closeDialogFunction={handleCloseDialog}
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
          changeSection={changeSection}
          addPageItem={addPageItem}
        />
      }
    </>
  );
};
