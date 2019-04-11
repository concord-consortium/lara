[LARA Plugin API](../README.md) > [IRuntimeContext](../interfaces/iruntimecontext.md)

# Interface: IRuntimeContext

## Hierarchy

**IRuntimeContext**

## Index

### Properties

* [authoredState](iruntimecontext.md#authoredstate)
* [div](iruntimecontext.md#div)
* [experimental](iruntimecontext.md#experimental)
* [getClassInfo](iruntimecontext.md#getclassinfo)
* [getFirebaseJwt](iruntimecontext.md#getfirebasejwt)
* [getInteractiveState](iruntimecontext.md#getinteractivestate)
* [getReportingUrl](iruntimecontext.md#getreportingurl)
* [learnerState](iruntimecontext.md#learnerstate)
* [name](iruntimecontext.md#name)
* [pluginId](iruntimecontext.md#pluginid)
* [remoteEndpoint](iruntimecontext.md#remoteendpoint)
* [runId](iruntimecontext.md#runid)
* [url](iruntimecontext.md#url)
* [userEmail](iruntimecontext.md#useremail)
* [wrappedEmbeddableContext](iruntimecontext.md#wrappedembeddablecontext)
* [wrappedEmbeddableDiv](iruntimecontext.md#wrappedembeddablediv)

---

## Properties

<a id="authoredstate"></a>

###  authoredState

**● authoredState**: *`string`*

*Defined in [api/types.ts:15](https://github.com/concord-consortium/lara/blob/fadb0910/lara-plugin-api/src/api/types.ts#L15)*

The authored configuration for this instance.

___
<a id="div"></a>

###  div

**● div**: *`HTMLElement`*

*Defined in [api/types.ts:19](https://github.com/concord-consortium/lara/blob/fadb0910/lara-plugin-api/src/api/types.ts#L19)*

Reserved HTMLElement for the plugin output.

___
<a id="experimental"></a>

###  experimental

**● experimental**: *[IRuntimeContextExperimentalFeatures](iruntimecontextexperimentalfeatures.md)*

*Defined in [api/types.ts:58](https://github.com/concord-consortium/lara/blob/fadb0910/lara-plugin-api/src/api/types.ts#L58)*

___
<a id="getclassinfo"></a>

###  getClassInfo

**● getClassInfo**: *`function`*

*Defined in [api/types.ts:29](https://github.com/concord-consortium/lara/blob/fadb0910/lara-plugin-api/src/api/types.ts#L29)*

Function that returns class details (Promise) or null if class info is not available.

#### Type declaration
▸(): `Promise`<[IClassInfo](iclassinfo.md)> \| `null`

**Returns:** `Promise`<[IClassInfo](iclassinfo.md)> \| `null`

___
<a id="getfirebasejwt"></a>

###  getFirebaseJwt

**● getFirebaseJwt**: *`function`*

*Defined in [api/types.ts:27](https://github.com/concord-consortium/lara/blob/fadb0910/lara-plugin-api/src/api/types.ts#L27)*

Function that returns JWT (Promise) for given app name.

#### Type declaration
▸(appName: *`string`*): `Promise`<[IJwtResponse](ijwtresponse.md)>

**Parameters:**

| Name | Type |
| ------ | ------ |
| appName | `string` |

**Returns:** `Promise`<[IJwtResponse](ijwtresponse.md)>

___
<a id="getinteractivestate"></a>

###  getInteractiveState

**● getInteractiveState**: *`function`*

*Defined in [api/types.ts:31](https://github.com/concord-consortium/lara/blob/fadb0910/lara-plugin-api/src/api/types.ts#L31)*

Function that returns interactive state (Promise) or null if plugin is not wrapping an interactive.

#### Type declaration
▸(): `Promise`<[IInteractiveState](iinteractivestate.md)> \| `null`

**Returns:** `Promise`<[IInteractiveState](iinteractivestate.md)> \| `null`

___
<a id="getreportingurl"></a>

###  getReportingUrl

**● getReportingUrl**: *`function`*

*Defined in [api/types.ts:36](https://github.com/concord-consortium/lara/blob/fadb0910/lara-plugin-api/src/api/types.ts#L36)*

Function that returns reporting URL (Promise) or null if plugin is not wrapping an interactive or reporting URL is not defined.

#### Type declaration
▸(): `Promise`<`string` \| `null`> \| `null`

**Returns:** `Promise`<`string` \| `null`> \| `null`

___
<a id="learnerstate"></a>

###  learnerState

**● learnerState**: *`string`*

*Defined in [api/types.ts:17](https://github.com/concord-consortium/lara/blob/fadb0910/lara-plugin-api/src/api/types.ts#L17)*

The saved learner data for this instance.

___
<a id="name"></a>

###  name

**● name**: *`string`*

*Defined in [api/types.ts:9](https://github.com/concord-consortium/lara/blob/fadb0910/lara-plugin-api/src/api/types.ts#L9)*

Name of the plugin

___
<a id="pluginid"></a>

###  pluginId

**● pluginId**: *`string`*

*Defined in [api/types.ts:13](https://github.com/concord-consortium/lara/blob/fadb0910/lara-plugin-api/src/api/types.ts#L13)*

Active record ID of the plugin scope id.

___
<a id="remoteendpoint"></a>

###  remoteEndpoint

**● remoteEndpoint**: *`string`*

*Defined in [api/types.ts:25](https://github.com/concord-consortium/lara/blob/fadb0910/lara-plugin-api/src/api/types.ts#L25)*

The portal remote endpoint (if available).

___
<a id="runid"></a>

###  runId

**● runId**: *`number`*

*Defined in [api/types.ts:21](https://github.com/concord-consortium/lara/blob/fadb0910/lara-plugin-api/src/api/types.ts#L21)*

The run ID for the current run.

___
<a id="url"></a>

###  url

**● url**: *`string`*

*Defined in [api/types.ts:11](https://github.com/concord-consortium/lara/blob/fadb0910/lara-plugin-api/src/api/types.ts#L11)*

Url from which the plugin was loaded.

___
<a id="useremail"></a>

###  userEmail

**● userEmail**: *`string`*

*Defined in [api/types.ts:23](https://github.com/concord-consortium/lara/blob/fadb0910/lara-plugin-api/src/api/types.ts#L23)*

The current users email address if available.

___
<a id="wrappedembeddablecontext"></a>

###  wrappedEmbeddableContext

**● wrappedEmbeddableContext**: *`any` \| `null`*

*Defined in [api/types.ts:57](https://github.com/concord-consortium/lara/blob/fadb0910/lara-plugin-api/src/api/types.ts#L57)*

When plugin is wrapping an embeddable, this field will contain its properties - serialized form of the embeddable, e.g.:

```
{
aspect_ratio_method: "DEFAULT",
authored_state: null,
click_to_play: false,
enable_learner_state: true,
name: "Test Interactive",
native_height: 435,
native_width: 576,
url: "http://concord-consortium.github.io/lara-interactive-api/iframe.html",
type: "MwInteractive",
ref_id: "86-MwInteractive"
}
```

___
<a id="wrappedembeddablediv"></a>

###  wrappedEmbeddableDiv

**● wrappedEmbeddableDiv**: *`HTMLElement` \| `undefined`*

*Defined in [api/types.ts:38](https://github.com/concord-consortium/lara/blob/fadb0910/lara-plugin-api/src/api/types.ts#L38)*

Wrapped embeddable container, available only when plugin is wrapping an interactive.

___

