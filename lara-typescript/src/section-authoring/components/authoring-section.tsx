import * as React from "react";
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

const classNameForItem = (layout: Layouts, itemIndex: number) => {
  const layouts = layoutClassNames[layout];
  const classNameIndex = itemIndex % layouts.length;
  return layoutClassNames[layout][classNameIndex];
};

export interface SectionProps {

  /**
   * Can the smaller side collapse?
   */
  can_collapse_small?: boolean;

  /**
   * Record ID
   */
  id: number;

  /**
   * Associated Page for this section
   */
  interactive_page_id: number;

  /**
   * How are the items positioned in the section
   */
  layout?: Layouts;

  /**
   * Optional function to update the section (elsewhere)
   * Todo: maybe we change the return type to be a Promise<SectionProps|error>
   */
   updateFunction?: (changes: Partial<SectionProps>, id: number) => void;

  /**
   * Or display order on the page
   */
  position?: number;
}

/**
 * Primary UI component for user interaction
 */
export const AuthoringSection = ({
  id,
  updateFunction,
  layout: initLayout = defaultLayout,
  }: SectionProps) => {

  const [layout, setLayout] = React.useState(initLayout);

  React.useEffect(() => {
    setLayout(initLayout);
  }, [initLayout]);

  const selectionChanged = (change: React.ChangeEvent<HTMLSelectElement>) => {
    const newLayout = change.target.value as Layouts;
    updateFunction?.({layout: newLayout}, id);
    setLayout(newLayout);
  };

  // TODO: There is probably a more react-like way to handle this
  const deleteTag = <a
      href={`/remove_section/${id}`}
      data-method="delete"
      rel="nofollow">
      <i className="fa fa-trash"/>
    </a>;

  return (
    <div className="edit-page-grid-container">
      <div className="section-menu full-row">
        <div className="menu-start">
          <span><i className="fa fa-bars"/></span>
          <span>Section Layout</span>
          <select
            id="section_layout"
            name="section[layout]"
            onChange={selectionChanged}
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
          <span><i className="fa fa-cog"/></span>
          <span>{deleteTag}
          </span>
          <span><i className="fa fa-close"/></span>
        </div>
        </div>
        <div className={`section-container ${classNameForItem(layout, 0)}`}>
          <button className="small-button">
            + Add Item
          </button>
        </div>
        <div className={`section-container ${classNameForItem(layout, 1)}`}>
          <button className="small-button">
            + Add Item
          </button>
        </div>
      </div>
  );
};
