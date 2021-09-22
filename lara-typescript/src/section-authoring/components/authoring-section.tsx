import * as React from "react";
import { GripLines } from "../../shared/components/icons/grip-lines";
import { SectionItem, ISectionItemProps} from "./section-item";
import { ISectionItem, SectionItemPicker } from "./section-item-picker";
import { absorbClickThen } from "../../shared/absorb-click";
import { ICreatePageItem } from "../authoring-types";
import { DragDropContext, Droppable, Draggable, DropResult, DraggableProvided } from "react-beautiful-dnd";
import { Add } from "../../shared/components/icons/add-icon";

import "./authoring-section.scss";

export enum Layouts {
  LAYOUT_FULL_WIDTH = "Full Width",
  LAYOUT_60_40 = "60-40",
  LAYOUT_40_60 = "40-60",
  LAYOUT_70_30 = "70-30",
  LAYOUT_30_70 = "30-70",
  LAYOUT_RESPONSIVE = "Responsive",
}

const defaultLayout = Layouts.LAYOUT_FULL_WIDTH;
const layoutClassNames = {
  [Layouts.LAYOUT_FULL_WIDTH]: ["section-full-width"],
  [Layouts.LAYOUT_60_40]: ["section-60", "section-40"] ,
  [Layouts.LAYOUT_40_60]: ["section-40", "section-60"],
  [Layouts.LAYOUT_70_30]: ["section-70", "section-30"],
  [Layouts.LAYOUT_30_70]: ["section-30", "section-70"],
  [Layouts.LAYOUT_RESPONSIVE]: ["section-responsive"]
};

const classNameForItem = (_layout: Layouts, itemIndex: number) => {
  const layout = _layout || defaultLayout;
  const layouts = layoutClassNames[layout];
  const classNameIndex = itemIndex % layouts.length;
  return layoutClassNames[layout][classNameIndex];
};

export interface ISectionProps {

  /**
   * Can the smaller side collapse?
   */
  can_collapse_small?: boolean;

  /**
   * Record ID
   */
  id: string;

  /**
   * Associated Page for this section
   */
  interactive_page_id: string;

  /**
   * How are the items positioned in the section
   */
  layout?: Layouts;

  /**
   * Optional function to update the section (elsewhere)
   * Todo: maybe we change the return type to be a Promise<SectionProps|error>
   */
  updateFunction?: (changes: {section: Partial<ISectionProps>}) => void;

  /**
   * Optional function to delete the section (elsewhere)
   */
  deleteFunction?: (id: string) => void;

  /**
   * Or display order on the page
   */
  position?: number;

  /**
   * Name of the section will be displayed in the header
   */
  title?: string;

  /**
   * Should the section be collapsed?
   */
  collapsed?: boolean;

  /**
   * Items in this section
   */
  items?: ISectionItemProps[];

  /**
   * Optional function to delete the section (elsewhere)
   */
  updatePageItems?: (items: ISectionItemProps[], sectionId: string) => void;

  /**
   * Function to move an item
   */
  moveItemFunction?: (id: string) => void;

  /*
   * List of all section items available
   */
  allSectionItems?: ISectionItem[];

  /**
   * how to add a new page item
   */
   addPageItem?: (pageItem: ICreatePageItem) => void;

   /**
    * DraggingContext
    */
   draggableProvided?: DraggableProvided;
}

/**
 * Primary UI component for user interaction
 */
export const AuthoringSection: React.FC<ISectionProps> = ({
  id,
  updateFunction,
  deleteFunction,
  layout: initLayout = defaultLayout,
  items: initItems = [],
  collapsed: initCollapsed = false,
  title,
  updatePageItems,
  moveItemFunction,
  allSectionItems,
  draggableProvided,
  addPageItem
  }: ISectionProps) => {

  const [items, setItems] = React.useState([...initItems]); // TODO: Initial Items as in layout
  const [layout, setLayout] = React.useState(initLayout);
  const [collapsed, setCollapsed] = React.useState(initCollapsed);
  const [showAddItem, setShowAddItem] = React.useState(false);

  React.useEffect(() => {
    setLayout(initLayout);
  }, [initLayout]);

  React.useEffect(() => {
    updatePageItems?.(items, id);
  }, [items]);

  const layoutChanged = (change: React.ChangeEvent<HTMLSelectElement>) => {
    const newLayout = change.target.value as Layouts;
    setLayout(newLayout);
    updateFunction?.({section: {layout: newLayout, id}});
  };

  const toggleCollapse = () => {
    const nextCollapsed = !collapsed;
    setCollapsed(nextCollapsed);
    updateFunction?.({section: {collapsed: nextCollapsed, id}});
  };

  const handleDelete = () => {
    deleteFunction?.(id);
  };

  const handleMove = () => {
    // tslint:disable-next-line:no-console
    console.log("move");
  };

  const handleCopy = () => {
    // tslint:disable-next-line:no-console
    console.log("copy");
  };

  const sortedItems = () => {
    return items.sort((a, b) => a.position - b.position);
  };

  const getColumnItems = (columnIndex: number) => {
    let columnItems: any[] = [];
    columnItems = items.map(i => {
      if (i.section_col === columnIndex) {
        return i;
      }
    }).filter(Boolean);
    return columnItems;
  };

  const addItem = (sectionCol: number) => {
    const nextId = `section-${id}-item-${items.length}`;
    const position = items.length + 1;
    const newItem: ISectionItemProps = {
      id: `${nextId}`,
      section_id: id,
      section_col: sectionCol,
      position,
      type: "unknown",
      title: `Item ${position} - ${Math.random().toString(36).substr(2, 9)}`
    };
    setItems([...items, newItem]);
  };

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
    let nextItems = [];
    if (e.source.droppableId !== e.destination.droppableId) {
      // items[e.source.index].section_col = items[e.source.index].section_col === 0 ? 1 : 0;
      // disallow cross column reordering for now
      return;
    }
    if (e.destination && e.destination.index !== e.source.index) {
      nextItems = swapIndexes(items, e.source.index, e.destination.index);
    }
    if (setItems) {
      setItems(nextItems);
    }
  };

  const handleMoveItem = (itemId: string) => {
    if (moveItemFunction) {
      moveItemFunction(itemId);
    }
  };

  const handleCopyItem = (itemId: string) => {
    const item = items.find(i => i.id === itemId);
    if (item) {
      addItem(item.section_col);
    }
  };

  const handleDeleteItem = (itemId: string) => {
    const nextItems: ISectionItemProps[] = [];
    items.forEach(i => {
      if (i.id !== itemId) {
        nextItems.push(i);
      }
    });
    setItems(nextItems);
  };

  const sectionColumns = () => {
    const colOneItems = getColumnItems(0);
    const colTwoItems = getColumnItems(1);
    const colOneAddItemHandler = () => addItem(0);
    const colTwoAddItemHandler = () => addItem(1);
    return (
      <>
        <DragDropContext onDragEnd={onDragEnd}>
          <div className={`edit-page-grid-container col-1 ${classNameForItem(layout, 0)}`}>
            <Droppable droppableId="droppableCol1">
              {(droppableProvided) => (
                <div
                  ref={droppableProvided.innerRef}
                  className="edit-items-container full-row"
                  {...droppableProvided.droppableProps}
                >
                  <div className="itemsContainer">
                    { !collapsed
                      && colOneItems
                      && colOneItems.length > 0
                      && colOneItems.map((element, index) => {
                      return (
                        <Draggable
                          key={`col-1-item-${index}`}
                          draggableId={`col-1-item-${index}`}
                          index={element.position - 1}
                        >
                          {(draggableProvidedColOne) => (
                            <div
                              className="sectionItem"
                              key={`col-1-item-inner-${index}`}
                              {...draggableProvidedColOne.draggableProps}
                              {...draggableProvidedColOne.dragHandleProps}
                              ref={draggableProvidedColOne.innerRef}
                            >
                              <SectionItem
                                {...element}
                                key={element.id}
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
                    <button className="small-button" onClick={colOneAddItemHandler}>
                      <Add height="16" width="16" /> <span className="lineAdjust">Add Item</span>
                    </button>
                  </div>
                </div>
            )}
            </Droppable>
          </div>
          {layout !== "Full Width" &&
            <div className={`edit-page-grid-container col-2 ${classNameForItem(layout, 1)}`}>
              <Droppable droppableId="droppableCol2">
                {(droppableProvided) => (
                  <div
                    ref={droppableProvided.innerRef}
                    className="edit-items-container full-row"
                    {...droppableProvided.droppableProps}
                  >
                    <div className="itemsContainer">
                      { !collapsed
                        && colTwoItems
                        && colTwoItems.length > 0
                        && colTwoItems.map((element, index) => {
                        return (
                          <Draggable
                            key={`col-2-item-${index}`}
                            draggableId={`col-2-item-${index}`}
                            index={element.position - 1}
                          >
                            {(draggableProvidedColTwo) => (
                              <div
                                className="sectionItem"
                                key={`col-2-item-inner-${index}`}
                                {...draggableProvidedColTwo.draggableProps}
                                {...draggableProvidedColTwo.dragHandleProps}
                                ref={draggableProvidedColTwo.innerRef}
                              >
                                <SectionItem
                                  {...element}
                                  key={element.id}
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
                      <button className="small-button" onClick={colTwoAddItemHandler}>
                      <Add height="16" width="16" /> <span className="lineAdjust">Add Item</span>
                      </button>
                    </div>
                  </div>
                )}
              </Droppable>
            </div>
          }
        </DragDropContext>
      </>
    );
  };

  const handleToggleShowAddItem = () => setShowAddItem((prev) => !prev);
  const handleShowAddItem = absorbClickThen(handleToggleShowAddItem);

  const handleAddItem = (itemId: string) => {
    addPageItem?.({
      section_id: id,
      embeddable: itemId
    });
    handleToggleShowAddItem();
  };

  const sectionClassName = (index: number) => `section-container ${classNameForItem(layout, index)}`;

  return (
    <div className="edit-page-grid-container">
      <header className="section-menu full-row">
        <div className="menu-start">
          <span {...draggableProvided?.dragHandleProps}>
            <GripLines  />
          </span>
          <h3>{title}{id}</h3>
          <label htmlFor="section_layout">Layout: </label>
          <select
            id="section_layout"
            name="section[layout]"
            onChange={layoutChanged}
            defaultValue={layout}
            title="Section layout">
            {
              Object.values(Layouts).map( (l) => {
                return (
                  <option key={l} value={l}>{l}</option>
                );
              })
            }
          </select>
        </div>
        <div className="menu-end">
          <ul>
            <li><button onClick={toggleCollapse}>Collapse</button></li>
            <li><button onClick={handleMove}>Move</button></li>
            <li><button onClick={handleCopy}>Copy</button></li>
            <li><button onClick={handleDelete}>Delete</button></li>
          </ul>
        </div>
      </header>
      {sectionColumns()}
    </div>
  );
};
