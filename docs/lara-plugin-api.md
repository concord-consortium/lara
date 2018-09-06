
# LARA Plugin API

A LARA Plugin architecture which can be used by
javascript developers to add new features to LARA.

NP 2018-08-29 -- This documentation is being developed and is
subject to change.  

## The hosted LARA Plugin API

This describes the functions attached to the global `window.LARA` object
LARA exports.

```typescript

/****************************************************************************
// @function addSidebar: Ask lara to add a new sidebar window
// @arg {ISidebarOptions} sidebarOptions
// @returns void
****************************************************************************/
LARA.addSidebar = function (sidebarOptions: ISidebarOptions): void;

interface ISidebarOptions {
  title: string;
  color?: string;
  icon?: HTMLElement;
  content: HTMLElement;
}

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
****************************************************************************/
LARA.addPopup = function (popupOptions: IPopupOptions): IPopupController;

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


/****************************************************************************
@function decorateContent: Ask LARA to decorate authored content (text / html)
@arg {string[]} words - a list of case-insensitive words to be decorated
    can use limited regex
@arg {string} replace - the replacement string.
     Can include '$1' representing the matched word.
@arg {string} wordClass - class used for the enclosing tag (e.g. 'cc-glossary-word')
@arg {IEventListeners} listeners - one or more { type, listener } tuples
@returns void
****************************************************************************/
LARA.decorateContent = function (words: string[], replace: string, wordClass: string. listeners: IEventListeners): void;

interface IEventListener {
  type: string;
  listener: (evt: Event) => void;
}

type IEventListeners = IEventListener | IEventListener[];


/****************************************************************************
@function saveUserState: Ask lara to save the users state for the plugin
@arg {ILaraPluginRef} pluginInstance - The plugin trying to save data
@arg {string} state - A JSON string representing serialized plugin state.
@returns Promise
****************************************************************************/
LARA.saveUserState = function(pluginInstance: ILaraPluginRef, state: string): Promise;

```


## Sample Usage ##

Here is an example of a LARA Plugin

```typescript

class GlossaryPlugin {
    constructor(context: Context) {
    this.name = "Glossary";
    this.runKey = context.runKey;
    this.definitions = context.authoredState.definitions;
    this.userDefinitions = context.userState.definitions;
    this.setupSidebar();
    this.decorate(); // invoke the text-decorator
  }

  setupSidebar() {
    ReactDOM.render(<GlossaryPopup>, container);
    ReactDOM.render(<GlossaryIcon>, icon);
    LARA.addSidebar({
      content: container,
      icon: icon,
      title: "Glossary",
      color: "gray"
    });
  }

  decorate() {
    const words = Object.keys(this.definitions);
    const replace = `<span class="cc-glossary-word">$1</span>`;
    LARA.decorateText(words, replace, this.wordClicked);
  }

  wordClicked = (word, event) => {
    ReactDOM.render(<GlossaryPopup>, container);
    const wordDomELement = event.target;
    LARA.addPopup({
      content: container,
      title: "Glossary",
      position: { my: "left top", at: "left bottom", of: wordDomELement }
    });
  }
}
```

## Plugin Contract ##
Methods we expect to exist on our plugins:
* constructor
* …
