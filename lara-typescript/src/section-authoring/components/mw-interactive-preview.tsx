import * as React from "react";
import classNames from "classnames";
import { IMWInteractiveData, ISectionItem } from "../api/api-types";
import { InteractiveAuthoringPreview } from "../../page-item-authoring/common/components/interactive-authoring-preview";

import "./mw-interactive-preview.scss";

export interface IMWInteractivePreviewProps {
  pageItem: ISectionItem;
}

export const MWInteractivePreview: React.FC<IMWInteractivePreviewProps> = ({
  pageItem
  }: IMWInteractivePreviewProps) => {
  const {
    aspectRatio, aspectRatioMethod, authoredState, id, interactiveItemId,
    isHalfWidth, name, linkedInteractives, url, fontSize, fontType,
   } = pageItem.data as IMWInteractiveData;

  const interactive = {
    id,
    name,
    url,
    aspect_ratio: aspectRatio,
    aspect_ratio_method: aspectRatioMethod,
    authored_state: authoredState,
    interactive_item_id: interactiveItemId,
    linked_interactives: linkedInteractives,
    font_size: fontSize,
    font_type: fontType,
  };

  const wrapperClasses = classNames("mwInteractive", {
    halfWidth: isHalfWidth
  });

  return (
    <div className={wrapperClasses}>
      <div className="mwInteractiveContent">
        <InteractiveAuthoringPreview interactive={interactive} />
      </div>
    </div>
  );
};
