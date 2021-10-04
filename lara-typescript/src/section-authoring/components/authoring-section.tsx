import * as React from "react";
import { useState } from "react";
import { GripLines } from "../../shared/components/icons/grip-lines";
import { SectionColumn } from "./section-column";
import { ICreatePageItem, ISection, ISectionItem, SectionColumns, SectionLayouts } from "../api/api-types";
import { DraggableProvided } from "react-beautiful-dnd";

import "./authoring-section.scss";

const defaultLayout = SectionLayouts.LAYOUT_FULL_WIDTH;
const layoutClassNames = {
  [SectionLayouts.LAYOUT_FULL_WIDTH]: ["section-full-width"],
  [SectionLayouts.LAYOUT_60_40]: ["section-60", "section-40"] ,
  [SectionLayouts.LAYOUT_40_60]: ["section-40", "section-60"],
  [SectionLayouts.LAYOUT_70_30]: ["section-70", "section-30"],
  [SectionLayouts.LAYOUT_30_70]: ["section-30", "section-70"],
  [SectionLayouts.LAYOUT_RESPONSIVE]: ["section-responsive-static", "section-responsive-fluid"]
};

const classNameForItem = (_layout: SectionLayouts, itemIndex: number) => {
  const layout = _layout || defaultLayout;
  const layouts = layoutClassNames[layout];
  const classNameIndex = itemIndex % layouts.length;
  return layoutClassNames[layout][classNameIndex];
};

export interface ISectionProps extends ISection {

  /**
   * DraggingContext
   */
  draggableProvided?: DraggableProvided;

  /**
   * Optional function to update the section (elsewhere)
   * Todo: maybe we change the return type to be a Promise<SectionProps|error>
   */
  updateFunction?: (changes: {section: Partial<ISection>}) => void;

  /**
   * Optional function to delete the section (elsewhere)
   */
  deleteFunction?: (id: string) => void;

  /**
   * Optional function to move the section
   */
  moveFunction?: (id: string) => void;

  /**
   * Optional function to copy the section
   */
  copyFunction?: (id: string) => void;

  /**
   * Optional function to delete the section (elsewhere)
   */
  updatePageItems?: (items: ISectionItem[], sectionId: string) => void;

  /**
   * Function to move an item
   */
  moveItemFunction?: (id: string) => void;

  /**
   * how to add a new page item
   */
  addPageItem?: (pageItem: ICreatePageItem) => void;

}

/**
 * Primary UI component for user interaction
 */
export const AuthoringSection: React.FC<ISectionProps> = ({
  id,
  updateFunction,
  deleteFunction,
  moveFunction,
  copyFunction,
  layout: initLayout = defaultLayout,
  items = [],
  collapsed: initCollapsed = false,
  title,
  updatePageItems,
  moveItemFunction,
  draggableProvided,
  addPageItem
  }: ISectionProps) => {

  const [layout, setLayout] = useState(initLayout);
  const [collapsed, setCollapsed] = useState(initCollapsed);

  React.useEffect(() => {
    setLayout(initLayout);
  }, [initLayout]);

  const layoutChanged = (change: React.ChangeEvent<HTMLSelectElement>) => {
    const newLayout = change.target.value as SectionLayouts;
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

  // const setItems = (nextItems: ISection[]) => {
  //   updateFunction?.({section: {id, items: nextItems}});
  // };

  const handleMove = () => {
    moveFunction?.(id);

  };

  const handleCopy = () => {
    copyFunction?.(id);
  };

  // const sortedItems = () => {
  //   return items.sort((a, b) => (a?.position || 0) - (b?.position || 0));
  // };

  const getColumnItems = (column: SectionColumns) => {
    if (layout === SectionLayouts.LAYOUT_FULL_WIDTH) return items;
    return items.filter(i => i.column === column);
  };

  const columnValueForIndex = (columnNumber: number): SectionColumns => {
    // if our layout is full-width we are SectionColumns.primary
    // if our layout is responsive, 30_70 or 40_60 and index is 0 → SectionColumns.secondary
    // if our layout is responsive, 30_70 or 40_60 and index is >0 → SectionColumns.primary
    // if our layout is 70_30 or 60_40 and index is 0 -> SectionColumns.primary
    // if our layout is 70_30 or 60_40 and index is >0 -> SectionColumns.secondary
    if (layout === SectionLayouts.LAYOUT_FULL_WIDTH) {
      return SectionColumns.PRIMARY;
    }
    if (layout === SectionLayouts.LAYOUT_30_70 ||
        layout === SectionLayouts.LAYOUT_40_60 ||
        layout === SectionLayouts.LAYOUT_RESPONSIVE) {
          if (columnNumber === 0) {
            return SectionColumns.SECONDARY;
          } else {
            return SectionColumns.PRIMARY;
          }
        }
    else { // Layout is bigger section first
      if (columnNumber === 0) {
        return SectionColumns.PRIMARY;
      }
    }
    return SectionColumns.SECONDARY;
  };

  const addItem = (column: SectionColumns) => {
    const nextId = `section-${id}-item-${items.length}`;
    const position = items.length + 1;
    const newItem: ICreatePageItem = {
      // id: `${nextId}`,
      section_id: id,
      column,
      position,
      embeddable: "unknown",
      // title: `Item ${position} - ${Math.random().toString(36).substr(2, 9)}`
    };
    // setItems([...items, newItem]);
    addPageItem?.(newItem);
  };

  const handleMoveItem = (itemId: string) => {
    if (moveItemFunction) {
      moveItemFunction(itemId);
    }
  };

  const sectionClassNames = () => {
    const layoutClass = "section-" + layout.toLowerCase().replace(/ /g, "-");
    return `edit-page-grid-container sectionContainer ${layoutClass}`;
  };

  return (
    <div className={sectionClassNames()}>
      <header className="sectionMenu full-row">
        <div className="menuStart">
          <span className="sectionDragHandle" {...draggableProvided?.dragHandleProps}>
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
              Object.values(SectionLayouts).map( (l) => {
                return (
                  <option key={l} value={l}>{l}</option>
                );
              })
            }
          </select>
        </div>
        <div className="menuEnd">
          <ul>
            <li><button onClick={toggleCollapse}>Collapse</button></li>
            <li><button onClick={handleMove}>Move</button></li>
            <li><button onClick={handleCopy}>Copy</button></li>
            <li><button onClick={handleDelete}>Delete</button></li>
          </ul>
        </div>
      </header>
      {<SectionColumn
        addItem={addItem}
        addPageItem={addPageItem}
        className={classNameForItem(layout, 0)}
        column={columnValueForIndex(0)}
        columnNumber={1}
        items={getColumnItems(columnValueForIndex(0))}
        moveFunction={handleMoveItem}
        sectionId={id}
        updatePageItems={updatePageItems}
        />
      }
      {layout !== "Full Width" &&
        <SectionColumn
          addItem={addItem}
          addPageItem={addPageItem}
          className={classNameForItem(layout, 1)}
          column={columnValueForIndex(1)}
          columnNumber={2}
          items={getColumnItems(columnValueForIndex(1))}
          moveFunction={handleMoveItem}
          sectionId={id}
          updatePageItems={updatePageItems}
        />
      }
    </div>
  );
};
