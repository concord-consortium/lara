export type SectionId = string;
export type PageId = string;
export type ItemId = string;
export type RelativePosition = "before" | "after";

export enum SectionLayouts {
  LAYOUT_FULL_WIDTH = "Full Width",
  LAYOUT_60_40 = "60-40",
  LAYOUT_40_60 = "40-60",
  LAYOUT_70_30 = "70-30",
  LAYOUT_30_70 = "30-70",
  LAYOUT_RESPONSIVE = "Responsive",
}

export enum SectionColumns {
  PRIMARY =  "primary",
  SECONDARY =  "secondary"
}
export interface ISectionItem {
  id: ItemId;
  title?: string;
  embeddable?: string;
  column?: SectionColumns;
  section_id?: string;
  position?: number;
}

export interface ISectionItemType {
  id: string;
  name: string;
  useCount: number;
  dateAdded: number;
  isQuickAddItem?: boolean;
}

export interface ICreatePageItem {
  section_id: string;
  column: SectionColumns;
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
  /**
   * Can the smaller side collapse?
   */
  can_collapse_small?: boolean;

  /**
   * Record ID
   */
  id: string;

  /**
   * Associated Page for this section
   */
  interactive_page_id?: string;

  /**
   * How are the items positioned in the section
   */
  layout?: SectionLayouts;

  /**
   * Or display order on the page
   */
  position?: number;

  /**
   * Name of the section will be displayed in the header
   */
  title?: string;

  /**
   * Should the section be collapsed?
   */
  collapsed?: boolean;

  /**
   * Items in this section
   */
  items?: ISectionItem[];
}

export interface IPage {
  /**
   * Record ID
   */
  id: string;

  /**
   * Indicates if this is a newly created page
   */
  isNew?: boolean;

  /**
   * Optional title for the page
   */
  title?: string;

  /**
   * Is page a completion page?
   */
  isCompletion?: boolean;

  /**
   * Sections on this page:
   */
  sections: ISection[];

  /**
   * Items on this page:
   * TODO: NP: I don't think this should be flat like this.
   */
  items?: ISectionItem[];
}

// API Call Signatures
export type APIPagesGetF = () => Promise<IPage[]>;
export type APIPageGetF = (id: PageId) => Promise<IPage | null>;
export type APIPageCreateF = () => Promise<IPage>;
export type APIPageDeleteF = (id: PageId) => Promise<IPage[]>;

export type APISectionCreateF = (pageId: PageId) => Promise<IPage>;
export type APISectionsUpdateF = (nextPage: IPage) => Promise<IPage>;
export type APISectionUpdateF = (args: {pageId: PageId, changes: { section: Partial<ISection>}}) => Promise<IPage>;

export type APIPageItemCreateF = (pageId: PageId, newPageItem: ICreatePageItem) => Promise<IPage>;

/**
 * The implementation providing the API has to conform to this provider API
 */
export interface IAuthoringAPIProvider {
  getPages: APIPagesGetF;
  getPage: APIPageGetF;
  createPage: APIPageCreateF;
  deletePage: APIPageDeleteF;

  createSection: APISectionCreateF;
  updateSections: APISectionsUpdateF;
  updateSection: APISectionUpdateF;

  createPageItem: APIPageItemCreateF;

  getAllEmbeddables: () => Promise<{allEmbeddables: ISectionItemType[]}>;
}
