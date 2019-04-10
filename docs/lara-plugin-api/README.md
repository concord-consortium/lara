
LARA Plugin API
===============

### This documentation is meant to be used by LARA Plugin developers.

#### Setup and webpack configuration

LARA API will be available under `window.LARA` object / namespace once the plugin is initialized by LARA.

However, if the plugin is implemented using TypeScript, the best way to get type checking and hints in your IDE is to install [LARA Plugin API NPM package](https://www.npmjs.com/package/@concord-consortium/lara-plugin-api):

```
npm i --save-dev @concord-consortium/lara-plugin-api
```

Then, you need to configure [webpack externals](https://webpack.js.org/configuration/externals/), so webpack does not bundle Plugin API code but looks for global `window.LARA` object instead (and do the same for React if the plugin uses it).

Example of **webpack.config.js**:

```
  externals: {
    // LARA Plugin API implementation is exported to the window.LARA namespace.
    '@concord-consortium/lara-plugin-api': 'LARA',
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

The Plugin will be initialized by LARA automatically. LARA calls its constructor and provides the runtime context object. The plugin constructor should expect [IRuntimeContext](interfaces/iruntimecontext.md) instance as the only argument.

Example:

```typescript
class TestPlugin {
  constructor(context: IRuntimeContext) {
    console.log("Plugin initialized, id:", context.pluginId);
  }
}  

LARAPluginAPI.registerPlugin("testPlugin", TestPlugin);
```

[registerPlugin](#registerplugin) should be called only once, but note that LARA might instantiate multiple instances of the same plugin (e.g. if the activity author adds multiple plugin instances to a page).

Plugins can use all the functions documented below to modify LARA runtime or provide custom features. This documentation is generated automatically from TypeScript definitions and comments.

## Index

### Interfaces

* [IEventListener](interfaces/ieventlistener.md)
* [IPlugin](interfaces/iplugin.md)
* [IPluginStatePath](interfaces/ipluginstatepath.md)
* [IPopupController](interfaces/ipopupcontroller.md)
* [IPopupOptions](interfaces/ipopupoptions.md)
* [IRuntimeContext](interfaces/iruntimecontext.md)
* [IRuntimeContextExperimentalFeatures](interfaces/iruntimecontextexperimentalfeatures.md)
* [ISidebarController](interfaces/isidebarcontroller.md)
* [ISidebarOptions](interfaces/isidebaroptions.md)

### Type aliases

* [IPluginConstructor](#ipluginconstructor)

### Functions

* [addPopup](#addpopup)
* [addSidebar](#addsidebar)
* [decorateContent](#decoratecontent)
* [initPlugin](#initplugin)
* [isTeacherEdition](#isteacheredition)
* [registerPlugin](#registerplugin)
* [saveLearnerPluginState](#savelearnerpluginstate)

### Object literals

* [ADD_POPUP_DEFAULT_OPTIONS](#add_popup_default_options)
* [ADD_SIDEBAR_DEFAULT_OPTIONS](#add_sidebar_default_options)

---

## Type aliases

<a id="ipluginconstructor"></a>

###  IPluginConstructor

**Ƭ IPluginConstructor**: *`object`*

*Defined in [api/plugins.ts:5](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/api/plugins.ts#L5)*

#### Type declaration

___

## Functions

<a id="addpopup"></a>

### `<Const>` addPopup

▸ **addPopup**(_options: *[IPopupOptions](interfaces/ipopupoptions.md)*): [IPopupController](interfaces/ipopupcontroller.md)

*Defined in [lara-plugin-api.ts:94](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L94)*

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

*Defined in [api/sidebar.ts:89](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/api/sidebar.ts#L89)*

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

▸ **decorateContent**(words: *`string`[]*, replace: *`string`*, wordClass: *`string`*, listeners: *`IEventListeners`*): `void`

*Defined in [lara-plugin-api.ts:173](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L173)*

Ask LARA to decorate authored content (text / html).

**Parameters:**

| Name | Type | Description |
| ------ | ------ | ------ |
| words | `string`[] |  A list of case-insensitive words to be decorated. Can use limited regex. |
| replace | `string` |  The replacement string. Can include '$1' representing the matched word. |
| wordClass | `string` |  CSS class used in replacement string. Necessary only if \`listeners\` are provided too. |
| listeners | `IEventListeners` |  One or more { type, listener } tuples. Note that events are added to \`wordClass\` described above. It's client code responsibility to use this class in the \`replace\` string. |

**Returns:** `void`

___
<a id="initplugin"></a>

### `<Const>` initPlugin

▸ **initPlugin**(label: *`string`*, runtimeContext: *[IRuntimeContext](interfaces/iruntimecontext.md)*, pluginStatePath: *[IPluginStatePath](interfaces/ipluginstatepath.md)*): `void`

*Defined in [api/plugins.ts:92](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/api/plugins.ts#L92)*

Note that this method is NOT meant to be called by plugins. It's used by LARA internals. This method is called to initialize the plugin. Called at runtime by LARA to create an instance of the plugin as would happen in `views/plugin/_show.html.haml`.

**Parameters:**

| Name | Type | Description |
| ------ | ------ | ------ |
| label | `string` |  The the script identifier. |
| runtimeContext | [IRuntimeContext](interfaces/iruntimecontext.md) |  Context for the plugin. |
| pluginStatePath | [IPluginStatePath](interfaces/ipluginstatepath.md) |  For saving & loading learner data. |

**Returns:** `void`

___
<a id="isteacheredition"></a>

### `<Const>` isTeacherEdition

▸ **isTeacherEdition**(): `boolean`

*Defined in [lara-plugin-api.ts:186](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L186)*

Find out if the page being displayed is being run in teacher-edition

**Returns:** `boolean`
`true` if lara is running in teacher-edition.

___
<a id="registerplugin"></a>

### `<Const>` registerPlugin

▸ **registerPlugin**(label: *`string`*, _class: *[IPluginConstructor](#ipluginconstructor)*): `boolean`

*Defined in [api/plugins.ts:152](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/api/plugins.ts#L152)*

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
<a id="savelearnerpluginstate"></a>

### `<Const>` saveLearnerPluginState

▸ **saveLearnerPluginState**(pluginId: *`string`*, state: *`any`*): `Promise`<`string`>

*Defined in [api/plugins.ts:120](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/api/plugins.ts#L120)*

Ask LARA to save the users state for the plugin.

```
LARA.saveLearnerPluginState(pluginId, '{"one": 1}').then((data) => console.log(data))
```

**Parameters:**

| Name | Type | Description |
| ------ | ------ | ------ |
| pluginId | `string` |  ID of the plugin trying to save data, initially passed to plugin constructor in the context. |
| state | `any` |  A JSON string representing serialized plugin state. |

**Returns:** `Promise`<`string`>

___

## Object literals

<a id="add_popup_default_options"></a>

### `<Const>` ADD_POPUP_DEFAULT_OPTIONS

**ADD_POPUP_DEFAULT_OPTIONS**: *`object`*

*Defined in [lara-plugin-api.ts:56](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L56)*

<a id="add_popup_default_options.autoopen"></a>

####  autoOpen

**● autoOpen**: *`boolean`* = true

*Defined in [lara-plugin-api.ts:58](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L58)*

___
<a id="add_popup_default_options.backgroundcolor"></a>

####  backgroundColor

**● backgroundColor**: *`string`* = ""

*Defined in [lara-plugin-api.ts:73](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L73)*

___
<a id="add_popup_default_options.closebutton"></a>

####  closeButton

**● closeButton**: *`boolean`* = true

*Defined in [lara-plugin-api.ts:59](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L59)*

___
<a id="add_popup_default_options.closeonescape"></a>

####  closeOnEscape

**● closeOnEscape**: *`boolean`* = false

*Defined in [lara-plugin-api.ts:60](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L60)*

___
<a id="add_popup_default_options.dialogclass"></a>

####  dialogClass

**● dialogClass**: *`string`* = ""

*Defined in [lara-plugin-api.ts:72](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L72)*

Note that dialogClass is intentionally undocumented. Styling uses class makes us depend on the current dialog implementation. It might be necessary for LARA themes, although plugins should not use it.

___
<a id="add_popup_default_options.draggable"></a>

####  draggable

**● draggable**: *`boolean`* = true

*Defined in [lara-plugin-api.ts:63](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L63)*

___
<a id="add_popup_default_options.height"></a>

####  height

**● height**: *`string`* = "auto"

*Defined in [lara-plugin-api.ts:66](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L66)*

___
<a id="add_popup_default_options.modal"></a>

####  modal

**● modal**: *`boolean`* = false

*Defined in [lara-plugin-api.ts:62](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L62)*

___
<a id="add_popup_default_options.onbeforeclose"></a>

####  onBeforeClose

**● onBeforeClose**: *`null`* =  null

*Defined in [lara-plugin-api.ts:77](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L77)*

___
<a id="add_popup_default_options.ondragstart"></a>

####  onDragStart

**● onDragStart**: *`null`* =  null

*Defined in [lara-plugin-api.ts:79](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L79)*

___
<a id="add_popup_default_options.ondragstop"></a>

####  onDragStop

**● onDragStop**: *`null`* =  null

*Defined in [lara-plugin-api.ts:80](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L80)*

___
<a id="add_popup_default_options.onopen"></a>

####  onOpen

**● onOpen**: *`null`* =  null

*Defined in [lara-plugin-api.ts:76](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L76)*

___
<a id="add_popup_default_options.onresize"></a>

####  onResize

**● onResize**: *`null`* =  null

*Defined in [lara-plugin-api.ts:78](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L78)*

___
<a id="add_popup_default_options.padding"></a>

####  padding

**● padding**: *`number`* = 10

*Defined in [lara-plugin-api.ts:67](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L67)*

___
<a id="add_popup_default_options.removeonclose"></a>

####  removeOnClose

**● removeOnClose**: *`boolean`* = true

*Defined in [lara-plugin-api.ts:61](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L61)*

___
<a id="add_popup_default_options.resizable"></a>

####  resizable

**● resizable**: *`boolean`* = true

*Defined in [lara-plugin-api.ts:64](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L64)*

___
<a id="add_popup_default_options.title"></a>

####  title

**● title**: *`string`* = ""

*Defined in [lara-plugin-api.ts:57](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L57)*

___
<a id="add_popup_default_options.titlebarcolor"></a>

####  titlebarColor

**● titlebarColor**: *`string`* = ""

*Defined in [lara-plugin-api.ts:74](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L74)*

___
<a id="add_popup_default_options.width"></a>

####  width

**● width**: *`number`* = 300

*Defined in [lara-plugin-api.ts:65](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L65)*

___
<a id="add_popup_default_options.position"></a>

####  position

**position**: *`object`*

*Defined in [lara-plugin-api.ts:75](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L75)*

<a id="add_popup_default_options.position.at"></a>

####  at

**● at**: *`string`* = "center"

*Defined in [lara-plugin-api.ts:75](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L75)*

___
<a id="add_popup_default_options.position.my"></a>

####  my

**● my**: *`string`* = "center"

*Defined in [lara-plugin-api.ts:75](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L75)*

___
<a id="add_popup_default_options.position.of"></a>

####  of

**● of**: *`Window`* =  window

*Defined in [lara-plugin-api.ts:75](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L75)*

___

___

___
<a id="add_sidebar_default_options"></a>

### `<Const>` ADD_SIDEBAR_DEFAULT_OPTIONS

**ADD_SIDEBAR_DEFAULT_OPTIONS**: *`object`*

*Defined in [api/sidebar.ts:30](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/api/sidebar.ts#L30)*

<a id="add_sidebar_default_options.handle"></a>

####  handle

**● handle**: *`string`* = ""

*Defined in [api/sidebar.ts:32](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/api/sidebar.ts#L32)*

___
<a id="add_sidebar_default_options.handlecolor"></a>

####  handleColor

**● handleColor**: *`string`* = "#aaa"

*Defined in [api/sidebar.ts:33](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/api/sidebar.ts#L33)*

___
<a id="add_sidebar_default_options.icon"></a>

####  icon

**● icon**: *`string`* = "default"

*Defined in [api/sidebar.ts:31](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/api/sidebar.ts#L31)*

___
<a id="add_sidebar_default_options.padding"></a>

####  padding

**● padding**: *`number`* = 25

*Defined in [api/sidebar.ts:37](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/api/sidebar.ts#L37)*

___
<a id="add_sidebar_default_options.titlebar"></a>

####  titleBar

**● titleBar**: *`null`* =  null

*Defined in [api/sidebar.ts:34](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/api/sidebar.ts#L34)*

___
<a id="add_sidebar_default_options.titlebarcolor"></a>

####  titleBarColor

**● titleBarColor**: *`string`* = "#bbb"

*Defined in [api/sidebar.ts:35](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/api/sidebar.ts#L35)*

___
<a id="add_sidebar_default_options.width"></a>

####  width

**● width**: *`number`* = 500

*Defined in [api/sidebar.ts:36](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/api/sidebar.ts#L36)*

___

___

