[LARA Plugin API](../README.md) > [IPluginAuthoringContext](../interfaces/ipluginauthoringcontext.md)

# Interface: IPluginAuthoringContext

## Hierarchy

**IPluginAuthoringContext**

## Index

### Properties

* [authoredState](ipluginauthoringcontext.md#authoredstate)
* [componentLabel](ipluginauthoringcontext.md#componentlabel)
* [container](ipluginauthoringcontext.md#container)
* [getFirebaseJwt](ipluginauthoringcontext.md#getfirebasejwt)
* [name](ipluginauthoringcontext.md#name)
* [pluginId](ipluginauthoringcontext.md#pluginid)
* [saveAuthoredPluginState](ipluginauthoringcontext.md#saveauthoredpluginstate)
* [url](ipluginauthoringcontext.md#url)
* [wrappedEmbeddable](ipluginauthoringcontext.md#wrappedembeddable)

---

## Properties

<a id="authoredstate"></a>

###  authoredState

**● authoredState**: *`string` \| `null`*

*Defined in [types.ts:120](../../../lara-typescript/src/plugin-api/types.ts#L120)*

___
<a id="componentlabel"></a>

###  componentLabel

**● componentLabel**: *`string`*

*Defined in [types.ts:124](../../../lara-typescript/src/plugin-api/types.ts#L124)*

___
<a id="container"></a>

###  container

**● container**: *`HTMLElement`*

*Defined in [types.ts:122](../../../lara-typescript/src/plugin-api/types.ts#L122)*

___
<a id="getfirebasejwt"></a>

###  getFirebaseJwt

**● getFirebaseJwt**: *`function`*

*Defined in [types.ts:138](../../../lara-typescript/src/plugin-api/types.ts#L138)*

#### Type declaration
▸(appName: *`string`*): `Promise`<[IJwtResponse](ijwtresponse.md)>

**Parameters:**

| Name | Type |
| ------ | ------ |
| appName | `string` |

**Returns:** `Promise`<[IJwtResponse](ijwtresponse.md)>

___
<a id="name"></a>

###  name

**● name**: *`string`*

*Defined in [types.ts:114](../../../lara-typescript/src/plugin-api/types.ts#L114)*

___
<a id="pluginid"></a>

###  pluginId

**● pluginId**: *`number`*

*Defined in [types.ts:118](../../../lara-typescript/src/plugin-api/types.ts#L118)*

___
<a id="saveauthoredpluginstate"></a>

###  saveAuthoredPluginState

**● saveAuthoredPluginState**: *`function`*

*Defined in [types.ts:132](../../../lara-typescript/src/plugin-api/types.ts#L132)*

#### Type declaration
▸(state: *`string`*): `Promise`<`string`>

**Parameters:**

| Name | Type |
| ------ | ------ |
| state | `string` |

**Returns:** `Promise`<`string`>

___
<a id="url"></a>

###  url

**● url**: *`string`*

*Defined in [types.ts:116](../../../lara-typescript/src/plugin-api/types.ts#L116)*

___
<a id="wrappedembeddable"></a>

###  wrappedEmbeddable

**● wrappedEmbeddable**: *[IEmbeddableRuntimeContext](iembeddableruntimecontext.md) \| `null`*

*Defined in [types.ts:136](../../../lara-typescript/src/plugin-api/types.ts#L136)*

___

