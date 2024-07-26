import classNames from "classnames";
import * as React from "react";
import { ReactNode, useState } from "react";

import "./rubric-panel.scss";

const Caret = ({expanded}: {expanded: boolean}) => {
  const transform = expanded ? "rotate(180 13 12)" : "";
  return (
    <svg width="26" height="24" viewBox="0 0 26 24" xmlns="http://www.w3.org/2000/svg">
      <g fill="none" fill-rule="evenodd">
        <circle cx="13" cy="12" r="11.75" fill="white"/>
        <path fill="#0592AF" fill-rule="nonzero" transform={transform}  d="M17.973 8.59 13 13.17 8.027 8.59 6.5 10l6.5 6 6.5-6z"/>
      </g>
    </svg>
  );
};

export interface IPanelProps {
  title: string;
  backgroundColor?: string;
  children: ReactNode;
}

export const RubricPanel = ({title, backgroundColor, children}: IPanelProps) => {
  const [expanded, setExpanded] = useState(true);

  const handleToggleExpanded = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setExpanded(prev => !prev);
  };

  const bodyClass = classNames("rubric-panel-body", {"rubric-panel-body-expanded": expanded});
  const bodyStyle: React.CSSProperties = {backgroundColor};

  return (
    <div className="rubric-panel">
      <div className="rubric-panel-header" onClick={handleToggleExpanded}>
        <div>{title}</div>
        <div>
          <Caret expanded={expanded} />
        </div>
      </div>
      <div className={bodyClass} style={bodyStyle}>
        {children}
      </div>
    </div>
  );
};
