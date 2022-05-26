import * as React from "react";
import { ISectionItem, ITextBlockData } from "../api/api-types";

export interface IPluginPreviewProps {
  pageItem: ISectionItem;
}

export const PluginPreview: React.FC<IPluginPreviewProps> = ({
  pageItem
  }: IPluginPreviewProps) => {

  const wrapperClasses = "plugin-preview-wrapper";

  const data = pageItem.data;
  const pageItemDeets = JSON.stringify(pageItem, null, 2);
  const dataString = JSON.stringify(data, null, 2);

  const name = "Plugin - Teacher Edition: WindowShade";
  return (
    <div className={wrapperClasses}>
      <div className="textBlockName">
        {name}
      </div>
      {/* <div className="data">
        <pre style={{overflow: "auto"}}>
          {dataString}
        </pre>
        <pre style={{overflow: "auto"}}>
          {pageItemDeets}
        </pre>
      </div> */}
    </div>
  );
};
