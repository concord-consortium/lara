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

  /****************************************************************************
   private variables to keep track of our plugins.
  ****************************************************************************/
  _pluginClasses: {},
  _plugins:[],
  _plugin_labels:[],

  _pluginError: function(e, other) {
    console.group("LARA Plugin Error");
    console.error(e);
    console.dir(other);
    console.groupEnd();
  },

  _nameForPlugin: function(plugin) {
    return(plugin.name || "(unknown)");
  },

  /**************************************************************
  @function init
  This method is called to initialize the external scripts
  Called at runtime by LARA to create an instance of the plugin
  as would happen in `views/plugin/_show.html.haml`
  @arg {string} label - the the script identifier.
  @arg {IRuntimContext} runtimeContext - context for the plugin

  // Its likely we dont need most of these context values. TBD.
  Interface IRuntimeContext {
    name: string;         // Name of the plugin
    url: string;          // Url from which the plugin was loaded
    pluginId: string;     // Active record ID of the plugin scope id
    authorData: string;   // The authored configuration for this instance
    learnerData: string;  // The saved learner data for this instance
    div: DomNode;         // reserved DomNode for the plugin in ther runtime.
  }
  **************************************************************/
  initPlugin: function(_label, runtimeContext) {
    var constructor = this._pluginClasses[_label];
    var config = {};
    var plugin = null;
    if (typeof constructor == 'function') {
      try {
        if (typeof runtimeContext.config == 'string'){
          config = JSON.parse(runtimeContext.config);
          delete runtimeContext.config;
        }
        plugin = new constructor(config, runtimeContext);
        this._plugins.push(plugin);
        this._plugin_labels.push(_label);
      }
      catch(e) {
        this._pluginError(e, runtimeContext);
      }
      console.log('Plugin', _label, 'is now registered');
    }
    else {
      console.error("No plugin registered for label:", _label);
    }
  },


  /**************************************************************
   @function register
   Register a new external script as `label` with `_class `
   @arg label - the identifier of the sctipt
   @arg Class - the Plugin Class being associated with the identifier
   @example: `ExternalScripts.register('debugger', Dubugger)`
   **************************************************************/
  registerPlugin: function(_label, _class) {
    if(typeof _class == 'function') {
      if(this._pluginClasses[_label]) {
        console.error("Duplicate Plugin for label " + _label);
      }
      else {
        this._pluginClasses[_label] = _class;
      }
    }
  },
};
