import * as React from "react";
import { GripLines } from "./icons/grip-lines";
import { MinusSquare } from "./icons/minus-square";
import { Cog } from "./icons/cog";
import { Trash } from "./icons/trash";
import { SectionItem, ISectionItemProps} from "./section-item";
import { DragDropContext, Droppable, Draggable, DropResult } from "react-beautiful-dnd";
// NP 2021-08-12 -- default imports aren't working correctly when evaled on page
import "./authoring-section.css";

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
   * Section Items in this section
   */
   items?: ISectionItemProps[];
   columnOneItems?: ISectionItemProps[];
   columnTwoItems?: ISectionItemProps[];

}

/**
 * Primary UI component for user interaction
 */
export const AuthoringSection: React.FC<ISectionProps> = ({
  id,
  updateFunction,
  deleteFunction,
  layout: initLayout = defaultLayout,
  items: initItems = [] as ISectionItemProps[],
  columnOneItems: initColumnOneItems = [] as ISectionItemProps[],
  columnTwoItems: initColumnTwoItems = [] as ISectionItemProps[],
  collapsed: initCollapsed = false,
  title
  }: ISectionProps) => {

  const getColumnItems = (columnIndex: number) => {
    let columnItems: any[] = [];
    columnItems = items.map(i => {
      if (i.section_col === columnIndex) {
        return <SectionItem {...i} key={i.id} />;
      }
    }).filter(Boolean);
    return columnItems;
  }

  const [layout, setLayout] = React.useState(initLayout);
  const [collapsed, setCollapsed] = React.useState(initCollapsed);
  const [items, setItems] = React.useState([...initItems]); // TODO: Initial Items as in layout
  const [columnOneItems, setColumnOneItems] = React.useState(getColumnItems(0));
  const [columnTwoItems, setColumnTwoItems] = React.useState(getColumnItems(1));

  React.useEffect(() => {
    setLayout(initLayout);
  }, [initLayout]);

  // React.useEffect(() => {
  //   setItems([...initItems]);
  // }, [initItems]);

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
    console.log("move");
  };

  const handleCopy = () => {
    console.log("copy");
  };

  const sortedItems = () => {
    return items.sort((a, b) => a.position - b.position);
  };

  const addItemCol1 = () => {
    const nextId = columnOneItems.length;
    const position = nextId + 1;
    const newItem: ISectionItemProps = {
      id: `${nextId}`,
      section_id: id,
      section_col: 0,
      position,
      title: `item ${position}`
    };
    setColumnOneItems([...columnOneItems, newItem]);
  };

  const addItemCol2 = () => {
    const nextId = columnTwoItems.length;
    const position = nextId + 1;
    const newItem: ISectionItemProps = {
      id: `${nextId}`,
      section_id: id,
      section_col: 1,
      position,
      title: `item ${position}`
    };
    setColumnTwoItems([...columnTwoItems, newItem]);
  };

  const swapIndexes = (array: any[], a: number, b: number) => {
    console.log('swap shop');
    const bItem = array[b];
    array[b] = array[a];
    array[a] = bItem;
    return [...array];
  };

  const onDragEnd = (e: DropResult) => {
    // if (e.destination && e.destination.index !== e.source.index) {
    //   const nextItems = swapIndexes(items, e.source.index, e.destination.index);
    //   if (setItems) {
    //     setItems(nextItems);
    //   }
    // }
  };

  const sectionColumns = (columnOneItems: any[], columnTwoItems: any[]) => {
    return (
      <>
      <DragDropContext onDragEnd={onDragEnd}>
        <div className={`edit-page-grid-container col-1 ${classNameForItem(layout, 0)}`}>
          <Droppable droppableId="droppableCol1">
            {(droppableProvided, snapshot) => (
              <div ref={droppableProvided.innerRef} className="edit-items-container full-row" {...droppableProvided.droppableProps}>
                <div className="itemsContainer">
                  { !collapsed && columnOneItems && columnOneItems.length > 0 && columnOneItems.map((element, index) => {
                    return (
                      <Draggable key={`col-1-item-${index}`} draggableId={`col-1-item-${index}`} index={index}>
                        {(draggableProvided) => (
                          <div className="sectionItem" key={`col-1-item-inner-${index}`} {...draggableProvided.draggableProps} {...draggableProvided.dragHandleProps} ref={draggableProvided.innerRef}>
                            {element}
                          </div>
                        )}
                      </Draggable>
                    );
                  })}
                  { droppableProvided.placeholder }
                  <button className="small-button" onClick={addItemCol1}>
                    + Add Item
                  </button>
                </div>
              </div>
          )}
          </Droppable>
        </div>
        {layout !== "Full Width" &&
          <div className={`edit-page-grid-container col-2 ${classNameForItem(layout, 1)}`}>
            <Droppable droppableId="droppableCol2">
              {(droppableProvided, snapshot) => (
                <div ref={droppableProvided.innerRef} className="edit-items-container full-row" {...droppableProvided.droppableProps}>
                  <div className="itemsContainer">
                    { !collapsed && columnTwoItems && columnTwoItems.length > 0 && columnTwoItems.map((element, index) => {
                      return (
                        <Draggable key={`col-2-item-${index}`} draggableId={`col-2-item-${index}`} index={index}>
                          {(draggableProvided) => (
                            <div className="sectionItem" key={`col-2-item-inner-${index}`} {...draggableProvided.draggableProps} {...draggableProvided.dragHandleProps} ref={draggableProvided.innerRef}>
                              {element}
                            </div>
                          )}
                        </Draggable>
                      );
                    })}
                    { droppableProvided.placeholder }
                    <button className="small-button" onClick={addItemCol2}>
                      + Add Item
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
  }
 
  return (
    <div className="edit-page-grid-container">
      <header className="section-menu full-row">
        <div className="menu-start">
          <GripLines />
          <span>{title}{id}</span>
          <span>Layout</span>
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
      {sectionColumns(columnOneItems, columnTwoItems)}
    </div>
  );
};
