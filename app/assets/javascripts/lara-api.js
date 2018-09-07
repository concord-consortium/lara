window.LARA = {
  /****************************************************************************
   @function addPopup: Ask LARA to add a new popup window
   @arg {IPopupOptions} popupOptions
   @returns {IPopupController} popupController

   Note that many options closely resemble jQuery UI dialog options which is used under the hood.
   You can refer to jQuery UI API docs in many cases: https://api.jqueryui.com/dialog
   Only `content` is required. Other options have reasonable default values (subject to change,
   so if you expect particular behaviour, provide necessary options explicitly).

   React warning: if you use React to render content, remember to call `ReactDOM.unmountComponentAtNode(content)`
   in `onRemove` handler.

   interface IPopupOptions {
     content: HTMLElement | string;
     autoOpen?: boolean;
     closeOnEscape?: boolean;
     // Removes popup HTMLElement when it is closed by the user. Otherwise, it will stay hidden and might be
     // reopened programmatically.
     removeOnClose?: boolean;
     title?: string;
     closeButton?: boolean;
     color?: string;
     modal?: boolean;
     draggable?: boolean;
     resizable?: boolean;
     // Please see: https://api.jqueryui.com/dialog/#option-position
     position?: { my: string, at: string, of: HTMLElement};
     width?: number;
     // number in px or "auto"
     height?: number | string;
     padding?: number;
     backgroundColor?: string;
     titlebarColor?: string;
     onOpen?: () => void;
     onClose?: () => void;
     // Triggered when a dialog is about to close. If canceled (by returning false), the dialog will not close.
     onBeforeClose?: () => boolean;
     onResize?: () => void;
     onDragStart?: () => void;
     onDragStop?: () => void;
   }

   interface IPopupController {
     // Opens popup (makes sense only if autoOpen option is set to false during initialization).
     open: () => void;
     // Closes popup (display: none). Also removes HTML element from DOM tree if `removeOnClose` is equal to true.
     close: () => void;
     // Removes HTML element from DOM tree.
     remove: () => void;
   }
   ****************************************************************************/
   OPEN_POPUP_DEFAULT_OPTIONS: {
    title: '',
    autoOpen: true,
    closeButton: true,
    closeOnEscape: false,
    removeOnClose: true,
    modal: false,
    draggable: true,
    resizable: true,
    width: 300,
    height: 'auto',
    padding: 10,
    // Note that dialogClass is intentionally undocumented. Styling uses class makes us depend on the
    // current dialog implementation. It might be necessary for LARA themes, although plugins should not use it.
    dialogClass: '',
    backgroundColor: '',
    titlebarColor: '',
    position: { my: "center", at: "center", of: window },
    onOpen: null,
    onClose: null,
    onBeforeClose: null,
    onResize: null,
    onDragStart: null,
    onDragStop: null
  },

  addPopup: function (options) {
    options = $.extend({}, this.OPEN_POPUP_DEFAULT_OPTIONS, options);
    if (!options.content) {
      throw new Error('LARA.addPopup - content option is required');
    }
    if (options.dialogClass) {
      console.warn('LARA.addPopup - dialogClass option is discouraged and should not be used by plugins');
    }
    var $content = typeof options.content === 'string' ? $('<span>' + options.content + '</span>') : $(options.content);
    var $dialog = null;
    var remove = function () {
      if (options.onRemove) {
        options.onRemove();
      }
      $dialog.remove();
    }
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
      close: function () {
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
    $dialog = $content.closest('.ui-dialog');
    $dialog.css('background', options.backgroundColor);
    $dialog.find('.ui-dialog-titlebar').css('background', options.titlebarColor);
    $dialog.find('.ui-dialog-content').css('padding', options.padding);
    if (!options.closeButton) {
      $dialog.find('.ui-dialog-titlebar-close').remove();
    }

    // IPopupController implementation.
    return {
      open: function () {
        $content.dialog('open');
      },
      close: function () {
        $content.dialog('close');
      },
      remove: remove
    }
  },

  /****************************************************************************
   @function saveUserState: Ask LARA to save the users state for the plugin
   @arg {ILaraPluginRef} pluginInstance - The plugin trying to save data
   @arg {string} state - A JSON string representing serialized plugin state.
   @returns Promise
  ****************************************************************************/
  saveUserState: function (pluginInstance, state) {
    console.log('Plugin', pluginInstance, 'wants to save a state:', state);
  },

  /****************************************************************************
  @function decorateContent: Ask LARA to decorate authored content (text / html)
  @arg {string[]} words - a list of case-insensitive words to be decorated. Can use limited regex.
  @arg {string} replace - the replacement string. Can include '$1' representing the matched word.
  @arg {wordClass} wordClass - CSS class used in replacement string. Necessary only if `listeners` are provided too.
  @arg {IEventListeners} listeners - one or more { type, listener } tuples. Note that events are added to `wordClass`
      described above. It's client code responsibility to use this class in the `replace` string.
  @returns void

  interface IEventListener {
    type: string;
    listener: (evt: Event) => void;
  }

  type IEventListeners = IEventListener | IEventListener[];
  ****************************************************************************/
  decorateContent: function (words, replace, wordClass, listeners) {
    var domClasses = ['question-txt', 'intro-txt'];
    var options = {
      words: words,
      replace: replace
    }
    TextDecorator.decorateDOMClasses(domClasses, options, wordClass, listeners);
  },


  /**************************************************************
   @function register
   Register a new external script as `label` with `_class `
   @arg label - the identifier of the script
   @arg _class - the Plugin Class being associated with the identifier
   @returns void
   @example: `LARA.registerPlugin('debugger', Dubugger);`
   **************************************************************/
  registerPlugin: function(label, _class) {
    Plugins.registerPlugin(label, _class);
  }
};
