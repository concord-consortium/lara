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
* [resourceUrl](ipluginruntimecontext.md#resourceurl)
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

___
<a id="container"></a>

###  container

**● container**: *`HTMLElement`*

*Defined in [types.ts:22](../../../lara-typescript/src/plugin-api/types.ts#L22)*

___
<a id="getclassinfo"></a>

###  getClassInfo

**● getClassInfo**: *`function`*

*Defined in [types.ts:43](../../../lara-typescript/src/plugin-api/types.ts#L43)*

#### Type declaration
▸(): `Promise`<[IClassInfo](iclassinfo.md)> \| `null`

**Returns:** `Promise`<[IClassInfo](iclassinfo.md)> \| `null`

___
<a id="getfirebasejwt"></a>

###  getFirebaseJwt

**● getFirebaseJwt**: *`function`*

*Defined in [types.ts:45](../../../lara-typescript/src/plugin-api/types.ts#L45)*

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

___
<a id="log"></a>

###  log

**● log**: *`function`*

*Defined in [types.ts:63](../../../lara-typescript/src/plugin-api/types.ts#L63)*

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

___
<a id="pluginid"></a>

###  pluginId

**● pluginId**: *`number`*

*Defined in [types.ts:16](../../../lara-typescript/src/plugin-api/types.ts#L16)*

___
<a id="remoteendpoint"></a>

###  remoteEndpoint

**● remoteEndpoint**: *`string` \| `null`*

*Defined in [types.ts:26](../../../lara-typescript/src/plugin-api/types.ts#L26)*

___
<a id="resourceurl"></a>

###  resourceUrl

**● resourceUrl**: *`string`*

*Defined in [types.ts:30](../../../lara-typescript/src/plugin-api/types.ts#L30)*

___
<a id="runid"></a>

###  runId

**● runId**: *`number`*

*Defined in [types.ts:24](../../../lara-typescript/src/plugin-api/types.ts#L24)*

___
<a id="savelearnerpluginstate"></a>

###  saveLearnerPluginState

**● saveLearnerPluginState**: *`function`*

*Defined in [types.ts:41](../../../lara-typescript/src/plugin-api/types.ts#L41)*

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

___
<a id="useremail"></a>

###  userEmail

**● userEmail**: *`string` \| `null`*

*Defined in [types.ts:28](../../../lara-typescript/src/plugin-api/types.ts#L28)*

___
<a id="wrappedembeddable"></a>

###  wrappedEmbeddable

**● wrappedEmbeddable**: *[IEmbeddableRuntimeContext](iembeddableruntimecontext.md) \| `null`*

*Defined in [types.ts:49](../../../lara-typescript/src/plugin-api/types.ts#L49)*

___

