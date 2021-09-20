import * as React from "react";

export interface ISectionItemProps {

  /**
   * Record ID
   */
  id: string;

  /**
   * Record Type
   */
   type: string;

  /**
   * Optional function to change the item
   */
  updateFunction?: (changes: {sectionItem: Partial<ISectionItemProps>}) => void;

  /**
   * Optional function to delete the item
   */
   deleteFunction?: (id: string) => void;

  /**
   * Display order within the section
   */
  position: number;

  /**
   * Name of the section will be displayed in the header
   */
  title?: string;
}

/**
 * Primary UI component for user interaction
 */
export const SectionItem: React.FC<ISectionItemProps> = ({
  id,
  type,
  title
  }: ISectionItemProps) => {

  const renderTitle = () => (
    <>
      {(title || "").length > 0 ? title : <i>Untitled</i>}
    </>
  );

  return(
    <div className="section-item-container">
      {id} - {type} - {renderTitle()}
    </div>
  );
};
