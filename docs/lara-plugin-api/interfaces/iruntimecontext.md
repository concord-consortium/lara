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
* [interactiveStateUrl](iruntimecontext.md#interactivestateurl)
* [learnerState](iruntimecontext.md#learnerstate)
* [name](iruntimecontext.md#name)
* [pluginId](iruntimecontext.md#pluginid)
* [pluginStateKey](iruntimecontext.md#pluginstatekey)
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

*Defined in [api/plugins.ts:19](https://github.com/concord-consortium/lara/blob/ef83a8df/lara-plugin-api/src/api/plugins.ts#L19)*

The authored configuration for this instance.

___
<a id="classinfourl"></a>

###  classInfoUrl

**● classInfoUrl**: *`string`*

*Defined in [api/plugins.ts:29](https://github.com/concord-consortium/lara/blob/ef83a8df/lara-plugin-api/src/api/plugins.ts#L29)*

The portal URL for class details (if available).

___
<a id="div"></a>

###  div

**● div**: *`HTMLElement`*

*Defined in [api/plugins.ts:23](https://github.com/concord-consortium/lara/blob/ef83a8df/lara-plugin-api/src/api/plugins.ts#L23)*

Reserved HTMLElement for the plugin output.

___
<a id="experimental"></a>

###  experimental

**● experimental**: *[IRuntimeContextExperimentalFeatures](iruntimecontextexperimentalfeatures.md)*

*Defined in [api/plugins.ts:57](https://github.com/concord-consortium/lara/blob/ef83a8df/lara-plugin-api/src/api/plugins.ts#L57)*

___
<a id="getfirebasejwturl"></a>

###  getFirebaseJwtUrl

**● getFirebaseJwtUrl**: *`function`*

*Defined in [api/plugins.ts:35](https://github.com/concord-consortium/lara/blob/ef83a8df/lara-plugin-api/src/api/plugins.ts#L35)*

A function that returns the URL to use fetch a JWT.

#### Type declaration
▸(): `string`

**Returns:** `string`

___
<a id="interactivestateurl"></a>

###  interactiveStateUrl

**● interactiveStateUrl**: *`string`*

*Defined in [api/plugins.ts:33](https://github.com/concord-consortium/lara/blob/ef83a8df/lara-plugin-api/src/api/plugins.ts#L33)*

Interactive state URL, available only when plugin is wrapping an interactive (empty string otherwise).

___
<a id="learnerstate"></a>

###  learnerState

**● learnerState**: *`string`*

*Defined in [api/plugins.ts:21](https://github.com/concord-consortium/lara/blob/ef83a8df/lara-plugin-api/src/api/plugins.ts#L21)*

The saved learner data for this instance.

___
<a id="name"></a>

###  name

**● name**: *`string`*

*Defined in [api/plugins.ts:11](https://github.com/concord-consortium/lara/blob/ef83a8df/lara-plugin-api/src/api/plugins.ts#L11)*

Name of the plugin

___
<a id="pluginid"></a>

###  pluginId

**● pluginId**: *`string`*

*Defined in [api/plugins.ts:15](https://github.com/concord-consortium/lara/blob/ef83a8df/lara-plugin-api/src/api/plugins.ts#L15)*

Active record ID of the plugin scope id.

___
<a id="pluginstatekey"></a>

###  pluginStateKey

**● pluginStateKey**: *`string`*

*Defined in [api/plugins.ts:17](https://github.com/concord-consortium/lara/blob/ef83a8df/lara-plugin-api/src/api/plugins.ts#L17)*

Plugin learner state key. Is this necessary and what can that be used for? TDB.

___
<a id="remoteendpoint"></a>

###  remoteEndpoint

**● remoteEndpoint**: *`string`*

*Defined in [api/plugins.ts:31](https://github.com/concord-consortium/lara/blob/ef83a8df/lara-plugin-api/src/api/plugins.ts#L31)*

The portal remote endpoint (if available).

___
<a id="runid"></a>

###  runID

**● runID**: *`number`*

*Defined in [api/plugins.ts:25](https://github.com/concord-consortium/lara/blob/ef83a8df/lara-plugin-api/src/api/plugins.ts#L25)*

The run ID for the current run.

___
<a id="url"></a>

###  url

**● url**: *`string`*

*Defined in [api/plugins.ts:13](https://github.com/concord-consortium/lara/blob/ef83a8df/lara-plugin-api/src/api/plugins.ts#L13)*

Url from which the plugin was loaded.

___
<a id="useremail"></a>

###  userEmail

**● userEmail**: *`string`*

*Defined in [api/plugins.ts:27](https://github.com/concord-consortium/lara/blob/ef83a8df/lara-plugin-api/src/api/plugins.ts#L27)*

The current users email address if available.

___
<a id="wrappedembeddablecontext"></a>

###  wrappedEmbeddableContext

**● wrappedEmbeddableContext**: *`any` \| `null`*

*Defined in [api/plugins.ts:56](https://github.com/concord-consortium/lara/blob/ef83a8df/lara-plugin-api/src/api/plugins.ts#L56)*

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

*Defined in [api/plugins.ts:37](https://github.com/concord-consortium/lara/blob/ef83a8df/lara-plugin-api/src/api/plugins.ts#L37)*

Wrapped embeddable container, available only when plugin is wrapping an interactive.

___

