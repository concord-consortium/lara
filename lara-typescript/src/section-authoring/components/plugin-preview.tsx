import * as React from "react";
import { ISectionItem } from "../api/api-types";
import { initPlugin, setNextPluginLabel } from "../../plugins/plugins";
import { IPluginRuntimeContextOptions } from "../../plugins/plugin-context";
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

  const effectDeps = [
    wrappedDiv.current, containerDiv.current, firebaseJwtUrl,
    portalJwtUrl, label, url, authorData
  ];

  // Hack: The only way to express teacher edition mode AFIK is to add it to
  // the query string. TE won't display without that query param.
  const maybeAddTeacherEditionParams = () => {
    if (window.location.search.indexOf("mode=teacher-edition") < 0) {
      window.location.search = "?mode=teacher-edition";
    }
  };

  React.useEffect(() => {
    if (!(url && containerDiv.current)) return;
    const script = document.createElement("script");
    maybeAddTeacherEditionParams();
    script.onload = () => {
      if (authorData) {
        setNextPluginLabel(label);
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
          /**** TODO: Handle Wrapped Embeddable for other plugin types
           #{!wrapped_embeddable ? 'null' : "{
            container: wrappedDiv,
            laraJson: #{wrapped_embeddable_lara_json},
            interactiveStateUrl: null,
            interactiveAvailable: #{!click_to_play}
          }"},
            if ($('#wrapped_embeddable').length > 0) {
            const interactiveContainer = $('#wrapped_embeddable').find('.interactive-container')[0];
            renderInteractiveAuthoringPreview(interactiveContainer, {
            interactive: #{wrapped_embeddable
                && defined?(wrapped_embeddable.to_authoring_preview_hash)
                ? wrapped_embeddable.to_authoring_preview_hash().to_json
                : 'null'},
            user: #{userInfo.to_json}
          });
        }
          **/
          firebaseJwtUrl,
          portalJwtUrl
        };
        initPlugin(label, pluginContext);
      }
    },
    script.onerror = (e) => alert(`Unable to load plugin script: ${url} ${e} ${script.src}`);
    script.src = url;
    document.head.append(script);
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
