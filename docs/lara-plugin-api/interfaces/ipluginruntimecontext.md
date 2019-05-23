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

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:15](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L15)*
=======
*Defined in [types.ts:15](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L15)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:15](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L15)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:15](lara-typescript/src/plugin-api/types.ts#L15)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:15](../../../lara-typescript/src/plugin-api/types.ts#L15)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

The authored configuration for this instance (if available).

___
<a id="container"></a>

###  container

**● container**: *`HTMLElement`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:19](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L19)*
=======
*Defined in [types.ts:19](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L19)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:19](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L19)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:19](lara-typescript/src/plugin-api/types.ts#L19)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:19](../../../lara-typescript/src/plugin-api/types.ts#L19)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

Reserved HTMLElement for the plugin output.

___
<a id="getclassinfo"></a>

###  getClassInfo

**● getClassInfo**: *`function`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:38](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L38)*
=======
*Defined in [types.ts:38](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L38)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:38](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L38)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:38](lara-typescript/src/plugin-api/types.ts#L38)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:38](../../../lara-typescript/src/plugin-api/types.ts#L38)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

Function that returns class details (Promise) or null if class info is not available.

#### Type declaration
▸(): `Promise`<[IClassInfo](iclassinfo.md)> \| `null`

**Returns:** `Promise`<[IClassInfo](iclassinfo.md)> \| `null`

___
<a id="getfirebasejwt"></a>

###  getFirebaseJwt

**● getFirebaseJwt**: *`function`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:40](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L40)*
=======
*Defined in [types.ts:40](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L40)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:40](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L40)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:40](lara-typescript/src/plugin-api/types.ts#L40)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:40](../../../lara-typescript/src/plugin-api/types.ts#L40)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

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

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:17](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L17)*
=======
*Defined in [types.ts:17](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L17)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:17](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L17)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:17](lara-typescript/src/plugin-api/types.ts#L17)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:17](../../../lara-typescript/src/plugin-api/types.ts#L17)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

The saved learner data for this instance (if available).

___
<a id="log"></a>

###  log

**● log**: *`function`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:56](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L56)*
=======
*Defined in [types.ts:56](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L56)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:56](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L56)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:56](lara-typescript/src/plugin-api/types.ts#L56)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:56](../../../lara-typescript/src/plugin-api/types.ts#L56)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

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

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:9](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L9)*
=======
*Defined in [types.ts:9](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L9)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:9](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L9)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:9](lara-typescript/src/plugin-api/types.ts#L9)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:9](../../../lara-typescript/src/plugin-api/types.ts#L9)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

Name of the plugin

___
<a id="pluginid"></a>

###  pluginId

**● pluginId**: *`number`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:13](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L13)*
=======
*Defined in [types.ts:13](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L13)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:13](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L13)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:13](lara-typescript/src/plugin-api/types.ts#L13)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:13](../../../lara-typescript/src/plugin-api/types.ts#L13)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

Plugin instance ID.

___
<a id="remoteendpoint"></a>

###  remoteEndpoint

**● remoteEndpoint**: *`string` \| `null`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:23](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L23)*
=======
*Defined in [types.ts:23](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L23)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:23](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L23)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:23](lara-typescript/src/plugin-api/types.ts#L23)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:23](../../../lara-typescript/src/plugin-api/types.ts#L23)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

The portal remote endpoint (if available).

___
<a id="runid"></a>

###  runId

**● runId**: *`number`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:21](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L21)*
=======
*Defined in [types.ts:21](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L21)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:21](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L21)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:21](lara-typescript/src/plugin-api/types.ts#L21)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:21](../../../lara-typescript/src/plugin-api/types.ts#L21)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

The run ID for the current LARA run.

___
<a id="savelearnerpluginstate"></a>

###  saveLearnerPluginState

**● saveLearnerPluginState**: *`function`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:36](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L36)*
=======
*Defined in [types.ts:36](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L36)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:36](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L36)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:36](lara-typescript/src/plugin-api/types.ts#L36)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:36](../../../lara-typescript/src/plugin-api/types.ts#L36)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

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

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:11](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L11)*
=======
*Defined in [types.ts:11](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L11)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:11](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L11)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:11](lara-typescript/src/plugin-api/types.ts#L11)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:11](../../../lara-typescript/src/plugin-api/types.ts#L11)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

Url from which the plugin was loaded.

___
<a id="useremail"></a>

###  userEmail

**● userEmail**: *`string` \| `null`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:25](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L25)*
=======
*Defined in [types.ts:25](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L25)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:25](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L25)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:25](lara-typescript/src/plugin-api/types.ts#L25)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:25](../../../lara-typescript/src/plugin-api/types.ts#L25)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

The current user email address (if available).

___
<a id="wrappedembeddable"></a>

###  wrappedEmbeddable

**● wrappedEmbeddable**: *[IEmbeddableRuntimeContext](iembeddableruntimecontext.md) \| `null`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:42](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L42)*
=======
*Defined in [types.ts:42](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L42)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:42](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L42)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:42](lara-typescript/src/plugin-api/types.ts#L42)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:42](../../../lara-typescript/src/plugin-api/types.ts#L42)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

Wrapped embeddable runtime context if plugin is wrapping some embeddable.

___

