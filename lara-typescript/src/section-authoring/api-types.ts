
export type SectionId = string;
export type PageId = string;
export type ItemId = string;
export type RelativePosition = "before" | "after";

export interface ISectionItem {
  id: ItemId;
  title?: string;
}

export interface ICreatePageItem {
  section_id: string;
  embeddable: string;
  position?: number;
}

export interface ILibraryInteractiveResponse {
  library_interactives: Array<{
    id: string;
    name: string;
    use_count: number;
    date_added: number;
  }>;
}

export interface ISection {
  id: SectionId;
  items: ISectionItem[];
  title?: string;
}

export interface IPage {
  id: PageId;
  sections: ISection[];
  title?: string;
}

export type IPageList = IPage[];

// API Call Signatures
export type APIPagesGetF = () => Promise<IPageList>;
export type APIPageGetF = (id: PageId) => Promise<IPage | null>;
export type APIPageCreateF = () => Promise<IPage>;
export type APIPageDeleteF = (id: PageId) => Promise<IPageList>;
export type APISectionsUpdateF = (nextPage: IPage)  => Promise<IPage>;
export type APISectionCreateF = (pageId: PageId) => Promise<IPage>;
export type APIPageItemCreateF = (pageId: PageId, newPageItem: ICreatePageItem) => Promise<IPage>;
export type APISectionUpdateF = (pageId: PageId, changes: { section: Partial<ISection> }) => Promise<IPage>;

export interface IAuthoringApi {
  getPages: APIPagesGetF;
  getPage: APIPageGetF;
  createPage: APIPageCreateF;
  deletePage: APIPageDeleteF;
  updateSections: APISectionsUpdateF;
  createSection: APISectionCreateF;
  createPageItem: APIPageItemCreateF;
  updateSection: APISectionUpdateF;
}
