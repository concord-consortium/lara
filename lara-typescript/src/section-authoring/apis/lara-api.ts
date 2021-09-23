import {
  IPage, PageId, ISection,
  APIPageGetF, APIPagesGetF, IAuthoringApi,
  ICreatePageItem, ILibraryInteractiveResponse
} from "../api-types";

const APIBase = "/api/v1";

export const getLaraPageAPI = (host: string = "", activityId: string): IAuthoringApi => {

  const prefix = `${host}/${APIBase}`;
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

  const createPage = () => {
    return sendToLara({url: createPageUrl, method: "POST"});
  };

  const deletePage = (id: PageId) => {
    return sendToLara({url: deletePageUrl(id), method: "POST"});
  };

  const updateSections = (nextPage: IPage) => {
    return sendToLara({url: updatePageSectionsURL(nextPage.id), method: "PUT", body: nextPage});
  };

  const createSection = (id: PageId) => {
    return sendToLara({url: createPageSectionUrl(id), method: "POST"});
    // This shouldn't be required :  body: JSON.stringify({ id })
  };

  const createPageItem = (pageId: PageId, newPageItem: ICreatePageItem) => {
    return sendToLara({url: createPageItemUrl(pageId), method: "POST", body: newPageItem});
  };

  const updateSection = (pageId: PageId, changes: { section: Partial<ISection> }) => {
    const data = { id: pageId, section: { ...changes.section } };
    return sendToLara({url: updateSectionUrl(pageId), method: "POST", body: data});
  };

  return {
    getPages, getPage, createPage, deletePage,
    updateSections, createSection, createPageItem, updateSection
  };
};
