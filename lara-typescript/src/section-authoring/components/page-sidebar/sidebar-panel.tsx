import React, { ChangeEvent, useRef, useState} from "react";
import { IconClose } from "./icon-close";
import { renderHTML } from "../../../shared/render-html";
import { accessibilityClick } from "../../util/accessibility-helper";
import { Editor } from "@tinymce/tinymce-react";
import "./sidebar-panel.scss";
import { classNames } from "react-select/src/utils";
import { usePageAPI } from "../../hooks/use-api-provider";

interface IRenderEditorProps {
  content: string ;
  handleChangeContent: (newContent: string) => void;
}

// TODO: Wedge in TinyMCE using `import {RichEditor} from './rich-editor'`
const RichEditor = (params: IRenderEditorProps) => {
  const { content, handleChangeContent } = params;
  const handleTextChange = (evt: ChangeEvent<HTMLTextAreaElement>) => {
    handleChangeContent(evt.target.value);
  };
  return(
    <textarea
      className="wysiwyg-minimal"
      defaultValue={content}
      id="content"
      name="content"
      onChange={handleTextChange}
    />
  );
};

interface ISidebarPanelProps {
  handleCloseSidebarContent: (index: number, show: boolean) => void;
  index: number;
  content: string;
  title: string;
  show: boolean;
}

export const SidebarPanel = (props: ISidebarPanelProps) => {
  const [editMode, setEditMode] = useState(false);
  const [title, setTitle] = useState(props.title);
  const [content, setContent] = useState(props.content);
  const toggleEditMode = () => setEditMode(!editMode);
  const titleRef = useRef<HTMLInputElement>(null);
  const contentRef = useRef<HTMLTextAreaElement>(null);

  const handleSave = () => {
    if (titleRef.current) {
      setTitle(titleRef.current.value);
    }
    if (contentRef.current) {
      setContent(contentRef.current.value);
    }
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
      return <textarea ref={contentRef} defaultValue={content} />;
      // return <>renderHTML(innerContent)</>;
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
        <div className="sidebar-title" data-cy="sidebar-title">
          <Title />
        </div>
        <div className="sidebar-menu" data-cy="sidebar-menu">
          <MenuItems />
        </div>
        <div className="icon" onClick={handleCloseButton}
              data-cy="sidebar-close-button" tabIndex={0}>
          <IconClose />
        </div>
      </div>
      <div className="sidebar-content help-content" data-cy="sidebar-content">
        <Content />
      </div>
    </div>
  );
};

