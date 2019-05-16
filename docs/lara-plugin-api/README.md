
LARA Plugin API
===============

### This documentation is meant to be used by LARA Plugin developers.

#### Setup and webpack configuration

LARA API will be available under `window.LARA.PluginAPI_V3` object / namespace once the plugin is initialized by LARA.

However, if the plugin is implemented using TypeScript, the best way to get type checking and hints in your IDE is to install [LARA Plugin API NPM package](https://www.npmjs.com/package/@concord-consortium/lara-plugin-api):

```
npm i --save-dev @concord-consortium/lara-plugin-api
```

Then, you need to configure [webpack externals](https://webpack.js.org/configuration/externals/), so webpack does not bundle Plugin API code but looks for global `window.LARA.PluginAPI_V3` object instead (and do the same for React if the plugin uses it).

Example of **webpack.config.js**:

```
  externals: {
    // LARA Plugin API implementation is exported to the window.LARA.PluginAPI_V3 namespace.
    '@concord-consortium/lara-plugin-api': 'LARA.PluginAPI_V3',
    // Use React and ReactDOM provided by LARA, do not bundle an own copy.  
    'react': 'React',
    'react-dom': 'ReactDOM',
  }
```

Finally, you can import LARA Plugin API anywhere in your code and benefit from automatic type checking:

```typescript
import * as LARAPluginAPI from "@concord-consortium/lara-plugin-api";
// (...)
LARAPluginAPI.registerPlugin("test", Test);
// (...)
LARAPluginAPI.addSidebar({ content: "test sidebar" });
// etc.
```

#### Plugin implementation

LARA Plugin is a regular JavaScript class (or constructor). There are no special requirements regarding its interface at the moment, but it's a subject to change. Always check [IPlugin](interfaces/iplugin.md) interface first.

The first thing that should be done by plugin script is call to [registerPlugin](#registerplugin).

The Plugin will be initialized by LARA automatically. LARA calls its constructor and provides the runtime context object. The plugin constructor should expect [IPluginRuntimeContext](interfaces/ipluginruntimecontext.md) instance as the only argument.

Example:

```typescript
class TestPlugin {
  constructor(context: IPluginRuntimeContext) {
    console.log("Plugin initialized, id:", context.pluginId);
  }
}  

LARAPluginAPI.registerPlugin("testPlugin", TestPlugin);
```

[registerPlugin](#registerplugin) should be called only once, but note that LARA might instantiate multiple instances of the same plugin (e.g. if the activity author adds multiple plugin instances to a page).

Plugins can use all the functions documented below to modify LARA runtime or provide custom features. This documentation is generated automatically from TypeScript definitions and comments.

## Index

### Interfaces

* [IClassInfo](interfaces/iclassinfo.md)
* [IEmbeddableRuntimeContext](interfaces/iembeddableruntimecontext.md)
* [IEventListener](interfaces/ieventlistener.md)
* [IInteractiveAvailableEvent](interfaces/iinteractiveavailableevent.md)
* [IInteractiveState](interfaces/iinteractivestate.md)
* [IJwtClaims](interfaces/ijwtclaims.md)
* [IJwtResponse](interfaces/ijwtresponse.md)
* [ILogData](interfaces/ilogdata.md)
* [IOffering](interfaces/ioffering.md)
* [IPlugin](interfaces/iplugin.md)
* [IPluginRuntimeContext](interfaces/ipluginruntimecontext.md)
* [IPopupController](interfaces/ipopupcontroller.md)
* [IPopupOptions](interfaces/ipopupoptions.md)
* [IPortalClaims](interfaces/iportalclaims.md)
* [ISidebarController](interfaces/isidebarcontroller.md)
* [ISidebarOptions](interfaces/isidebaroptions.md)
* [IUser](interfaces/iuser.md)

### Type aliases

* [IEventListeners](#ieventlisteners)
* [IInteractiveAvailableEventHandler](#iinteractiveavailableeventhandler)
* [ILogEventHandler](#ilogeventhandler)
* [IPluginConstructor](#ipluginconstructor)

### Functions

* [addPopup](#addpopup)
* [addSidebar](#addsidebar)
* [decorateContent](#decoratecontent)
* [registerPlugin](#registerplugin)

### Object literals

* [ADD_POPUP_DEFAULT_OPTIONS](#add_popup_default_options)
* [ADD_SIDEBAR_DEFAULT_OPTIONS](#add_sidebar_default_options)
* [events](#events)

---

## Type aliases

<a id="ieventlisteners"></a>

###  IEventListeners

**Ƭ IEventListeners**: *[IEventListener](interfaces/ieventlistener.md) \| [IEventListener](interfaces/ieventlistener.md)[]*

*Defined in [decorate-content.ts:8](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/decorate-content.ts#L8)*

___
<a id="iinteractiveavailableeventhandler"></a>

###  IInteractiveAvailableEventHandler

**Ƭ IInteractiveAvailableEventHandler**: *`function`*

*Defined in [types.ts:188](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/types.ts#L188)*

InteractiveAvailable event handler.

#### Type declaration
▸(event: *[IInteractiveAvailableEvent](interfaces/iinteractiveavailableevent.md)*): `void`

**Parameters:**

| Name | Type |
| ------ | ------ |
| event | [IInteractiveAvailableEvent](interfaces/iinteractiveavailableevent.md) |

**Returns:** `void`

___
<a id="ilogeventhandler"></a>

###  ILogEventHandler

**Ƭ ILogEventHandler**: *`function`*

*Defined in [types.ts:169](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/types.ts#L169)*

Log event handler.

*__param__*: Data logged by the code.

#### Type declaration
▸(event: *[ILogData](interfaces/ilogdata.md)*): `void`

**Parameters:**

| Name | Type |
| ------ | ------ |
| event | [ILogData](interfaces/ilogdata.md) |

**Returns:** `void`

___
<a id="ipluginconstructor"></a>

###  IPluginConstructor

**Ƭ IPluginConstructor**: *`object`*

*Defined in [types.ts:5](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/types.ts#L5)*

#### Type declaration

___

## Functions

<a id="addpopup"></a>

### `<Const>` addPopup

▸ **addPopup**(_options: *[IPopupOptions](interfaces/ipopupoptions.md)*): [IPopupController](interfaces/ipopupcontroller.md)

*Defined in [popup.ts:86](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L86)*

Ask LARA to add a new popup window.

Note that many options closely resemble jQuery UI dialog options which is used under the hood. You can refer to jQuery UI API docs in many cases: [https://api.jqueryui.com/dialog](https://api.jqueryui.com/dialog) Only `content` is required. Other options have reasonable default values (subject to change, so if you expect particular behaviour, provide necessary options explicitly).

React warning: if you use React to render content, remember to call `ReactDOM.unmountComponentAtNode(content)` in `onRemove` handler.

**Parameters:**

| Name | Type |
| ------ | ------ |
| _options | [IPopupOptions](interfaces/ipopupoptions.md) |

**Returns:** [IPopupController](interfaces/ipopupcontroller.md)

___
<a id="addsidebar"></a>

### `<Const>` addSidebar

▸ **addSidebar**(_options: *[ISidebarOptions](interfaces/isidebaroptions.md)*): [ISidebarController](interfaces/isidebarcontroller.md)

*Defined in [sidebar.ts:90](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/sidebar.ts#L90)*

Ask LARA to add a new sidebar.

Sidebar will be added to the edge of the interactive page window. When multiple sidebars are added, there's no way to specify their positions, so no assumptions should be made about current display - it might change.

Sidebar height cannot be specified. It's done on purpose to prevent issues on very short screens. It's based on the provided content HTML element, but it's limited to following range:

*   100px is the min-height
*   max-height is calculated dynamically and ensures that sidebar won't go off the screen If the provided content is taller than the max-height of the sidebar, a sidebar content container will scroll.

It returns a simple controller that can be used to open or close sidebar.

**Parameters:**

| Name | Type |
| ------ | ------ |
| _options | [ISidebarOptions](interfaces/isidebaroptions.md) |

**Returns:** [ISidebarController](interfaces/isidebarcontroller.md)

___
<a id="decoratecontent"></a>

### `<Const>` decorateContent

▸ **decorateContent**(words: *`string`[]*, replace: *`string`*, wordClass: *`string`*, listeners: *[IEventListeners](#ieventlisteners)*): `void`

*Defined in [decorate-content.ts:19](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/decorate-content.ts#L19)*

Ask LARA to decorate authored content (text / html).

**Parameters:**

| Name | Type | Description |
| ------ | ------ | ------ |
| words | `string`[] |  A list of case-insensitive words to be decorated. Can use limited regex. |
| replace | `string` |  The replacement string. Can include '$1' representing the matched word. |
| wordClass | `string` |  CSS class used in replacement string. Necessary only if \`listeners\` are provided too. |
| listeners | [IEventListeners](#ieventlisteners) |  One or more { type, listener } tuples. Note that events are added to \`wordClass\` described above. It's client code responsibility to use this class in the \`replace\` string. |

**Returns:** `void`

___
<a id="registerplugin"></a>

### `<Const>` registerPlugin

▸ **registerPlugin**(label: *`string`*, _class: *[IPluginConstructor](#ipluginconstructor)*): `boolean`

*Defined in [plugins.ts:13](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/plugins.ts#L13)*

Register a new external script as `label` with `_class`, e.g.:

```
registerPlugin('debugger', Dubugger)
```

**Parameters:**

| Name | Type | Description |
| ------ | ------ | ------ |
| label | `string` |  The identifier of the script. |
| _class | [IPluginConstructor](#ipluginconstructor) |  The Plugin class/constructor being associated with the identifier. |

**Returns:** `boolean`
`true` if plugin was registered correctly.

___

## Object literals

<a id="add_popup_default_options"></a>

### `<Const>` ADD_POPUP_DEFAULT_OPTIONS

**ADD_POPUP_DEFAULT_OPTIONS**: *`object`*

*Defined in [popup.ts:48](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L48)*

<a id="add_popup_default_options.autoopen"></a>

####  autoOpen

**● autoOpen**: *`boolean`* = true

*Defined in [popup.ts:50](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L50)*

___
<a id="add_popup_default_options.backgroundcolor"></a>

####  backgroundColor

**● backgroundColor**: *`string`* = ""

*Defined in [popup.ts:65](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L65)*

___
<a id="add_popup_default_options.closebutton"></a>

####  closeButton

**● closeButton**: *`boolean`* = true

*Defined in [popup.ts:51](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L51)*

___
<a id="add_popup_default_options.closeonescape"></a>

####  closeOnEscape

**● closeOnEscape**: *`boolean`* = false

*Defined in [popup.ts:52](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L52)*

___
<a id="add_popup_default_options.dialogclass"></a>

####  dialogClass

**● dialogClass**: *`string`* = ""

*Defined in [popup.ts:64](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L64)*

Note that dialogClass is intentionally undocumented. Styling uses class makes us depend on the current dialog implementation. It might be necessary for LARA themes, although plugins should not use it.

___
<a id="add_popup_default_options.draggable"></a>

####  draggable

**● draggable**: *`boolean`* = true

*Defined in [popup.ts:55](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L55)*

___
<a id="add_popup_default_options.height"></a>

####  height

**● height**: *`string`* = "auto"

*Defined in [popup.ts:58](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L58)*

___
<a id="add_popup_default_options.modal"></a>

####  modal

**● modal**: *`boolean`* = false

*Defined in [popup.ts:54](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L54)*

___
<a id="add_popup_default_options.onbeforeclose"></a>

####  onBeforeClose

**● onBeforeClose**: *`null`* =  null

*Defined in [popup.ts:69](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L69)*

___
<a id="add_popup_default_options.ondragstart"></a>

####  onDragStart

**● onDragStart**: *`null`* =  null

*Defined in [popup.ts:71](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L71)*

___
<a id="add_popup_default_options.ondragstop"></a>

####  onDragStop

**● onDragStop**: *`null`* =  null

*Defined in [popup.ts:72](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L72)*

___
<a id="add_popup_default_options.onopen"></a>

####  onOpen

**● onOpen**: *`null`* =  null

*Defined in [popup.ts:68](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L68)*

___
<a id="add_popup_default_options.onresize"></a>

####  onResize

**● onResize**: *`null`* =  null

*Defined in [popup.ts:70](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L70)*

___
<a id="add_popup_default_options.padding"></a>

####  padding

**● padding**: *`number`* = 10

*Defined in [popup.ts:59](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L59)*

___
<a id="add_popup_default_options.removeonclose"></a>

####  removeOnClose

**● removeOnClose**: *`boolean`* = true

*Defined in [popup.ts:53](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L53)*

___
<a id="add_popup_default_options.resizable"></a>

####  resizable

**● resizable**: *`boolean`* = true

*Defined in [popup.ts:56](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L56)*

___
<a id="add_popup_default_options.title"></a>

####  title

**● title**: *`string`* = ""

*Defined in [popup.ts:49](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L49)*

___
<a id="add_popup_default_options.titlebarcolor"></a>

####  titlebarColor

**● titlebarColor**: *`string`* = ""

*Defined in [popup.ts:66](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L66)*

___
<a id="add_popup_default_options.width"></a>

####  width

**● width**: *`number`* = 300

*Defined in [popup.ts:57](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L57)*

___
<a id="add_popup_default_options.position"></a>

####  position

**position**: *`object`*

*Defined in [popup.ts:67](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L67)*

<a id="add_popup_default_options.position.at"></a>

####  at

**● at**: *`string`* = "center"

*Defined in [popup.ts:67](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L67)*

___
<a id="add_popup_default_options.position.my"></a>

####  my

**● my**: *`string`* = "center"

*Defined in [popup.ts:67](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L67)*

___
<a id="add_popup_default_options.position.of"></a>

####  of

**● of**: *`Window`* =  window

*Defined in [popup.ts:67](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/popup.ts#L67)*

___

___

___
<a id="add_sidebar_default_options"></a>

### `<Const>` ADD_SIDEBAR_DEFAULT_OPTIONS

**ADD_SIDEBAR_DEFAULT_OPTIONS**: *`object`*

*Defined in [sidebar.ts:30](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/sidebar.ts#L30)*

<a id="add_sidebar_default_options.handle"></a>

####  handle

**● handle**: *`string`* = ""

*Defined in [sidebar.ts:33](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/sidebar.ts#L33)*

___
<a id="add_sidebar_default_options.handlecolor"></a>

####  handleColor

**● handleColor**: *`string`* = "#aaa"

*Defined in [sidebar.ts:34](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/sidebar.ts#L34)*

___
<a id="add_sidebar_default_options.icon"></a>

####  icon

**● icon**: *`string`* = "default"

*Defined in [sidebar.ts:32](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/sidebar.ts#L32)*

Arrow pointing left.

___
<a id="add_sidebar_default_options.padding"></a>

####  padding

**● padding**: *`number`* = 25

*Defined in [sidebar.ts:38](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/sidebar.ts#L38)*

___
<a id="add_sidebar_default_options.titlebar"></a>

####  titleBar

**● titleBar**: *`null`* =  null

*Defined in [sidebar.ts:35](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/sidebar.ts#L35)*

___
<a id="add_sidebar_default_options.titlebarcolor"></a>

####  titleBarColor

**● titleBarColor**: *`string`* = "#bbb"

*Defined in [sidebar.ts:36](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/sidebar.ts#L36)*

___
<a id="add_sidebar_default_options.width"></a>

####  width

**● width**: *`number`* = 500

*Defined in [sidebar.ts:37](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/sidebar.ts#L37)*

___

___
<a id="events"></a>

### `<Const>` events

**events**: *`object`*

*Defined in [events.ts:7](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/events.ts#L7)*

Functions related to event observing provided by LARA.

<a id="events.offinteractiveavailable"></a>

####  offInteractiveAvailable

▸ **offInteractiveAvailable**(handler: *[IInteractiveAvailableEventHandler](#iinteractiveavailableeventhandler)*): `void`

*Defined in [events.ts:28](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/events.ts#L28)*

Removes InteractiveAvailable event handler.

**Parameters:**

| Name | Type |
| ------ | ------ |
| handler | [IInteractiveAvailableEventHandler](#iinteractiveavailableeventhandler) |

**Returns:** `void`

___
<a id="events.offlog"></a>

####  offLog

▸ **offLog**(handler: *[ILogEventHandler](#ilogeventhandler)*): `void`

*Defined in [events.ts:19](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/events.ts#L19)*

Removes log event handler.

**Parameters:**

| Name | Type |
| ------ | ------ |
| handler | [ILogEventHandler](#ilogeventhandler) |

**Returns:** `void`

___
<a id="events.oninteractiveavailable"></a>

####  onInteractiveAvailable

▸ **onInteractiveAvailable**(handler: *[IInteractiveAvailableEventHandler](#iinteractiveavailableeventhandler)*): `void`

*Defined in [events.ts:24](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/events.ts#L24)*

Subscribes to InteractiveAvailable events. Gets called when any interactive changes its availablity state. Currently uses when click to play mode is enabled and the click to play overlay is clicked.

**Parameters:**

| Name | Type |
| ------ | ------ |
| handler | [IInteractiveAvailableEventHandler](#iinteractiveavailableeventhandler) |

**Returns:** `void`

___
<a id="events.onlog"></a>

####  onLog

▸ **onLog**(handler: *[ILogEventHandler](#ilogeventhandler)*): `void`

*Defined in [events.ts:15](https://github.com/concord-consortium/lara/blob/c29432d2/lara-typescript/src/plugin-api/events.ts#L15)*

Subscribes to log events. Gets called when any event is logged to the CC Log Manager app.

**Parameters:**

| Name | Type |
| ------ | ------ |
| handler | [ILogEventHandler](#ilogeventhandler) |

**Returns:** `void`

___

___

