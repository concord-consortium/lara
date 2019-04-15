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

*Defined in [api/types.ts:63](https://github.com/concord-consortium/lara/blob/22b6b3d8/lara-plugin-api/src/api/types.ts#L63)*

DOM id of click to play overlay if enabled.

___
<a id="container"></a>

###  container

**● container**: *`HTMLElement`*

*Defined in [api/types.ts:36](https://github.com/concord-consortium/lara/blob/22b6b3d8/lara-plugin-api/src/api/types.ts#L36)*

Embeddable container.

___
<a id="getinteractivestate"></a>

###  getInteractiveState

**● getInteractiveState**: *`function`*

*Defined in [api/types.ts:57](https://github.com/concord-consortium/lara/blob/22b6b3d8/lara-plugin-api/src/api/types.ts#L57)*

Function that returns interactive state (Promise) or null if embeddable isn't interactive.

#### Type declaration
▸(): `Promise`<[IInteractiveState](iinteractivestate.md)> \| `null`

**Returns:** `Promise`<[IInteractiveState](iinteractivestate.md)> \| `null`

___
<a id="getreportingurl"></a>

###  getReportingUrl

**● getReportingUrl**: *`function`*

*Defined in [api/types.ts:61](https://github.com/concord-consortium/lara/blob/22b6b3d8/lara-plugin-api/src/api/types.ts#L61)*

Function that returns reporting URL (Promise) or null if it's not an interactive or reporting URL is not defined.

#### Type declaration
▸(): `Promise`<`string` \| `null`> \| `null`

**Returns:** `Promise`<`string` \| `null`> \| `null`

___
<a id="larajson"></a>

###  laraJson

**● laraJson**: *`any`*

*Defined in [api/types.ts:55](https://github.com/concord-consortium/lara/blob/22b6b3d8/lara-plugin-api/src/api/types.ts#L55)*

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

