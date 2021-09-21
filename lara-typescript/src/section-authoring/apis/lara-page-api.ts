
import {
  IPage, PageId,
  APIPageGetF, APIPagesGetF, IAPIPages
} from "../authoring-types";

const APIBase = "/api/v1";
let counter = 0;

export const getLaraPageAPI = (host: string = "", pageId: string): IAPIPages => {
  const prefix = `${host}/${APIBase}`;
  const getPagesUrl = `${prefix}/get_pages/${pageId}.json`;

  const getPages: APIPagesGetF = () => {
    console.log("Getting page list");
    return fetch(getPagesUrl, {
      method: "GET",
      headers: { "Content-Type": "application/json" }
    }).then(res => {
      return res.json();
    });
  };

  // TODO:
  const getPage: APIPageGetF = (id: PageId) => {
    console.log("Faking get single page");
    const newPage: IPage = {
      id: `${++counter}`,
      title: `Page ${counter}`,
      sections: []
    };
    return Promise.resolve(newPage);
  };

  // TODO:
  const createPage = () => {
    console.log("Faking create");
    const newPage: IPage = {
      id: `${++counter}`,
      title: `Page ${counter}`,
      sections: []
    };
    return Promise.resolve(newPage);
  };

  // TODO:
  const deletePage = (id: PageId) => {
    console.log("Faking delete");
    return Promise.resolve([]);
  };
  return {getPages, getPage, createPage, deletePage};
};
