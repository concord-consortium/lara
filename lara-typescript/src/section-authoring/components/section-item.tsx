import * as React from "react";

export interface ISectionItemProps {

  /**
   * Record ID
   */
  id: string;

  /**
   * Optional function to change the item
   */
  updateFunction?: (changes: {sectionItem: Partial<ISectionItemProps>}) => void;

  /**
   * Optional function to delete the item
   */
  deleteFunction?: (id: string) => void;

  /**
   * Section the item belongs in
   */

  section_id: string;

   /**
   * Section column item belongs in
   */

  section_col: number;

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
  title
  }: ISectionItemProps) => {
  return(
    <div className="section-item-container">
      {id} - {title}
    </div>
  );
}
