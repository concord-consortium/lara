import * as React from "react";
import { ISectionItem } from "../api/api-types";
import { initPlugin } from "../../plugins/plugins";
import { IPluginRuntimeContextOptions } from "../../plugins/plugin-context";
import { useScript } from "../hooks/use-script";

export interface IPluginPreviewProps {
  pageItem: ISectionItem;
}

export const PluginPreview: React.FC<IPluginPreviewProps> = ({
  pageItem
  }: IPluginPreviewProps) => {

  const wrapperClasses = "plugin-preview-wrapper";

  const { data } = pageItem;
  const { componentLabel, url, label, name, authorData, pluginId} = data;

  const wrappedDiv = React.useRef<HTMLDivElement>(null);
  const containerDiv = React.useRef<HTMLDivElement>(null);
  const firebaseJwtUrl = "TODO:firebaseJwtUrl"; // NP 2022-05-26 TODO: from whence?
  const portalJwtUrl = "TODO:portalJwtUrl";     // NP 2022-05-26 TODO: from whence?

  const scriptStatus = useScript(label, url);

  const effectDeps = [
    wrappedDiv.current, containerDiv.current, firebaseJwtUrl,
    portalJwtUrl, label, url, authorData, scriptStatus
  ];

  // Hack: The only way to express teacher edition mode AFIK is to add it to
  // the query string. TE won't display without that query param.
  if (window.location.search.indexOf("mode=teacher-edition") < 0) {
    window.location.search = "?mode=teacher-edition";
  }

  const renderPluginPreview = () => {
    if (authorData) {
      const pluginContext: IPluginRuntimeContextOptions = {
        type: "runtime",
        learnerState: null,
        runId: 0,
        name,
        url,
        pluginId,
        componentLabel,
        authoredState: authorData || null,
        // Most of the runtime properties are null or blank
        // Because we are just previewing.
        learnerStateSaveUrl: "",
        remoteEndpoint: "",
        userEmail: "",
        classInfoUrl: "",
        embeddablePluginId: null,
        resourceUrl: "",
        offlineMode: false,
        container: containerDiv.current!,
        wrappedEmbeddable: null,
        firebaseJwtUrl,
        portalJwtUrl
      };
      initPlugin(label, pluginContext);
    }
  };

  React.useEffect(() => {
    if (containerDiv.current && scriptStatus === "ready") {
      renderPluginPreview();
    }
  }, effectDeps);

  return (
    <div className={wrapperClasses}>
      {name} <br/>
      <div className="plugin-authoring-container">
        <div ref={containerDiv}/>
        <div ref={wrappedDiv} />
      </div>
    </div>
  );
};
