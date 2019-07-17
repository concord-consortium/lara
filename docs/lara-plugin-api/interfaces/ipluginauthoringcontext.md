[LARA Plugin API](../README.md) > [IPluginAuthoringContext](../interfaces/ipluginauthoringcontext.md)

# Interface: IPluginAuthoringContext

## Hierarchy

**IPluginAuthoringContext**

## Index

### Properties

* [authoredState](ipluginauthoringcontext.md#authoredstate)
* [componentLabel](ipluginauthoringcontext.md#componentlabel)
* [container](ipluginauthoringcontext.md#container)
* [name](ipluginauthoringcontext.md#name)
* [pluginId](ipluginauthoringcontext.md#pluginid)
* [saveAuthoredPluginState](ipluginauthoringcontext.md#saveauthoredpluginstate)
* [url](ipluginauthoringcontext.md#url)

---

## Properties

<a id="authoredstate"></a>

###  authoredState

**● authoredState**: *`string` \| `null`*

*Defined in [types.ts:116](../../../lara-typescript/src/plugin-api/types.ts#L116)*

The authored configuration for this instance (if available).

___
<a id="componentlabel"></a>

###  componentLabel

**● componentLabel**: *`string`*

*Defined in [types.ts:120](../../../lara-typescript/src/plugin-api/types.ts#L120)*

The label of the plugin component.

___
<a id="container"></a>

###  container

**● container**: *`HTMLElement`*

*Defined in [types.ts:118](../../../lara-typescript/src/plugin-api/types.ts#L118)*

Reserved HTMLElement for the plugin output.

___
<a id="name"></a>

###  name

**● name**: *`string`*

*Defined in [types.ts:110](../../../lara-typescript/src/plugin-api/types.ts#L110)*

Name of the plugin

___
<a id="pluginid"></a>

###  pluginId

**● pluginId**: *`number`*

*Defined in [types.ts:114](../../../lara-typescript/src/plugin-api/types.ts#L114)*

Plugin instance ID.

___
<a id="saveauthoredpluginstate"></a>

###  saveAuthoredPluginState

**● saveAuthoredPluginState**: *`function`*

*Defined in [types.ts:128](../../../lara-typescript/src/plugin-api/types.ts#L128)*

Function that saves the authoring state for the plugin.

```
context.saveAuthoredPluginState('{"one": 1}').then((data) => console.log(data))
```

*__param__*: A string representing serialized author data; if it's JSON, remember to stringify it first.

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

*Defined in [types.ts:112](../../../lara-typescript/src/plugin-api/types.ts#L112)*

Url from which the plugin was loaded.

___

