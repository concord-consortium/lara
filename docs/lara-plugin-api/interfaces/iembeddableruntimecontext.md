[LARA Plugin API](../README.md) > [IEmbeddableRuntimeContext](../interfaces/iembeddableruntimecontext.md)

# Interface: IEmbeddableRuntimeContext

## Hierarchy

**IEmbeddableRuntimeContext**

## Index

### Properties

* [clickToPlayId](iembeddableruntimecontext.md#clicktoplayid)
* [container](iembeddableruntimecontext.md#container)
* [getInteractiveState](iembeddableruntimecontext.md#getinteractivestate)
* [getReportingUrl](iembeddableruntimecontext.md#getreportingurl)
* [laraJson](iembeddableruntimecontext.md#larajson)

---

## Properties

<a id="clicktoplayid"></a>

###  clickToPlayId

**● clickToPlayId**: *`string` \| `null`*

*Defined in [types.ts:84](https://github.com/concord-consortium/lara/blob/c6470a88/lara-typescript/src/plugin-api/types.ts#L84)*

DOM id of click to play overlay if enabled.

*__deprecated__*: This property will be removed soon and replaced with a better mechanism that lets the plugin monitor interactive status, including click to play state.

___
<a id="container"></a>

###  container

**● container**: *`HTMLElement`*

*Defined in [types.ts:47](https://github.com/concord-consortium/lara/blob/c6470a88/lara-typescript/src/plugin-api/types.ts#L47)*

Embeddable container.

___
<a id="getinteractivestate"></a>

###  getInteractiveState

**● getInteractiveState**: *`function`*

*Defined in [types.ts:68](https://github.com/concord-consortium/lara/blob/c6470a88/lara-typescript/src/plugin-api/types.ts#L68)*

Function that returns interactive state (Promise) or null if embeddable isn't interactive.

#### Type declaration
▸(): `Promise`<[IInteractiveState](iinteractivestate.md)> \| `null`

**Returns:** `Promise`<[IInteractiveState](iinteractivestate.md)> \| `null`

___
<a id="getreportingurl"></a>

###  getReportingUrl

**● getReportingUrl**: *`function`*

*Defined in [types.ts:78](https://github.com/concord-consortium/lara/blob/c6470a88/lara-typescript/src/plugin-api/types.ts#L78)*

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
<a id="larajson"></a>

###  laraJson

**● laraJson**: *`any`*

*Defined in [types.ts:66](https://github.com/concord-consortium/lara/blob/c6470a88/lara-typescript/src/plugin-api/types.ts#L66)*

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

