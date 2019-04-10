[LARA Plugin API](../README.md) > [IRuntimeContext](../interfaces/iruntimecontext.md)

# Interface: IRuntimeContext

## Hierarchy

**IRuntimeContext**

## Index

### Properties

* [authoredState](iruntimecontext.md#authoredstate)
* [classInfoUrl](iruntimecontext.md#classinfourl)
* [div](iruntimecontext.md#div)
* [experimental](iruntimecontext.md#experimental)
* [getFirebaseJwtUrl](iruntimecontext.md#getfirebasejwturl)
* [learnerState](iruntimecontext.md#learnerstate)
* [name](iruntimecontext.md#name)
* [pluginId](iruntimecontext.md#pluginid)
* [remoteEndpoint](iruntimecontext.md#remoteendpoint)
* [runID](iruntimecontext.md#runid)
* [url](iruntimecontext.md#url)
* [userEmail](iruntimecontext.md#useremail)
* [wrappedEmbeddableContext](iruntimecontext.md#wrappedembeddablecontext)
* [wrappedEmbeddableDiv](iruntimecontext.md#wrappedembeddablediv)

---

## Properties

<a id="authoredstate"></a>

###  authoredState

**● authoredState**: *`string`*

*Defined in [api/plugins.ts:15](https://github.com/concord-consortium/lara/blob/6c40ce49/lara-plugin-api/src/api/plugins.ts#L15)*

The authored configuration for this instance.

___
<a id="classinfourl"></a>

###  classInfoUrl

**● classInfoUrl**: *`string`*

*Defined in [api/plugins.ts:25](https://github.com/concord-consortium/lara/blob/6c40ce49/lara-plugin-api/src/api/plugins.ts#L25)*

The portal URL for class details (if available).

___
<a id="div"></a>

###  div

**● div**: *`HTMLElement`*

*Defined in [api/plugins.ts:19](https://github.com/concord-consortium/lara/blob/6c40ce49/lara-plugin-api/src/api/plugins.ts#L19)*

Reserved HTMLElement for the plugin output.

___
<a id="experimental"></a>

###  experimental

**● experimental**: *[IRuntimeContextExperimentalFeatures](iruntimecontextexperimentalfeatures.md)*

*Defined in [api/plugins.ts:51](https://github.com/concord-consortium/lara/blob/6c40ce49/lara-plugin-api/src/api/plugins.ts#L51)*

___
<a id="getfirebasejwturl"></a>

###  getFirebaseJwtUrl

**● getFirebaseJwtUrl**: *`function`*

*Defined in [api/plugins.ts:29](https://github.com/concord-consortium/lara/blob/6c40ce49/lara-plugin-api/src/api/plugins.ts#L29)*

A function that returns the URL to use fetch a JWT.

#### Type declaration
▸(): `string`

**Returns:** `string`

___
<a id="learnerstate"></a>

###  learnerState

**● learnerState**: *`string`*

*Defined in [api/plugins.ts:17](https://github.com/concord-consortium/lara/blob/6c40ce49/lara-plugin-api/src/api/plugins.ts#L17)*

The saved learner data for this instance.

___
<a id="name"></a>

###  name

**● name**: *`string`*

*Defined in [api/plugins.ts:9](https://github.com/concord-consortium/lara/blob/6c40ce49/lara-plugin-api/src/api/plugins.ts#L9)*

Name of the plugin

___
<a id="pluginid"></a>

###  pluginId

**● pluginId**: *`string`*

*Defined in [api/plugins.ts:13](https://github.com/concord-consortium/lara/blob/6c40ce49/lara-plugin-api/src/api/plugins.ts#L13)*

Active record ID of the plugin scope id.

___
<a id="remoteendpoint"></a>

###  remoteEndpoint

**● remoteEndpoint**: *`string`*

*Defined in [api/plugins.ts:27](https://github.com/concord-consortium/lara/blob/6c40ce49/lara-plugin-api/src/api/plugins.ts#L27)*

The portal remote endpoint (if available).

___
<a id="runid"></a>

###  runID

**● runID**: *`number`*

*Defined in [api/plugins.ts:21](https://github.com/concord-consortium/lara/blob/6c40ce49/lara-plugin-api/src/api/plugins.ts#L21)*

The run ID for the current run.

___
<a id="url"></a>

###  url

**● url**: *`string`*

*Defined in [api/plugins.ts:11](https://github.com/concord-consortium/lara/blob/6c40ce49/lara-plugin-api/src/api/plugins.ts#L11)*

Url from which the plugin was loaded.

___
<a id="useremail"></a>

###  userEmail

**● userEmail**: *`string`*

*Defined in [api/plugins.ts:23](https://github.com/concord-consortium/lara/blob/6c40ce49/lara-plugin-api/src/api/plugins.ts#L23)*

The current users email address if available.

___
<a id="wrappedembeddablecontext"></a>

###  wrappedEmbeddableContext

**● wrappedEmbeddableContext**: *`any`*

*Defined in [api/plugins.ts:50](https://github.com/concord-consortium/lara/blob/6c40ce49/lara-plugin-api/src/api/plugins.ts#L50)*

TBD, it can be almost anything, details of the wrapped embeddable, serialized form of the embeddable, e.g.:

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

**● wrappedEmbeddableDiv**: *`HTMLElement`*

*Defined in [api/plugins.ts:31](https://github.com/concord-consortium/lara/blob/6c40ce49/lara-plugin-api/src/api/plugins.ts#L31)*

If we are wrapping an embeddable its DOM.

___

