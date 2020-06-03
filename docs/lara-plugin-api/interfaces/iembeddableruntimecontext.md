[LARA Plugin API](../README.md) › [Globals](../globals.md) › [IEmbeddableRuntimeContext](iembeddableruntimecontext.md)

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

## Properties

###  container

• **container**: *HTMLElement*

*Defined in [types.ts:68](../../../lara-typescript/src/plugin-api/types.ts#L68)*

Embeddable container.

___

###  getInteractiveState

• **getInteractiveState**: *function*

*Defined in [types.ts:89](../../../lara-typescript/src/plugin-api/types.ts#L89)*

Function that returns interactive state (Promise) or null if embeddable isn't interactive.

#### Type declaration:

▸ (): *Promise‹[IInteractiveState](iinteractivestate.md)› | null*

___

###  getReportingUrl

• **getReportingUrl**: *function*

*Defined in [types.ts:99](../../../lara-typescript/src/plugin-api/types.ts#L99)*

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

*Defined in [types.ts:109](../../../lara-typescript/src/plugin-api/types.ts#L109)*

True if the interactive is immediately available

___

###  laraJson

• **laraJson**: *any*

*Defined in [types.ts:87](../../../lara-typescript/src/plugin-api/types.ts#L87)*

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

*Defined in [types.ts:107](../../../lara-typescript/src/plugin-api/types.ts#L107)*

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
