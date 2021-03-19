[@concord-consortium/lara-plugin-api](README.md) › [Globals](globals.md)

# @concord-consortium/lara-plugin-api

## Index

### Interfaces

* [IClassInfo](interfaces/iclassinfo.md)
* [IEmbeddableRuntimeContext](interfaces/iembeddableruntimecontext.md)
* [IEventListener](interfaces/ieventlistener.md)
* [IInteractiveAvailableEvent](interfaces/iinteractiveavailableevent.md)
* [IInteractiveState](interfaces/iinteractivestate.md)
* [IInteractiveSupportedFeaturesEvent](interfaces/iinteractivesupportedfeaturesevent.md)
* [IJwtClaims](interfaces/ijwtclaims.md)
* [IJwtResponse](interfaces/ijwtresponse.md)
* [ILogData](interfaces/ilogdata.md)
* [IOffering](interfaces/ioffering.md)
* [IPlugin](interfaces/iplugin.md)
* [IPluginAuthoringContext](interfaces/ipluginauthoringcontext.md)
* [IPluginRuntimeContext](interfaces/ipluginruntimecontext.md)
* [IPluginSyncEvent](interfaces/ipluginsyncevent.md)
* [IPluginSyncUpdate](interfaces/ipluginsyncupdate.md)
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
* [IInteractiveSupportedFeaturesEventHandler](globals.md#iinteractivesupportedfeatureseventhandler)
* [ILogEventHandler](globals.md#ilogeventhandler)
* [IPluginSyncRequestEventHandler](globals.md#ipluginsyncrequesteventhandler)
* [PluginSyncUpdateCallback](globals.md#pluginsyncupdatecallback)

### Functions

* [addPopup](globals.md#const-addpopup)
* [addSidebar](globals.md#const-addsidebar)
* [decorateContent](globals.md#const-decoratecontent)
* [offInteractiveAvailable](globals.md#const-offinteractiveavailable)
* [offInteractiveSupportedFeatures](globals.md#const-offinteractivesupportedfeatures)
* [offLog](globals.md#const-offlog)
* [onInteractiveAvailable](globals.md#const-oninteractiveavailable)
* [onInteractiveSupportedFeatures](globals.md#const-oninteractivesupportedfeatures)
* [onLog](globals.md#const-onlog)
* [registerPlugin](globals.md#const-registerplugin)

### Object literals

* [ADD_POPUP_DEFAULT_OPTIONS](globals.md#const-add_popup_default_options)
* [ADD_SIDEBAR_DEFAULT_OPTIONS](globals.md#const-add_sidebar_default_options)
* [events](globals.md#const-events)

## Type aliases

###  IEventListeners

Ƭ **IEventListeners**: *[IEventListener](interfaces/ieventlistener.md) | [IEventListener](interfaces/ieventlistener.md)[]*

___

###  IInteractiveAvailableEventHandler

Ƭ **IInteractiveAvailableEventHandler**: *function*

InteractiveAvailable event handler.

#### Type declaration:

▸ (`event`: [IInteractiveAvailableEvent](interfaces/iinteractiveavailableevent.md)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`event` | [IInteractiveAvailableEvent](interfaces/iinteractiveavailableevent.md) |

___

###  IInteractiveSupportedFeaturesEventHandler

Ƭ **IInteractiveSupportedFeaturesEventHandler**: *function*

SupportedFeatures event handler.

#### Type declaration:

▸ (`event`: [IInteractiveSupportedFeaturesEvent](interfaces/iinteractivesupportedfeaturesevent.md)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`event` | [IInteractiveSupportedFeaturesEvent](interfaces/iinteractivesupportedfeaturesevent.md) |

___

###  ILogEventHandler

Ƭ **ILogEventHandler**: *function*

Log event handler.

**`param`** Data logged by the code.

#### Type declaration:

▸ (`event`: [ILogData](interfaces/ilogdata.md)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`event` | [ILogData](interfaces/ilogdata.md) |

___

###  IPluginSyncRequestEventHandler

Ƭ **IPluginSyncRequestEventHandler**: *function*

PluginSync event handler.

#### Type declaration:

▸ (`event`: [IPluginSyncEvent](interfaces/ipluginsyncevent.md)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`event` | [IPluginSyncEvent](interfaces/ipluginsyncevent.md) |

___

###  PluginSyncUpdateCallback

Ƭ **PluginSyncUpdateCallback**: *function*

#### Type declaration:

▸ (`update`: [IPluginSyncUpdate](interfaces/ipluginsyncupdate.md)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`update` | [IPluginSyncUpdate](interfaces/ipluginsyncupdate.md) |

## Functions

### `Const` addPopup

▸ **addPopup**(`_options`: [IPopupOptions](interfaces/ipopupoptions.md)): *[IPopupController](interfaces/ipopupcontroller.md)*

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

### `Const` decorateContent

▸ **decorateContent**(`words`: string[], `replace`: string, `wordClass`: string, `listeners`: [IEventListeners](globals.md#ieventlisteners)): *void*

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

### `Const` offInteractiveAvailable

▸ **offInteractiveAvailable**(`handler`: [IInteractiveAvailableEventHandler](globals.md#iinteractiveavailableeventhandler)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [IInteractiveAvailableEventHandler](globals.md#iinteractiveavailableeventhandler) |

**Returns:** *void*

___

### `Const` offInteractiveSupportedFeatures

▸ **offInteractiveSupportedFeatures**(`handler`: [IInteractiveSupportedFeaturesEventHandler](globals.md#iinteractivesupportedfeatureseventhandler)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [IInteractiveSupportedFeaturesEventHandler](globals.md#iinteractivesupportedfeatureseventhandler) |

**Returns:** *void*

___

### `Const` offLog

▸ **offLog**(`handler`: [ILogEventHandler](globals.md#ilogeventhandler)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [ILogEventHandler](globals.md#ilogeventhandler) |

**Returns:** *void*

___

### `Const` onInteractiveAvailable

▸ **onInteractiveAvailable**(`handler`: [IInteractiveAvailableEventHandler](globals.md#iinteractiveavailableeventhandler)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [IInteractiveAvailableEventHandler](globals.md#iinteractiveavailableeventhandler) |

**Returns:** *void*

___

### `Const` onInteractiveSupportedFeatures

▸ **onInteractiveSupportedFeatures**(`handler`: [IInteractiveSupportedFeaturesEventHandler](globals.md#iinteractivesupportedfeatureseventhandler)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [IInteractiveSupportedFeaturesEventHandler](globals.md#iinteractivesupportedfeatureseventhandler) |

**Returns:** *void*

___

### `Const` onLog

▸ **onLog**(`handler`: [ILogEventHandler](globals.md#ilogeventhandler)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [ILogEventHandler](globals.md#ilogeventhandler) |

**Returns:** *void*

___

### `Const` registerPlugin

▸ **registerPlugin**(`options`: [IRegisterPluginOptions](interfaces/iregisterpluginoptions.md)): *boolean*

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

###  autoOpen

• **autoOpen**: *boolean* = true

###  backgroundColor

• **backgroundColor**: *string* = ""

###  closeButton

• **closeButton**: *boolean* = true

###  closeOnEscape

• **closeOnEscape**: *boolean* = false

###  dialogClass

• **dialogClass**: *string* = ""

Note that dialogClass is intentionally undocumented. Styling uses class makes us depend on the
current dialog implementation. It might be necessary for LARA themes, although plugins should not use it.

###  draggable

• **draggable**: *boolean* = true

###  height

• **height**: *string* = "auto"

###  modal

• **modal**: *boolean* = false

###  onBeforeClose

• **onBeforeClose**: *undefined* = undefined

###  onDragStart

• **onDragStart**: *undefined* = undefined

###  onDragStop

• **onDragStop**: *undefined* = undefined

###  onOpen

• **onOpen**: *undefined* = undefined

###  onResize

• **onResize**: *undefined* = undefined

###  padding

• **padding**: *number* = 10

###  removeOnClose

• **removeOnClose**: *boolean* = true

###  resizable

• **resizable**: *boolean* = true

###  title

• **title**: *string* = ""

###  titlebarColor

• **titlebarColor**: *string* = ""

###  width

• **width**: *number* = 300

▪ **position**: *object*

* **at**: *string* = "center"

* **my**: *string* = "center"

* **of**: *Window & globalThis* = window

___

### `Const` ADD_SIDEBAR_DEFAULT_OPTIONS

### ▪ **ADD_SIDEBAR_DEFAULT_OPTIONS**: *object*

###  handle

• **handle**: *string* = ""

###  handleColor

• **handleColor**: *string* = "#aaa"

###  icon

• **icon**: *string* = "default"

Arrow pointing left.

###  padding

• **padding**: *number* = 25

###  titleBar

• **titleBar**: *undefined* = undefined

###  titleBarColor

• **titleBarColor**: *string* = "#bbb"

###  width

• **width**: *number* = 500

___

### `Const` events

### ▪ **events**: *object*

Functions related to event observing provided by LARA.

###  offInteractiveAvailable

▸ **offInteractiveAvailable**(`handler`: [IInteractiveAvailableEventHandler](globals.md#iinteractiveavailableeventhandler)): *void*

Removes InteractiveAvailable event handler.

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [IInteractiveAvailableEventHandler](globals.md#iinteractiveavailableeventhandler) |

**Returns:** *void*

###  offInteractiveSupportedFeatures

▸ **offInteractiveSupportedFeatures**(`handler`: [IInteractiveSupportedFeaturesEventHandler](globals.md#iinteractivesupportedfeatureseventhandler)): *void*

Removes InteractiveSupportedFeatures event handler.

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [IInteractiveSupportedFeaturesEventHandler](globals.md#iinteractivesupportedfeatureseventhandler) |

**Returns:** *void*

###  offLog

▸ **offLog**(`handler`: [ILogEventHandler](globals.md#ilogeventhandler)): *void*

Removes log event handler.

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [ILogEventHandler](globals.md#ilogeventhandler) |

**Returns:** *void*

###  offPluginSyncRequest

▸ **offPluginSyncRequest**(`handler`: [IPluginSyncRequestEventHandler](globals.md#ipluginsyncrequesteventhandler)): *void*

Removes PluginSyncRequest event handler.

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [IPluginSyncRequestEventHandler](globals.md#ipluginsyncrequesteventhandler) |

**Returns:** *void*

###  onInteractiveAvailable

▸ **onInteractiveAvailable**(`handler`: [IInteractiveAvailableEventHandler](globals.md#iinteractiveavailableeventhandler)): *void*

Subscribes to InteractiveAvailable events. Gets called when any interactive changes its availability state.
Currently uses when click to play mode is enabled and the click to play overlay is clicked.

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [IInteractiveAvailableEventHandler](globals.md#iinteractiveavailableeventhandler) |

**Returns:** *void*

###  onInteractiveSupportedFeatures

▸ **onInteractiveSupportedFeatures**(`handler`: [IInteractiveSupportedFeaturesEventHandler](globals.md#iinteractivesupportedfeatureseventhandler)): *void*

Subscribes to InteractiveSupportedFeatures events. Gets called when any interactive calls setSupportedFeatures().

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [IInteractiveSupportedFeaturesEventHandler](globals.md#iinteractivesupportedfeatureseventhandler) |

**Returns:** *void*

###  onLog

▸ **onLog**(`handler`: [ILogEventHandler](globals.md#ilogeventhandler)): *void*

Subscribes to log events. Gets called when any event is logged to the CC Log Manager app.

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [ILogEventHandler](globals.md#ilogeventhandler) |

**Returns:** *void*

###  onPluginSyncRequest

▸ **onPluginSyncRequest**(`handler`: [IPluginSyncRequestEventHandler](globals.md#ipluginsyncrequesteventhandler)): *void*

Subscribes to PluginSyncRequest events. Gets called when the plugins are commanded to sync their offline data.

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [IPluginSyncRequestEventHandler](globals.md#ipluginsyncrequesteventhandler) |

**Returns:** *void*
