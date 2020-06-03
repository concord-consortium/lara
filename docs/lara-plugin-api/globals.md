[LARA Plugin API](README.md) › [Globals](globals.md)

# LARA Plugin API

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
* [IPluginAuthoringContext](interfaces/ipluginauthoringcontext.md)
* [IPluginRuntimeContext](interfaces/ipluginruntimecontext.md)
* [IPopupController](interfaces/ipopupcontroller.md)
* [IPopupOptions](interfaces/ipopupoptions.md)
* [IPortalClaims](interfaces/iportalclaims.md)
* [IRegisterPluginOptions](interfaces/iregisterpluginoptions.md)
* [ISidebarController](interfaces/isidebarcontroller.md)
* [ISidebarOptions](interfaces/isidebaroptions.md)
* [IUser](interfaces/iuser.md)

### Type aliases

* [IEventListeners](globals.md#ieventlisteners)
* [IInteractiveAvailableEventHandler](globals.md#iinteractiveavailableeventhandler)
* [ILogEventHandler](globals.md#ilogeventhandler)

### Variables

* [BOTTOM_MARGIN](globals.md#const-bottom_margin)
* [SIDEBAR_SPACER](globals.md#const-sidebar_spacer)
* [controllers](globals.md#const-controllers)

### Functions

* [addPopup](globals.md#const-addpopup)
* [addSidebar](globals.md#const-addsidebar)
* [closeAllSidebars](globals.md#const-closeallsidebars)
* [decorateContent](globals.md#const-decoratecontent)
* [positionMultipleSidebars](globals.md#const-positionmultiplesidebars)
* [registerPlugin](globals.md#const-registerplugin)

### Object literals

* [ADD_POPUP_DEFAULT_OPTIONS](globals.md#const-add_popup_default_options)
* [ADD_SIDEBAR_DEFAULT_OPTIONS](globals.md#const-add_sidebar_default_options)
* [events](globals.md#const-events)

## Type aliases

###  IEventListeners

Ƭ **IEventListeners**: *[IEventListener](interfaces/ieventlistener.md) | [IEventListener](interfaces/ieventlistener.md)[]*

*Defined in [decorate-content.ts:8](../../lara-typescript/src/plugin-api/decorate-content.ts#L8)*

___

###  IInteractiveAvailableEventHandler

Ƭ **IInteractiveAvailableEventHandler**: *function*

*Defined in [types.ts:235](../../lara-typescript/src/plugin-api/types.ts#L235)*

InteractiveAvailable event handler.

#### Type declaration:

▸ (`event`: [IInteractiveAvailableEvent](interfaces/iinteractiveavailableevent.md)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`event` | [IInteractiveAvailableEvent](interfaces/iinteractiveavailableevent.md) |

___

###  ILogEventHandler

Ƭ **ILogEventHandler**: *function*

*Defined in [types.ts:216](../../lara-typescript/src/plugin-api/types.ts#L216)*

Log event handler.

**`param`** Data logged by the code.

#### Type declaration:

▸ (`event`: [ILogData](interfaces/ilogdata.md)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`event` | [ILogData](interfaces/ilogdata.md) |

## Variables

### `Const` BOTTOM_MARGIN

• **BOTTOM_MARGIN**: *30* = 30

*Defined in [sidebar.ts:7](../../lara-typescript/src/plugin-api/sidebar.ts#L7)*

___

### `Const` SIDEBAR_SPACER

• **SIDEBAR_SPACER**: *35* = 35

*Defined in [sidebar.ts:5](../../lara-typescript/src/plugin-api/sidebar.ts#L5)*

___

### `Const` controllers

• **controllers**: *[ISidebarController](interfaces/isidebarcontroller.md)[]* = []

*Defined in [sidebar.ts:42](../../lara-typescript/src/plugin-api/sidebar.ts#L42)*

## Functions

### `Const` addPopup

▸ **addPopup**(`_options`: [IPopupOptions](interfaces/ipopupoptions.md)): *[IPopupController](interfaces/ipopupcontroller.md)*

*Defined in [popup.ts:86](../../lara-typescript/src/plugin-api/popup.ts#L86)*

Ask LARA to add a new popup window.

Note that many options closely resemble jQuery UI dialog options which is used under the hood.
You can refer to jQuery UI API docs in many cases: https://api.jqueryui.com/dialog
Only `content` is required. Other options have reasonable default values (subject to change,
so if you expect particular behaviour, provide necessary options explicitly).

React warning: if you use React to render content, remember to call `ReactDOM.unmountComponentAtNode(content)`
in `onRemove` handler.

**Parameters:**

Name | Type |
------ | ------ |
`_options` | [IPopupOptions](interfaces/ipopupoptions.md) |

**Returns:** *[IPopupController](interfaces/ipopupcontroller.md)*

___

### `Const` addSidebar

▸ **addSidebar**(`_options`: [ISidebarOptions](interfaces/isidebaroptions.md)): *[ISidebarController](interfaces/isidebarcontroller.md)*

*Defined in [sidebar.ts:90](../../lara-typescript/src/plugin-api/sidebar.ts#L90)*

Ask LARA to add a new sidebar.

Sidebar will be added to the edge of the interactive page window. When multiple sidebars are added, there's no way
to specify their positions, so no assumptions should be made about current display - it might change.

Sidebar height cannot be specified. It's done on purpose to prevent issues on very short screens. It's based on the
provided content HTML element, but it's limited to following range:
- 100px is the min-height
- max-height is calculated dynamically and ensures that sidebar won't go off the screen
If the provided content is taller than the max-height of the sidebar, a sidebar content container will scroll.

It returns a simple controller that can be used to open or close sidebar.

**Parameters:**

Name | Type |
------ | ------ |
`_options` | [ISidebarOptions](interfaces/isidebaroptions.md) |

**Returns:** *[ISidebarController](interfaces/isidebarcontroller.md)*

___

### `Const` closeAllSidebars

▸ **closeAllSidebars**(): *void*

*Defined in [sidebar.ts:72](../../lara-typescript/src/plugin-api/sidebar.ts#L72)*

**Returns:** *void*

___

### `Const` decorateContent

▸ **decorateContent**(`words`: string[], `replace`: string, `wordClass`: string, `listeners`: [IEventListeners](globals.md#ieventlisteners)): *void*

*Defined in [decorate-content.ts:19](../../lara-typescript/src/plugin-api/decorate-content.ts#L19)*

Ask LARA to decorate authored content (text / html).

**Parameters:**

Name | Type | Description |
------ | ------ | ------ |
`words` | string[] | A list of case-insensitive words to be decorated. Can use limited regex. |
`replace` | string | The replacement string. Can include '$1' representing the matched word. |
`wordClass` | string | CSS class used in replacement string. Necessary only if `listeners` are provided too. |
`listeners` | [IEventListeners](globals.md#ieventlisteners) | One or more { type, listener } tuples. Note that events are added to `wordClass` described above. It's client code responsibility to use this class in the `replace` string.  |

**Returns:** *void*

___

### `Const` positionMultipleSidebars

▸ **positionMultipleSidebars**(): *void*

*Defined in [sidebar.ts:45](../../lara-typescript/src/plugin-api/sidebar.ts#L45)*

**Returns:** *void*

___

### `Const` registerPlugin

▸ **registerPlugin**(`options`: [IRegisterPluginOptions](interfaces/iregisterpluginoptions.md)): *boolean*

*Defined in [plugins.ts:12](../../lara-typescript/src/plugin-api/plugins.ts#L12)*

Register a new external script
```
registerPlugin({runtimeClass: DebuggerRuntime, authoringClass: DebuggerAuthoring})
```

**Parameters:**

Name | Type | Description |
------ | ------ | ------ |
`options` | [IRegisterPluginOptions](interfaces/iregisterpluginoptions.md) | The registration options |

**Returns:** *boolean*

`true` if plugin was registered correctly.

## Object literals

### `Const` ADD_POPUP_DEFAULT_OPTIONS

### ▪ **ADD_POPUP_DEFAULT_OPTIONS**: *object*

*Defined in [popup.ts:48](../../lara-typescript/src/plugin-api/popup.ts#L48)*

###  autoOpen

• **autoOpen**: *boolean* = true

*Defined in [popup.ts:50](../../lara-typescript/src/plugin-api/popup.ts#L50)*

###  backgroundColor

• **backgroundColor**: *string* = ""

*Defined in [popup.ts:65](../../lara-typescript/src/plugin-api/popup.ts#L65)*

###  closeButton

• **closeButton**: *boolean* = true

*Defined in [popup.ts:51](../../lara-typescript/src/plugin-api/popup.ts#L51)*

###  closeOnEscape

• **closeOnEscape**: *boolean* = false

*Defined in [popup.ts:52](../../lara-typescript/src/plugin-api/popup.ts#L52)*

###  dialogClass

• **dialogClass**: *string* = ""

*Defined in [popup.ts:64](../../lara-typescript/src/plugin-api/popup.ts#L64)*

Note that dialogClass is intentionally undocumented. Styling uses class makes us depend on the
current dialog implementation. It might be necessary for LARA themes, although plugins should not use it.

###  draggable

• **draggable**: *boolean* = true

*Defined in [popup.ts:55](../../lara-typescript/src/plugin-api/popup.ts#L55)*

###  height

• **height**: *string* = "auto"

*Defined in [popup.ts:58](../../lara-typescript/src/plugin-api/popup.ts#L58)*

###  modal

• **modal**: *boolean* = false

*Defined in [popup.ts:54](../../lara-typescript/src/plugin-api/popup.ts#L54)*

###  onBeforeClose

• **onBeforeClose**: *undefined* = undefined

*Defined in [popup.ts:69](../../lara-typescript/src/plugin-api/popup.ts#L69)*

###  onDragStart

• **onDragStart**: *undefined* = undefined

*Defined in [popup.ts:71](../../lara-typescript/src/plugin-api/popup.ts#L71)*

###  onDragStop

• **onDragStop**: *undefined* = undefined

*Defined in [popup.ts:72](../../lara-typescript/src/plugin-api/popup.ts#L72)*

###  onOpen

• **onOpen**: *undefined* = undefined

*Defined in [popup.ts:68](../../lara-typescript/src/plugin-api/popup.ts#L68)*

###  onResize

• **onResize**: *undefined* = undefined

*Defined in [popup.ts:70](../../lara-typescript/src/plugin-api/popup.ts#L70)*

###  padding

• **padding**: *number* = 10

*Defined in [popup.ts:59](../../lara-typescript/src/plugin-api/popup.ts#L59)*

###  removeOnClose

• **removeOnClose**: *boolean* = true

*Defined in [popup.ts:53](../../lara-typescript/src/plugin-api/popup.ts#L53)*

###  resizable

• **resizable**: *boolean* = true

*Defined in [popup.ts:56](../../lara-typescript/src/plugin-api/popup.ts#L56)*

###  title

• **title**: *string* = ""

*Defined in [popup.ts:49](../../lara-typescript/src/plugin-api/popup.ts#L49)*

###  titlebarColor

• **titlebarColor**: *string* = ""

*Defined in [popup.ts:66](../../lara-typescript/src/plugin-api/popup.ts#L66)*

###  width

• **width**: *number* = 300

*Defined in [popup.ts:57](../../lara-typescript/src/plugin-api/popup.ts#L57)*

▪ **position**: *object*

*Defined in [popup.ts:67](../../lara-typescript/src/plugin-api/popup.ts#L67)*

* **at**: *string* = "center"

* **my**: *string* = "center"

* **of**: *Window & globalThis* = window

___

### `Const` ADD_SIDEBAR_DEFAULT_OPTIONS

### ▪ **ADD_SIDEBAR_DEFAULT_OPTIONS**: *object*

*Defined in [sidebar.ts:30](../../lara-typescript/src/plugin-api/sidebar.ts#L30)*

###  handle

• **handle**: *string* = ""

*Defined in [sidebar.ts:33](../../lara-typescript/src/plugin-api/sidebar.ts#L33)*

###  handleColor

• **handleColor**: *string* = "#aaa"

*Defined in [sidebar.ts:34](../../lara-typescript/src/plugin-api/sidebar.ts#L34)*

###  icon

• **icon**: *string* = "default"

*Defined in [sidebar.ts:32](../../lara-typescript/src/plugin-api/sidebar.ts#L32)*

Arrow pointing left.

###  padding

• **padding**: *number* = 25

*Defined in [sidebar.ts:38](../../lara-typescript/src/plugin-api/sidebar.ts#L38)*

###  titleBar

• **titleBar**: *undefined* = undefined

*Defined in [sidebar.ts:35](../../lara-typescript/src/plugin-api/sidebar.ts#L35)*

###  titleBarColor

• **titleBarColor**: *string* = "#bbb"

*Defined in [sidebar.ts:36](../../lara-typescript/src/plugin-api/sidebar.ts#L36)*

###  width

• **width**: *number* = 500

*Defined in [sidebar.ts:37](../../lara-typescript/src/plugin-api/sidebar.ts#L37)*

___

### `Const` events

### ▪ **events**: *object*

*Defined in [events.ts:7](../../lara-typescript/src/plugin-api/events.ts#L7)*

Functions related to event observing provided by LARA.

###  offInteractiveAvailable

▸ **offInteractiveAvailable**(`handler`: [IInteractiveAvailableEventHandler](globals.md#iinteractiveavailableeventhandler)): *void*

*Defined in [events.ts:28](../../lara-typescript/src/plugin-api/events.ts#L28)*

Removes InteractiveAvailable event handler.

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [IInteractiveAvailableEventHandler](globals.md#iinteractiveavailableeventhandler) |

**Returns:** *void*

###  offLog

▸ **offLog**(`handler`: [ILogEventHandler](globals.md#ilogeventhandler)): *void*

*Defined in [events.ts:19](../../lara-typescript/src/plugin-api/events.ts#L19)*

Removes log event handler.

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [ILogEventHandler](globals.md#ilogeventhandler) |

**Returns:** *void*

###  onInteractiveAvailable

▸ **onInteractiveAvailable**(`handler`: [IInteractiveAvailableEventHandler](globals.md#iinteractiveavailableeventhandler)): *void*

*Defined in [events.ts:24](../../lara-typescript/src/plugin-api/events.ts#L24)*

Subscribes to InteractiveAvailable events. Gets called when any interactive changes its availablity state.
Currently uses when click to play mode is enabled and the click to play overlay is clicked.

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [IInteractiveAvailableEventHandler](globals.md#iinteractiveavailableeventhandler) |

**Returns:** *void*

###  onLog

▸ **onLog**(`handler`: [ILogEventHandler](globals.md#ilogeventhandler)): *void*

*Defined in [events.ts:15](../../lara-typescript/src/plugin-api/events.ts#L15)*

Subscribes to log events. Gets called when any event is logged to the CC Log Manager app.

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [ILogEventHandler](globals.md#ilogeventhandler) |

**Returns:** *void*
