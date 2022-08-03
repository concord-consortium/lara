import * as React from "react";
import { useEffect, useRef, useState } from "react";
import classNames from "classnames";
import { usePageAPI } from "../hooks/use-api-provider";
import { GripLines } from "../../shared/components/icons/grip-lines";
import { UserInterfaceContext } from "../containers/user-interface-provider";
import { TextBlockPreview } from "./text-block-preview";
import { PluginPreview } from "./plugin-preview";
import { ManagedInteractivePreview } from "./managed-interactive-preview";
import { MWInteractivePreview } from "./mw-interactive-preview";
import { SectionItemPluginList } from "./section-item-plugin-list";

import "./section-item.scss";
import { SectionColumns } from "../api/api-types";

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

  sectionId: string;

  sectionColumn: SectionColumns;

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
  sectionId,
  sectionColumn
  }: ISectionItemProps) => {

  const api = usePageAPI();
  const pageItems = api.getItems();
  const pageItem = pageItems.find(pi => pi.id === id);
  const {
    userInterface: {editingItemId, movingItemId},
    actions: {setEditingItemId, setMovingItemId}
  } = React.useContext(UserInterfaceContext);
  const [isBeingUpdated, setIsBeingUpdated] = useState<boolean>(false);
  const prevEditingItemId = useRef<string>("");
  let supportsPlugins = false;

  useEffect(() => {
    if (editingItemId === id) {
      setIsBeingUpdated(true);
    } else if (isBeingUpdated && prevEditingItemId.current === id) {
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
        supportsPlugins = false;
        return <TextBlockPreview pageItem={pageItem} />;
      case "ManagedInteractive":
        supportsPlugins = true;
        return <ManagedInteractivePreview pageItem={pageItem} />;
      case "MwInteractive":
        supportsPlugins = true;
        return <MWInteractivePreview pageItem={pageItem} />;
      case "Embeddable::EmbeddablePlugin":
        return <PluginPreview pageItem={pageItem} />;
      default:
        return (
          <div className="previewNotSupported">
            <span>Authoring mode preview not supported for "{pageItem?.type}"</span>
          </div>
        );
    }
  };

  const containerClasses = classNames(
    "sectionItemContainer",
    pageItem?.data.isHidden ? "hidden" : "",
  );

  return(
    <div className={containerClasses}>
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
            {copyFunction && <li><button onClick={handleCopy}>Copy</button></li>}
            <li><button onClick={handleDelete}>Delete</button></li>
          </ul>
        </div>
      </header>
      <section>
        {pageItem && getContent()}
        {supportsPlugins &&
          <SectionItemPluginList sectionColumn={sectionColumn} sectionId={sectionId} sectionItemId={id} />
        }
      </section>
    </div>
  );
};
