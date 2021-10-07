import * as React from "react";
import { useRef } from "react";
import { Editor } from "@tinymce/tinymce-react";
import { ISectionItem, ITextBlockData } from "../api/api-types";
import { usePageAPI } from "../api/use-api-provider";

import "./text-block-edit-form.scss";

export interface ITextBlockEditFormProps {
  pageItem: ISectionItem;
}

export const TextBlockEditForm: React.FC<ITextBlockEditFormProps> = ({
  pageItem
  }: ITextBlockEditFormProps) => {
  const { content, name, isCallout, isFullWidth } = pageItem.data as ITextBlockData;
  const editorRef = useRef(null);
  const initEditor = (e: any, editor: any) => {
    editorRef.current = editor;
  };
  const pathToTinyMCE = usePageAPI().pathToTinyMCE;
  const updatePageItem = usePageAPI().updatePageItem;

  const handleChangeName = (event: React.ChangeEvent<HTMLInputElement>) => {
    const nextItem = {...pageItem};
    nextItem.data.name = event.target.value;
    updatePageItem(nextItem);
  };

  const handleChangeContent = (value: any, editor: any) => {
    // content = value;
    // if (editorRef.current) {
    //   content = editorRef.current.getContent();
    // }
  };

  const handleTextareaChangeContent = (event: React.ChangeEvent<HTMLTextAreaElement>) => {
    const nextItem = {...pageItem};
    nextItem.data.content = event.target.value;
    updatePageItem(nextItem);
  };

  const handleChangeIsCallout = () => {
    const nextItem = {...pageItem};
    nextItem.data.isCallout = !isCallout;
    updatePageItem(nextItem);
  };

  const handleChangeIsFullWidth = () => {
    const nextItem = {...pageItem};
    nextItem.data.isFullWidth = !isFullWidth;
    updatePageItem(nextItem);
  };

  return (
    <dl className="textBlockEditForm">
      <dt className="row1"><label htmlFor="name">Heading <span className="inputNote">optional</span></label></dt>
      <dd className="row1">
        <input
          defaultValue={name}
          id="name"
          name="name"
          onChange={handleChangeName}
        />
      </dd>
      <dt className="row2">
        <label htmlFor="content">Content</label>
      </dt>
      <dd className="row2">
        {!pathToTinyMCE &&
          <textarea
            className="wysiwyg-minimal"
            defaultValue={content}
            id="content"
            name="content"
            onChange={handleTextareaChangeContent}
          />
        }
        {pathToTinyMCE &&
          <Editor
            tinymceScriptSrc={pathToTinyMCE}
            onInit={initEditor}
            initialValue={content}
            onEditorChange={handleChangeContent}
            init={{
              height: 300,
              menubar: false,
              statusbar: false,
              toolbar_items_size: "small",
              plugins: [
                "paste link hr image autoresize code lists"
              ],
              paste_as_text: true,
              image_class_list: [
                {title: "None", value: ""},
                {title: "Float left", value: "tinymce-img-float-left"},
                {title: "Float right", value: "tinymce-img-float-right"}
              ],
              autoresize_bottom_margin: 5,
              toolbar: "bold italic underline | " +
              "aligncenter alignleft alignright indent outdent | " +
              "subscript superscript | numlist bullist | link unlink | hr image | code",
              content_css: "/assets/tinymce-content.css"
            }}
          />
        }
      </dd>
      <dt className="row3">
        <label htmlFor="is-callout">Callout</label>
      </dt>
      <dd className="row3">
        <input
          defaultChecked={isCallout}
          id="is-callout"
          name="is_callout"
          onChange={handleChangeIsCallout}
          type="checkbox"
        />
      </dd>
      <dd className="inputNote row3">Displayed within a shaded box.</dd>
      <dt className="row4">
        <label htmlFor="is-full-width">Full Width</label>
      </dt>
      <dd className="row4">
        <input
          defaultChecked={isFullWidth}
          id="is-full-width"
          name="is_full_width"
          onChange={handleChangeIsFullWidth}
          type="checkbox"
          />
      </dd>
      <dd className="inputNote row4">In full width layout only.</dd>
    </dl>
  );
};
