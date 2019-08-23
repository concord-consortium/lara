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
* [log](ipluginruntimecontext.md#log)
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

*Defined in [types.ts:18](../../../lara-typescript/src/plugin-api/types.ts#L18)*

The authored configuration for this instance (if available).

___
<a id="container"></a>

###  container

**● container**: *`HTMLElement`*

*Defined in [types.ts:22](../../../lara-typescript/src/plugin-api/types.ts#L22)*

HTMLElement created by LARA for the plugin to use to render both its runtime and authoring output.

___
<a id="getclassinfo"></a>

###  getClassInfo

**● getClassInfo**: *`function`*

*Defined in [types.ts:41](../../../lara-typescript/src/plugin-api/types.ts#L41)*

Function that returns class details (Promise) or null if class info is not available.

#### Type declaration
▸(): `Promise`<[IClassInfo](iclassinfo.md)> \| `null`

**Returns:** `Promise`<[IClassInfo](iclassinfo.md)> \| `null`

___
<a id="getfirebasejwt"></a>

###  getFirebaseJwt

**● getFirebaseJwt**: *`function`*

*Defined in [types.ts:43](../../../lara-typescript/src/plugin-api/types.ts#L43)*

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

*Defined in [types.ts:20](../../../lara-typescript/src/plugin-api/types.ts#L20)*

The saved learner data for this instance (if available).

___
<a id="log"></a>

###  log

**● log**: *`function`*

*Defined in [types.ts:61](../../../lara-typescript/src/plugin-api/types.ts#L61)*

Logs event to the CC Log Server. Note that logging must be enabled for a given activity. Either by setting URL param logging=true or by enabling logging in Portal.

```
context.log("testEvent");
context.log({event: "testEvent", event_value: 123});
context.log({event: "testEvent", someExtraParam: 123});
context.log({event: "testEvent", parameters: { paramInParamsHash: 123 }});
```

This augments the logged data with plugin\_id, and optionally, embeddable\_type and embeddable\_id.

*__param__*: Data to log. Can be either event name or hash with at least `event` property.

#### Type declaration
▸(logData: *`string` \| [ILogData](ilogdata.md)*): `void`

**Parameters:**

| Name | Type |
| ------ | ------ |
| logData | `string` \| [ILogData](ilogdata.md) |

**Returns:** `void`

___
<a id="name"></a>

###  name

**● name**: *`string`*

*Defined in [types.ts:12](../../../lara-typescript/src/plugin-api/types.ts#L12)*

Name of the plugin

___
<a id="pluginid"></a>

###  pluginId

**● pluginId**: *`number`*

*Defined in [types.ts:16](../../../lara-typescript/src/plugin-api/types.ts#L16)*

Plugin instance ID.

___
<a id="remoteendpoint"></a>

###  remoteEndpoint

**● remoteEndpoint**: *`string` \| `null`*

*Defined in [types.ts:26](../../../lara-typescript/src/plugin-api/types.ts#L26)*

The portal remote endpoint (if available).

___
<a id="runid"></a>

###  runId

**● runId**: *`number`*

*Defined in [types.ts:24](../../../lara-typescript/src/plugin-api/types.ts#L24)*

The run ID for the current LARA run.

___
<a id="savelearnerpluginstate"></a>

###  saveLearnerPluginState

**● saveLearnerPluginState**: *`function`*

*Defined in [types.ts:39](../../../lara-typescript/src/plugin-api/types.ts#L39)*

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

*Defined in [types.ts:14](../../../lara-typescript/src/plugin-api/types.ts#L14)*

Url from which the plugin was loaded.

___
<a id="useremail"></a>

###  userEmail

**● userEmail**: *`string` \| `null`*

*Defined in [types.ts:28](../../../lara-typescript/src/plugin-api/types.ts#L28)*

The current user email address (if available).

___
<a id="wrappedembeddable"></a>

###  wrappedEmbeddable

**● wrappedEmbeddable**: *[IEmbeddableRuntimeContext](iembeddableruntimecontext.md) \| `null`*

*Defined in [types.ts:47](../../../lara-typescript/src/plugin-api/types.ts#L47)*

Wrapped embeddable runtime context if plugin is wrapping some embeddable and the plugin has the guiPreview option set to true within its manifest.

___

