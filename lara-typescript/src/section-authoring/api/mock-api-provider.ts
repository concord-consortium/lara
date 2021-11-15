import { findItemAddress, findItemByAddress } from "../util/finding-utils";
import { updatePositions } from "../util/move-utils";
import {
  IPage, PageId,
  APIPageGetF, APIPagesGetF, APIPageItemUpdateF,
  IAuthoringAPIProvider, ISection, ICreatePageItem, ISectionItem, SectionColumns,
  ISectionItemType, APIPageItemDeleteF, ItemId, SectionId, SectionLayouts, ILibraryInteractive
} from "./api-types";
import { IManagedInteractive } from "../../page-item-authoring/managed-interactives";

let pageCounter = 1;
let sectionCounter = 1;
let itemCounter = 1;
let managedInteractiveCounter = 0;

let pages: IPage[] = [
  {
    id: `${pageCounter++}`,
    title: `Page ${pageCounter}`,
    sections: []
  }
];

const makeNewSection = (): ISection => {
  const section: ISection = {
    id: `${++sectionCounter}`,
    items: [],
    layout: SectionLayouts.LAYOUT_FULL_WIDTH
  };
  return section;
};

const makeNewPageItem = (attributes: ICreatePageItem): ISectionItem => {
  const returnAttributes = {...attributes, type: makePageItemType(attributes.type)};
  const newItem: ISectionItem = {
    id: `${++itemCounter}`,
    column: attributes.column || SectionColumns.PRIMARY,
    data: makeNewEmbeddable(returnAttributes),
    position: attributes.position || 1,
    type: returnAttributes.type
  };
  return newItem;
};

const makePageItemType = (pickerType: string | undefined) => {
  switch (pickerType) {
    case "LibraryInteractive":
      return "ManagedInteractive";
    default:
      return pickerType;
  }
};

const makeNewEmbeddable = (attributes: ICreatePageItem) => {
  const itemType = attributes.type;

  switch (itemType) {
    case "Embeddable::Xhtml":
      return ({});
      break;
    case "ManagedInteractive":
      const [libraryInteractiveType, libraryInteractiveId] = attributes.embeddable.split("_");
      return (
        {
          id: managedInteractiveCounter++,
          library_interactive_id: parseInt(libraryInteractiveId, 10),
          name: "",
          url_fragment: "",
          authored_state: "",
          is_hidden: false,
          is_full_width: true,
          aspect_ratio: 1,
          enable_learner_state: false,
          linked_interactive_type: "",
          show_in_featured_question_report: true,
          inherit_aspect_ratio_method: true,
          custom_aspect_ratio_method: "",
          inherit_native_width: true,
          custom_native_width: 576,
          inherit_native_height: true,
          custom_native_height: 435,
          inherit_click_to_play: true,
          custom_click_to_play: false,
          inherit_full_window: true,
          custom_full_window: false,
          inherit_click_to_play_prompt: true,
          custom_click_to_play_prompt: "",
          inherit_image_url: true,
          custom_image_url: "",
          interactive_item_id: "",
          linked_interactive_item_id: "",
          linked_interactives: []
        }) as Partial<IManagedInteractive>;
      break;
    default:
      return ({});
  }
};

export const updatePageItem: APIPageItemUpdateF = (args: {pageId: string, sectionItem: ISectionItem}) => {
  const { pageId, sectionItem } = args;
  const page = pages.find(p => p.id === pageId);
  let item: ISectionItem | undefined;
  page?.sections.forEach((s) => {
    item = s.items?.find(i => i.id === sectionItem.id);
  });
  if (item) {
    const updatedItem: ISectionItem = {
      id: sectionItem.id,
      column: sectionItem.column || SectionColumns.PRIMARY,
      data: sectionItem.data,
      position: sectionItem.position || 1,
      type: sectionItem.type
    };
    item = updatedItem;
    if (page) {
      updatePage(page.id, page);
    }
    return Promise.resolve(updatedItem);
  }
  return Promise.reject("something went wrong");
};

export const getPages: APIPagesGetF = () => {
  return Promise.resolve(pages);
};

export const getPage: APIPageGetF = (id: PageId) => {
  return Promise.resolve(pages.find(p => p.id === id) || null);
};

export const createPage = () => {
  const newPage: IPage = {
    id: `${++pageCounter}`,
    title: `Page ${pageCounter}`,
    sections: []
  };
  pages.push(newPage);
  updatePositions(pages);
  return Promise.resolve(newPage);
};

export const deletePage = (id: PageId) => {
  pages = pages.filter(p => p.id !== id);
  return Promise.resolve(pages);
};

const copyPage = (args: {pageId: PageId, destIndex: number}) => {
  const {pageId, destIndex} = args;
  const page = pages.find(p => p.id === pageId);
  if (page) {
    const nextPage = {...page};
    nextPage.id = `${++pageCounter}`;
    nextPage.sections = page.sections.map( s => {
      const items = s.items?.map(item => {
        const id = `${++itemCounter}`;
        return {...item, id };
      });
      return { ...s, items };
    });
    pages.splice(destIndex, 0, nextPage);
    updatePositions(pages);
    return Promise.resolve(nextPage);
  }
  return Promise.reject("no source page in copy");
};

export const updatePage = (id: PageId, changes: Partial<IPage>) => {
  const indx = pages.findIndex(p => p.id === id);
  if (indx > -1) {
    const nextPage = {... pages[indx], ...changes };
    pages[indx] = nextPage;
    return Promise.resolve({... nextPage});
  }
  return Promise.reject("Can't find that page");
};

const createSection = (id: PageId) => {
  const page = pages.find(p => p.id === id);
  if (page) {
    page.sections.push(makeNewSection());
    return Promise.resolve(page);
  }
  return Promise.reject(`cant find page ${id}`);
};

const updateSections = (nextPage: IPage) => {
  const existingPage = pages.find(p => p.id === nextPage.id);
  if (existingPage) {
    updatePage(nextPage.id, nextPage);
  }
  return Promise.resolve(nextPage);
};

const updateSection = (args: {pageId: PageId, changes: { section: Partial<ISection> }}) => {
  const {pageId, changes} = args;
  const page = pages.find(p => p.id === pageId);
  if (page) {
    const section  = page.sections.find(s => s.id === changes.section.id);
    if (section) {
      Object.assign(section, changes.section);
    }
    return Promise.resolve(page);
  }
  return Promise.reject(`cant find page ${pageId}`);
};

const copySection = (args: {pageId: PageId, sectionId: SectionId}) => {
  const {pageId, sectionId} = args;
  const page = pages.find(p => p.id === pageId);
  if (!page) {
    return Promise.reject(`can't find page: ${pageId}`);
  }
  const address = findItemAddress({pages, sectionId});

  // updates position, assumes the array is in the right order.
  const reorderSection = (sections: ISection[]) => {
    sections.forEach((s, i) => {
      s.position = i;
    });
  };

  // Deep Clone object:
  const clone = <T>(source: T): T => {
    return JSON.parse(JSON.stringify(source));
  };

  if (! (address.pageIndex === null || address.sectionIndex ===  null)) {
    const section = page.sections[address.sectionIndex];
    const newSection = clone(section);
    newSection.id = `${sectionCounter++}`;
    newSection.position = (newSection.position || 0) + 1;
    newSection.items?.forEach(i => {
      i.id = `${itemCounter++}`;
    });
    const start = page.sections.findIndex(i => i.id === sectionId);
    if (start > -1) {
      page.sections.splice(start + 1, 0, newSection);
      reorderSection(page.sections);
    }
  }
  return Promise.resolve(page);
};

const createPageItem = (args: {pageId: PageId, newPageItem: ICreatePageItem}) => {
  const {newPageItem, pageId} = args;
  const sectionId = newPageItem.section_id;
  const page = pages.find(p => p.id === pageId);
  if (page) {
    const section = page.sections.find(s => s.id === sectionId);
    if (section) {
      const newlyCreatedPageItem = makeNewPageItem(newPageItem);
      section.items?.push(newlyCreatedPageItem);
      return Promise.resolve(newlyCreatedPageItem);
    }
    return Promise.reject(`cant find section ${sectionId}`);
  }
  return Promise.reject(`cant find page ${pageId}`);
};

const deletePageItem: APIPageItemDeleteF = (args: {pageId: PageId, pageItemId: ItemId}) => {
  const { pageId, pageItemId } = args;
  const page = pages.find(p => p.id === pageId);
  if (page) {
    let replacementSection: ISection | null = null;
    page?.sections.forEach(s => {
      s.items?.forEach(i => {
        if (i.id === pageItemId) {
          replacementSection = s;
        }
      });
    });

    if (replacementSection) {
      (replacementSection as ISection).items = (replacementSection as ISection).items?.filter(i => i.id !== pageItemId);
    }
    return Promise.resolve(page);
  }
  return Promise.reject(`cant find page ${pageId}`);
};

const getAllEmbeddables = () => {
  const allEmbeddables: ISectionItemType[] = [
    {
      id: "1",
      serializeable_id: "LibraryInteractive_1",
      name: "Carousel",
      type: "LibraryInteractive",
      useCount: 1,
      dateAdded: 1630440496,
    },
    {
      id: "2",
      serializeable_id: "LibraryInteractive_2",
      name: "CODAP",
      type: "LibraryInteractive",
      useCount: 5,
      dateAdded: 1630440497
    },
    {
      id: "3",
      serializeable_id: "LibraryInteractive_3",
      name: "Drag & Drop",
      type: "LibraryInteractive",
      useCount: 5,
      dateAdded: 1630440498
    },
    {
      id: "4",
      serializeable_id: "LibraryInteractive_4",
      name: "Fill in the Blank",
      type: "LibraryInteractive",
      useCount: 8,
      dateAdded: 1630440495
    },
    {
      id: "5",
      serializeable_id: "MwInteractive_5",
      name: "iFrame Interactive",
      type: "MwInteractive",
      useCount: 200,
      dateAdded: 1630440494,
      isQuickAddItem: true
    },
    {
      id: "6",
      serializeable_id: "LibraryInteractive_6",
      name: "Multiple Choice",
      type: "LibraryInteractive",
      useCount: 300,
      dateAdded: 1630440493
    },
    {
      id: "7",
      serializeable_id: "LibraryInteractive_7",
      name: "Open Response",
      type: "LibraryInteractive",
      useCount: 400,
      dateAdded: 1630440492,
      isQuickAddItem: true
    },
    {
      id: "8",
      serializeable_id: "LibraryInteractive_8",
      name: "SageModeler",
      type: "LibraryInteractive",
      useCount: 3,
      dateAdded: 1630440499
    },
    {
      id: "9",
      serializeable_id: "LibraryInteractive_9",
      name: "Teacher Edition Window Shade",
      type: "LibraryInteractive",
      useCount: 4,
      dateAdded: 1630440490
    },
    {
      id: "10",
      serializeable_id: "Embeddable::Xhtml_10",
      name: "Text Block",
      type: "Embeddable::Xhtml",
      useCount: 500,
      dateAdded: 1630440491,
      isQuickAddItem: true
    }
  ];
  return Promise.resolve({allEmbeddables});
};

const getLibraryInteractives = () => {
  const libraryInteractives: ILibraryInteractive[] = [
    {
      id: 1,
      serializeable_id: "LibraryInteractive_1",
      name: "Carousel",
      type: "LibraryInteractive",
      use_count: 1,
      date_added: 1630440496,
      aspect_ratio_method: "DEFAULT",
      authorable: true,
      authoring_guidance: "",
      base_url: "https://localhost:8081/carousel/",
      click_to_play: false,
      click_to_play_prompt: "",
      created_at: "2020-07-27T16:33:01Z",
      customizable: true,
      description: "",
      enable_learner_state: true,
      export_hash: "ccdfa2d588c34914cb072ef5e88834bce7e0702a",
      full_window: false,
      has_report_url: false,
      image_url: "",
      native_height: 435,
      native_width: 576,
      no_snapshots: false,
      show_delete_data_button: false,
      thumbnail_url: "",
      updated_at: "2021-05-04T21:26:18Z"
    },
    {
      id: 3,
      serializeable_id: "LibraryInteractive_3",
      name: "Drag & Drop",
      type: "LibraryInteractive",
      use_count: 5,
      date_added: 1630440498,
      aspect_ratio_method: "DEFAULT",
      authorable: true,
      authoring_guidance: "",
      base_url: "https://localhost:8081/drag-and-drop/",
      click_to_play: false,
      click_to_play_prompt: "",
      created_at: "2020-07-27T16:33:01Z",
      customizable: true,
      description: "",
      enable_learner_state: true,
      export_hash: "ccdfa2d588c34914cb072ef5e88834bce7e0702b",
      full_window: false,
      has_report_url: false,
      image_url: "",
      native_height: 435,
      native_width: 576,
      no_snapshots: false,
      show_delete_data_button: false,
      thumbnail_url: "",
      updated_at: "2021-05-04T21:26:18Z"
    },
    {
      id: 4,
      serializeable_id: "LibraryInteractive_4",
      name: "Fill in the Blank",
      type: "LibraryInteractive",
      use_count: 8,
      date_added: 1630440495,
      aspect_ratio_method: "DEFAULT",
      authorable: true,
      authoring_guidance: "",
      base_url: "https://localhost:8081/fill-in-the-blank/",
      click_to_play: false,
      click_to_play_prompt: "",
      created_at: "2020-07-27T16:33:01Z",
      customizable: true,
      description: "",
      enable_learner_state: true,
      export_hash: "ccdfa2d588c34914cb072ef5e88834bce7e0702c",
      full_window: false,
      has_report_url: false,
      image_url: "",
      native_height: 435,
      native_width: 576,
      no_snapshots: false,
      show_delete_data_button: false,
      thumbnail_url: "",
      updated_at: "2021-05-04T21:26:18Z"
    },
    {
      id: 6,
      serializeable_id: "LibraryInteractive_6",
      name: "Multiple Choice",
      type: "LibraryInteractive",
      use_count: 300,
      date_added: 1630440493,
      aspect_ratio_method: "DEFAULT",
      authorable: true,
      authoring_guidance: "",
      base_url: "https://localhost:8081/multiple-choice/",
      click_to_play: false,
      click_to_play_prompt: "",
      created_at: "2020-07-27T16:33:01Z",
      customizable: true,
      description: "",
      enable_learner_state: true,
      export_hash: "ccdfa2d588c34914cb072ef5e88834bce7e0702d",
      full_window: false,
      has_report_url: false,
      image_url: "",
      native_height: 435,
      native_width: 576,
      no_snapshots: false,
      show_delete_data_button: false,
      thumbnail_url: "",
      updated_at: "2021-05-04T21:26:18Z"
    },
    {
      id: 7,
      serializeable_id: "LibraryInteractive_7",
      name: "Open Response",
      type: "LibraryInteractive",
      use_count: 400,
      date_added: 1630440492,
      isQuickAddItem: true,
      aspect_ratio_method: "DEFAULT",
      authorable: true,
      authoring_guidance: "",
      base_url: "https://localhost:8081/open-response/",
      click_to_play: false,
      click_to_play_prompt: "",
      created_at: "2020-07-27T16:33:01Z",
      customizable: true,
      description: "",
      enable_learner_state: true,
      export_hash: "ccdfa2d588c34914cb072ef5e88834bce7e0702e",
      full_window: false,
      has_report_url: false,
      image_url: "",
      native_height: 435,
      native_width: 576,
      no_snapshots: false,
      show_delete_data_button: false,
      thumbnail_url: "",
      updated_at: "2021-05-04T21:26:18Z"
    }
  ];
  return Promise.resolve({libraryInteractives});
};

const copyPageItem = (args: {pageId: PageId, sectionItemId: ItemId}) => {
  const {sectionItemId, pageId} = args;
  const page = pages.find(p => p.id === pageId);
  let nextItem = null;
  let destSection = null;
  if (page) {
    sectionLoop:
    for (const pageSection of page.sections) {
      for (const item of pageSection.items || []) {
        if (item.id === sectionItemId) {
          nextItem = {...item};
          nextItem.id = `${++itemCounter}`;
          destSection = pageSection;
          break sectionLoop;
        }
      }
    }
    if (nextItem && destSection) {
      (destSection.items || []).push(nextItem);
      return Promise.resolve(nextItem);
    }
  }
  return Promise.reject(`cant find page:${pageId}, item: ${sectionItemId}`);
};

export const API: IAuthoringAPIProvider = {
  getPages, getPage, createPage, deletePage, copyPage,
  createSection, updateSections, updateSection, copySection,
  createPageItem, updatePageItem, deletePageItem, copyPageItem,
  getAllEmbeddables, getLibraryInteractives,
  pathToTinyMCE: "https://cdnjs.cloudflare.com/ajax/libs/tinymce/5.10.0/tinymce.min.js", pathToTinyMCECSS: undefined
};
