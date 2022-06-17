[@concord-consortium/lara-plugin-api](../README.md) › [Globals](../globals.md) › [IPluginAuthoringContext](ipluginauthoringcontext.md)

# Interface: IPluginAuthoringContext

## Hierarchy

* **IPluginAuthoringContext**

## Index

### Properties

* [authoredState](ipluginauthoringcontext.md#authoredstate)
* [closeAuthoredPluginForm](ipluginauthoringcontext.md#optional-closeauthoredpluginform)
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

The authored configuration for this instance (if available).

___

### `Optional` closeAuthoredPluginForm

• **closeAuthoredPluginForm**? : *undefined | function*

Function that closes a plugin authoring form

___

###  componentLabel

• **componentLabel**: *string*

The label of the plugin component.

___

###  container

• **container**: *HTMLElement*

Reserved HTMLElement for the plugin output.

___

###  getFirebaseJwt

• **getFirebaseJwt**: *function*

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

Name of the plugin

___

###  pluginId

• **pluginId**: *number*

Plugin instance ID.

___

###  saveAuthoredPluginState

• **saveAuthoredPluginState**: *function*

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

Url from which the plugin was loaded.

___

###  wrappedEmbeddable

• **wrappedEmbeddable**: *[IEmbeddableRuntimeContext](iembeddableruntimecontext.md) | null*

Wrapped embeddable runtime context if plugin is wrapping some embeddable and the plugin has the
guiPreview option set to true within its manifest.
