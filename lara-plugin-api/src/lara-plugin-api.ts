import * as $ from "jquery";
import "jqueryui";
import * as Sidebar from "sidebar";
import * as TextDecorator from "text-decorator";

export {
  IPlugin, IPluginConstructor, IRuntimeContext, registerPlugin, initPlugin, saveLearnerPluginState
} from "./api/plugins";

export interface IPopupOptions {
  content: HTMLElement | string;
  autoOpen?: boolean;
  closeOnEscape?: boolean;
  /**
   * Removes popup HTMLElement when it is closed by the user.
   * Otherwise, it will stay hidden and might be reopened programmatically.
   */
  removeOnClose?: boolean;
  title?: string;
  closeButton?: boolean;
  color?: string;
  modal?: boolean;
  dialogClass?: string;
  draggable?: boolean;
  resizable?: boolean;
  /** Please see: https://api.jqueryui.com/dialog/#option-position */
  position?: { my: string, at: string, of: HTMLElement};
  width?: number;
  /** Number in px or "auto" */
  height?: number | string;
  padding?: number;
  backgroundColor?: string;
  titlebarColor?: string;
  onOpen?: () => void;
  onClose?: () => void;
  /** Triggered when a dialog is about to close. If canceled (by returning false), the dialog will not close. */
  onBeforeClose?: () => boolean;
  onRemove?: () => void;
  onResize?: () => void;
  onDragStart?: () => void;
  onDragStop?: () => void;
}

export interface IPopupController {
  /** Opens popup (makes sense only if autoOpen option is set to false during initialization). */
  open: () => void;
  /** Closes popup (display: none). Also removes HTML element from DOM tree if `removeOnClose` is equal to true. */
  close: () => void;
  /** Removes HTML element from DOM tree. */
  remove: () => void;
}

const ADD_POPUP_DEFAULT_OPTIONS = {
  title: "",
  autoOpen: true,
  closeButton: true,
  closeOnEscape: false,
  removeOnClose: true,
  modal: false,
  draggable: true,
  resizable: true,
  width: 300,
  height: "auto",
  padding: 10,
  /**
   * Note that dialogClass is intentionally undocumented. Styling uses class makes us depend on the
   * current dialog implementation. It might be necessary for LARA themes, although plugins should not use it.
   */
  dialogClass: "",
  backgroundColor: "",
  titlebarColor: "",
  position: { my: "center", at: "center", of: window },
  onOpen: null,
  onBeforeClose: null,
  onResize: null,
  onDragStart: null,
  onDragStop: null
};

/****************************************************************************
 Ask LARA to add a new popup window.

 Note that many options closely resemble jQuery UI dialog options which is used under the hood.
 You can refer to jQuery UI API docs in many cases: https://api.jqueryui.com/dialog
 Only `content` is required. Other options have reasonable default values (subject to change,
 so if you expect particular behaviour, provide necessary options explicitly).

 React warning: if you use React to render content, remember to call `ReactDOM.unmountComponentAtNode(content)`
 in `onRemove` handler.
 ****************************************************************************/
export const addPopup = (_options: IPopupOptions): IPopupController => {
  const options = $.extend({}, ADD_POPUP_DEFAULT_OPTIONS, _options);
  if (!options.content) {
    throw new Error("LARA.addPopup - content option is required");
  }
  if (options.dialogClass) {
    // tslint:disable-next-line:no-console
    console.warn("LARA.addPopup - dialogClass option is discouraged and should not be used by plugins");
  }
  const $content = typeof options.content === "string" ?
    $("<span>" + options.content + "</span>") : $(options.content);
  let $dialog: JQuery;
  const remove = () => {
    if (options.onRemove) {
      options.onRemove();
    }
    $dialog.remove();
  };
  $content.dialog({
    title: options.title,
    autoOpen: options.autoOpen,
    closeOnEscape: options.closeOnEscape,
    modal: options.modal,
    draggable: options.draggable,
    width: options.width,
    height: options.height,
    resizable: options.resizable,
    // Note that dialogClass is intentionally undocumented. Styling uses class makes us depend on the
    // current dialog implementation. It might be necessary for LARA themes, although plugins should not use it.
    dialogClass: options.dialogClass,
    position: options.position,
    open: options.onOpen,
    close() {
      if (options.onClose) {
        options.onClose();
      }
      // Remove dialog from DOM tree.
      if (options.removeOnClose) {
        remove();
      }
    },
    beforeClose: options.onBeforeClose,
    resize: options.onResize,
    dragStart: options.onDragStart,
    dragStop: options.onDragStop
  });
  $dialog = $content.closest(".ui-dialog");
  $dialog.css("background", options.backgroundColor);
  $dialog.find(".ui-dialog-titlebar").css("background", options.titlebarColor);
  $dialog.find(".ui-dialog-content").css("padding", options.padding);
  if (!options.closeButton) {
    $dialog.find(".ui-dialog-titlebar-close").remove();
  }
  // IPopupController implementation.
  return {
    open() {
      $content.dialog("open");
    },
    close() {
      $content.dialog("close");
    },
    remove
  };
};

export interface ISidebarOptions {
  content: string | HTMLElement;
  // Icon can be 'default' (arrow) or an HTML element.
  icon?: string | HTMLElement;
  // Text displayed on the sidebar handle.
  handle?: string;
  handleColor?: string;
  // Title visible after sidebar is opened by user. If it's not provided, it won't be displayed at all.
  titleBar?: string;
  titleBarColor?: string;
  width?: number;
  padding?: 25;
  onOpen?: () => void;
  onClose?: () => void;
}

export interface ISidebarController {
  open: () => void;
  close: () => void;
}

const ADD_SIDEBAR_DEFAULT_OPTIONS = {
  icon: "default", // arrow pointing left
  handle: "",
  handleColor: "#aaa",
  titleBar: null,
  titleBarColor: "#bbb",
  width: 500,
  padding: 25,
  onOpen: null,
  onClose: null
};

/****************************************************************************
 Ask LARA to add a new sidebar.

 Sidebar will be added to the edge of the interactive page window. When multiple sidebars are added, there's no way
 to specify their positions, so no assumptions should be made about current display - it might change.

 Sidebar height cannot be specified. It's done on purpose to prevent issues on very short screens. It's based on the
 provided content HTML element, but it's limited to following range:
 - 100px is the min-height
 - max-height is calculated dynamically and ensures that sidebar won't go off the screen
 If the provided content is taller than the max-height of the sidebar, a sidebar content container will scroll.

 It returns a simple controller that can be used to open or close sidebar.
 ****************************************************************************/
export const addSidebar = (options: ISidebarOptions): ISidebarController => {
  options = $.extend({}, ADD_SIDEBAR_DEFAULT_OPTIONS, options);
  if (options.icon === "default") {
    options.icon = $("<i class='default-icon fa fa-arrow-circle-left'>")[0];
  }
  return Sidebar.addSidebar(options);
};

export interface IEventListener {
  type: string;
  listener: (evt: Event) => void;
}

type IEventListeners = IEventListener | IEventListener[];

/****************************************************************************
 Ask LARA to decorate authored content (text / html).

 @param words A list of case-insensitive words to be decorated. Can use limited regex.
 @param replace The replacement string. Can include '$1' representing the matched word.
 @param wordClass CSS class used in replacement string. Necessary only if `listeners` are provided too.
 @param listeners One or more { type, listener } tuples. Note that events are added to `wordClass`
 described above. It's client code responsibility to use this class in the `replace` string.
 ****************************************************************************/
export const decorateContent = (words: string[], replace: string, wordClass: string, listeners: IEventListeners) => {
  const domClasses = ["question-txt", "help-content", "intro-txt"];
  const options = {
    words,
    replace
  };
  TextDecorator.decorateDOMClasses(domClasses, options, wordClass, listeners);
};

/**************************************************************
 Find out if the page being displayed is being run in teacher-edition
 @returns `true` if lara is running in teacher-edition.
 **************************************************************/
export const isTeacherEdition = () => {
  // If we decide to do something more complex in the future,
  // the client's API won't change.
  return window.location.search.indexOf("mode=teacher-edition") > 0;
};
