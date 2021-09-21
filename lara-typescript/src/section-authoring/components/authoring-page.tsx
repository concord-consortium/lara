import React, { useState } from "react";
import { AuthoringSection, ISectionProps } from "./authoring-section";
import { ISectionItemProps } from "./section-item";
import { SectionItemMoveDialog } from "./section-item-move-dialog";
import { DragDropContext, Droppable, Draggable, DropResult } from "react-beautiful-dnd";
import { ISectionItem } from "./section-item-picker";
import { ICreatePageItem } from "./query-bound-page";

import "./authoring-page.css";

export interface IPageProps {

  /**
   * Record ID
   */
  id: string;

  /**
   * Optional title for the page
   */
  title?: string;

  /**
   * Sections on this page:
   */
  sections: ISectionProps[];

  /**
   * Is page a completion page?
   */
  is_completion: boolean;

  /**
   * Func to add a new section:
   */
  addSection?: () => void;

  /**
   * Func to update a section.
   */
  changeSection?: (changes: {section: Partial<ISectionProps>, sectionID: string}) => void;

  /*
   * Callback to invoke when sections have been rearranged or deleted
   */
  setSections?: (pageData: {id: string, sections: ISectionProps[]}) => void;

  /**
   * Items on this page:
   */
  items?: ISectionItemProps[];

  /*
   * Callback to invoke when items have been rearranged or deleted
   */
  setPageItems?: (items: ISectionItemProps[]) => void;

  /**
   * Move an item
   */
  itemToMove?: ISectionItemProps;

  /*
   * List of all section items available
   */
  allSectionItems?: ISectionItem[];

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
  sections = [],
  addSection,
  changeSection,
  setSections,
  items: initItems = [] as ISectionItemProps[],
  itemToMove: initItemToMove,
  allSectionItems,
  addPageItem
  }: IPageProps) => {

  const [itemToMove, setItemToMove] = useState(initItemToMove);
  const [items, setItems] = useState([...initItems]);

  const updateSectionItems = (newItems: ISectionItemProps[], sectionId: string) => {
    const sectionIndex = sections.findIndex(i => i.id === sectionId);
    sections[sectionIndex].items = newItems;
    const updatedItems = [] as ISectionItemProps[];
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

  const handleDelete = (sectionId: string) => {
    if (setSections) {
      const nextSections: ISectionProps[] = [];
      sections.forEach(s => {
        if (s.id !== sectionId) {
          nextSections.push(s);
        }
      });
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
    const itemToMoveIndex = items.findIndex(i => i.id === itemId);
    const itemToMove = items[itemToMoveIndex];
    const otherItemIndex = items.findIndex(i => (i.id === selectedOtherItemId && i.section_id === selectedSectionId));
    const otherItem = items[otherItemIndex];
    itemToMove.section_id = selectedSectionId;
    itemToMove.section_col = selectedColumn;
    itemToMove.position = otherItem ? otherItem.position : 1;
    const newIndex = otherItemIndex
                       ? selectedPosition === "after"
                         ? otherItemIndex + 1
                         : otherItemIndex - 1
                       : 0;
    const updatedItems = items;
    updatedItems.splice(itemToMoveIndex, 1);
    updatedItems.splice(newIndex, 0, itemToMove);
    let sectionItemsCount = 0;
    updatedItems.forEach((i, index) => {
      if (otherItem && i.section_id === otherItem.section_id) {
        updatedItems[index].position = ++sectionItemsCount;
      }
    });
    setItems(updatedItems);
    sections.forEach((s, index) => {
      sections[index].items = items.filter(i => i.section_id === s.id);
    });
    if (setSections) {
      setSections({ id, sections });
    }
  };

  const handleCloseMoveItemDialog = () => {
    setItemToMove(undefined);
  };

  return (
    <>
      <DragDropContext onDragEnd={onDragEnd}>
        <Droppable droppableId="droppable">
          {(droppableProvided, snapshot) => (
            <div ref={droppableProvided.innerRef}
              className="edit-page-container"
              {...droppableProvided.droppableProps}>
              {
                sections.map( (sProps, index) => (
                  <Draggable
                    key={sProps.id}
                    draggableId={sProps.id}
                    index={index}>
                  {
                    (draggableProvided) => (
                      <div
                        {...draggableProvided.draggableProps}
                        ref={draggableProvided.innerRef}>
                          <AuthoringSection {...sProps}
                            draggableProvided={draggableProvided}
                            key={sProps.id}
                            updateFunction={changeSection}
                            deleteFunction={handleDelete}
                            allSectionItems={allSectionItems}
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
              <button className="big-button" onClick={addSection}>
                + Add Section
              </button>
            </div>
          )}
        </Droppable>
      </DragDropContext>
      {itemToMove &&
        <SectionItemMoveDialog
          item={itemToMove}
          sections={sections}
          moveItemFunction={handleMoveItem}
          closeDialogFunction={handleCloseMoveItemDialog}
        />
      }
    </>
  );
};
