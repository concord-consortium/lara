[@concord-consortium/lara-plugin-api - v3.1.2](../README.md) › [Globals](../globals.md) › [IEmbeddableRuntimeContext](iembeddableruntimecontext.md)

# Interface: IEmbeddableRuntimeContext

## Hierarchy

* **IEmbeddableRuntimeContext**

## Index

### Properties

* [container](iembeddableruntimecontext.md#container)
* [getInteractiveState](iembeddableruntimecontext.md#getinteractivestate)
* [getReportingUrl](iembeddableruntimecontext.md#getreportingurl)
* [interactiveAvailable](iembeddableruntimecontext.md#interactiveavailable)
* [laraJson](iembeddableruntimecontext.md#larajson)
* [onInteractiveAvailable](iembeddableruntimecontext.md#oninteractiveavailable)
* [onInteractiveSupportedFeatures](iembeddableruntimecontext.md#oninteractivesupportedfeatures)
* [sendCustomMessage](iembeddableruntimecontext.md#sendcustommessage)

## Properties

###  container

• **container**: *HTMLElement*

Embeddable container.

___

###  getInteractiveState

• **getInteractiveState**: *function*

Function that returns interactive state (Promise) or null if embeddable isn't interactive.

#### Type declaration:

▸ (): *Promise‹[IInteractiveState](iinteractivestate.md)› | null*

___

###  getReportingUrl

• **getReportingUrl**: *function*

Function that returns reporting URL (Promise) or null if it's not an interactive or reporting URL is not defined.
Note that reporting URL is defined in the interactive state (that can be obtained via #getInteractiveState method).
If your code needs both interactive state and reporting URL, you can pass interactiveStatePromise as an argument
to this method to limit number of network requests.

**`param`** An optional promise returned from #getInteractiveState method. If it's provided
this function will use it to get interacive state and won't issue any additional network requests.

#### Type declaration:

▸ (`interactiveStatePromise?`: Promise‹[IInteractiveState](iinteractivestate.md)›): *Promise‹string | null› | null*

**Parameters:**

Name | Type |
------ | ------ |
`interactiveStatePromise?` | Promise‹[IInteractiveState](iinteractivestate.md)› |

___

###  interactiveAvailable

• **interactiveAvailable**: *boolean*

True if the interactive is immediately available

___

###  laraJson

• **laraJson**: *any*

Serialized form of the embeddable. Defined by LARA export code, so it's format cannot be specified here.
Example (interactive):
```
{
aspect_ratio_method: "DEFAULT",
authored_state: null,
click_to_play: false,
enable_learner_state: true,
name: "Test Interactive",
native_height: 435,
native_width: 576,
url: "http://concord-consortium.github.io/lara-interactive-api/iframe.html",
type: "MwInteractive",
ref_id: "86-MwInteractive"
}
```

___

###  onInteractiveAvailable

• **onInteractiveAvailable**: *function*

Function that subscribes provided handler to event that gets called when the interactive's availablity changes.
Normally an interactive starts as available unless click to play is enabled.  When click to play is enabled
the interactive starts as not available and this handler is called when the click to play overlay is hidden.

**`param`** Event handler function.

#### Type declaration:

▸ (`handler`: [IInteractiveAvailableEventHandler](../globals.md#iinteractiveavailableeventhandler)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [IInteractiveAvailableEventHandler](../globals.md#iinteractiveavailableeventhandler) |

___

###  onInteractiveSupportedFeatures

• **onInteractiveSupportedFeatures**: *function*

Function that subscribes provided handler to event that gets called when the interactive's supported features are
are available.

**`param`** Event handler function.

#### Type declaration:

▸ (`handler`: IInteractiveSupportedFeaturesEventHandler): *void*

**Parameters:**

Name | Type |
------ | ------ |
`handler` | IInteractiveSupportedFeaturesEventHandler |

___

###  sendCustomMessage

• **sendCustomMessage**: *function*

Function that sends a custom message to the embeddable.

**`param`** The message to be sent

#### Type declaration:

▸ (`message`: ICustomMessage): *void*

**Parameters:**

Name | Type |
------ | ------ |
`message` | ICustomMessage |
