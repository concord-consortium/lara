import * as $ from "jquery";
import "jqueryui";

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

export const ADD_POPUP_DEFAULT_OPTIONS = {
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
