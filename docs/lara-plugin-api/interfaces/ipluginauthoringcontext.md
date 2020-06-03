[@concord-consortium/lara-plugin-api - v3.1.2](../README.md) › [Globals](../globals.md) › [IPluginAuthoringContext](ipluginauthoringcontext.md)

# Interface: IPluginAuthoringContext

## Hierarchy

* **IPluginAuthoringContext**

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

## Properties

###  authoredState

• **authoredState**: *string | null*

*Defined in [types.ts:120](../../../lara-typescript/src/plugin-api/types.ts#L120)*

The authored configuration for this instance (if available).

___

###  componentLabel

• **componentLabel**: *string*

*Defined in [types.ts:124](../../../lara-typescript/src/plugin-api/types.ts#L124)*

The label of the plugin component.

___

###  container

• **container**: *HTMLElement*

*Defined in [types.ts:122](../../../lara-typescript/src/plugin-api/types.ts#L122)*

Reserved HTMLElement for the plugin output.

___

###  getFirebaseJwt

• **getFirebaseJwt**: *function*

*Defined in [types.ts:138](../../../lara-typescript/src/plugin-api/types.ts#L138)*

Function that returns JWT (Promise) for given app name.

#### Type declaration:

▸ (`appName`: string): *Promise‹[IJwtResponse](ijwtresponse.md)›*

**Parameters:**

Name | Type |
------ | ------ |
`appName` | string |

___

###  name

• **name**: *string*

*Defined in [types.ts:114](../../../lara-typescript/src/plugin-api/types.ts#L114)*

Name of the plugin

___

###  pluginId

• **pluginId**: *number*

*Defined in [types.ts:118](../../../lara-typescript/src/plugin-api/types.ts#L118)*

Plugin instance ID.

___

###  saveAuthoredPluginState

• **saveAuthoredPluginState**: *function*

*Defined in [types.ts:132](../../../lara-typescript/src/plugin-api/types.ts#L132)*

Function that saves the authoring state for the plugin.
```
context.saveAuthoredPluginState('{"one": 1}').then((data) => console.log(data))
```

**`param`** A string representing serialized author data; if it's JSON, remember to stringify it first.

#### Type declaration:

▸ (`state`: string): *Promise‹string›*

**Parameters:**

Name | Type |
------ | ------ |
`state` | string |

___

###  url

• **url**: *string*

*Defined in [types.ts:116](../../../lara-typescript/src/plugin-api/types.ts#L116)*

Url from which the plugin was loaded.

___

###  wrappedEmbeddable

• **wrappedEmbeddable**: *[IEmbeddableRuntimeContext](iembeddableruntimecontext.md) | null*

*Defined in [types.ts:136](../../../lara-typescript/src/plugin-api/types.ts#L136)*

Wrapped embeddable runtime context if plugin is wrapping some embeddable and the plugin has the
guiPreview option set to true within its manifest.
