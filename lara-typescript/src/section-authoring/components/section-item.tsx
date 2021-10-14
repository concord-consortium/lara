import * as React from "react";
import { GripLines } from "../../shared/components/icons/grip-lines";
import { UserInterfaceContext } from "../api/use-user-interface-context";

import "./section-item.scss";

export interface ISectionItemProps {

  /**
   * Record ID
   */
  id: string;

  /**
   * Record Type
   */
  type?: string;

  /**
   * Optional function to change the item
   */
  updateFunction?: (changes: {sectionItem: Partial<ISectionItemProps>}) => void;

  /**
   * Optional function to copy the item
   */
  copyFunction?: (id: string) => void;

  /**
   * Optional function to delete the item
   */
  deleteFunction?: (id: string) => void;

  /**
   * Display order within the section
   */
  position?: number;

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
  copyFunction,
  deleteFunction,
  type,
  position,
  title
  }: ISectionItemProps) => {

  const { userInterface: {movingItemId}, actions: {setMovingItemId}} = React.useContext(UserInterfaceContext);
  const { userInterface: {editingItemId}, actions: {setEditingItemId}} = React.useContext(UserInterfaceContext);

  const renderTitle = () => (
    <>
      {(title || "").length > 0 ? title : <i>Untitled</i>}
    </>
  );

  const toggleCollapse = () => {
    return;
  };

  const handleEdit = () => {
    setEditingItemId(id);
  };

  const handleMove = () => {
    setMovingItemId(id);
  };

  const handleCopy = () => {
    copyFunction?.(id);
  };

  const handleDelete = () => {
    deleteFunction?.(id);
  };

  return(
    <div className="sectionItemContainer">
      <header className="sectionItemMenu">
        <div className="menuStart">
          <GripLines />
          <h4>{id} - {title} - {renderTitle()}</h4>
        </div>
        <div className="menuEnd">
          <ul>
            <li><button onClick={toggleCollapse}>Collapse</button></li>
            <li><button onClick={handleEdit}>Edit</button></li>
            <li><button onClick={handleMove}>Move</button></li>
            <li><button onClick={handleCopy}>Copy</button></li>
            <li><button onClick={handleDelete}>Delete</button></li>
          </ul>
        </div>
      </header>
      <section/>
    </div>
  );
};
