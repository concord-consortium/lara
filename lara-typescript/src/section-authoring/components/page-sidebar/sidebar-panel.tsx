import * as React from "react";
import { IconClose } from "./icon-close";
import { renderHTML } from "../../../shared/render-html";

import "./sidebar-panel.scss";
import { IPage } from "../../api/api-types";

interface IRenderEditorProps {
  content: string ;
  handleChangeContent: (newContent: string) => void;
}

interface ISidebarPanelProps {
  handleCloseSidebarContent: (index: number, show: boolean) => void;
  updateSettingsFunction: (changes: Partial<IPage>) => void;
  index: number;
  content: string;
  title: string;
  show: boolean;
}

export const SidebarPanel = (props: ISidebarPanelProps) => {
  const { updateSettingsFunction } = props;
  const [editMode, setEditMode] = React.useState(false);
  const [title, setTitle] = React.useState(props.title);
  const [content, setContent] = React.useState(props.content);
  const toggleEditMode = () => setEditMode(!editMode);
  const titleRef = React.useRef<HTMLInputElement>(null);
  const contentRef = React.useRef<HTMLTextAreaElement>(null);

  const handleSave = () => {
    if (titleRef.current) {
      setTitle(titleRef.current.value);
    }
    if (contentRef.current) {
      setContent(contentRef.current.value);
    }
    const sidebarTitle = titleRef?.current?.value || title;
    const sidebar = contentRef?.current?.value || content;
    updateSettingsFunction({sidebarTitle, sidebar });
    setEditMode(false);
  };

  const handleCloseButton = () => {
    props.handleCloseSidebarContent(props.index, false);
  };

  const Title = () => {
    if (editMode) {
      return (
        <input ref={titleRef} defaultValue={title} />
      );
    }
    return <>{title}</>;
  };

  const Content = () => {
    if (editMode) {
      // NP 2022-07-01: I couldn't get TinyMCE to work here.
      // TODO: For rich text editing `import {RichEditor} from './rich-editor'`?
      return <textarea ref={contentRef} defaultValue={content} />;
    }
    return <>{renderHTML(content)}</>;
  };

  const MenuItems = () => {
    if (editMode) {
      return (
        <>
          <span onClick={handleSave} className="menu">save</span> |
          <span onClick={toggleEditMode} className="menu">cancel</span>
        </>
      );
    }
    return(
      <>
        <span onClick={toggleEditMode} className="menu">edit</span>
      </>
    );
  };

  return (
    <div className={`sidebar-panel ${props.show ? "visible " : "hidden"}`}>
      <div className="sidebar-header">
        <div className="sidebar-title" data-testid="sidebar-title">
          <Title />
        </div>
        <div className="sidebar-menu" data-testid="sidebar-menu">
          <MenuItems />
        </div>
        <div className="icon" onClick={handleCloseButton}
              data-testid="sidebar-close-button" tabIndex={0}>
          <IconClose />
        </div>
      </div>
      <div className="sidebar-content help-content" data-testid="sidebar-content">
        <Content />
      </div>
    </div>
  );
};
