import { stringify } from "uuid";
import { camelToSnakeCaseKeys } from "../../shared/convert-keys";
import {
  IAuthoringAPIProvider,
  IPage, PageId, ISection, ICreatePageItem, ItemId,
  APIPageGetF, APIPagesGetF,
  APIPageCreateF, APIPageDeleteF,
  APISectionCreateF, APISectionsUpdateF, APISectionUpdateF,
  APIPageItemCreateF, APIPageItemUpdateF,
  ILibraryInteractive, ILibraryInteractiveResponse, ILibraryInteractiveDetails,
  APIPageItemDeleteF,
  ISectionItem
} from "./api-types";

const APIBase = "/api/v1";

export const getLaraAuthoringAPI =
  (activityId: string, host: string = window.location.origin): IAuthoringAPIProvider => {

  const prefix = `${host}${APIBase}`;
  // endpoints:

  const getPagesUrl = `${prefix}/get_pages/${activityId}.json`;
  const getPageUrl = (pageId: PageId) => `${prefix}/get_page/${pageId}.json`;
  const createPageUrl = `${prefix}/create_page/${activityId}.json`;
  const deletePageUrl = (pageId: PageId) => `${prefix}/delete_page/${pageId}.json`;
  const pageSectionsUrl = (pageId: PageId) => `${prefix}/get_page_sections/${pageId}.json`;
  const updatePageSectionsURL = (pageId: PageId) => `${prefix}/set_page_sections/${pageId}.json`;
  const createPageSectionUrl = (pageId: PageId) => `${prefix}/create_page_section/${pageId}.json`;
  const updateSectionUrl = (pageId: PageId) => `${prefix}/update_page_section/${pageId}.json`;
  const createPageItemUrl = (pageId: PageId) => `${prefix}/create_page_item/${pageId}.json`;
  const updatePageItemUrl = (pageId: PageId) => `${prefix}/update_page_item/${pageId}.json`;
  const deletePageItemUrl = (pageId: PageId) => `${prefix}/delete_page_item/${pageId}.json`;
  const libraryInteractivesUrl = `${prefix}/get_library_interactives.json`;
  const libraryInteractivesListUrl = `${prefix}/get_library_interactives_list.json`;

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
    return sendToLara({url: getPagesUrl});
  };

  const getPage: APIPageGetF = (id: PageId) => {
    return sendToLara({url: getPageUrl(id)});
  };

  const createPage: APIPageCreateF = () => {
    return sendToLara({url: createPageUrl, method: "POST"});
  };

  const deletePage: APIPageDeleteF = (id: PageId) => {
    return sendToLara({url: deletePageUrl(id), method: "POST"});
  };

  const createSection: APISectionCreateF = (id: PageId) => {
    return sendToLara({url: createPageSectionUrl(id), method: "POST"});
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

  const useLibraryInteractives = () => {
    return sendToLara({url: libraryInteractivesUrl})
      // tslint:disable-next-line
      .then( (json: any) => {
        const result = {
          libraryInteractives: json.library_interactives.map((li: ILibraryInteractiveDetails) => ({
            id: li.id,
            name: li.name,
            aspect_ratio_method: li.aspect_ratio_method,
            authoring_guidance: li.authoring_guidance,
            base_url: li.base_url,
            click_to_play: li.click_to_play,
            click_to_play_prompt: li.click_to_play_prompt,
            description: li.description,
            enable_learner_state: li.enable_learner_state,
            export_hash: li.export_hash,
            full_window: li.full_window,
            has_report_url: li.has_report_url,
            image_url: li.image_url,
            native_height: li.native_height,
            native_width: li.native_width,
            no_snapshots: li.no_snapshots,
            show_delete_data_button: li.show_delete_data_button,
            thumbnail_url: li.thumbnail_url,
            created_at: li.created_at,
            updated_at: li.updated_at,
            customizable: li.customizable,
            authorable: li.authorable
          }))
        };
        return result;
      });
  };

  const getAllEmbeddables = () => {
    return sendToLara({url: libraryInteractivesListUrl})
      // tslint:disable-next-line
      .then( (json: any) => {
        const result = {
          allEmbeddables: json.library_interactives.map((li: ILibraryInteractive) => ({
            id: li.id,
            name: li.name,
            type: li.type,
            useCount: li.use_count,
            dateAdded: li.date_added
          }))
        };
        result.allEmbeddables.push({
          id: "MwInteractive",
          name: "Interactive IFrame",
          type: "MwInteractive",
          useCount: 0,
          dateAdded: 0,
          isQuickAddItem: true
        });
        result.allEmbeddables.push({
          id: "Embeddable::Xhtml",
          name: "Text Block",
          type: "Embeddable::Xhtml",
          useCount: 0,
          dateAdded: 0,
          isQuickAddItem: true
        });
        return result;
      });
  };

  return {
    getPages, getPage, createPage, deletePage,
    createSection, updateSections, updateSection,
    createPageItem, updatePageItem, deletePageItem,
    getAllEmbeddables, useLibraryInteractives,
    pathToTinyMCE: "/assets/tinymce.js", pathToTinyMCECSS: "/assets/tinymce-content.css"
  };
};
