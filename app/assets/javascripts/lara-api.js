window.LARA = {
  /****************************************************************************
   @function openPopup: Ask LARA to add a new popup window
   @arg {IPopupOptions} popupOptions
   @returns void

   Note that many options closely resemble jQuery UI dialog options which is used under the hood.
   Only `content` is required. Other options have reasonable default values (subject to change,
   so if you expect particular behaviour, provide necessary options explicitly).

   React warning: if you use React to render content, remember to call `ReactDOM.unmountComponentAtNode(content)`
   in onClose handler.

   interface IPopupOptions {
     content: HTMLElement,
     title?: string,
     color?: string,
     modal?: boolean,
     draggable?: boolean,
     resizable?: boolean,
     // Please see: https://api.jqueryui.com/dialog/#option-position
     position?: { my: string, at: string, of: HTMLElement},
     width?: number,
     // number in px or "auto"
     height?: number | string,
     onClose?: () => void
   }
   ****************************************************************************/
   OPEN_POPUP_DEFAULT_OPTIONS: {
    title: '',
    modal: false,
    draggable: true,
    resizable: true,
    width: 300,
    height: 'auto',
    position: { my: "center", at: "center", of: window },
    onClose: null
  },
  openPopup: function (options) {
    options = $.extend({}, this.OPEN_POPUP_DEFAULT_OPTIONS, options);
    $(options.content).dialog({
      title: options.title,
      modal: options.modal,
      draggable: options.draggable,
      width: options.width,
      height: options.height,
      resizable: options.resizable,
      position: options.position,
      close: function () {
        if (options.onClose) {
          options.onClose();
        }
        // Remove dialog from DOM tree.
        $(this).remove();
      },
    })
  },

  /****************************************************************************
   @function saveUserState: Ask LARA to save the users state for the plugin
   @arg {ILaraPluginRef} pluginInstance - The plugin trying to save data
   @arg {string} state - A JSON string representing serialized plugin state.
   @returns Promise
  ****************************************************************************/
  saveUserState: function (pluginInstance, state) {
    console.log('Plugin', pluginInstance, 'wants to save a state:', state);
  }
};
