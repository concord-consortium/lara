[LARA Plugin API](../README.md) > [IPluginRuntimeContext](../interfaces/ipluginruntimecontext.md)

# Interface: IPluginRuntimeContext

## Hierarchy

**IPluginRuntimeContext**

## Index

### Properties

* [authoredState](ipluginruntimecontext.md#authoredstate)
* [container](ipluginruntimecontext.md#container)
* [getClassInfo](ipluginruntimecontext.md#getclassinfo)
* [getFirebaseJwt](ipluginruntimecontext.md#getfirebasejwt)
* [learnerState](ipluginruntimecontext.md#learnerstate)
* [name](ipluginruntimecontext.md#name)
* [pluginId](ipluginruntimecontext.md#pluginid)
* [remoteEndpoint](ipluginruntimecontext.md#remoteendpoint)
* [runId](ipluginruntimecontext.md#runid)
* [saveLearnerPluginState](ipluginruntimecontext.md#savelearnerpluginstate)
* [url](ipluginruntimecontext.md#url)
* [userEmail](ipluginruntimecontext.md#useremail)
* [wrappedEmbeddable](ipluginruntimecontext.md#wrappedembeddable)

---

## Properties

<a id="authoredstate"></a>

###  authoredState

**● authoredState**: *`string` \| `null`*

*Defined in [api/types.ts:15](https://github.com/concord-consortium/lara/blob/d4ac322a/lara-plugin-api/src/api/types.ts#L15)*

The authored configuration for this instance (if available).

___
<a id="container"></a>

###  container

**● container**: *`HTMLElement`*

*Defined in [api/types.ts:19](https://github.com/concord-consortium/lara/blob/d4ac322a/lara-plugin-api/src/api/types.ts#L19)*

Reserved HTMLElement for the plugin output.

___
<a id="getclassinfo"></a>

###  getClassInfo

**● getClassInfo**: *`function`*

*Defined in [api/types.ts:38](https://github.com/concord-consortium/lara/blob/d4ac322a/lara-plugin-api/src/api/types.ts#L38)*

Function that returns class details (Promise) or null if class info is not available.

#### Type declaration
▸(): `Promise`<[IClassInfo](iclassinfo.md)> \| `null`

**Returns:** `Promise`<[IClassInfo](iclassinfo.md)> \| `null`

___
<a id="getfirebasejwt"></a>

###  getFirebaseJwt

**● getFirebaseJwt**: *`function`*

*Defined in [api/types.ts:40](https://github.com/concord-consortium/lara/blob/d4ac322a/lara-plugin-api/src/api/types.ts#L40)*

Function that returns JWT (Promise) for given app name.

#### Type declaration
▸(appName: *`string`*): `Promise`<[IJwtResponse](ijwtresponse.md)>

**Parameters:**

| Name | Type |
| ------ | ------ |
| appName | `string` |

**Returns:** `Promise`<[IJwtResponse](ijwtresponse.md)>

___
<a id="learnerstate"></a>

###  learnerState

**● learnerState**: *`string` \| `null`*

*Defined in [api/types.ts:17](https://github.com/concord-consortium/lara/blob/d4ac322a/lara-plugin-api/src/api/types.ts#L17)*

The saved learner data for this instance (if available).

___
<a id="name"></a>

###  name

**● name**: *`string`*

*Defined in [api/types.ts:9](https://github.com/concord-consortium/lara/blob/d4ac322a/lara-plugin-api/src/api/types.ts#L9)*

Name of the plugin

___
<a id="pluginid"></a>

###  pluginId

**● pluginId**: *`number`*

*Defined in [api/types.ts:13](https://github.com/concord-consortium/lara/blob/d4ac322a/lara-plugin-api/src/api/types.ts#L13)*

Plugin instance ID.

___
<a id="remoteendpoint"></a>

###  remoteEndpoint

**● remoteEndpoint**: *`string` \| `null`*

*Defined in [api/types.ts:23](https://github.com/concord-consortium/lara/blob/d4ac322a/lara-plugin-api/src/api/types.ts#L23)*

The portal remote endpoint (if available).

___
<a id="runid"></a>

###  runId

**● runId**: *`number`*

*Defined in [api/types.ts:21](https://github.com/concord-consortium/lara/blob/d4ac322a/lara-plugin-api/src/api/types.ts#L21)*

The run ID for the current LARA run.

___
<a id="savelearnerpluginstate"></a>

###  saveLearnerPluginState

**● saveLearnerPluginState**: *`function`*

*Defined in [api/types.ts:36](https://github.com/concord-consortium/lara/blob/d4ac322a/lara-plugin-api/src/api/types.ts#L36)*

Function that saves the users state for the plugin. Note that plugins can have different scopes, e.g. activity or a single page. If the plugin instance is added to the activity, its state will be shared across all the pages. If multiple plugin instances are added to various pages, their state will be different on every page.

```
context.saveLearnerPluginState('{"one": 1}').then((data) => console.log(data))
```

*__param__*: A string representing serialized plugin state; if it's JSON, remember to stringify it first.

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

*Defined in [api/types.ts:11](https://github.com/concord-consortium/lara/blob/d4ac322a/lara-plugin-api/src/api/types.ts#L11)*

Url from which the plugin was loaded.

___
<a id="useremail"></a>

###  userEmail

**● userEmail**: *`string` \| `null`*

*Defined in [api/types.ts:25](https://github.com/concord-consortium/lara/blob/d4ac322a/lara-plugin-api/src/api/types.ts#L25)*

The current user email address (if available).

___
<a id="wrappedembeddable"></a>

###  wrappedEmbeddable

**● wrappedEmbeddable**: *[IEmbeddableRuntimeContext](iembeddableruntimecontext.md) \| `null`*

*Defined in [api/types.ts:42](https://github.com/concord-consortium/lara/blob/d4ac322a/lara-plugin-api/src/api/types.ts#L42)*

Wrapped embeddable runtime context if plugin is wrapping some embeddable.

___

