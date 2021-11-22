import * as React from "react";

import { IPreviewLinksProps, PreviewLinks } from "../components/preview-links";
import { usePageAPI } from "../hooks/use-api-provider";

export const PreviewLinksContainer: React.FC = () => {
  const {getPreviewOptions } = usePageAPI();
  const previewLinks = getPreviewOptions.data || null;
  const props: IPreviewLinksProps = { previewLinks };
  return <PreviewLinks {...props} />;
};
