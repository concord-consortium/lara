import * as React from "react";
import { GripLines } from "./icons/grip-lines";

import "./section-item.css";

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
  * Optional function to move the item
  */
  moveFunction?: (id: string) => void;

  /**
   * Optional function to copy the item
   */
  copyFunction?: (id: string) => void;

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
  moveFunction,
  copyFunction,
  deleteFunction,
  position,
  section_col,
  section_id,
  type,
  title
  }: ISectionItemProps) => {

  const toggleCollapse = () => {

  }

  const handleEdit = () => {

  }

  const handleMove = () => {
    moveFunction?.(id);
  }

  const handleCopy = () => {
    copyFunction?.(id);
  }

  const handleDelete = () => {
    deleteFunction?.(id);
  }

  return(
    <div className="section-item-container">
      <header className="section-item-menu">
        <div className="menu-start">
          <GripLines />
          <h4>{id} - {title}</h4>
        </div>
        <div className="menu-end">
          <ul>
            <li><button onClick={toggleCollapse}>Collapse</button></li>
            <li><button onClick={handleEdit}>Edit</button></li>
            <li><button onClick={handleMove}>Move</button></li>
            <li><button onClick={handleCopy}>Copy</button></li>
            <li><button onClick={handleDelete}>Delete</button></li>
          </ul>
        </div>
      </header>
      <section>

      </section>
    </div>
  );
};
