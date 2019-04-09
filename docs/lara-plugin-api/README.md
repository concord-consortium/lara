
LARA Plugin API
===============

### This document is meant to be used by LARA Plugin developers.

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

[registerPlugin](#registerplugin) should be called only once, but note that LARA might instantiate multiple instances of the same plugin.

Plugins can use all the functions documented below to modify LARA runtime or provide custom features.

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

---

## Type aliases

<a id="ipluginconstructor"></a>

###  IPluginConstructor

**Ƭ IPluginConstructor**: *`object`*

*Defined in [api/plugins.ts:5](https://github.com/concord-consortium/lara/blob/e0cb6cdb/lara-plugin-api/src/api/plugins.ts#L5)*

#### Type declaration

___

## Functions

<a id="addpopup"></a>

### `<Const>` addPopup

▸ **addPopup**(_options: *[IPopupOptions](interfaces/ipopupoptions.md)*): [IPopupController](interfaces/ipopupcontroller.md)

*Defined in [lara-plugin-api.ts:91](https://github.com/concord-consortium/lara/blob/e0cb6cdb/lara-plugin-api/src/lara-plugin-api.ts#L91)*

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

▸ **addSidebar**(options: *[ISidebarOptions](interfaces/isidebaroptions.md)*): [ISidebarController](interfaces/isidebarcontroller.md)

*Defined in [lara-plugin-api.ts:203](https://github.com/concord-consortium/lara/blob/e0cb6cdb/lara-plugin-api/src/lara-plugin-api.ts#L203)*

Ask LARA to add a new sidebar.

Sidebar will be added to the edge of the interactive page window. When multiple sidebars are added, there's no way to specify their positions, so no assumptions should be made about current display - it might change.

Sidebar height cannot be specified. It's done on purpose to prevent issues on very short screens. It's based on the provided content HTML element, but it's limited to following range:

*   100px is the min-height
*   max-height is calculated dynamically and ensures that sidebar won't go off the screen If the provided content is taller than the max-height of the sidebar, a sidebar content container will scroll.

It returns a simple controller that can be used to open or close sidebar.

**Parameters:**

| Name | Type |
| ------ | ------ |
| options | [ISidebarOptions](interfaces/isidebaroptions.md) |

**Returns:** [ISidebarController](interfaces/isidebarcontroller.md)

___
<a id="decoratecontent"></a>

### `<Const>` decorateContent

▸ **decorateContent**(words: *`string`[]*, replace: *`string`*, wordClass: *`string`*, listeners: *`IEventListeners`*): `void`

*Defined in [lara-plugin-api.ts:227](https://github.com/concord-consortium/lara/blob/e0cb6cdb/lara-plugin-api/src/lara-plugin-api.ts#L227)*

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

*Defined in [api/plugins.ts:92](https://github.com/concord-consortium/lara/blob/e0cb6cdb/lara-plugin-api/src/api/plugins.ts#L92)*

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

*Defined in [lara-plugin-api.ts:240](https://github.com/concord-consortium/lara/blob/e0cb6cdb/lara-plugin-api/src/lara-plugin-api.ts#L240)*

Find out if the page being displayed is being run in teacher-edition

**Returns:** `boolean`
`true` if lara is running in teacher-edition.

___
<a id="registerplugin"></a>

### `<Const>` registerPlugin

▸ **registerPlugin**(label: *`string`*, _class: *[IPluginConstructor](#ipluginconstructor)*): `boolean`

*Defined in [api/plugins.ts:152](https://github.com/concord-consortium/lara/blob/e0cb6cdb/lara-plugin-api/src/api/plugins.ts#L152)*

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

*Defined in [api/plugins.ts:120](https://github.com/concord-consortium/lara/blob/e0cb6cdb/lara-plugin-api/src/api/plugins.ts#L120)*

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

