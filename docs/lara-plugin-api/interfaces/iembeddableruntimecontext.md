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

*Defined in [types.ts:68](../../../lara-typescript/src/plugin-api/types.ts#L68)*

___
<a id="getinteractivestate"></a>

###  getInteractiveState

**● getInteractiveState**: *`function`*

*Defined in [types.ts:89](../../../lara-typescript/src/plugin-api/types.ts#L89)*

#### Type declaration
▸(): `Promise`<[IInteractiveState](iinteractivestate.md)> \| `null`

**Returns:** `Promise`<[IInteractiveState](iinteractivestate.md)> \| `null`

___
<a id="getreportingurl"></a>

###  getReportingUrl

**● getReportingUrl**: *`function`*

*Defined in [types.ts:99](../../../lara-typescript/src/plugin-api/types.ts#L99)*

#### Type declaration
▸(interactiveStatePromise: *`Promise`<[IInteractiveState](iinteractivestate.md)>*): `Promise`<`string` \| `null`> \| `null`

**Parameters:**

| Name | Type |
| ------ | ------ |
| `Optional` interactiveStatePromise | `Promise`<[IInteractiveState](iinteractivestate.md)> |

**Returns:** `Promise`<`string` \| `null`> \| `null`

___
<a id="interactiveavailable"></a>

###  interactiveAvailable

**● interactiveAvailable**: *`boolean`*

*Defined in [types.ts:109](../../../lara-typescript/src/plugin-api/types.ts#L109)*

___
<a id="larajson"></a>

###  laraJson

**● laraJson**: *`any`*

*Defined in [types.ts:87](../../../lara-typescript/src/plugin-api/types.ts#L87)*

___
<a id="oninteractiveavailable"></a>

###  onInteractiveAvailable

**● onInteractiveAvailable**: *`function`*

*Defined in [types.ts:107](../../../lara-typescript/src/plugin-api/types.ts#L107)*

#### Type declaration
▸(handler: *[IInteractiveAvailableEventHandler](../#iinteractiveavailableeventhandler)*): `void`

**Parameters:**

| Name | Type |
| ------ | ------ |
| handler | [IInteractiveAvailableEventHandler](../#iinteractiveavailableeventhandler) |

**Returns:** `void`

___

