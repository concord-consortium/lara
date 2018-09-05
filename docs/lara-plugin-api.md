
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
LARA.addSidebar(sidebarOptions: ISidebarOptions) : void


/****************************************************************************
@function openPopup: Ask lara to add a new popup window
@arg {IPopupOptions} popupOptions
@returns void
****************************************************************************/
LARA.openPopup(popupOptions: IPopupOptions) : void


/****************************************************************************
@function decorateContent: Ask LARA to decorate authored content (text / html)
@arg {string[]} words - a list of case-insensitive words to be decorated
    can use limited regex
@arg {string} replace - the replacement string.
     Can include '$1' representing the matched word.
@arg {IEventListeners} listeners - one or more { type, listener } tuples
@returns void
****************************************************************************/
LARA.decorateContent(words: string[], replace: string, listeners: IEventListeners) : void


/****************************************************************************
@function saveUserState: Ask lara to save the users state for the plugin
@arg {ILaraPluginRef} pluginInstance - The plugin trying to save data
@arg {string} state - A JSON string representing serialized plugin state.
@returns Promise
****************************************************************************/
LARA.saveUserState(pluginInstance: ILaraPluginRef, state: string) : Promise

// @interface ISidebarOptions:
interface ISidebarOptions {
  title: string
  color?: string,
  icon?: HTMLElement,
  content: DomNode
}

// @interface IPopupOptions:
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

// @interface IEventListener:
interface IEventListener {
    type: string;
    listener: (evt: Event) => void;
}
// @type IEventListener:
type IEventListeners = IEventListener | IEventListener[]

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
    LARA.openPopup({
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
