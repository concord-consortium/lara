
#  LARA Plugin API

## Index

### Interfaces

* [IEventListener](interfaces/ieventlistener.md)
* [IPopupController](interfaces/ipopupcontroller.md)
* [IPopupOptions](interfaces/ipopupoptions.md)
* [ISidebarController](interfaces/isidebarcontroller.md)
* [ISidebarOptions](interfaces/isidebaroptions.md)

### Functions

* [addPopup](#addpopup)
* [addSidebar](#addsidebar)
* [decorateContent](#decoratecontent)
* [isTeacherEdition](#isteacheredition)
* [registerPlugin](#registerplugin)
* [saveLearnerPluginState](#savelearnerpluginstate)

---

## Functions

<a id="addpopup"></a>

### `<Const>` addPopup

▸ **addPopup**(_options: *[IPopupOptions](interfaces/ipopupoptions.md)*): [IPopupController](interfaces/ipopupcontroller.md)

*Defined in [lara-plugin-api.ts:88](https://github.com/concord-consortium/lara/blob/ffbf9439/lara-plugin-api/src/lara-plugin-api.ts#L88)*

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

*Defined in [lara-plugin-api.ts:200](https://github.com/concord-consortium/lara/blob/ffbf9439/lara-plugin-api/src/lara-plugin-api.ts#L200)*

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

*Defined in [lara-plugin-api.ts:236](https://github.com/concord-consortium/lara/blob/ffbf9439/lara-plugin-api/src/lara-plugin-api.ts#L236)*

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
<a id="isteacheredition"></a>

### `<Const>` isTeacherEdition

▸ **isTeacherEdition**(): `boolean`

*Defined in [lara-plugin-api.ts:262](https://github.com/concord-consortium/lara/blob/ffbf9439/lara-plugin-api/src/lara-plugin-api.ts#L262)*

Find out if the page being displayed is being run in teacher-edition

**Returns:** `boolean`
`true` if lara is running in teacher-edition.

___
<a id="registerplugin"></a>

### `<Const>` registerPlugin

▸ **registerPlugin**(label: *`string`*, _class: *`any`*): `any`

*Defined in [lara-plugin-api.ts:254](https://github.com/concord-consortium/lara/blob/ffbf9439/lara-plugin-api/src/lara-plugin-api.ts#L254)*

Register a new external script as `label` with `_class`.

```
LARA.registerPlugin('debugger', Dubugger);
```

**Parameters:**

| Name | Type | Description |
| ------ | ------ | ------ |
| label | `string` |  The identifier of the script. |
| _class | `any` |  The Plugin Class being associated with the identifier. |

**Returns:** `any`
`true` if plugin was registered correctly.

___
<a id="savelearnerpluginstate"></a>

### `<Const>` saveLearnerPluginState

▸ **saveLearnerPluginState**(pluginId: *`string`*, state: *`string`*): `Promise`<`string`>

*Defined in [lara-plugin-api.ts:216](https://github.com/concord-consortium/lara/blob/ffbf9439/lara-plugin-api/src/lara-plugin-api.ts#L216)*

Ask LARA to save the users state for the plugin.

```
LARA.saveLearnerPluginState(plugin, '{"one": 1}').then((data) => console.log(data))
```

**Parameters:**

| Name | Type | Description |
| ------ | ------ | ------ |
| pluginId | `string` |  ID of the plugin trying to save data, initially passed to plugin constructor in the context |
| state | `string` |  A JSON string representing serialized plugin state. |

**Returns:** `Promise`<`string`>

___

