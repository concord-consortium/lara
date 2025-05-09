import * as React from "react";
import { useState } from "react";
import classNames from "classnames";
import { SectionItem, ISectionItemProps} from "./section-item";
import { absorbClickThen } from "../../shared/absorb-click";
import { ICreatePageItem, ISection, ISectionItem, ItemId, SectionColumns } from "../api/api-types";
import { DragDropContext, Droppable, Draggable, DropResult, DraggableProvided } from "react-beautiful-dnd";
import { Add } from "../../shared/components/icons/add-icon";
import { SectionItemPicker } from "./section-item-picker";
import { usePageAPI } from "../hooks/use-api-provider";
import { snakeToCamelCaseKeys } from "../../shared/convert-keys";

import "./section-column.scss";

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
   * The ID of the column's parent section
   */
  sectionId: string;
}

export const SectionColumn: React.FC<ISectionColumnProps> = ({
  addItem,
  addPageItem,
  className,
  column,
  columnNumber,
  items,
  sectionId
  }: ISectionColumnProps) => {

  const api = usePageAPI();
  const getAllEmbeddables = api.getAllEmbeddables;
  const embeddables = getAllEmbeddables.data?.allEmbeddables;
  const { deletePageItem, updateSectionItems, copyPageItem } = api;
  const [showAddItem, setShowAddItem] = useState(false);

  const updateItemPositions = (sectionItems: ISectionItem[], sourceIndex: number, destinationIndex: number) => {
    const itemToMove = sectionItems[sourceIndex];
    sectionItems.splice(sourceIndex, 1);
    sectionItems.splice(destinationIndex, 0, itemToMove);
    sectionItems.forEach((i, index) => {
      i.position = index + 1;
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

  const handleToggleShowAddItem = () => setShowAddItem((prev) => !prev);

  const handleAddItem = (itemId: string) => {
    const lastItemPosition = items.length > 0 ? items[items.length - 1].position : undefined;
    const position = lastItemPosition ? lastItemPosition + 1 : 1;
    const embeddable = embeddables?.find(e => e.id === itemId);
    if (embeddable) {
      addPageItem?.({
        section_id: sectionId,
        embeddable: embeddable.serializeable_id,
        column,
        position
      });
      handleToggleShowAddItem();
    }
  };

  const showItemPicker = () => setShowAddItem(true);

  // TODO: Find a way to more generically identify wrapping items so this function isn't needed.
  const isWrappingItem = (itemData: any) => {
    // "interactives" is the Sharing Plugin's label
    return ["questionWrapper", "interactives"].indexOf(itemData.componentLabel) !== -1;
  };

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
                    let itemCanBeCopied = true;
                    // TODO: Figure out why item.data property names are sometimes not converted
                    // to camel case, and fix it instead of using this itemData variable.
                    const itemData = snakeToCamelCaseKeys(item.data);
                    // Wrapping items should not be rendered as separate page items
                    if (isWrappingItem(itemData)) {
                      return;
                    }
                    const sectionItemClasses = classNames("sectionItem", {
                       halfWidth: itemData.isHalfWidth,
                       pluginItem: item.type === "Embeddable::EmbeddablePlugin",
                       sideTipItem: itemData.componentLabel === "sideTip"
                    });
                    if (itemData.componentLabel === "sideTip") {
                      itemCanBeCopied = false;
                    }
                    return (
                      <Draggable
                        key={`col-${columnNumber}-item-${index}`}
                        draggableId={`col-${columnNumber}-item-${index}`}
                        index={index}
                      >
                        {(draggableProvidedColOne) => (
                          <div
                            className={sectionItemClasses}
                            key={`col-${columnNumber}-item-inner-${index}`}
                            {...draggableProvidedColOne.draggableProps}
                            {...draggableProvidedColOne.dragHandleProps}
                            ref={draggableProvidedColOne.innerRef}
                          >
                            <SectionItem
                              {...item}
                              key={item.id}
                              sectionColumn={column}
                              sectionId={sectionId}
                              copyFunction={itemCanBeCopied ? copyPageItem : undefined}
                              deleteFunction={deletePageItem}
                            />
                          </div>
                        )}
                      </Draggable>
                    );
                  })}
                  { droppableProvided.placeholder }
                  <div className="addItem">
                    <button
                      className="smallButton"
                      data-testid="add-item-button"
                      onClick={showItemPicker}
                    >
                      <Add height="16" width="16" /> <span className="lineAdjust">Add Item</span>
                    </button>
                  </div>
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
