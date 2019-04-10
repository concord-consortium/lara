export {
  IPlugin, IPluginConstructor, IRuntimeContext, registerPlugin, initPlugin, saveLearnerPluginState
} from "./api/plugins";

export {
  ISidebarOptions, ISidebarController, ADD_SIDEBAR_DEFAULT_OPTIONS, addSidebar
} from "./api/sidebar";

export {
  IPopupOptions, IPopupController, ADD_POPUP_DEFAULT_OPTIONS, addPopup
} from "./api/popup";

export {
  IEventListener, IEventListeners, decorateContent
} from "./api/decorate-content";

/**************************************************************
 Find out if the page being displayed is being run in teacher-edition
 @returns `true` if lara is running in teacher-edition.
 **************************************************************/
export const isTeacherEdition = () => {
  // If we decide to do something more complex in the future,
  // the client's API won't change.
  return window.location.search.indexOf("mode=teacher-edition") > 0;
};
