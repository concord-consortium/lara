import * as React from "react";
import { useState } from "react";
import { SectionItem, ISectionItemProps} from "./section-item";
import { absorbClickThen } from "../../shared/absorb-click";
import { ICreatePageItem, ISection, ISectionItem, ItemId, SectionColumns } from "../api/api-types";
import { DragDropContext, Droppable, Draggable, DropResult, DraggableProvided } from "react-beautiful-dnd";
import { Add } from "../../shared/components/icons/add-icon";

import "./section-column.scss";
import { SectionItemPicker } from "./section-item-picker";
import { usePageAPI } from "../hooks/use-api-provider";

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
  items: ISectionItem[];

  /**
   * Function to move an item
   */
  moveFunction?: (id: string) => void;

  /**
   * The ID of the column's parent section
   */
  sectionId: string;

  /**
   * Function to edit an item
   */
  editItemFunction?: (id: string) => void;
}

export const SectionColumn: React.FC<ISectionColumnProps> = ({
  addItem,
  addPageItem,
  className,
  column,
  columnNumber,
  items,
  moveFunction,
  editItemFunction,
  sectionId
  }: ISectionColumnProps) => {

  const api = usePageAPI();
  const getAllEmbeddables = api.getAllEmbeddables;
  const embeddables = getAllEmbeddables.data?.allEmbeddables;
  const { deletePageItem, updateSectionItems, copyPageItem } = api;
  const [showAddItem, setShowAddItem] = useState(false);

  const updateItemPositions = (sectionItems: ISectionItem[], sourceIndex: number, destinationIndex: number) => {
    const itemToMove = sectionItems[sourceIndex];
    const otherItem = sectionItems[destinationIndex];
    itemToMove.position = otherItem.position;
    sectionItems.splice(sourceIndex, 1);
    sectionItems.splice(destinationIndex, 0, itemToMove);
    let itemsCount = 0;
    sectionItems.forEach((i, index) => {
      itemsCount++;
      if (index > destinationIndex) {
        i.position = itemsCount;
      }
    });
    return [...sectionItems];
  };

  const onDragEnd = (e: DropResult) => {
    if (!e.destination) {
      return;
    }
    let nextItems: ISectionItem[] = [];
    if (e.source.droppableId !== e.destination.droppableId) {
      // items[e.source.index].section_col = items[e.source.index].section_col === 0 ? 1 : 0;
      // disallow cross column reordering for now
      return;
    }
    if (e.destination && e.destination.index !== e.source.index) {
      nextItems = updateItemPositions(items, e.source.index, e.destination.index);
      updateSectionItems({sectionId, newItems: nextItems, column });
    }
  };

  const handleMoveItem = (itemId: string) => {
    moveFunction?.(itemId);
  };

  const handleEditItem = (itemId: string) => {
    editItemFunction?.(itemId);
  };

  const handleToggleShowAddItem = () => setShowAddItem((prev) => !prev);
  const handleShowAddItem = absorbClickThen(handleToggleShowAddItem);

  const handleAddItem = (itemId: string) => {
    const position = items.length + 1;
    const embeddable = embeddables?.find(e => e.id === itemId);
    if (embeddable) {
      addPageItem?.({
        section_id: sectionId,
        embeddable: embeddable.serializeable_id,
        column,
        position,
        type: embeddable.type
      });
      handleToggleShowAddItem();
    }
  };

  const showItemPicker = () => setShowAddItem(true);

  return (
    <>
      <DragDropContext onDragEnd={onDragEnd}>
        <div className={`edit-page-grid-container col-${columnNumber} ${className}`}>
          <Droppable droppableId={`droppableCol${columnNumber}`}>
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
                        index={index}
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
                              copyFunction={copyPageItem}
                              deleteFunction={deletePageItem}
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
