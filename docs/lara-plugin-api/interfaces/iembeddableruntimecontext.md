[LARA Plugin API](../README.md) > [IEmbeddableRuntimeContext](../interfaces/iembeddableruntimecontext.md)

# Interface: IEmbeddableRuntimeContext

## Hierarchy

**IEmbeddableRuntimeContext**

## Index

### Properties

* [container](iembeddableruntimecontext.md#container)
* [getInteractiveState](iembeddableruntimecontext.md#getinteractivestate)
* [getReportingUrl](iembeddableruntimecontext.md#getreportingurl)
* [interactiveAvailable](iembeddableruntimecontext.md#interactiveavailable)
* [laraJson](iembeddableruntimecontext.md#larajson)
* [onInteractiveAvailable](iembeddableruntimecontext.md#oninteractiveavailable)

---

## Properties

<a id="container"></a>

###  container

**● container**: *`HTMLElement`*

*Defined in [types.ts:61](https://github.com/concord-consortium/lara/blob/75f8b467/lara-typescript/src/plugin-api/types.ts#L61)*

Embeddable container.

___
<a id="getinteractivestate"></a>

###  getInteractiveState

**● getInteractiveState**: *`function`*

*Defined in [types.ts:82](https://github.com/concord-consortium/lara/blob/75f8b467/lara-typescript/src/plugin-api/types.ts#L82)*

Function that returns interactive state (Promise) or null if embeddable isn't interactive.

#### Type declaration
▸(): `Promise`<[IInteractiveState](iinteractivestate.md)> \| `null`

**Returns:** `Promise`<[IInteractiveState](iinteractivestate.md)> \| `null`

___
<a id="getreportingurl"></a>

###  getReportingUrl

**● getReportingUrl**: *`function`*

*Defined in [types.ts:92](https://github.com/concord-consortium/lara/blob/75f8b467/lara-typescript/src/plugin-api/types.ts#L92)*

Function that returns reporting URL (Promise) or null if it's not an interactive or reporting URL is not defined. Note that reporting URL is defined in the interactive state (that can be obtained via #getInteractiveState method). If your code needs both interactive state and reporting URL, you can pass interactiveStatePromise as an argument to this method to limit number of network requests.

*__param__*: An optional promise returned from #getInteractiveState method. If it's provided this function will use it to get interacive state and won't issue any additional network requests.

#### Type declaration
▸(interactiveStatePromise?: *`Promise`<[IInteractiveState](iinteractivestate.md)>*): `Promise`<`string` \| `null`> \| `null`

**Parameters:**

| Name | Type |
| ------ | ------ |
| `Optional` interactiveStatePromise | `Promise`<[IInteractiveState](iinteractivestate.md)> |

**Returns:** `Promise`<`string` \| `null`> \| `null`

___
<a id="interactiveavailable"></a>

###  interactiveAvailable

**● interactiveAvailable**: *`boolean`*

*Defined in [types.ts:102](https://github.com/concord-consortium/lara/blob/75f8b467/lara-typescript/src/plugin-api/types.ts#L102)*

True if the interactive is immediately available

___
<a id="larajson"></a>

###  laraJson

**● laraJson**: *`any`*

*Defined in [types.ts:80](https://github.com/concord-consortium/lara/blob/75f8b467/lara-typescript/src/plugin-api/types.ts#L80)*

Serialized form of the embeddable. Defined by LARA export code, so it's format cannot be specified here. Example (interactive):

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
<a id="oninteractiveavailable"></a>

###  onInteractiveAvailable

**● onInteractiveAvailable**: *`function`*

*Defined in [types.ts:100](https://github.com/concord-consortium/lara/blob/75f8b467/lara-typescript/src/plugin-api/types.ts#L100)*

Function that subscribes provided handler to event that gets called when the interactive's availablity changes. Normally an interactive starts as available unless click to play is enabled. When click to play is enabled the interactive starts as not available and this handler is called when the click to play overlay is hidden.

*__param__*: Event handler function.

#### Type declaration
▸(handler: *[IInteractiveAvailableEventHandler](../#iinteractiveavailableeventhandler)*): `void`

**Parameters:**

| Name | Type |
| ------ | ------ |
| handler | [IInteractiveAvailableEventHandler](../#iinteractiveavailableeventhandler) |

**Returns:** `void`

___

