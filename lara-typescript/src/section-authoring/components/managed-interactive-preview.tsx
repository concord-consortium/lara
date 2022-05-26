import * as React from "react";
import classNames from "classnames";
import { IManagedInteractiveData, ISectionItem } from "../api/api-types";
import { usePageAPI } from "../hooks/use-api-provider";
import { InteractiveAuthoringPreview } from "../../page-item-authoring/common/components/interactive-authoring-preview";

import "./managed-interactive-preview.scss";

export interface IManagedInteractivePreviewProps {
  pageItem: ISectionItem;
}

export const ManagedInteractivePreview: React.FC<IManagedInteractivePreviewProps> = ({
  pageItem
  }: IManagedInteractivePreviewProps) => {

  const {
    aspectRatio, authoredState, customAspectRatioMethod, id, interactiveItemId,
    isHalfWidth, name, libraryInteractiveId, linkedInteractives, urlFragment
  } = pageItem.data as IManagedInteractiveData;
  const { getLibraryInteractives } = usePageAPI();

  if (!authoredState) {
    return null;
  }

  const libraryInteractives = getLibraryInteractives.data?.libraryInteractives;
  const libraryInteractive = libraryInteractives?.find(i => i.id === libraryInteractiveId);
  const interactive = {
    id,
    name,
    url: `${libraryInteractive?.base_url}${urlFragment || ""}`,
    aspect_ratio: aspectRatio,
    aspect_ratio_method: customAspectRatioMethod ? customAspectRatioMethod : "",
    authored_state: authoredState,
    interactive_item_id: interactiveItemId,
    linked_interactives: linkedInteractives
  };

  const wrapperClasses = classNames("managedInteractive", {
    halfWidth: isHalfWidth
  });

  return (
    <div className={wrapperClasses}>
      <div className="managedInteractiveContent">
        {libraryInteractive && <InteractiveAuthoringPreview interactive={interactive} />}
      </div>
    </div>
  );
};
