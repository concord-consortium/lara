
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
// @returns A parent DomNode where component can render content
****************************************************************************/
LARA.addSidebar(sidebarOptions: ISidebarOptions) : DomNode


/****************************************************************************
@function openPopup: Ask lara to add a new popup window
@arg {IPopupOptions} popupOptions
@returns A parent DomNode node where component can render content
****************************************************************************/
LARA.openPopup(popupOptions: IPopupOptions) : DomNode


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
}

// @interface IPopupOptions:
interface IPopupOptions {
  title: string,
  color?: string,
  position?: {screenX: number, screenY: number}
  origin?: string,
  draggable?: boolean,
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

Here is an example of how a LARA Plugin

```typescript

constructor(context:Context) {
   this.name = "Glossary"
   this.runKey = context.runKey
   this.definitions = context.authoredState.definitions
   this.userDefinitions = context.userState.definitions
   this.setupSidebar()
   this.decorate() // invoke the text-decorator
 }

 setupSidebar() {
   const { container, icon } = LARA.addSidebar({
      title: “Glossary”,
      color: “gray”
   });
  ReactDOM.render(<GlossaryPopup>, container);
  ReactDOM.render(<GlossaryIcon>, icon);
 }


 decorate() {
   const words = Object.keys(this.definitions)
   const replace = `<span class="cc-glossary-word">$1</span>`
   LARA.decorateText(words, replace, this.wordClicked)
 }

 wordClicked = (word, event) => {
   const popup = this.renderPopup(word, this.userDefinitions)
   const position = // some magic calculations taking into account 
                    // event.screenX/Y, popup size, screen size etc.
   const { container } = LARA.openPopup({
	     title: “Glossary”,
      color: “gray”,
      position: position
   })  // returns {container: <>}
   ReactDOM.render(<GlossaryPopup>, container);
}
```

## Plugin Constract ##
Methods we expect to exist on our plugins:
* constructor
* …