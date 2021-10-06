import {
  IAuthoringAPIProvider,
  IPage, PageId, ISection, ICreatePageItem, ItemId,
  APIPageGetF, APIPagesGetF,
  APIPageCreateF, APIPageDeleteF,
  APISectionCreateF, APISectionsUpdateF, APISectionUpdateF,
  APIPageItemCreateF,
  ILibraryInteractiveResponse,
  APIPageItemDeleteF
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
  const deletePageItemUrl = (pageId: PageId) => `${prefix}/delete_page_item/${pageId}.json`;
  const libraryInteractivesUrl = `${prefix}/get_library_interactives_list.json`;

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

  const deletePageItem: APIPageItemDeleteF = (args: {pageId: PageId, pageItemId: ItemId}) => {
    const { pageId, pageItemId } = args;
    const body = { page_item_id: pageItemId };
    return sendToLara({url: deletePageItemUrl(pageId), method: "POST", body});
  };

  const getAllEmbeddables = () => {
    return sendToLara({url: libraryInteractivesUrl})
      .then( (json: ILibraryInteractiveResponse) => {
        const result = {
          allEmbeddables: json.library_interactives.map(li => ({
            id: li.id,
            name: li.name,
            useCount: li.use_count,
            dateAdded: li.date_added
          }))
        };
        result.allEmbeddables.push({
          id: "MwInteractive",
          name: "Interactive IFrame",
          useCount: 0,
          dateAdded: 0
        });
        return result;
      });
  };

  return {
    getPages, getPage, createPage, deletePage,
    createSection, updateSections, updateSection,
    createPageItem, deletePageItem,
    getAllEmbeddables
  };
};
