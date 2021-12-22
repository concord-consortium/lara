import * as React from "react";
import * as DOMPurify from "dompurify";
import parse from "html-react-parser";
import classNames from "classnames";
import { ISectionItem, ITextBlockData } from "../api/api-types";

import "./text-block-preview.scss";

export interface ITextBlockPreviewProps {
  pageItem: ISectionItem;
}

export const TextBlockPreview: React.FC<ITextBlockPreviewProps> = ({
  pageItem
  }: ITextBlockPreviewProps) => {
  const { content, isCallout, isHalfWidth, name } = pageItem.data as ITextBlockData;

  const processContent = () => {
    return content ? parse(DOMPurify.sanitize(content)) : "";
  };

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
        {processContent()}
      </div>
    </div>
  );
};
