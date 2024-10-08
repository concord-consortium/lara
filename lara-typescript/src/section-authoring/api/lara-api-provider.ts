import { camelToSnakeCaseKeys, snakeToCamelCaseKeys } from "../../shared/convert-keys";
import {
  IAuthoringAPIProvider,
  IPage, PageId, ISection, ICreatePageItem, ItemId,
  APIPageGetF, APIPagesGetF,
  APIPageCreateF, APIPageUpdateF, APIPageDeleteF,
  APISectionCreateF, APISectionsUpdateF, APISectionUpdateF,
  APIPageItemCreateF, APIPageItemUpdateF,
  ILibraryInteractive, ILibraryInteractiveResponse,
  IPlugin,
  IPortal,
  APIPageItemDeleteF,
  ISectionItem,
  APISectionCopyF,
  SectionId,
  APIPageItemCopyF,
  APIPageCopyF,
  ISectionItemType
} from "./api-types";
import { IPluginType } from "./plugin-types";

const APIBase = "/api/v1";

interface IGetLARAAuthoringAPIParams {
  activityId: string;
  host: string;
  isAdmin: boolean;
}

export const getLaraAuthoringAPI =
  (authoringArgs: IGetLARAAuthoringAPIParams = {
    activityId: "",
    host: window.location.origin,
    isAdmin: false
  }): IAuthoringAPIProvider => {
  const { activityId, host, isAdmin } = authoringArgs;
  const prefix = `${host}${APIBase}`;
  // endpoints:

  const getPagesUrl = `${prefix}/get_pages/${activityId}.json`;
  const getPageUrl = (pageId: PageId) => `${prefix}/get_page/${pageId}.json`;
  const createPageUrl = `${prefix}/create_page/${activityId}.json`;
  const updatePageUrl = (pageId: PageId) => `${prefix}/update_page/${pageId}.json`;
  const deletePageUrl = (pageId: PageId) => `${prefix}/delete_page/${pageId}.json`;
  const copyPageUrl = (pageId: PageId) => `${prefix}/copy_page/${pageId}.json`;

  const pageSectionsUrl = (pageId: PageId) => `${prefix}/get_page_sections/${pageId}.json`;
  const updatePageSectionsURL = (pageId: PageId) => `${prefix}/set_page_sections/${pageId}.json`;
  const createPageSectionUrl = (pageId: PageId) => `${prefix}/create_page_section/${pageId}.json`;
  const updateSectionUrl = (pageId: PageId) => `${prefix}/update_page_section/${pageId}.json`;
  const copySectionUrl = (pageId: PageId) => `${prefix}/copy_page_section/${pageId}.json`;
  const createPageItemUrl = (pageId: PageId) => `${prefix}/create_page_item/${pageId}.json`;
  const updatePageItemUrl = (pageId: PageId) => `${prefix}/update_page_item/${pageId}.json`;
  const deletePageItemUrl = (pageId: PageId) => `${prefix}/delete_page_item/${pageId}.json`;
  const copyPageItemUrl = (pageId: PageId) => `${prefix}/copy_page_item/${pageId}.json`;
  const getPreviewUrl = (pageId: PageId) => `${prefix}/get_preview_url/${pageId}.json`;
  const libraryInteractivesUrl = `${prefix}/get_library_interactives_list.json`;
  const pageLevelPluginsUrl = `${prefix}/get_page_level_plugins_list.json`;
  const portalsURL = `${prefix}/get_portal_list.json`;
  const pluginsURL = `${prefix}/get_wrapping_plugins_list.json`;
  const pageItemPluginsURL = (pageItemId: string) => `${prefix}/get_page_item_plugins/${pageItemId}.json`;
  const pageItemEmbeddableMetaDataURL = (pageItemId: string) => `${prefix}/get_embeddable_metadata/${pageItemId}.json`;

  interface ISendToLaraParams {
    url: string;
    method?: "GET" | "POST" | "PUT" ;
    body?: any;
    headers?: { "Content-Type": "application/json" };
    credentials?: "include";
  }

  const sendToLara = (params: ISendToLaraParams) => {
    const {url, method = "GET", body = null} = params;
    const options: Omit<ISendToLaraParams, "url"> = {
      method,
      headers: { "Content-Type": "application/json" },
      credentials: "include"
    };
    if (body) {
      options.body = JSON.stringify(body);
    }
    return fetch(url, options)
      .then(res => {
        return res.json();
      });
  };

  const getPages: APIPagesGetF = () => {
    if (activityId) {
      return sendToLara({url: getPagesUrl}).then(data => {
        return Promise.resolve(data.map((page: any) => snakeToCamelCaseKeys(page)));
      });
    }
    return Promise.reject("No activity ID specified.");
  };

  const getPage: APIPageGetF = (id: PageId) => {
    return sendToLara({url: getPageUrl(id)});
  };

  const createPage: APIPageCreateF = () => {
    return sendToLara({url: createPageUrl, method: "POST"});
  };

  const updatePage: APIPageUpdateF = async (args: {pageId: PageId, changes: Partial<IPage>}) => {
    const {pageId, changes} = args;
    const data = { id: pageId,
                   page: { id: pageId,
                           name: changes.name,
                           isCompletion: changes.isCompletion,
                           isHidden: changes.isHidden,
                           showSidebar: changes.showSidebar,
                           sidebar: changes.sidebar,
                           sidebarTitle: changes.sidebarTitle
                         }
                 };
    return sendToLara({url: updatePageUrl(pageId), method: "PUT", body: data});
  };

  const deletePage: APIPageDeleteF = (id: PageId) => {
    return sendToLara({url: deletePageUrl(id), method: "POST"});
  };

  const copyPage: APIPageCopyF = (args: {pageId: PageId, destIndex: number}) => {
    const {pageId, destIndex} = args;
    const body = { dest_index: destIndex };
    return sendToLara({url: copyPageUrl(pageId), method: "POST", body});
  };

  const createSection: APISectionCreateF = (id: PageId) => {
    return sendToLara({url: createPageSectionUrl(id), method: "POST"});
  };

  const copySection: APISectionCopyF = (args: {pageId: PageId, sectionId: SectionId}) => {
    const { pageId, sectionId } = args;
    const body = { section_id: sectionId };
    return sendToLara({url: copySectionUrl(pageId), method: "POST", body});
  };

  const updateSections: APISectionsUpdateF = (nextPage: IPage) => {
    return sendToLara({url: updatePageSectionsURL(nextPage.id), method: "PUT", body: nextPage});
  };

  const updateSection: APISectionUpdateF = (args: {pageId: PageId, changes: { section: Partial<ISection> }}) => {
    const {pageId, changes} = args;
    const data = { id: pageId, section: { ...changes.section } };
    return sendToLara({url: updateSectionUrl(pageId), method: "POST", body: data});
  };

  const createPageItem: APIPageItemCreateF = (args: {pageId: PageId, newPageItem: ICreatePageItem}) => {
    const body = { page_item: args.newPageItem };
    return sendToLara({url: createPageItemUrl(args.pageId), method: "POST", body});
  };

  const updatePageItem: APIPageItemUpdateF = (args: {pageId: string, sectionItem: ISectionItem}) => {
    const pageItem = args.sectionItem;
    const pageItemData = pageItem.data;
    const translatedData = camelToSnakeCaseKeys(pageItemData);
    pageItem.data = translatedData;
    const body = { page_item: pageItem };
    return sendToLara({url: updatePageItemUrl(args.pageId), method: "POST", body});
  };

  const deletePageItem: APIPageItemDeleteF = (args: {pageId: PageId, pageItemId: ItemId}) => {
    const { pageId, pageItemId } = args;
    const body = { page_item_id: pageItemId };
    return sendToLara({url: deletePageItemUrl(pageId), method: "POST", body});
  };

  const copyPageItem: APIPageItemCopyF = (args: {pageId: PageId, sectionItemId: ItemId}) => {
    const { pageId, sectionItemId } = args;
    const body = { page_item_id: sectionItemId };
    return sendToLara({url: copyPageItemUrl(pageId), method: "POST", body});
  };

  const getLibraryInteractives = () => {
    return sendToLara({url: libraryInteractivesUrl})
      // tslint:disable-next-line
      .then( (json: any) => {
        const result = {
          libraryInteractives: json.library_interactives.map((li: ILibraryInteractive) => ({...li}))
        };
        return result;
      });
  };

  const getPortals = () => {
    return sendToLara({url: portalsURL})
    // tslint:disable-next-line
    .then( (json: any) => {
      const result = {
        portals: json.portals.map((p: IPortal) => ({...p}))
      };
      return result;
    });
  };

  const mapPluginToEmbeddable = (plugin: IPluginType): ISectionItemType[]  => {
    const { authoring_metadata } = plugin;
    const { components } = authoring_metadata;
    const embeddables = [];
    for (const component of components) {
      const { label, name, scope } = component;
      if (scope === "embeddable") {
        embeddables.push({
          name: `${plugin.name}: ${name}`,
          id: `Plugin::${label}`,
          serializeable_id: `Plugin_${plugin.id}::${label}`, // TODO?
          type: `Plugin::${plugin.label}`,
          useCount: 0,
          dateAdded: 0,
          isQuickAddItem: false,
          // since there is no official column for plugins in the model
          // we force it to true here so it shows in the item picker for non-admins
          official: true,
        });
      }
    }
    return embeddables;
  };

  const getPageItemEmbeddableMetaData = (pageItemId: ItemId) => {
    return sendToLara({url: pageItemEmbeddableMetaDataURL(pageItemId), method: "GET"})
    // tslint:disable-next-line
    .then( (json: any) => {
      const result = snakeToCamelCaseKeys(json);
      return result;
    });
  };

  const getAvailablePlugins = () => {
    return sendToLara({url: pluginsURL})
    // tslint:disable-next-line
    .then( (json: any) => {
      const result = {
        plugins: json.plugins.map((p: IPlugin) => ({...p}))
      };
      return result;
    });
  };

  const getPageItemPlugins = (pageItemId: ItemId) => {
    return sendToLara({url: pageItemPluginsURL(pageItemId), method: "GET"})
    // tslint:disable-next-line
    .then( (json: any) => {
      const result = {
        pageItemPlugins: json.plugins.map((p: IPlugin) => (snakeToCamelCaseKeys({...p})))
      };
      return result;
    });
  };

  const getAllEmbeddables = () => {
    return sendToLara({url: libraryInteractivesUrl})
      // tslint:disable-next-line
      .then( (json: any) => {
        const result = {
          allEmbeddables: json.library_interactives.map((li: ILibraryInteractive) => ({...li})),
        };
        result.allEmbeddables.push({
          id: "MwInteractive",
          serializeable_id: "MwInteractive",
          name: "Interactive IFrame",
          type: "MwInteractive",
          useCount: 0,
          dateAdded: 0,
          isQuickAddItem: true,
          official: true,
        });
        result.allEmbeddables.push({
          id: "Embeddable::Xhtml",
          serializeable_id: "Embeddable::Xhtml",
          name: "Text Block",
          type: "Embeddable::Xhtml",
          useCount: 0,
          dateAdded: 0,
          isQuickAddItem: true,
          official: true,
        });
        const plugins = (json.plugins as IPluginType[]);
        for (const plugin of plugins) {
          result.allEmbeddables = result.allEmbeddables.concat(mapPluginToEmbeddable(plugin));
        }
        return result;
      });
  };

  const getPreviewOptions = (args: {pageId: PageId}) => {
    const { pageId } = args;
    if (pageId) {
      return sendToLara({url: getPreviewUrl(args.pageId)});
    }
    return Promise.resolve(null);
  };

  return {
    getPages, getPage, createPage, updatePage, deletePage, copyPage,
    createSection, updateSections, updateSection, copySection, getPageItemPlugins,
    createPageItem, updatePageItem, deletePageItem, copyPageItem, getAvailablePlugins,
    getAllEmbeddables, getLibraryInteractives, getPortals, getPreviewOptions, getPageItemEmbeddableMetaData,
    pathToTinyMCE: "/assets/tinymce.js", pathToTinyMCECSS: "/assets/tinymce-content.css",
    isAdmin
  };
};
