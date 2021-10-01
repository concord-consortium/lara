import * as React from "react";
import { useState } from "react";
import { SectionItem, ISectionItemProps} from "./section-item";
import { absorbClickThen } from "../../shared/absorb-click";
import { ICreatePageItem, ISection, ISectionItem, SectionColumns } from "../api/api-types";
import { DragDropContext, Droppable, Draggable, DropResult, DraggableProvided } from "react-beautiful-dnd";
import { Add } from "../../shared/components/icons/add-icon";

import "./section-column.scss";
import { SectionItemPicker } from "./section-item-picker";
import { usePageAPI } from "../api/use-api-provider";

export interface ISectionColumnProps {

  addItem: (column: SectionColumns) => void;

  addPageItem?: (pageItem: ICreatePageItem) => void;

  /**
   * A class name for the column
   */
  className: string;

  /**
   * primary or secondary (large/small)
   */
  column: SectionColumns;

  /**
   * The 1-based index of the column
   */
  columnNumber: number;

  /**
   * DraggingContext
   */
  draggableProvided?: DraggableProvided;

  /*
   * List of all items in the column
   */
  items: ISection[];

  /**
   * Function to move an item
   */
  moveFunction?: (id: string) => void;

  /**
   * The ID of the column's parent section
   */
  sectionId: string;

  /**
   * Optional function to update section items
   */
  updatePageItems?: (items: ISectionItem[], sectionId: string) => void;

}

export const SectionColumn: React.FC<ISectionColumnProps> = ({
  addItem,
  addPageItem,
  className,
  column,
  columnNumber,
  draggableProvided,
  items,
  moveFunction,
  sectionId
  }: ISectionColumnProps) => {

  const api = usePageAPI();
  const updateSectionItems = api.updateSectionItems;

  const [showAddItem, setShowAddItem] = useState(false);

  const swapIndexes = (array: any[], a: number, b: number) => {
    const aItem = array[a];
    const bItem = array[b];
    const aPos = aItem.position;
    const bPos = bItem.position;
    aItem.position = bPos;
    bItem.position = aPos;
    array[b] = aItem;
    array[a] = bItem;
    return [...array];
  };

  const onDragEnd = (e: DropResult) => {
    if (!e.destination) {
      return;
    }
    let nextItems: ISection[]  = [];
    if (e.source.droppableId !== e.destination.droppableId) {
      // items[e.source.index].section_col = items[e.source.index].section_col === 0 ? 1 : 0;
      // disallow cross column reordering for now
      return;
    }
    if (e.destination && e.destination.index !== e.source.index) {
      nextItems = swapIndexes(items, e.source.index, e.destination.index);
    }
    updateSectionItems({sectionId, newItems: nextItems});
  };

  const handleMoveItem = (itemId: string) => {
    moveFunction?.(itemId);
  };

  const handleCopyItem = (itemId: string) => {
    const item = items.find(i => i.id === itemId);
    if (item) {
      addItem(column);
    }
  };

  const handleDeleteItem = (itemId: string) => {
    const nextItems: ISectionItemProps[] = [];
    items.forEach(i => {
      if (i.id !== itemId) {
        nextItems.push(i);
      }
    });
    updateSectionItems({sectionId, newItems: nextItems});
  };

  const handleToggleShowAddItem = () => setShowAddItem((prev) => !prev);
  const handleShowAddItem = absorbClickThen(handleToggleShowAddItem);

  const handleAddItem = (itemId: string) => {
    addPageItem?.({
      section_id: sectionId,
      embeddable: itemId,
      column
    });
    handleToggleShowAddItem();
  };
  const showItemPicker = () => setShowAddItem(true);

  return (
    <>
      <DragDropContext onDragEnd={onDragEnd}>
        <div className={`edit-page-grid-container col-${columnNumber} ${className}`}>
          <Droppable droppableId="droppableCol1">
            {(droppableProvided) => (
              <div
                ref={droppableProvided.innerRef}
                className="edit-items-container full-row"
                {...droppableProvided.droppableProps}
              >
                <div className="itemsContainer">
                  { items
                    && items.length > 0
                    && items.map((item, index) => {
                    return (
                      <Draggable
                        key={`col-${columnNumber}-item-${index}`}
                        draggableId={`col-${columnNumber}-item-${index}`}
                        index={(item.position || 0) - 1}
                      >
                        {(draggableProvidedColOne) => (
                          <div
                            className="sectionItem"
                            key={`col-${columnNumber}-item-inner-${index}`}
                            {...draggableProvidedColOne.draggableProps}
                            {...draggableProvidedColOne.dragHandleProps}
                            ref={draggableProvidedColOne.innerRef}
                          >
                            <SectionItem
                              {...item}
                              key={item.id}
                              moveFunction={handleMoveItem}
                              copyFunction={handleCopyItem}
                              deleteFunction={handleDeleteItem}
                            />
                          </div>
                        )}
                      </Draggable>
                    );
                  })}
                  { droppableProvided.placeholder }
                  <button className="smallButton" onClick={showItemPicker}>
                    <Add height="16" width="16" /> <span className="lineAdjust">Add Item</span>
                  </button>
                </div>
              </div>
          )}
          </Droppable>
        </div>
      </DragDropContext>
      { showAddItem &&
        <SectionItemPicker
          onClose={handleToggleShowAddItem}
          onAdd={handleAddItem}
        />
      }
    </>
  );
};
