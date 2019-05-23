[LARA Plugin API](../README.md) > [IPopupOptions](../interfaces/ipopupoptions.md)

# Interface: IPopupOptions

## Hierarchy

**IPopupOptions**

## Index

### Properties

* [autoOpen](ipopupoptions.md#autoopen)
* [backgroundColor](ipopupoptions.md#backgroundcolor)
* [closeButton](ipopupoptions.md#closebutton)
* [closeOnEscape](ipopupoptions.md#closeonescape)
* [color](ipopupoptions.md#color)
* [content](ipopupoptions.md#content)
* [dialogClass](ipopupoptions.md#dialogclass)
* [draggable](ipopupoptions.md#draggable)
* [height](ipopupoptions.md#height)
* [modal](ipopupoptions.md#modal)
* [onBeforeClose](ipopupoptions.md#onbeforeclose)
* [onClose](ipopupoptions.md#onclose)
* [onDragStart](ipopupoptions.md#ondragstart)
* [onDragStop](ipopupoptions.md#ondragstop)
* [onOpen](ipopupoptions.md#onopen)
* [onRemove](ipopupoptions.md#onremove)
* [onResize](ipopupoptions.md#onresize)
* [padding](ipopupoptions.md#padding)
* [position](ipopupoptions.md#position)
* [removeOnClose](ipopupoptions.md#removeonclose)
* [resizable](ipopupoptions.md#resizable)
* [title](ipopupoptions.md#title)
* [titlebarColor](ipopupoptions.md#titlebarcolor)
* [width](ipopupoptions.md#width)

---

## Properties

<a id="autoopen"></a>

### `<Optional>` autoOpen

**● autoOpen**: *`undefined` \| `false` \| `true`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:7](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L7)*
=======
*Defined in [popup.ts:7](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L7)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:7](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L7)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___
<a id="backgroundcolor"></a>

### `<Optional>` backgroundColor

**● backgroundColor**: *`undefined` \| `string`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:27](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L27)*
=======
*Defined in [popup.ts:27](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L27)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:27](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L27)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___
<a id="closebutton"></a>

### `<Optional>` closeButton

**● closeButton**: *`undefined` \| `false` \| `true`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:15](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L15)*
=======
*Defined in [popup.ts:15](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L15)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:15](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L15)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___
<a id="closeonescape"></a>

### `<Optional>` closeOnEscape

**● closeOnEscape**: *`undefined` \| `false` \| `true`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:8](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L8)*
=======
*Defined in [popup.ts:8](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L8)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:8](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L8)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___
<a id="color"></a>

### `<Optional>` color

**● color**: *`undefined` \| `string`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:16](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L16)*
=======
*Defined in [popup.ts:16](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L16)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:16](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L16)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___
<a id="content"></a>

###  content

**● content**: *`HTMLElement` \| `string`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:6](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L6)*
=======
*Defined in [popup.ts:6](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L6)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:6](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L6)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___
<a id="dialogclass"></a>

### `<Optional>` dialogClass

**● dialogClass**: *`undefined` \| `string`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:18](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L18)*
=======
*Defined in [popup.ts:18](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L18)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:18](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L18)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___
<a id="draggable"></a>

### `<Optional>` draggable

**● draggable**: *`undefined` \| `false` \| `true`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:19](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L19)*
=======
*Defined in [popup.ts:19](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L19)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:19](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L19)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___
<a id="height"></a>

### `<Optional>` height

**● height**: *`number` \| `string`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:25](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L25)*
=======
*Defined in [popup.ts:25](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L25)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:25](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L25)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

Number in px or "auto"

___
<a id="modal"></a>

### `<Optional>` modal

**● modal**: *`undefined` \| `false` \| `true`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:17](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L17)*
=======
*Defined in [popup.ts:17](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L17)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:17](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L17)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___
<a id="onbeforeclose"></a>

### `<Optional>` onBeforeClose

**● onBeforeClose**: *`undefined` \| `function`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:32](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L32)*
=======
*Defined in [popup.ts:32](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L32)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:32](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L32)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

Triggered when a dialog is about to close. If canceled (by returning false), the dialog will not close.

___
<a id="onclose"></a>

### `<Optional>` onClose

**● onClose**: *`undefined` \| `function`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:30](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L30)*
=======
*Defined in [popup.ts:30](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L30)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:30](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L30)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___
<a id="ondragstart"></a>

### `<Optional>` onDragStart

**● onDragStart**: *`undefined` \| `function`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:35](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L35)*
=======
*Defined in [popup.ts:35](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L35)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:35](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L35)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___
<a id="ondragstop"></a>

### `<Optional>` onDragStop

**● onDragStop**: *`undefined` \| `function`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:36](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L36)*
=======
*Defined in [popup.ts:36](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L36)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:36](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L36)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___
<a id="onopen"></a>

### `<Optional>` onOpen

**● onOpen**: *`undefined` \| `function`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:29](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L29)*
=======
*Defined in [popup.ts:29](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L29)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:29](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L29)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___
<a id="onremove"></a>

### `<Optional>` onRemove

**● onRemove**: *`undefined` \| `function`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:33](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L33)*
=======
*Defined in [popup.ts:33](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L33)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:33](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L33)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___
<a id="onresize"></a>

### `<Optional>` onResize

**● onResize**: *`undefined` \| `function`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:34](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L34)*
=======
*Defined in [popup.ts:34](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L34)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:34](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L34)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___
<a id="padding"></a>

### `<Optional>` padding

**● padding**: *`undefined` \| `number`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:26](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L26)*
=======
*Defined in [popup.ts:26](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L26)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:26](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L26)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___
<a id="position"></a>

### `<Optional>` position

**● position**: *`undefined` \| `object`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:22](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L22)*
=======
*Defined in [popup.ts:22](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L22)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:22](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L22)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

Please see: [https://api.jqueryui.com/dialog/#option-position](https://api.jqueryui.com/dialog/#option-position)

___
<a id="removeonclose"></a>

### `<Optional>` removeOnClose

**● removeOnClose**: *`undefined` \| `false` \| `true`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:13](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L13)*
=======
*Defined in [popup.ts:13](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L13)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:13](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L13)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

Removes popup HTMLElement when it is closed by the user. Otherwise, it will stay hidden and might be reopened programmatically.

___
<a id="resizable"></a>

### `<Optional>` resizable

**● resizable**: *`undefined` \| `false` \| `true`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:20](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L20)*
=======
*Defined in [popup.ts:20](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L20)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:20](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L20)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___
<a id="title"></a>

### `<Optional>` title

**● title**: *`undefined` \| `string`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:14](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L14)*
=======
*Defined in [popup.ts:14](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L14)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:14](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L14)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___
<a id="titlebarcolor"></a>

### `<Optional>` titlebarColor

**● titlebarColor**: *`undefined` \| `string`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:28](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L28)*
=======
*Defined in [popup.ts:28](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L28)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:28](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L28)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___
<a id="width"></a>

### `<Optional>` width

**● width**: *`undefined` \| `number`*

<<<<<<< HEAD
<<<<<<< HEAD
*Defined in [popup.ts:23](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L23)*
=======
*Defined in [popup.ts:23](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L23)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.
=======
*Defined in [popup.ts:23](https://github.com/concord-consortium/lara/blob/master/lara-typescript/src/plugin-api/popup.ts#L23)*
>>>>>>> Added lara-typescript api doc build step to rewrite blob to master in docs

___

