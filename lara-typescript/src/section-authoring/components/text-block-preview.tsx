import * as React from "react";
import classNames from "classnames";
import { ISectionItem, ITextBlockData } from "../api/api-types";

import "./text-block-preview.scss";
import { renderHTML } from "../../shared/render-html";

export interface ITextBlockPreviewProps {
  pageItem: ISectionItem;
}

export const TextBlockPreview: React.FC<ITextBlockPreviewProps> = ({
  pageItem
  }: ITextBlockPreviewProps) => {
  const { content, isCallout, isHalfWidth, name } = pageItem.data as ITextBlockData;

  const wrapperClasses = classNames("textBlock", {
    callout: isCallout,
    halfWidth: isHalfWidth
  });

  return (
    <div className={wrapperClasses}>
      {name && <div className="textBlockName">
        {name}
      </div>}
      <div className="textBlockContent">
        {content && renderHTML(content)}
      </div>
    </div>
  );
};
