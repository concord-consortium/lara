import { IPluginAuthoringMetaDataComponent, IPluginType } from "./plugin-types";

export type SectionId = string;
export type PageId = string;
export type ItemId = string;
export type RelativePosition = "before" | "after";

export enum SectionLayouts {
  LAYOUT_FULL_WIDTH = "full-width",
  LAYOUT_60_40 = "60-40",
  LAYOUT_40_60 = "40-60",
  LAYOUT_70_30 = "70-30",
  LAYOUT_30_70 = "30-70",
  LAYOUT_RESPONSIVE_30_70 = "responsive-30-70",
  LAYOUT_RESPONSIVE_50_50 = "responsive-50-50",
  LAYOUT_RESPONSIVE_FULL_WIDTH = "responsive-full-width",
}

export enum SectionColumns {
  PRIMARY =  "primary",
  SECONDARY =  "secondary"
}

interface AuthoringApiUrls {
  get_interactive_list?: string;
  set_linked_interactives?: string;
}

export interface ISectionItem {
  authoring_api_urls?: AuthoringApiUrls;
  column: SectionColumns;
  data?: any;
  embeddableId?: string;
  id: ItemId;
  position?: number;
  section_id?: string;
  type?: string;
}

export interface ISectionItemType {
  id: ItemId;
  serializeable_id: string;
  name: string;
  type: string;
  useCount: number;
  dateAdded: number;
  isQuickAddItem?: boolean;
}

export interface ISectionItemPlugin extends ISectionItemType {
  type: "plugin";
  components: IPluginAuthoringMetaDataComponent [];
}

export interface ICreatePageItem {
  section_id: string;
  column: SectionColumns;
  data?: any;
  embeddable: string;
  position?: number;
  type?: string;
  wrapped_embeddable_id?: string;
  wrapped_embeddable_type?: string;
}

export interface ITextBlockData {
  content?: string;
  name?: string;
  isCallout?: boolean;
  isHalfWidth?: boolean;
}

export interface ILibraryInteractive {
  aspect_ratio_method: string;
  authorable: boolean;
  authoring_guidance: string;
  base_url: string;
  click_to_play: boolean;
  click_to_play_prompt: string;
  created_at: string;
  customizable: boolean;
  date_added: number;
  description: string;
  enable_learner_state: boolean;
  hide_question_number: boolean;
  save_interactive_state_history: boolean;
  export_hash: string;
  full_window: boolean;
  has_report_url: boolean;
  id: number;
  image_url: string;
  isQuickAddItem?: boolean;
  name: string;
  native_height: number;
  native_width: number;
  no_snapshots: boolean;
  official: boolean;
  serializeable_id: string;
  show_delete_data_button: boolean;
  thumbnail_url: string;
  type: string;
  updated_at: string;
  use_count: number;
}

export interface ILibraryInteractiveResponse {
  library_interactives: Array<{
    id: string;
    name: string;
    type: string;
    use_count: number;
    date_added: number;
    isQuickAddItem: boolean;
  }>;
}

export interface IManagedInteractiveData {
  aspectRatio: number;
  authoredState: string;
  customAspectRatioMethod: string;
  customClickToPlay: boolean;
  customClickToPlayPrompt: string;
  customFullWindow: boolean;
  customImageUrl: string;
  customNativeHeight: number;
  customNativeWidth: number;
  enableLearnerState: boolean;
  hasReportUrl: boolean;
  id: number;
  imageUrl: string;
  inheritAspectRatioMethod: boolean;
  inheritClickToPlay: boolean;
  inheritClickToPlayPrompt: boolean;
  inheritFullWindow: boolean;
  inheritImageUrl: boolean;
  inheritNativeHeight: boolean;
  inheritNativeWidth: boolean;
  interactiveItemId: string;
  isHidden: boolean;
  isHalfWidth: boolean;
  libraryInteractiveId: number;
  linkedInteractiveId: number;
  linkedInteractiveType: string;
  linkedInteractiveItemId: string;
  linkedInteractives: any[];
  modelLibraryUrl: string;
  name: string;
  noSnapshots: boolean;
  showDeleteDataButton: boolean;
  showInFeaturedQuestionReport: boolean;
  urlFragment: string;
  fontSize: string;
  fontType: string;
}

export interface IMWInteractiveData {
  aspectRatio: number;
  aspectRatioMethod: string;
  authoredState: string;
  clickToPlay: boolean;
  clickToPlayPrompt: string;
  enableLearnerState: boolean;
  fullWindow: boolean;
  hasReportUrl: boolean;
  id: number;
  imageUrl: string;
  interactiveItemId: string;
  isHidden: boolean;
  isHalfWidth: boolean;
  modelLibraryUrl: string;
  linkedInteractiveId: number;
  linkedInteractiveType: string;
  linkedInteractiveItemId: string;
  linkedInteractives: any[];
  name: string;
  nativeHeight: number;
  nativeWidth: number;
  noSnapshots: boolean;
  showDeleteDataButton: boolean;
  showInFeaturedQuestionReport: boolean;
  url: string;
  fontSize: string;
  fontType: string;
}

type IApprovedScript = any;
export interface IEmbeddablePluginData {
  plugin: {
    approved_script: IApprovedScript;
    approved_script_label: "teacherEditionTips";
    author_data: string;
    component_label: "questionWrapper" | "sideTip" | "windowShade";
    description: string;
    id: number;
  };
  embeddable_id: number;
  is_half_width: boolean;
  is_hidden: boolean;
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

  /**
   * Should the section be shown in runtime?
   */
  show?: boolean;

  name?: string;
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
  name?: string;

  /**
   * Is page hidden?
   */
  isHidden?: boolean;

  /**
   * Is page a completion page?
   */
  isCompletion?: boolean;

  /**
   * Does the page have a sidebar?
   */
  showSidebar?: boolean;

  /**
   * The sidebar content
   */
  sidebar?: string;

  /**
   * The sidebar title
   */
  sidebarTitle?: string;

  /**
   * Sections on this page:
   */
  sections: ISection[];

  /**
   * Position of this page in the activity:
   */
  position?: number;

}

export interface IEmbeddableMetaData {
  embeddableId: string;
  embeddableType: string;
}

export interface IPlugin {
  id: string;
  name: string;
}

export interface IPluginEmbeddable {
  embeddableId: string;
  id: string;
  name: string;
  sectionItemId: string;
}

export interface IPortal {
  name: string;
  path: string;
}

// API Call Signatures
export type APIPagesGetF = () => Promise<IPage[]>;
export type APIPageGetF = (id: PageId) => Promise<IPage | null>;
export type APIPageCreateF = () => Promise<IPage>;
export type APIPageUpdateF = (args: {pageId: PageId, changes: Partial<IPage>}) => Promise<IPage>;
export type APIPageDeleteF = (id: PageId) => Promise<IPage[]>;
export type APIPageCopyF = (args: {pageId: PageId, destIndex: number}) => Promise<IPage>;

export type APISectionCreateF = (pageId: PageId) => Promise<IPage>;
export type APISectionsUpdateF = (nextPage: IPage) => Promise<IPage>;
export type APISectionUpdateF = (args: {pageId: PageId, changes: { section: Partial<ISection>}}) => Promise<IPage>;
export type APISectionCopyF = (args: {pageId: PageId, sectionId: SectionId}) => Promise<IPage>;

export type APIPageItemCreateF = (args: {pageId: PageId, newPageItem: ICreatePageItem}) => Promise<ISectionItem>;
export type APIPageItemDeleteF = (args: {pageId: PageId, pageItemId: ItemId}) => Promise<IPage>;
export type APIPageItemUpdateF = (args: {pageId: PageId, sectionItem: ISectionItem}) => Promise<ISectionItem>;
export type APIPageItemCopyF = (args: {pageId: PageId, sectionItemId: ItemId}) => Promise<ISectionItem>;
export type APIGetPreviewOptionsF = (args: {pageId: PageId | null}) => Promise<Record<string, string>|null>;
/**
 * The implementation providing the API must conform to this provider API
 */
export interface IAuthoringAPIProvider {
  getPages: APIPagesGetF;
  getPage: APIPageGetF;
  createPage: APIPageCreateF;
  updatePage: APIPageUpdateF;
  deletePage: APIPageDeleteF;
  copyPage: APIPageCopyF;

  createSection: APISectionCreateF;
  updateSections: APISectionsUpdateF;
  updateSection: APISectionUpdateF;
  copySection: APISectionCopyF;

  createPageItem: APIPageItemCreateF;
  deletePageItem: APIPageItemDeleteF;
  updatePageItem: APIPageItemUpdateF;
  copyPageItem: APIPageItemCopyF;

  getLibraryInteractives: () => Promise<{libraryInteractives: ILibraryInteractive[]}>;
  getAllEmbeddables: () => Promise<{allEmbeddables: ISectionItemType[]}>;
  getPreviewOptions: APIGetPreviewOptionsF;

  getPageItemEmbeddableMetaData: (pageItemId: ItemId) => Promise<IEmbeddableMetaData>;
  getPageItemPlugins: (pageItemId: ItemId) => Promise<{pageItemPlugins: IPlugin[]}>;
  getAvailablePlugins: () => Promise<{plugins: IPlugin[]}>;
  getPortals: () => Promise<{portals: IPortal[]}>;

  pathToTinyMCE: string | null;
  pathToTinyMCECSS: string | undefined;

  isAdmin: boolean;
}
