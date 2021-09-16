
export type SectionId = string;
export type PageId = string;
export type ItemId = string;
export type RelativePosition = "before" | "after";

export interface ISectionItem {
  id: ItemId;
  title?: string;
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
// PAGES:
export type APIPagesGetF = () => Promise<IPageList>;
export type APIPageGetF = (id: PageId) => Promise<IPage | null>;
export type APIPageCreateF = () => Promise<IPage>;
export type APIPageDeleteF = (id: PageId) => Promise<IPageList>;
