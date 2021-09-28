import {
  IAuthoringAPIProvider,
  IPage, PageId, ISection, ICreatePageItem,
  APIPageGetF, APIPagesGetF,
  APIPageCreateF, APIPageDeleteF,
  APISectionCreateF, APISectionsUpdateF, APISectionUpdateF,
  APIPageItemCreateF
} from "./api-types";

const APIBase = "/api/v1";

export const getLaraPageAPI = (activityId: string, host: string = window.location.origin, ): IAuthoringAPIProvider => {

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
  const libraryInteractivesUrl = (pageId: PageId) => `${prefix}/get_library_interactives_list.json`;

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
    // This shouldn't be required :  body: JSON.stringify({ id })
  };

  const updateSections: APISectionsUpdateF = (nextPage: IPage) => {
    return sendToLara({url: updatePageSectionsURL(nextPage.id), method: "PUT", body: nextPage});
  };

  const updateSection: APISectionUpdateF = (args: {pageId: PageId, changes: { section: Partial<ISection> }}) => {
    const {pageId, changes} = args;
    const data = { id: pageId, section: { ...changes.section } };
    return sendToLara({url: updateSectionUrl(pageId), method: "POST", body: data});
  };

  const createPageItem: APIPageItemCreateF = (pageId: PageId, newPageItem: ICreatePageItem) => {
    return sendToLara({url: createPageItemUrl(pageId), method: "POST", body: newPageItem});
  };

  return {
    getPages, getPage, createPage, deletePage,
    createSection, updateSections, createPageItem, updateSection
  };
};
