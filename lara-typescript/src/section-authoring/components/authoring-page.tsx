import * as React from "react";
import { useState } from "react";
import { PageSettingsDialog } from "../../page-settings/components/page-settings-dialog";
import { AuthoringSection, ISectionProps } from "./authoring-section";
import { SectionMoveDialog } from "./section-move-dialog";
import { ICreatePageItem, IPage, ISection, ISectionItem} from "../api/api-types";
import { SectionItemMoveDialog } from "./section-item-move-dialog";
import { DragDropContext, Droppable, Draggable, DropResult } from "react-beautiful-dnd";
import { Add } from "../../shared/components/icons/add-icon";
import { Cog } from "../../shared/components/icons/cog-icon";

import "./authoring-page.scss";

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
  sectionToMove?: ISection;

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
  allEmbeddables?: ISectionItem[];

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
  sectionToMove: initSectionToMove,
  items: initItems = [] as ISectionItem[],
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
  const [sectionToMove, setSectionToMove] = useState(initSectionToMove);
  const [itemToMove, setItemToMove] = useState(initItemToMove);
  const [items, setItems] = useState([...initItems]);
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

  const updateSectionItems = (newItems: ISectionItem[], sectionId: string) => {
    console.log("root updateSectionItems triggered");
    console.log(newItems);
    const sectionIndex = sections.findIndex(i => i.id === sectionId);
    sections[sectionIndex].items = newItems;
    const updatedItems = [] as ISectionItem[];
    sections.forEach((s) => {
      if (s.items) {
        s.items.forEach((i) => {
          updatedItems.push(i);
        });
      }
    });
    setItems(updatedItems);
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

  const handleMoveSectionInit = (sectionId: string) => {
    const section = sections.find(s => s.id === sectionId);
    if (section) {
      setSectionToMove(section);
    }
  };

  const handleMoveSection = (
    sectionId: string,
    selectedPageId: string,
    selectedPosition: string,
    selectedOtherSectionId: string
    ) => {
    const sectionIndex = sections.findIndex(s => s.id === sectionId);
    const section = sections[sectionIndex];
    const otherSectionIndex = sections.findIndex(s => s.id === selectedOtherSectionId);
    const otherSection = sections[otherSectionIndex];
    const newIndex = otherSectionIndex
                       ? selectedPosition === "after"
                         ? otherSectionIndex + 1
                         : otherSectionIndex - 1
                       : 0;
    const updatedSections = sections;
    updatedSections.splice(sectionIndex, 1);
    updatedSections.splice(newIndex, 0, section);
    let sectionsCount = 0;
    updatedSections.forEach((s, index) => {
      if (otherSection) {
        updatedSections[index].position = ++sectionsCount;
      }
    });
    if (setSections && updatedSections) {
      setSections({id, sections: updatedSections});
    }
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
    const item = items.find(i => i.id === itemId);
    if (item) {
      setItemToMove(item);
    }
  };

  const handleMoveItem = (
    itemId: string,
    selectedPageId: string,
    selectedSectionId: string,
    selectedColumn: number,
    selectedPosition: string,
    selectedOtherItemId: string
    ) => {
    const itemIndex = items.findIndex(i => i.id === itemId);
    const item = items[itemIndex];
    const otherItemIndex = items.findIndex(i => (i.id === selectedOtherItemId && i.id === selectedSectionId));
    const otherItem = items[otherItemIndex];
    item.id = selectedSectionId;
    item.section_col = selectedColumn;
    item.position = otherItem ? otherItem.position : 1;
    const newIndex = otherItemIndex
                       ? selectedPosition === "after"
                         ? otherItemIndex + 1
                         : otherItemIndex - 1
                       : 0;
    const updatedItems = items;
    updatedItems.splice(itemIndex, 1);
    updatedItems.splice(newIndex, 0, item);
    let sectionItemsCount = 0;
    updatedItems.forEach((i, index) => {
      if (otherItem && i.id === otherItem.id) {
        updatedItems[index].position = ++sectionItemsCount;
      }
    });
    setItems(updatedItems);
    sections.forEach((s, index) => {
      sections[index].items = items.filter(i => i.id === s.id);
    });
    if (setSections) {
      setSections({ id, sections });
    }
  };

  const handleCloseDialog = () => {
    setShowSettings(false);
    setSectionToMove(undefined);
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
                            moveFunction={handleMoveSectionInit}
                            deleteFunction={handleDelete}
                            copyFunction={handleCopy}
                            allEmbeddables={allEmbeddables}
                            items={items}
                            addPageItem={addPageItem}
                            moveItemFunction={handleMoveItemInit}
                            updatePageItems={updateSectionItems} />
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
      {sectionToMove &&
        <SectionMoveDialog
          sectionId={sectionToMove.id}
          sections={sections}
          moveFunction={handleMoveSection}
          closeDialogFunction={handleCloseDialog}
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
