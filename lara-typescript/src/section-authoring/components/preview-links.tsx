import * as React from "react";
import { useState } from "react";
import {ExternalLink } from "../../shared/components/icons/external-link-icon";

import "./preview-links.scss";

export interface IPreviewLinksProps {
  previewLinks: Record<string, string> | null;
}

export const PreviewLinks: React.FC<IPreviewLinksProps> =
  (props: IPreviewLinksProps) => {

  const { previewLinks } = props;
  const [ previewLink, setPreviewLink] = useState<string|false>(false);

  const handleLinkSelect = (evt: React.ChangeEvent<HTMLSelectElement>) => {
    const value = evt.currentTarget.value;
    if (value && value.length > 0) {
      setPreviewLink(value);
    }
    else {
      setPreviewLink(false);
    }
  };

  const renderPreviewOptions = () => {
    if (previewLinks) {
      return (
        <span className="links-list" >
          <select onChange={handleLinkSelect}>
            { Object.keys(previewLinks).map(label => {
              return (
                  <option key={label} value={previewLinks[label]} >
                    {label}
                  </option>
                );
              })
            }
          </select>
          { previewLink
            ? <a href={previewLink} target="_blank"><ExternalLink/></a>
            : <span className="disabled"><ExternalLink/></span>
          }
        </span>
      );
    }
    return (
        <span className="not-available">No preview link available</span>
    );
  };

  return (
      <div className="preview-links">
        <span>Preview in:</span>
        {renderPreviewOptions()}
      </div>
  );
};
