[LARA Plugin API](../README.md) > [ISidebarOptions](../interfaces/isidebaroptions.md)

# Interface: ISidebarOptions

## Hierarchy

**ISidebarOptions**

## Index

### Properties

* [content](isidebaroptions.md#content)
* [handle](isidebaroptions.md#handle)
* [handleColor](isidebaroptions.md#handlecolor)
* [icon](isidebaroptions.md#icon)
* [onClose](isidebaroptions.md#onclose)
* [onOpen](isidebaroptions.md#onopen)
* [padding](isidebaroptions.md#padding)
* [titleBar](isidebaroptions.md#titlebar)
* [titleBarColor](isidebaroptions.md#titlebarcolor)
* [width](isidebaroptions.md#width)

---

## Properties

<a id="content"></a>

###  content

**● content**: *`string` \| `HTMLElement`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [sidebar.ts:10](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/sidebar.ts#L10)*
=======
*Defined in [sidebar.ts:10](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/sidebar.ts#L10)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [sidebar.ts:10](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/sidebar.ts#L10)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [sidebar.ts:10](lara-typescript/src/plugin-api/sidebar.ts#L10)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [sidebar.ts:10](../../../lara-typescript/src/plugin-api/sidebar.ts#L10)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

___
<a id="handle"></a>

### `<Optional>` handle

**● handle**: *`undefined` \| `string`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [sidebar.ts:14](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/sidebar.ts#L14)*
=======
*Defined in [sidebar.ts:14](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/sidebar.ts#L14)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [sidebar.ts:14](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/sidebar.ts#L14)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [sidebar.ts:14](lara-typescript/src/plugin-api/sidebar.ts#L14)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [sidebar.ts:14](../../../lara-typescript/src/plugin-api/sidebar.ts#L14)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

Text displayed on the sidebar handle.

___
<a id="handlecolor"></a>

### `<Optional>` handleColor

**● handleColor**: *`undefined` \| `string`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [sidebar.ts:15](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/sidebar.ts#L15)*
=======
*Defined in [sidebar.ts:15](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/sidebar.ts#L15)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [sidebar.ts:15](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/sidebar.ts#L15)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [sidebar.ts:15](lara-typescript/src/plugin-api/sidebar.ts#L15)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [sidebar.ts:15](../../../lara-typescript/src/plugin-api/sidebar.ts#L15)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

___
<a id="icon"></a>

### `<Optional>` icon

**● icon**: *`string` \| `HTMLElement`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [sidebar.ts:12](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/sidebar.ts#L12)*
=======
*Defined in [sidebar.ts:12](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/sidebar.ts#L12)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [sidebar.ts:12](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/sidebar.ts#L12)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [sidebar.ts:12](lara-typescript/src/plugin-api/sidebar.ts#L12)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [sidebar.ts:12](../../../lara-typescript/src/plugin-api/sidebar.ts#L12)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

Icon can be 'default' (arrow) or an HTML element.

___
<a id="onclose"></a>

### `<Optional>` onClose

**● onClose**: *`undefined` \| `function`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [sidebar.ts:22](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/sidebar.ts#L22)*
=======
*Defined in [sidebar.ts:22](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/sidebar.ts#L22)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [sidebar.ts:22](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/sidebar.ts#L22)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [sidebar.ts:22](lara-typescript/src/plugin-api/sidebar.ts#L22)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [sidebar.ts:22](../../../lara-typescript/src/plugin-api/sidebar.ts#L22)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

___
<a id="onopen"></a>

### `<Optional>` onOpen

**● onOpen**: *`undefined` \| `function`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [sidebar.ts:21](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/sidebar.ts#L21)*
=======
*Defined in [sidebar.ts:21](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/sidebar.ts#L21)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [sidebar.ts:21](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/sidebar.ts#L21)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [sidebar.ts:21](lara-typescript/src/plugin-api/sidebar.ts#L21)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [sidebar.ts:21](../../../lara-typescript/src/plugin-api/sidebar.ts#L21)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

___
<a id="padding"></a>

### `<Optional>` padding

**● padding**: *`undefined` \| `number`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [sidebar.ts:20](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/sidebar.ts#L20)*
=======
*Defined in [sidebar.ts:20](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/sidebar.ts#L20)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [sidebar.ts:20](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/sidebar.ts#L20)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [sidebar.ts:20](lara-typescript/src/plugin-api/sidebar.ts#L20)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [sidebar.ts:20](../../../lara-typescript/src/plugin-api/sidebar.ts#L20)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

___
<a id="titlebar"></a>

### `<Optional>` titleBar

**● titleBar**: *`undefined` \| `string`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [sidebar.ts:17](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/sidebar.ts#L17)*
=======
*Defined in [sidebar.ts:17](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/sidebar.ts#L17)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [sidebar.ts:17](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/sidebar.ts#L17)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [sidebar.ts:17](lara-typescript/src/plugin-api/sidebar.ts#L17)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [sidebar.ts:17](../../../lara-typescript/src/plugin-api/sidebar.ts#L17)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

Title visible after sidebar is opened by user. If it's not provided, it won't be displayed at all.

___
<a id="titlebarcolor"></a>

### `<Optional>` titleBarColor

**● titleBarColor**: *`undefined` \| `string`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [sidebar.ts:18](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/sidebar.ts#L18)*
=======
*Defined in [sidebar.ts:18](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/sidebar.ts#L18)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [sidebar.ts:18](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/sidebar.ts#L18)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [sidebar.ts:18](lara-typescript/src/plugin-api/sidebar.ts#L18)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [sidebar.ts:18](../../../lara-typescript/src/plugin-api/sidebar.ts#L18)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

___
<a id="width"></a>

### `<Optional>` width

**● width**: *`undefined` \| `number`*

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [sidebar.ts:19](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/sidebar.ts#L19)*
=======
*Defined in [sidebar.ts:19](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/sidebar.ts#L19)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [sidebar.ts:19](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/sidebar.ts#L19)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs
=======
*Defined in [sidebar.ts:19](lara-typescript/src/plugin-api/sidebar.ts#L19)*
>>>>>>> Updated api doc replacement to use npm packages and relative paths
=======
*Defined in [sidebar.ts:19](../../../lara-typescript/src/plugin-api/sidebar.ts#L19)*
>>>>>>> Change fix docs paths to use script to give correct relative paths

___

