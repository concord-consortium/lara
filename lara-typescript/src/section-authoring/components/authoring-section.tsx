import * as React from "react";
import { GripLines } from "../../shared/components/icons/grip-lines";
import { MinusSquare } from "../../shared/components/icons/minus-square";
import { Cog } from "../../shared/components/icons/cog";
import { Trash } from "../../shared/components/icons/trash";
import { SectionItem, ISectionItemProps} from "./section-item";
// NP 2021-08-12 -- default imports aren"t working correctly when evaled on page
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
   * Section Items in this section
   */
  items?: ISectionItemProps[];

  /**
   * Drag handle.
   * DragHandleProps is a private type documented at
   * https://github.com/atlassian/react-beautiful-dnd/blob/master/docs/api/draggable.md
   */
  dragHandleProps?: any;

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
  collapsed: initCollapsed = false,
  title,
  dragHandleProps
  }: ISectionProps) => {

  const [layout, setLayout] = React.useState(initLayout);
  const [collapsed, setCollapsed] = React.useState(initCollapsed);
  const [items, setItems] = React.useState([...initItems]); // TODO: Initial Items as in layout

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

  const sortedItems = () => {
    return items.sort((a, b) => a.position - b.position);
  };

  const addItem = () => {
    const nextId = items.length;
    const position = nextId + 1;
    const newItem: ISectionItemProps = {
      id: `${nextId}`,
      position,
      title: `item ${position}`
    };
    setItems([...items, newItem]);
  };

  const displayItems = items.map(i => <SectionItem {...i} key={i.id} /> );
  displayItems.push(
    <button className="small-button" onClick={addItem}>
      + Add Item
    </button>
  );

  return (
    <div className="edit-page-grid-container">
      <div className="section-menu full-row">
        <div className="menu-start">
          <span  {...dragHandleProps}>
            <GripLines/>
          </span>
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
          <span><Cog /></span>
          <span><Trash onClick={handleDelete}/></span>
          <span><MinusSquare onClick={toggleCollapse}/></span>
        </div>
      </div>
    { !collapsed &&
      displayItems.map((element, index) => {
        const className = `section-container ${classNameForItem(layout, index)}`;
        return (
          <div className={className} key={index}>
            {element}
          </div>
        );
      })
    }
    </div>
  );
};
