[LARA Plugin API](../README.md) > [IEmbeddableRuntimeContext](../interfaces/iembeddableruntimecontext.md)

# Interface: IEmbeddableRuntimeContext

## Hierarchy

**IEmbeddableRuntimeContext**

## Index

### Properties

* [container](iembeddableruntimecontext.md#container)
* [getInteractiveState](iembeddableruntimecontext.md#getinteractivestate)
* [getReportingUrl](iembeddableruntimecontext.md#getreportingurl)
* [interactiveAvailable](iembeddableruntimecontext.md#interactiveavailable)
* [laraJson](iembeddableruntimecontext.md#larajson)
* [onInteractiveAvailable](iembeddableruntimecontext.md#oninteractiveavailable)

---

## Properties

<a id="container"></a>

###  container

**● container**: *`HTMLElement`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:61](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L61)*
=======
*Defined in [types.ts:61](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L61)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:61](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L61)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:61](lara-typescript/src/plugin-api/types.ts#L61)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:61](../../../lara-typescript/src/plugin-api/types.ts#L61)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

Embeddable container.

___
<a id="getinteractivestate"></a>

###  getInteractiveState

**● getInteractiveState**: *`function`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:82](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L82)*
=======
*Defined in [types.ts:82](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L82)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:82](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L82)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:82](lara-typescript/src/plugin-api/types.ts#L82)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:82](../../../lara-typescript/src/plugin-api/types.ts#L82)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

Function that returns interactive state (Promise) or null if embeddable isn't interactive.

#### Type declaration
▸(): `Promise`<[IInteractiveState](iinteractivestate.md)> \| `null`

**Returns:** `Promise`<[IInteractiveState](iinteractivestate.md)> \| `null`

___
<a id="getreportingurl"></a>

###  getReportingUrl

**● getReportingUrl**: *`function`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:92](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L92)*
=======
*Defined in [types.ts:92](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L92)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:92](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L92)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:92](lara-typescript/src/plugin-api/types.ts#L92)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:92](../../../lara-typescript/src/plugin-api/types.ts#L92)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

Function that returns reporting URL (Promise) or null if it's not an interactive or reporting URL is not defined. Note that reporting URL is defined in the interactive state (that can be obtained via #getInteractiveState method). If your code needs both interactive state and reporting URL, you can pass interactiveStatePromise as an argument to this method to limit number of network requests.

*__param__*: An optional promise returned from #getInteractiveState method. If it's provided this function will use it to get interacive state and won't issue any additional network requests.

#### Type declaration
▸(interactiveStatePromise?: *`Promise`<[IInteractiveState](iinteractivestate.md)>*): `Promise`<`string` \| `null`> \| `null`

**Parameters:**

| Name | Type |
| ------ | ------ |
| `Optional` interactiveStatePromise | `Promise`<[IInteractiveState](iinteractivestate.md)> |

**Returns:** `Promise`<`string` \| `null`> \| `null`

___
<a id="interactiveavailable"></a>

###  interactiveAvailable

**● interactiveAvailable**: *`boolean`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:102](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L102)*
=======
*Defined in [types.ts:102](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L102)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:102](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L102)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:102](lara-typescript/src/plugin-api/types.ts#L102)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:102](../../../lara-typescript/src/plugin-api/types.ts#L102)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

True if the interactive is immediately available

___
<a id="larajson"></a>

###  laraJson

**● laraJson**: *`any`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:80](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L80)*
=======
*Defined in [types.ts:80](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L80)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:80](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L80)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:80](lara-typescript/src/plugin-api/types.ts#L80)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:80](../../../lara-typescript/src/plugin-api/types.ts#L80)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

Serialized form of the embeddable. Defined by LARA export code, so it's format cannot be specified here. Example (interactive):

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
<a id="oninteractiveavailable"></a>

###  onInteractiveAvailable

**● onInteractiveAvailable**: *`function`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [types.ts:100](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L100)*
=======
*Defined in [types.ts:100](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L100)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [types.ts:100](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/types.ts#L100)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [types.ts:100](lara-typescript/src/plugin-api/types.ts#L100)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [types.ts:100](../../../lara-typescript/src/plugin-api/types.ts#L100)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

Function that subscribes provided handler to event that gets called when the interactive's availablity changes. Normally an interactive starts as available unless click to play is enabled. When click to play is enabled the interactive starts as not available and this handler is called when the click to play overlay is hidden.

*__param__*: Event handler function.

#### Type declaration
▸(handler: *[IInteractiveAvailableEventHandler](../#iinteractiveavailableeventhandler)*): `void`

**Parameters:**

| Name | Type |
| ------ | ------ |
| handler | [IInteractiveAvailableEventHandler](../#iinteractiveavailableeventhandler) |

**Returns:** `void`

___

