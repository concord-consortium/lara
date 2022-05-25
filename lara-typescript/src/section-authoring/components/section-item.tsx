import * as React from "react";
import { useEffect, useRef, useState } from "react";
import { usePageAPI } from "../hooks/use-api-provider";
import { GripLines } from "../../shared/components/icons/grip-lines";
import { UserInterfaceContext } from "../containers/user-interface-provider";
import { TextBlockPreview } from "./text-block-preview";
import { ManagedInteractivePreview } from "./managed-interactive-preview";
import { MWInteractivePreview } from "./mw-interactive-preview";

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

}

/**
 * Primary UI component for user interaction
 */
export const SectionItem: React.FC<ISectionItemProps> = ({
  id,
  copyFunction,
  deleteFunction,
  type,
  position
  }: ISectionItemProps) => {

  const api = usePageAPI();
  const pageItems = api.getItems();
  const pageItem = pageItems.find(pi => pi.id === id);
  const { userInterface: {movingItemId}, actions: {setMovingItemId}} = React.useContext(UserInterfaceContext);
  const { userInterface: {editingItemId}, actions: {setEditingItemId}} = React.useContext(UserInterfaceContext);
  const [isBeingUpdated, setIsBeingUpdated] = useState<boolean>(false);
  const resetCount = useRef<number>(0);
  const prevEditingItemId = useRef<string>("");

  useEffect(() => {
    if (editingItemId === id) {
      setIsBeingUpdated(true);
    } else if (isBeingUpdated && prevEditingItemId.current === id) {
      resetCount.current = resetCount.current + 1;
      setIsBeingUpdated(false);
    }
    if (editingItemId) {
      prevEditingItemId.current = editingItemId;
    }
  }, [editingItemId]);

  const renderTitle = () => (
    <>
      {(pageItem?.data.name || "").length > 0 ? pageItem?.data.name : <em>Untitled</em>}
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

  const getContent = () => {
    switch (pageItem?.type) {
      case "Embeddable::Xhtml":
        return <TextBlockPreview pageItem={pageItem} />;
      case "ManagedInteractive":
        return <ManagedInteractivePreview pageItem={pageItem} resetCount={resetCount.current} />;
      case "MwInteractive":
        return <MWInteractivePreview pageItem={pageItem} resetCount={resetCount.current} />;
      default:
        return (
          <div className="previewNotSupported">
            <span>Authoring mode preview not supported.</span>
          </div>
        );
    }
  };

  return(
    <div className="sectionItemContainer">
      <header className="sectionItemMenu">
        <div className="menuStart">
          <GripLines />
          <h4>{id} - {renderTitle()}</h4>
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
      <section>
        {getContent()}
      </section>
    </div>
  );
};
