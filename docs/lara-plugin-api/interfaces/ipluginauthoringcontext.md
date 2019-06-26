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

<<<<<<< HEAD
*Defined in [types.ts:116](../../../lara-typescript/src/plugin-api/types.ts#L116)*
=======
*Defined in [types.ts:123](../../../lara-typescript/src/plugin-api/types.ts#L123)*
>>>>>>> Added previewMode flag to plugin runtime context

The authored configuration for this instance (if available).

___
<a id="componentlabel"></a>

###  componentLabel

**● componentLabel**: *`string`*

<<<<<<< HEAD
*Defined in [types.ts:120](../../../lara-typescript/src/plugin-api/types.ts#L120)*
=======
*Defined in [types.ts:127](../../../lara-typescript/src/plugin-api/types.ts#L127)*
>>>>>>> Added previewMode flag to plugin runtime context

The label of the plugin component.

___
<a id="container"></a>

###  container

**● container**: *`HTMLElement`*

<<<<<<< HEAD
*Defined in [types.ts:118](../../../lara-typescript/src/plugin-api/types.ts#L118)*
=======
*Defined in [types.ts:125](../../../lara-typescript/src/plugin-api/types.ts#L125)*
>>>>>>> Added previewMode flag to plugin runtime context

Reserved HTMLElement for the plugin output.

___
<a id="name"></a>

###  name

**● name**: *`string`*

<<<<<<< HEAD
*Defined in [types.ts:110](../../../lara-typescript/src/plugin-api/types.ts#L110)*
=======
*Defined in [types.ts:117](../../../lara-typescript/src/plugin-api/types.ts#L117)*
>>>>>>> Added previewMode flag to plugin runtime context

Name of the plugin

___
<a id="pluginid"></a>

###  pluginId

**● pluginId**: *`number`*

<<<<<<< HEAD
*Defined in [types.ts:114](../../../lara-typescript/src/plugin-api/types.ts#L114)*
=======
*Defined in [types.ts:121](../../../lara-typescript/src/plugin-api/types.ts#L121)*
>>>>>>> Added previewMode flag to plugin runtime context

Plugin instance ID.

___
<a id="saveauthoredpluginstate"></a>

###  saveAuthoredPluginState

**● saveAuthoredPluginState**: *`function`*

<<<<<<< HEAD
*Defined in [types.ts:128](../../../lara-typescript/src/plugin-api/types.ts#L128)*
=======
*Defined in [types.ts:135](../../../lara-typescript/src/plugin-api/types.ts#L135)*
>>>>>>> Added previewMode flag to plugin runtime context

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

<<<<<<< HEAD
*Defined in [types.ts:112](../../../lara-typescript/src/plugin-api/types.ts#L112)*
=======
*Defined in [types.ts:119](../../../lara-typescript/src/plugin-api/types.ts#L119)*
>>>>>>> Added previewMode flag to plugin runtime context

Url from which the plugin was loaded.

___

