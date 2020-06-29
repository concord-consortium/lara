import * as React from "react";
import { useState, useEffect, useRef } from "react";

interface Props {
  id: string;
  name: string;
  authoredState: string;
}

const prettyAuthoredState = (authoredState: string) => {
  try {
    const json = JSON.parse(authoredState);
    return JSON.stringify(json, null, 2);
  } catch (e) {
    return "{}";
  }
};

const useValidateAuthoredState = (_authoredState: string) => {
  const [authoredState, setAuthoredState] = useState(_authoredState);
  const [isValidJSON, setIsValidJSON] = useState(true);

  useEffect(() => {
    try {
      JSON.parse(authoredState);
      setIsValidJSON(true);
    } catch (e) {
      setIsValidJSON(false);
    }
  }, [authoredState]);

  return {isValidJSON, setAuthoredState};
};

export const AuthoredState: React.FC<Props> = ({id, name, authoredState}) => {
  const [edit, setEdit] = useState(false);
  const {isValidJSON, setAuthoredState} = useValidateAuthoredState(authoredState);
  const prettyState = prettyAuthoredState(authoredState);
  const textareaRef = useRef<HTMLTextAreaElement|null>(null);

  const handleEditChange = () => {
    if (textareaRef.current) {
      // this is only here to check if the JSON is valid, the text area is not a controlled component
      setAuthoredState(textareaRef.current.value);
    }
  };

  const renderEditMode = () => {
    const style: React.CSSProperties = {width: "98%", height: "200px", border: "1px solid #aaa", outline: "none"};
    return (
      <textarea ref={textareaRef} onChange={handleEditChange} id={id} name={name} style={style}>
        {prettyState}
      </textarea>
    );
  };

  const renderReadOnlyMode = () => {
    return (
      <div style={{padding: 10, border: "1px solid #aaa", whiteSpace: "pre"}}>
        {prettyState}
      </div>
    );
  };

  const handleToggleEdit = () => {
    setEdit(!edit);
    if (!edit) {
      setTimeout(() => textareaRef.current?.focus(), 1);
    }
  };

  const editCheckboxLabel = "Edit authored state";

  return (
    <div>
      {edit ? renderEditMode() : renderReadOnlyMode()}
      <div style={{marginTop: 5}}>
        {isValidJSON ? "JSON is valid" : <span style={{color: "#f00"}}>JSON is INVALID!</span>}
      </div>
      <p>
        <input type="checkbox" checked={edit} onChange={handleToggleEdit} /> {editCheckboxLabel}
      </p>
      {edit ? <p>
        <strong>Note:</strong> any changes you make on the Authoring tab will be superseded
        by any changes made here when you save.<br/>You must leave the "{editCheckboxLabel}" checkbox
        enabled for your changes to be saved.
      </p> : undefined}
    </div>
  );
};
