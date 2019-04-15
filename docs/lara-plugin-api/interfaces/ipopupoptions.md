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

*Defined in [api/popup.ts:7](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L7)*

___
<a id="backgroundcolor"></a>

### `<Optional>` backgroundColor

**● backgroundColor**: *`undefined` \| `string`*

*Defined in [api/popup.ts:27](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L27)*

___
<a id="closebutton"></a>

### `<Optional>` closeButton

**● closeButton**: *`undefined` \| `false` \| `true`*

*Defined in [api/popup.ts:15](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L15)*

___
<a id="closeonescape"></a>

### `<Optional>` closeOnEscape

**● closeOnEscape**: *`undefined` \| `false` \| `true`*

*Defined in [api/popup.ts:8](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L8)*

___
<a id="color"></a>

### `<Optional>` color

**● color**: *`undefined` \| `string`*

*Defined in [api/popup.ts:16](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L16)*

___
<a id="content"></a>

###  content

**● content**: *`HTMLElement` \| `string`*

*Defined in [api/popup.ts:6](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L6)*

___
<a id="dialogclass"></a>

### `<Optional>` dialogClass

**● dialogClass**: *`undefined` \| `string`*

*Defined in [api/popup.ts:18](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L18)*

___
<a id="draggable"></a>

### `<Optional>` draggable

**● draggable**: *`undefined` \| `false` \| `true`*

*Defined in [api/popup.ts:19](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L19)*

___
<a id="height"></a>

### `<Optional>` height

**● height**: *`number` \| `string`*

*Defined in [api/popup.ts:25](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L25)*

Number in px or "auto"

___
<a id="modal"></a>

### `<Optional>` modal

**● modal**: *`undefined` \| `false` \| `true`*

*Defined in [api/popup.ts:17](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L17)*

___
<a id="onbeforeclose"></a>

### `<Optional>` onBeforeClose

**● onBeforeClose**: *`undefined` \| `function`*

*Defined in [api/popup.ts:32](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L32)*

Triggered when a dialog is about to close. If canceled (by returning false), the dialog will not close.

___
<a id="onclose"></a>

### `<Optional>` onClose

**● onClose**: *`undefined` \| `function`*

*Defined in [api/popup.ts:30](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L30)*

___
<a id="ondragstart"></a>

### `<Optional>` onDragStart

**● onDragStart**: *`undefined` \| `function`*

*Defined in [api/popup.ts:35](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L35)*

___
<a id="ondragstop"></a>

### `<Optional>` onDragStop

**● onDragStop**: *`undefined` \| `function`*

*Defined in [api/popup.ts:36](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L36)*

___
<a id="onopen"></a>

### `<Optional>` onOpen

**● onOpen**: *`undefined` \| `function`*

*Defined in [api/popup.ts:29](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L29)*

___
<a id="onremove"></a>

### `<Optional>` onRemove

**● onRemove**: *`undefined` \| `function`*

*Defined in [api/popup.ts:33](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L33)*

___
<a id="onresize"></a>

### `<Optional>` onResize

**● onResize**: *`undefined` \| `function`*

*Defined in [api/popup.ts:34](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L34)*

___
<a id="padding"></a>

### `<Optional>` padding

**● padding**: *`undefined` \| `number`*

*Defined in [api/popup.ts:26](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L26)*

___
<a id="position"></a>

### `<Optional>` position

**● position**: *`undefined` \| `object`*

*Defined in [api/popup.ts:22](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L22)*

Please see: [https://api.jqueryui.com/dialog/#option-position](https://api.jqueryui.com/dialog/#option-position)

___
<a id="removeonclose"></a>

### `<Optional>` removeOnClose

**● removeOnClose**: *`undefined` \| `false` \| `true`*

*Defined in [api/popup.ts:13](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L13)*

Removes popup HTMLElement when it is closed by the user. Otherwise, it will stay hidden and might be reopened programmatically.

___
<a id="resizable"></a>

### `<Optional>` resizable

**● resizable**: *`undefined` \| `false` \| `true`*

*Defined in [api/popup.ts:20](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L20)*

___
<a id="title"></a>

### `<Optional>` title

**● title**: *`undefined` \| `string`*

*Defined in [api/popup.ts:14](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L14)*

___
<a id="titlebarcolor"></a>

### `<Optional>` titlebarColor

**● titlebarColor**: *`undefined` \| `string`*

*Defined in [api/popup.ts:28](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L28)*

___
<a id="width"></a>

### `<Optional>` width

**● width**: *`undefined` \| `number`*

*Defined in [api/popup.ts:23](https://github.com/concord-consortium/lara/blob/d708ee30/lara-plugin-api/src/api/popup.ts#L23)*

___

