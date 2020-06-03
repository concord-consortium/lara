[LARA Plugin API](../README.md) › [Globals](../globals.md) › [IPluginRuntimeContext](ipluginruntimecontext.md)

# Interface: IPluginRuntimeContext

## Hierarchy

* **IPluginRuntimeContext**

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
* [resourceUrl](ipluginruntimecontext.md#resourceurl)
* [runId](ipluginruntimecontext.md#runid)
* [saveLearnerPluginState](ipluginruntimecontext.md#savelearnerpluginstate)
* [url](ipluginruntimecontext.md#url)
* [userEmail](ipluginruntimecontext.md#useremail)
* [wrappedEmbeddable](ipluginruntimecontext.md#wrappedembeddable)

## Properties

###  authoredState

• **authoredState**: *string | null*

*Defined in [types.ts:18](../../../lara-typescript/src/plugin-api/types.ts#L18)*

The authored configuration for this instance (if available).

___

###  container

• **container**: *HTMLElement*

*Defined in [types.ts:22](../../../lara-typescript/src/plugin-api/types.ts#L22)*

HTMLElement created by LARA for the plugin to use to render both its runtime and authoring output.

___

###  getClassInfo

• **getClassInfo**: *function*

*Defined in [types.ts:43](../../../lara-typescript/src/plugin-api/types.ts#L43)*

Function that returns class details (Promise) or null if class info is not available.

#### Type declaration:

▸ (): *Promise‹[IClassInfo](iclassinfo.md)› | null*

___

###  getFirebaseJwt

• **getFirebaseJwt**: *function*

*Defined in [types.ts:45](../../../lara-typescript/src/plugin-api/types.ts#L45)*

Function that returns JWT (Promise) for given app name.

#### Type declaration:

▸ (`appName`: string): *Promise‹[IJwtResponse](ijwtresponse.md)›*

**Parameters:**

Name | Type |
------ | ------ |
`appName` | string |

___

###  learnerState

• **learnerState**: *string | null*

*Defined in [types.ts:20](../../../lara-typescript/src/plugin-api/types.ts#L20)*

The saved learner data for this instance (if available).

___

###  log

• **log**: *function*

*Defined in [types.ts:63](../../../lara-typescript/src/plugin-api/types.ts#L63)*

Logs event to the CC Log Server. Note that logging must be enabled for a given activity.
Either by setting URL param logging=true or by enabling logging in Portal.
```
context.log("testEvent");
context.log({event: "testEvent", event_value: 123});
context.log({event: "testEvent", someExtraParam: 123});
context.log({event: "testEvent", parameters: { paramInParamsHash: 123 }});
```
This augments the logged data with plugin_id, and optionally, embeddable_type
and embeddable_id.

**`param`** Data to log. Can be either event name or hash with at least `event` property.

#### Type declaration:

▸ (`logData`: string | [ILogData](ilogdata.md)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`logData` | string &#124; [ILogData](ilogdata.md) |

___

###  name

• **name**: *string*

*Defined in [types.ts:12](../../../lara-typescript/src/plugin-api/types.ts#L12)*

Name of the plugin

___

###  pluginId

• **pluginId**: *number*

*Defined in [types.ts:16](../../../lara-typescript/src/plugin-api/types.ts#L16)*

Plugin instance ID.

___

###  remoteEndpoint

• **remoteEndpoint**: *string | null*

*Defined in [types.ts:26](../../../lara-typescript/src/plugin-api/types.ts#L26)*

The portal remote endpoint (if available).

___

###  resourceUrl

• **resourceUrl**: *string*

*Defined in [types.ts:30](../../../lara-typescript/src/plugin-api/types.ts#L30)*

URL of the resource associated with the current run (sequence URL or activity URL)

___

###  runId

• **runId**: *number*

*Defined in [types.ts:24](../../../lara-typescript/src/plugin-api/types.ts#L24)*

The run ID for the current LARA run.

___

###  saveLearnerPluginState

• **saveLearnerPluginState**: *function*

*Defined in [types.ts:41](../../../lara-typescript/src/plugin-api/types.ts#L41)*

Function that saves the users state for the plugin.
Note that plugins can have different scopes, e.g. activity or a single page.
If the plugin instance is added to the activity, its state will be shared across all the pages.
If multiple plugin instances are added to various pages, their state will be different on every page.
```
context.saveLearnerPluginState('{"one": 1}').then((data) => console.log(data))
```

**`param`** A string representing serialized plugin state; if it's JSON, remember to stringify it first.

#### Type declaration:

▸ (`state`: string): *Promise‹string›*

**Parameters:**

Name | Type |
------ | ------ |
`state` | string |

___

###  url

• **url**: *string*

*Defined in [types.ts:14](../../../lara-typescript/src/plugin-api/types.ts#L14)*

Url from which the plugin was loaded.

___

###  userEmail

• **userEmail**: *string | null*

*Defined in [types.ts:28](../../../lara-typescript/src/plugin-api/types.ts#L28)*

The current user email address (if available).

___

###  wrappedEmbeddable

• **wrappedEmbeddable**: *[IEmbeddableRuntimeContext](iembeddableruntimecontext.md) | null*

*Defined in [types.ts:49](../../../lara-typescript/src/plugin-api/types.ts#L49)*

Wrapped embeddable runtime context if plugin is wrapping some embeddable and the plugin has the
guiPreview option set to true within its manifest.
