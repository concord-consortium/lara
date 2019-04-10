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

*Defined in [lara-plugin-api.ts:15](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L15)*

___
<a id="backgroundcolor"></a>

### `<Optional>` backgroundColor

**● backgroundColor**: *`undefined` \| `string`*

*Defined in [lara-plugin-api.ts:35](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L35)*

___
<a id="closebutton"></a>

### `<Optional>` closeButton

**● closeButton**: *`undefined` \| `false` \| `true`*

*Defined in [lara-plugin-api.ts:23](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L23)*

___
<a id="closeonescape"></a>

### `<Optional>` closeOnEscape

**● closeOnEscape**: *`undefined` \| `false` \| `true`*

*Defined in [lara-plugin-api.ts:16](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L16)*

___
<a id="color"></a>

### `<Optional>` color

**● color**: *`undefined` \| `string`*

*Defined in [lara-plugin-api.ts:24](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L24)*

___
<a id="content"></a>

###  content

**● content**: *`HTMLElement` \| `string`*

*Defined in [lara-plugin-api.ts:14](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L14)*

___
<a id="dialogclass"></a>

### `<Optional>` dialogClass

**● dialogClass**: *`undefined` \| `string`*

*Defined in [lara-plugin-api.ts:26](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L26)*

___
<a id="draggable"></a>

### `<Optional>` draggable

**● draggable**: *`undefined` \| `false` \| `true`*

*Defined in [lara-plugin-api.ts:27](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L27)*

___
<a id="height"></a>

### `<Optional>` height

**● height**: *`number` \| `string`*

*Defined in [lara-plugin-api.ts:33](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L33)*

Number in px or "auto"

___
<a id="modal"></a>

### `<Optional>` modal

**● modal**: *`undefined` \| `false` \| `true`*

*Defined in [lara-plugin-api.ts:25](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L25)*

___
<a id="onbeforeclose"></a>

### `<Optional>` onBeforeClose

**● onBeforeClose**: *`undefined` \| `function`*

*Defined in [lara-plugin-api.ts:40](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L40)*

Triggered when a dialog is about to close. If canceled (by returning false), the dialog will not close.

___
<a id="onclose"></a>

### `<Optional>` onClose

**● onClose**: *`undefined` \| `function`*

*Defined in [lara-plugin-api.ts:38](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L38)*

___
<a id="ondragstart"></a>

### `<Optional>` onDragStart

**● onDragStart**: *`undefined` \| `function`*

*Defined in [lara-plugin-api.ts:43](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L43)*

___
<a id="ondragstop"></a>

### `<Optional>` onDragStop

**● onDragStop**: *`undefined` \| `function`*

*Defined in [lara-plugin-api.ts:44](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L44)*

___
<a id="onopen"></a>

### `<Optional>` onOpen

**● onOpen**: *`undefined` \| `function`*

*Defined in [lara-plugin-api.ts:37](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L37)*

___
<a id="onremove"></a>

### `<Optional>` onRemove

**● onRemove**: *`undefined` \| `function`*

*Defined in [lara-plugin-api.ts:41](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L41)*

___
<a id="onresize"></a>

### `<Optional>` onResize

**● onResize**: *`undefined` \| `function`*

*Defined in [lara-plugin-api.ts:42](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L42)*

___
<a id="padding"></a>

### `<Optional>` padding

**● padding**: *`undefined` \| `number`*

*Defined in [lara-plugin-api.ts:34](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L34)*

___
<a id="position"></a>

### `<Optional>` position

**● position**: *`undefined` \| `object`*

*Defined in [lara-plugin-api.ts:30](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L30)*

Please see: [https://api.jqueryui.com/dialog/#option-position](https://api.jqueryui.com/dialog/#option-position)

___
<a id="removeonclose"></a>

### `<Optional>` removeOnClose

**● removeOnClose**: *`undefined` \| `false` \| `true`*

*Defined in [lara-plugin-api.ts:21](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L21)*

Removes popup HTMLElement when it is closed by the user. Otherwise, it will stay hidden and might be reopened programmatically.

___
<a id="resizable"></a>

### `<Optional>` resizable

**● resizable**: *`undefined` \| `false` \| `true`*

*Defined in [lara-plugin-api.ts:28](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L28)*

___
<a id="title"></a>

### `<Optional>` title

**● title**: *`undefined` \| `string`*

*Defined in [lara-plugin-api.ts:22](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L22)*

___
<a id="titlebarcolor"></a>

### `<Optional>` titlebarColor

**● titlebarColor**: *`undefined` \| `string`*

*Defined in [lara-plugin-api.ts:36](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L36)*

___
<a id="width"></a>

### `<Optional>` width

**● width**: *`undefined` \| `number`*

*Defined in [lara-plugin-api.ts:31](https://github.com/concord-consortium/lara/blob/93f2901a/lara-plugin-api/src/lara-plugin-api.ts#L31)*

___

