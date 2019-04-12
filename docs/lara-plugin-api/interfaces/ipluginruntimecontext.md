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
* [url](ipluginruntimecontext.md#url)
* [userEmail](ipluginruntimecontext.md#useremail)
* [wrappedEmbeddable](ipluginruntimecontext.md#wrappedembeddable)

---

## Properties

<a id="authoredstate"></a>

###  authoredState

**● authoredState**: *`string` \| `null`*

*Defined in [api/types.ts:15](https://github.com/concord-consortium/lara/blob/c535a346/lara-plugin-api/src/api/types.ts#L15)*

The authored configuration for this instance (if available).

___
<a id="container"></a>

###  container

**● container**: *`HTMLElement`*

*Defined in [api/types.ts:19](https://github.com/concord-consortium/lara/blob/c535a346/lara-plugin-api/src/api/types.ts#L19)*

Reserved HTMLElement for the plugin output.

___
<a id="getclassinfo"></a>

###  getClassInfo

**● getClassInfo**: *`function`*

*Defined in [api/types.ts:27](https://github.com/concord-consortium/lara/blob/c535a346/lara-plugin-api/src/api/types.ts#L27)*

Function that returns class details (Promise) or null if class info is not available.

#### Type declaration
▸(): `Promise`<[IClassInfo](iclassinfo.md)> \| `null`

**Returns:** `Promise`<[IClassInfo](iclassinfo.md)> \| `null`

___
<a id="getfirebasejwt"></a>

###  getFirebaseJwt

**● getFirebaseJwt**: *`function`*

*Defined in [api/types.ts:29](https://github.com/concord-consortium/lara/blob/c535a346/lara-plugin-api/src/api/types.ts#L29)*

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

*Defined in [api/types.ts:17](https://github.com/concord-consortium/lara/blob/c535a346/lara-plugin-api/src/api/types.ts#L17)*

The saved learner data for this instance (if available).

___
<a id="name"></a>

###  name

**● name**: *`string`*

*Defined in [api/types.ts:9](https://github.com/concord-consortium/lara/blob/c535a346/lara-plugin-api/src/api/types.ts#L9)*

Name of the plugin

___
<a id="pluginid"></a>

###  pluginId

**● pluginId**: *`number`*

*Defined in [api/types.ts:13](https://github.com/concord-consortium/lara/blob/c535a346/lara-plugin-api/src/api/types.ts#L13)*

Plugin instance ID.

___
<a id="remoteendpoint"></a>

###  remoteEndpoint

**● remoteEndpoint**: *`string` \| `null`*

*Defined in [api/types.ts:23](https://github.com/concord-consortium/lara/blob/c535a346/lara-plugin-api/src/api/types.ts#L23)*

The portal remote endpoint (if available).

___
<a id="runid"></a>

###  runId

**● runId**: *`number`*

*Defined in [api/types.ts:21](https://github.com/concord-consortium/lara/blob/c535a346/lara-plugin-api/src/api/types.ts#L21)*

The run ID for the current LARA run.

___
<a id="url"></a>

###  url

**● url**: *`string`*

*Defined in [api/types.ts:11](https://github.com/concord-consortium/lara/blob/c535a346/lara-plugin-api/src/api/types.ts#L11)*

Url from which the plugin was loaded.

___
<a id="useremail"></a>

###  userEmail

**● userEmail**: *`string` \| `null`*

*Defined in [api/types.ts:25](https://github.com/concord-consortium/lara/blob/c535a346/lara-plugin-api/src/api/types.ts#L25)*

The current user email address (if available).

___
<a id="wrappedembeddable"></a>

###  wrappedEmbeddable

**● wrappedEmbeddable**: *[IEmbeddableRuntimeContext](iembeddableruntimecontext.md) \| `null`*

*Defined in [api/types.ts:31](https://github.com/concord-consortium/lara/blob/c535a346/lara-plugin-api/src/api/types.ts#L31)*

Wrapped embeddable runtime context if plugin is wrapping some embeddable.

___

