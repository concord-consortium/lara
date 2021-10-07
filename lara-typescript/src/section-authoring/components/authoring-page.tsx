import * as React from "react";
import { useState } from "react";
import { PageSettingsDialog } from "../../page-settings/components/page-settings-dialog";
import { AuthoringSection } from "./authoring-section";
import { SectionMoveDialog } from "./section-move-dialog";
import { ICreatePageItem, IPage, ISection, ISectionItem, ISectionItemType, SectionColumns } from "../api/api-types";
import { SectionItemMoveDialog } from "./section-item-move-dialog";
import { DragDropContext, Droppable, Draggable, DropResult } from "react-beautiful-dnd";
import { Add } from "../../shared/components/icons/add-icon";
import { Cog } from "../../shared/components/icons/cog-icon";

import "./authoring-page.scss";
import { usePageAPI } from "../api/use-api-provider";
import { UserInterfaceContext, useUserInterface } from "../api/use-user-interface-context";

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

  /**
   * Move a section
   */
  sectionToMove: string|false;

  /*
   * Callback to invoke when items have been rearranged or deleted
   */
  setPageItems?: (items: ISectionItem[]) => void;

  /**
   * Move an item
   */
  itemToMove?: ISectionItem;

  /*
   * List of all section items available
   */
  allEmbeddables?: ISectionItemType[];

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
  title,
  sections = [],
  addSection,
  changeSection,
  setSections,
  sectionToMove,
  itemToMove: initItemToMove,
  allEmbeddables: allEmbeddables,
  addPageItem,
  isCompletion = false,
  isHidden = false,
  hasArgBlock = false,
  hasStudentSidebar = false,
  hasTESidebar = false
  }: IPageProps) => {
  const [pageTitle, setPageTitle] = useState(title);
  const [isCompletionPage, setIsCompletionPage] = useState(isCompletion);
  const [isHiddenPage, setIsHiddenPage] = useState(isHidden);
  const [pageHasArgBlock, setPageHasArgBlock] = useState(hasArgBlock);
  const [pageHasStudentSidebar, setPageHasStudentSidebar] = useState(hasStudentSidebar);
  const [pageHasTESidebar, setPageHasTESidebar] = useState(hasTESidebar);

  const [itemToMove, setItemToMove] = useState(initItemToMove);
  const [showSettings, setShowSettings] = useState(isNew);

  const updateSettings = (
    updatedTitle: string | undefined,
    updatedIsCompletion: boolean,
    updatedIsHidden: boolean,
    updatedHasArgBlock: boolean,
    updatedHasStudentSidebar: boolean,
    updatedHasTESidebar: boolean
  ) => {
    setPageTitle(updatedTitle);
    setIsCompletionPage(updatedIsCompletion);
    setIsHiddenPage(updatedIsHidden);
    setPageHasArgBlock(updatedHasArgBlock);
    setPageHasStudentSidebar(updatedHasStudentSidebar);
    setPageHasTESidebar(updatedHasTESidebar);
    setShowSettings(false);
  };

  const getItems = () => {
    const sectionItems: ISectionItem[][] = sections.map(s => s.items || []) || [];
    // To flatten the nested array of ISectionItems
    return [].concat.apply([], sectionItems) as ISectionItem[];
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

  const handleDelete = (sectionId: string) => {
    if (setSections) {
      const nextSections: ISection[] = [];
      sections.forEach(s => {
        if (s.id !== sectionId) {
          nextSections.push(s);
        }
      });
      const update = { id, sections: nextSections };
      setSections(update);
    }
  };

  const handleCopy = (sectionId: string) => {
    if (setSections) {
      const nextSections: ISection[] = [];
      const copiedSectionIndex = sections.findIndex(i => i.id === sectionId);
      const copiedSection = sections[copiedSectionIndex];
      const newSection = Object.assign({}, copiedSection);
      const newSectionIndex = copiedSectionIndex + 1;
      // ID value should probably be determined some other way once this is integrated into LARA
      newSection.id = (sections.length + 1).toString();
      newSection.position = copiedSection.position ? copiedSection.position++ : undefined;
      const newSectionItems = newSection.items || [];
      newSectionItems.forEach(i => {
        // ID value should probably be determined some other way once this is integrated into LARA
        i.id = i.id + "-copy";
        i.id = newSection.id;
      });

      sections.forEach(s => {
        if (s.position && copiedSection.position && s.position > copiedSection.position) {
          s.position = s.position++;
        }
        nextSections.push(s);
      });
      nextSections.splice(newSectionIndex, 0, newSection);
      const update = { id, sections: nextSections };
      setSections(update);
    }
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

  const handleMoveItemInit = (itemId: string) => {
    const item = getItems().find(i => i.id === itemId);
    if (item) {
      setItemToMove(item);
    }
  };

  const handleMoveItem = (
    itemId: string,
    selectedPageId: string,
    selectedSectionId: string,
    selectedColumn: SectionColumns,
    selectedPosition: string,
    selectedOtherItemId: string
    ) => {
    const items = getItems();
    const itemIndex = items.findIndex(i => i.id === itemId);
    const item = items[itemIndex];
    const otherItemIndex = items.findIndex(i => (i.id === selectedOtherItemId));
    const otherItem = items[otherItemIndex];
    const targetSection = sections.find(s => s.id === selectedSectionId);
    item.column = selectedColumn;
    item.position = otherItem && otherItem.position
                      ? selectedPosition === "after"
                        ? otherItem.position + 1
                        : otherItem.position
                      : 1;
    const newIndex = otherItemIndex
                       ? selectedPosition === "after"
                         ? otherItemIndex + 1
                         : otherItemIndex
                       : 0;
    const updatedItems = targetSection?.items;
    updatedItems?.splice(itemIndex, 1);
    updatedItems?.splice(newIndex, 0, item);
    let sectionItemsCount = 0;
    updatedItems?.forEach((i, index) => {
      sectionItemsCount++;
      if (index > newIndex) {
        updatedItems[index].position = sectionItemsCount;
      }
    });
    // setItems(updatedItems);
    if (targetSection) {
      targetSection.items = updatedItems;
    }
    if (setSections) {
      setSections({ id, sections });
    }
  };

  const handleCloseDialog = () => {
    setShowSettings(false);
    setItemToMove(undefined);
  };

  const pageSettingsClickHandler = () => { setShowSettings(true); };
  const displayTitle = pageTitle && pageTitle !== "" ? pageTitle : <em>(title not set)</em>;

  return (
    <>
      <header className="editPageHeader">
        <h2>Page: {displayTitle}</h2>
        <button onClick={pageSettingsClickHandler}><Cog height="16" width="16" /> Page Settings</button>
      </header>
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
                            deleteFunction={handleDelete}
                            copyFunction={handleCopy}
                            addPageItem={addPageItem}
                            moveItemFunction={handleMoveItemInit}
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
      {showSettings &&
        <PageSettingsDialog
          title={pageTitle}
          isCompletion={isCompletionPage}
          isHidden={isHiddenPage}
          hasArgBlock={pageHasArgBlock}
          hasStudentSidebar={pageHasStudentSidebar}
          hasTESidebar={pageHasTESidebar}
          updateSettingsFunction={updateSettings}
          closeDialogFunction={handleCloseDialog}
        />
      }
      <div> Section To Move: {sectionToMove}</div>
      {sectionToMove &&
        <SectionMoveDialog
          sectionId={sectionToMove}
          sections={sections}
        />
      }
      {itemToMove &&
        <SectionItemMoveDialog
          item={itemToMove}
          sections={sections}
          moveFunction={handleMoveItem}
          closeDialogFunction={handleCloseDialog}
        />
      }
    </>
  );
};

export const AuthoringPageUsingAPI = () => {
  const api = usePageAPI();
  const {userInterface} = React.useContext(UserInterfaceContext);

  const pages = api.getPages.data;
  if (pages) {
    // TODO: we will want to rebind this when we support navigation
    const currentPage = pages[0];

    const addSection = () => api.addSectionMutation.mutate(currentPage.id);
    const changeSection = (changes: {
      section: Partial<ISection>,
      sectionID: string}) => api.updateSection.mutate({pageId: currentPage.id, changes});

    const addPageItem = (pageItem: ICreatePageItem) =>
      api.createPageItem.mutate({pageId: currentPage.id, newPageItem: pageItem});

    return (
      <>
        <AuthoringPage
          sections={currentPage?.sections}
          addSection={addSection }
          setSections={api.updateSections}
          sectionToMove={userInterface.movingSectionId}
          id={currentPage.id}
          changeSection={changeSection}
          addPageItem={addPageItem}
        />
      </>
    );
  }
  else {
    return (
      <div>loading ...</div>
    );
  }
};
