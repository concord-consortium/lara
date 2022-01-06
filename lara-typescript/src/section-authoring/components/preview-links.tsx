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
  const [ previewLink, setPreviewLink ] = useState<string|false>(false);
  const [ previewer, setPreviewer ] = useState<string|undefined>("");

  const getKeyOfLink = (link: string) => {
    if (previewLinks) {
      return (Object.keys(previewLinks) as string[]).find(key => previewLinks[key] === link);
    }
  };
  const getLinkFromKey = (key: string) => {
    if (previewLinks) {
      return (previewLinks[key]);
    }
  };

  const handleLinkSelect = (evt: React.ChangeEvent<HTMLSelectElement>) => {
    const value = evt.currentTarget.value;
    if (value && value.length > 0) {
      setPreviewLink(value);
      setPreviewer(getKeyOfLink(value));
    }
    else {
      setPreviewLink(false);
    }
  };

  const handlePreviewButtonClick = () => {
    if (previewer) {
      const pageToPreview = getLinkFromKey(previewer);
      if (pageToPreview) {
        window.open(pageToPreview + "&author-preview=true", "_blank");
      }
    }
  };

  const renderPreviewOptions = () => {
    if (previewLinks) {
      return (
        <>
          <select id="preview-links-select" onChange={handleLinkSelect}>
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
            ? <button onClick={handlePreviewButtonClick}><ExternalLink/></button>
            : <button className="disabled"><ExternalLink/></button>
          }
        </>
      );
    }
    return (
        <span className="not-available">No preview link available</span>
    );
  };

  return (
      <div id="preview-links">
        <label htmlFor="preview-links-select">Preview in:</label>
        {renderPreviewOptions()}
      </div>
  );
};
