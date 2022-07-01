import * as React from "react";
import { Editor } from "@tinymce/tinymce-react";
import "./sidebar-panel.scss";
import { usePageAPI } from "../../hooks/use-api-provider";

interface IRenderEditorProps {
  content: string ;
  handleChangeContent: (newContent: string) => void;
}

const RichEditor = (params: IRenderEditorProps) => {
  const api = usePageAPI();
  const { content, handleChangeContent } = params;
  const pathToTinyMCE = api.pathToTinyMCE;
  const pathToTinyMCECSS = api.pathToTinyMCECSS;
  const editorRef = React.useRef<any>(null);
  const initEditor = (e: any, editor: any) => {
    editorRef.current = editor;
  };
  const contentRef = React.useRef<HTMLTextAreaElement|null>(null);
  return(
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
    </>
  );
};
