import * as React from "react";
import { renderInteractiveAuthoringPreview } from "../../page-item-authoring";
import { initPlugin, setNextPluginLabel } from "../../plugins/plugins";
import { AuthoringApiUrls } from "../../page-item-authoring/common/types";
import { IPluginAuthoringContextOptions } from "../../plugins/plugin-context";
import { PageItemAuthoring } from "../..";
import { ISectionItem } from "../api/api-types";
const maxWidth = "75vw";
const maxHeight = "75vh";

interface IApprovedScript {
  authoring_metadata: string;
  description: string;
  label: string;
  name: string;
  url: string;
  version: 3;
}

export interface PluginAuthoringProps {
  pageItem: ISectionItem;
  authoringApiUrls: AuthoringApiUrls;
}

export const PluginAuthoringOld: React.FC<PluginAuthoringProps> = (
  { pageItem }: PluginAuthoringProps) => {
  const  {id, data } = pageItem;
  const { embeddableId } = data;
  const style = {
    width: maxWidth,
    height: maxHeight,
  };
  const iFrameSrc = `/embeddable/embeddable_plugins/${embeddableId}/edit`;
  return (
    <>
      <iframe style={style} src={iFrameSrc} width={maxWidth} height={maxHeight}/>
    </>
  );
};

export const PluginAuthoring: React.FC<PluginAuthoringProps> = (
  props: PluginAuthoringProps) => {
  const { pageItem, authoringApiUrls } = props;
  console.log(authoringApiUrls);
  const { data } = pageItem;
  const { plugin, embeddableId } = data;
  const { approved_script, id, component_label, author_data } = plugin;
  const { authoring_metadata, url, label, name } = approved_script;

  const wrappedDiv = React.useRef<HTMLDivElement>(null);
  const containerDiv = React.useRef<HTMLDivElement>(null);
  const firebaseJwtUrl = "firebaseJwtUrl"; // NP 2022-05-26 TODO:
  const portalJwtUrl = "portalJwtUrl";     // NP 2022-05-26 TODO:
  // Rails ROUTES for saving/loading data:
  // match 'plugins/:plugin_id/author_data'
  // => 'plugins#load_author_data', as: 'show_plugin_author_data', via: 'get'
  // match 'plugins/:plugin_id/author_data'
  // => 'plugins#save_author_data', as: 'update_plugin_author_data', via: 'put'
  const authorDataSaveUrl = "foo"; // pluginAuthorDataUrl(id); NP 2022-05-26 TODO:
  const effectDeps = [
    wrappedDiv.current, containerDiv.current, firebaseJwtUrl,
    portalJwtUrl, authorDataSaveUrl, id, label, url
  ];
  React.useEffect(() => {
    if (!(plugin && url && containerDiv.current)) return;
    const script = document.createElement("script");
    script.onload = () => {
      setNextPluginLabel(label);
      const pluginContext: IPluginAuthoringContextOptions = {
        type: "authoring",
        name,
        url,
        pluginId: id,
        componentLabel: component_label,
        authoredState: author_data ? author_data : null,
        container: containerDiv.current!,
        wrappedEmbeddable: null,
        /**** TODO: Handle Wrapped Embeddable
         #{!wrapped_embeddable ? 'null' : "{
          container: wrappedDiv,
          laraJson: #{wrapped_embeddable_lara_json},
          interactiveStateUrl: null,
          interactiveAvailable: #{!click_to_play}
        }"},
        **/
        authorDataSaveUrl,
        firebaseJwtUrl,
        portalJwtUrl
      };
      console.log(`Adding ${name} authoring plugin as ${label} with V3 LARA Plugin AP`);
      initPlugin(label, pluginContext);
      // if ($('#wrapped_embeddable').length > 0) {
      //   const interactiveContainer = $('#wrapped_embeddable').find('.interactive-container')[0];
      //   renderInteractiveAuthoringPreview(interactiveContainer, {
      //     interactive: #{wrapped_embeddable && defined?(wrapped_embeddable.to_authoring_preview_hash) ? wrapped_embeddable.to_authoring_preview_hash().to_json : 'null'},
      //     user: #{userInfo.to_json}
      //   });
      // }
    },
    script.onerror = (e) => alert(`Unable to load plugin script: ${url} ${e} ${script.src}`);
    script.src = url;
    document.head.append(script);
  }, effectDeps);

  return(
    <div className="plugin-authoring-container">
      Plugin Authoring:
      <div ref={containerDiv}/>
      <div ref={wrappedDiv} />
      <div className="plugin-info">
        <pre>
          id: {plugin.id}
          <br/>
          name: {name}
          <br/>
          label: {label}
          <br/>
          urL: {url}
          <br/>
        </pre>
      </div>
    </div>
  );
};
