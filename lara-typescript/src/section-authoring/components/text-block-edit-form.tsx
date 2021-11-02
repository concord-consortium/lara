import * as React from "react";
import { useRef } from "react";
import { Editor } from "@tinymce/tinymce-react";
import { ISectionItem, ITextBlockData } from "../api/api-types";
import { usePageAPI } from "../hooks/use-api-provider";

import "./text-block-edit-form.scss";

export interface ITextBlockEditFormProps {
  pageItem: ISectionItem;
}

export const TextBlockEditForm: React.FC<ITextBlockEditFormProps> = ({
  pageItem
  }: ITextBlockEditFormProps) => {
  const { content, name, isCallout, isFullWidth } = pageItem?.data as ITextBlockData;
  const editorRef = useRef<any>(null);
  const initEditor = (e: any, editor: any) => {
    editorRef.current = editor;
  };
  const contentRef = useRef<HTMLTextAreaElement|null>(null);
  const api = usePageAPI();
  const pathToTinyMCE = api.pathToTinyMCE;
  const pathToTinyMCECSS = api.pathToTinyMCECSS;

  const handleChangeContent = () => {
    if (contentRef.current) {
      contentRef.current.value = editorRef.current.getContent();
    }
  };

  return (
    <>
      {pathToTinyMCE &&
        <textarea
          defaultValue={content}
          id="content"
          name="content"
          ref={contentRef}
          style={{ display: "none" }}
        />
      }
      <dl className="textBlockEditForm">
      <dt className="row1"><label htmlFor="name">Heading <span className="inputNote">optional</span></label></dt>
      <dd className="row1">
        <input
          defaultValue={name}
          id="name"
          name="name"
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
              content_css: pathToTinyMCECSS
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
          type="checkbox"
          />
      </dd>
      <dd className="inputNote row4">In full width layout only.</dd>
    </dl>
    </>
  );
};
