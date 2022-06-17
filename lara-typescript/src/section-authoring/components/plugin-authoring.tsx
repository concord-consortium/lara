import * as React from "react";
import { initPlugin, setNextPluginLabel } from "../../plugins/plugins";
import { AuthoringApiUrls } from "../../page-item-authoring/common/types";
import { renderInteractiveAuthoringPreview } from "../../page-item-authoring";
import { IEmbeddableContextOptions, IPluginAuthoringContextOptions } from "../../plugins/plugin-context";
import { ISectionItem } from "../api/api-types";
import { useGetPageItemEmbeddableExport, usePageAPI } from "../hooks/use-api-provider";

export interface PluginAuthoringProps {
  pageItem: ISectionItem;
  authoringApiUrls: AuthoringApiUrls;
  onUpdate?: (authorData: string) => void;
  closeForm?: () => void;
  wrappedItem?: ISectionItem;
}

export const PluginAuthoring: React.FC<PluginAuthoringProps> = (
  props: PluginAuthoringProps
  ) => {
  const { pageItem, authoringApiUrls, onUpdate, closeForm, wrappedItem } = props;
  const { data } = pageItem;
  const { componentLabel, url, label, name, authorData, pluginId } = data;
  const api = usePageAPI();

  const wrappedDiv = React.useRef<HTMLDivElement|null>(null);
  const containerDiv = React.useRef<HTMLDivElement|null>(null);

  const libraryInteractiveId = wrappedItem?.data?.libraryInteractiveId;
  const libraryInteractives = api.getLibraryInteractives.data?.libraryInteractives;
  const libraryInteractive = libraryInteractives?.find(i => i.id === libraryInteractiveId);
  const wrappedInteractiveUrl = wrappedItem?.type === "MwInteractive"
                                  ? wrappedItem?.data.url
                                  : `${libraryInteractive?.base_url}${wrappedItem?.data?.urlFragment || ""}`;
  const wrappedInteractive = wrappedItem ? {
    id: parseFloat(wrappedItem.id),
    name: wrappedItem?.data.name,
    url: wrappedInteractiveUrl,
    aspect_ratio: wrappedItem?.data.aspectRatio,
    aspect_ratio_method: wrappedItem?.data.customAspectRatioMethod ? wrappedItem?.data.customAspectRatioMethod : "",
    authored_state: wrappedItem?.data.authoredState,
    interactive_item_id: wrappedItem?.data.interactiveItemId,
    linked_interactives: wrappedItem?.data.linkedInteractives
  } : undefined;

  const wrappedItemJson = useGetPageItemEmbeddableExport(wrappedItem?.id);
  const wrappedEmbeddable: IEmbeddableContextOptions | null = wrappedItemJson && wrappedDiv.current !== null
    ?  {
        container: wrappedDiv.current,
        laraJson: wrappedItemJson ? wrappedItemJson.data : undefined,
        interactiveStateUrl: null,
        interactiveAvailable: true
      }
    : null;

  const firebaseJwtUrl = "TODO:firebaseJwtUrl"; // NP 2022-05-26 TODO: from whence?
  const portalJwtUrl = "TODO:portalJwtUrl";     // NP 2022-05-26 TODO: from whence?
  const authorDataSaveUrl = authoringApiUrls.update_plugin_author_data || "";
  const effectDeps = [
    wrappedDiv.current, containerDiv.current, firebaseJwtUrl,
    portalJwtUrl, authorDataSaveUrl, label, url
  ];

  const existingTEAuthoringScript = document.getElementById("plugin-authoring-script");

  const renderPluginAuthoring = () => {
    setNextPluginLabel(label);
    const pluginContext: IPluginAuthoringContextOptions = {
      type: "authoring",
      name,
      url,
      pluginId,
      componentLabel,
      authoredState: authorData || null,
      container: containerDiv.current!,
      wrappedEmbeddable,
      saveAuthoredPluginState: (authoredPluginState: string) => {
        onUpdate?.(authoredPluginState);
        return Promise.resolve(authoredPluginState);
      },
      closeAuthoredPluginForm: closeForm,
      authorDataSaveUrl,
      firebaseJwtUrl,
      portalJwtUrl
    };
    initPlugin(label, pluginContext);
    if (wrappedInteractive && wrappedDiv.current && wrappedEmbeddable) {
      renderInteractiveAuthoringPreview(wrappedDiv.current, {
        interactive: wrappedInteractive,
        user: {
          loggedIn: true,
          authProvider: null,
          email: null
        }
      });
    }
  };

  const loadPluginScript = () => {
    const script = document.createElement("script");
    script.id = "plugin-authoring-script";
    script.onload = renderPluginAuthoring;
    script.onerror = (e) => alert(`Unable to load plugin script: ${url} ${e} ${script.src}`);
    script.src = url;
    document.head.append(script);
  };

  React.useEffect(() => {
    return () => {
      if (existingTEAuthoringScript) {
        existingTEAuthoringScript.remove();
      }
    };
  }, []);

  React.useEffect(() => {
    if (wrappedDiv.current && wrappedEmbeddable) {
      renderPluginAuthoring();
    }
  }, [wrappedDiv.current, wrappedEmbeddable]);

  React.useEffect(() => {
    // TODO: Make it so we're only adding the plugin script to the page once.
    // For some reason this attempt at doing that is causing the page to
    // crash the very first time you add a TE element to a page.
    // if (existingTEAuthoringScript) {
    //   renderPluginAuthoring();
    //   return;
    // }
    if (!(url && containerDiv.current) || (wrappedItem && !wrappedDiv.current)) {
      return;
    }
    loadPluginScript();
  }, effectDeps);

  return(
    <div className="plugin-authoring-container">
      <div ref={containerDiv}/>
      <div ref={wrappedDiv} />
    </div>
  );
};
