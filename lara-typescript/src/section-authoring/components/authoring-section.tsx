import * as React from "react";
import { useState } from "react";
import { DraggableProvided } from "react-beautiful-dnd";
import classNames from "classnames";
import { GripLines } from "../../shared/components/icons/grip-lines";
import { SectionColumn } from "./section-column";
import { ICreatePageItem, ISection, SectionColumns, SectionLayouts } from "../api/api-types";
import { UserInterfaceContext } from "../containers/user-interface-provider";
import { usePageAPI } from "../hooks/use-api-provider";
import { changeLayout } from "../util/change-layout-utils";

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
  // If the layout specified isn't valid, use the default layout:
  const layout = Object.keys(layoutClassNames).indexOf(_layout) !== -1
    ? _layout
    : defaultLayout;
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
   * Function to move an item
   */
  moveItemFunction?: (id: string) => void;

  /**
   * how to add a new page item
   */
  addPageItem?: (pageItem: ICreatePageItem) => void;

  /**
   * Function to initiate editing of an item
   */
  editItemFunction?: (itemId: string) => void;

}

/**
 * Primary UI component for user interaction
 */
export const AuthoringSection: React.FC<ISectionProps> = ({
  id,
  can_collapse_small,
  updateFunction,
  layout: initLayout = defaultLayout,
  items = [],
  position,
  collapsed: initCollapsed = false,
  title,
  moveItemFunction,
  editItemFunction,
  draggableProvided,
  addPageItem
  }: ISectionProps) => {

  const { currentPage, updateSection } = usePageAPI();
  const { actions: {setMovingSectionId}} = React.useContext(UserInterfaceContext);
  const { deleteSectionFunction, copySection } = usePageAPI();
  const [layout, setLayout] = useState(initLayout);
  const [collapsed, setCollapsed] = useState(initCollapsed);

  React.useEffect(() => {
    setLayout(initLayout);
  }, [initLayout]);

  const layoutChanged = (change: React.ChangeEvent<HTMLSelectElement>) => {
    const newLayout = change.target.value as SectionLayouts;
    const page = currentPage;
    setLayout(newLayout);
    if (page) {
      const updatedSection = changeLayout({id, layout: newLayout, page});
      if (updatedSection) {
        updateSection.mutate({pageId: page.id, changes: {section: updatedSection}});
      }
    }
  };

  const toggleCollapse = () => {
    const nextCollapsed = !collapsed;
    setCollapsed(nextCollapsed);
    updateFunction?.({section: {collapsed: nextCollapsed, id}});
  };

  const handleDelete = () => {
    deleteSectionFunction?.(id);
  };

  const handleMoveSection = () => {
    setMovingSectionId(id);
  };

  const handleCopy = () => {
    copySection(id);
  };

  const handleToggleSecondaryColumnChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const page = currentPage;
    const section = page?.sections.find(s => s.id === id);
    if (section) {
      section.can_collapse_small = e.target.checked;
      if (page) {
        updateSection.mutate({pageId: page.id, changes: {section}});
      }
    }
  };

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
    const itemPosition = items.length + 1;
    const newItem: ICreatePageItem = {
      // id: `${nextId}`,
      section_id: id,
      column,
      position: itemPosition,
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

  const handleEditItem = (itemId: string) => {
    if (editItemFunction) {
      editItemFunction(itemId);
    }
  };

  const sectionClassNames = () => {
    const layoutClass = "section-" + layout.toLowerCase().replace(/ /g, "-");
    return `edit-page-grid-container sectionContainer ${layoutClass}`;
  };

  const toggleSecondaryColumnDisabled = layout === SectionLayouts.LAYOUT_FULL_WIDTH;
  const toggleSecondaryColumnOptionClass = classNames("toggleSecondaryColumnOption", {
    disabled: toggleSecondaryColumnDisabled
  });

  return (
    <div className={sectionClassNames()}>
      <header className="sectionMenu full-row">
        <div className="menuStart">
          <span className="sectionDragHandle" {...draggableProvided?.dragHandleProps}>
            <GripLines  />
          </span>
          <h3>Section {position}{title ? " " + title : ""}</h3>
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
          <label className={toggleSecondaryColumnOptionClass} htmlFor="toggle-secondary-column">
            <input
              defaultChecked={can_collapse_small}
              disabled={toggleSecondaryColumnDisabled}
              id="toggle-secondary-column"
              name="can_collapse_small"
              onChange={handleToggleSecondaryColumnChange}
              type="checkbox"
            />
            Allow student to hide secondary column
          </label>
        </div>
        <div className="menuEnd">
          <ul>
            <li><button onClick={toggleCollapse}>Collapse</button></li>
            <li><button onClick={handleMoveSection}>Move</button></li>
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
        editItemFunction={handleEditItem}
        sectionId={id}
        />
      }
      {layout !== "full-width" &&
        <SectionColumn
          addItem={addItem}
          addPageItem={addPageItem}
          className={classNameForItem(layout, 1)}
          column={columnValueForIndex(1)}
          columnNumber={2}
          items={getColumnItems(columnValueForIndex(1))}
          moveFunction={handleMoveItem}
          sectionId={id}
        />
      }
    </div>
  );
};
