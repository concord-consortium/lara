import * as React from "react";
import { useState } from "react";
import { SectionItem, ISectionItemProps} from "./section-item";
import { absorbClickThen } from "../../shared/absorb-click";
import { ICreatePageItem, ISectionItem } from "../api/api-types";
import { DragDropContext, Droppable, Draggable, DropResult, DraggableProvided } from "react-beautiful-dnd";
import { Add } from "../../shared/components/icons/add-icon";

import "./section-column.scss";

export interface ISectionColumnProps {

  addItem: (sectionCol: number) => void;

  addPageItem?: (pageItem: ICreatePageItem) => void;

  /**
   * A class name for the column
   */
  className: string;

  /**
   * The index of the column, 1 or 2
   */
  columnIndex: number;

  /**
   * DraggingContext
   */
  draggableProvided?: DraggableProvided;

  /*
   * List of all items in the column
   */
  items: ISectionItemProps[];

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
  columnIndex,
  draggableProvided,
  items,
  moveFunction,
  sectionId,
  updatePageItems
  }: ISectionColumnProps) => {

  // const [updatedItems, setUpdatedItems] = useState([...items]);
  const [showAddItem, setShowAddItem] = useState(false);

  // React.useEffect(() => {
  //   updatePageItems?.(updatedItems, sectionId);
  // }, [updatedItems]);

  const swapIndexes = (array: any[], a: number, b: number) => {
    console.log(array);
    console.log(a);
    console.log(b);
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
    let nextItems = [];
    if (e.source.droppableId !== e.destination.droppableId) {
      // items[e.source.index].section_col = items[e.source.index].section_col === 0 ? 1 : 0;
      // disallow cross column reordering for now
      return;
    }
    if (e.destination && e.destination.index !== e.source.index) {
      nextItems = swapIndexes(items, e.source.index, e.destination.index);
    }
    console.log("These should be 1 and 0 after swap.");
    console.log(nextItems);
    updatePageItems?.(nextItems, sectionId);
  };

  const handleMoveItem = (itemId: string) => {
    moveFunction?.(itemId);
  };

  const handleCopyItem = (itemId: string) => {
    const item = items.find(i => i.id === itemId);
    if (item) {
      addItem(item.section_col || 0);
    }
  };

  const handleDeleteItem = (itemId: string) => {
    const nextItems: ISectionItemProps[] = [];
    items.forEach(i => {
      if (i.id !== itemId) {
        nextItems.push(i);
      }
    });
    updatePageItems?.(nextItems, sectionId);
  };

  const handleToggleShowAddItem = () => setShowAddItem((prev) => !prev);
  const handleShowAddItem = absorbClickThen(handleToggleShowAddItem);

  const handleAddItem = (itemId: string) => {
    addPageItem?.({
      section_id: sectionId,
      embeddable: itemId
    });
    handleToggleShowAddItem();
  };

  const addItemHandler = () => addItem(columnIndex);

  if (sectionId === "1" && columnIndex === 2) {
    console.log("SectionColumn items");
    console.log(items);
  }

  return (
    <>
      <DragDropContext onDragEnd={onDragEnd}>
        <div className={`edit-page-grid-container col-${columnIndex} ${className}`}>
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
                        key={`col-${columnIndex}-item-${index}`}
                        draggableId={`col-${columnIndex}-item-${index}`}
                        index={item.position - 1}
                      >
                        {(draggableProvidedColOne) => (
                          <div
                            className="sectionItem"
                            key={`col-${columnIndex}-item-inner-${index}`}
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
                  <button className="smallButton" onClick={addItemHandler}>
                    <Add height="16" width="16" /> <span className="lineAdjust">Add Item</span>
                  </button>
                </div>
              </div>
          )}
          </Droppable>
        </div>
      </DragDropContext>
    </>
  );
};
