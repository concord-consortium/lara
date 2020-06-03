[@concord-consortium/lara-plugin-api - v3.1.2](../README.md) › [Globals](../globals.md) › [IPopupOptions](ipopupoptions.md)

# Interface: IPopupOptions

## Hierarchy

* **IPopupOptions**

## Index

### Properties

* [autoOpen](ipopupoptions.md#optional-autoopen)
* [backgroundColor](ipopupoptions.md#optional-backgroundcolor)
* [closeButton](ipopupoptions.md#optional-closebutton)
* [closeOnEscape](ipopupoptions.md#optional-closeonescape)
* [color](ipopupoptions.md#optional-color)
* [content](ipopupoptions.md#content)
* [dialogClass](ipopupoptions.md#optional-dialogclass)
* [draggable](ipopupoptions.md#optional-draggable)
* [height](ipopupoptions.md#optional-height)
* [modal](ipopupoptions.md#optional-modal)
* [onBeforeClose](ipopupoptions.md#optional-onbeforeclose)
* [onClose](ipopupoptions.md#optional-onclose)
* [onDragStart](ipopupoptions.md#optional-ondragstart)
* [onDragStop](ipopupoptions.md#optional-ondragstop)
* [onOpen](ipopupoptions.md#optional-onopen)
* [onRemove](ipopupoptions.md#optional-onremove)
* [onResize](ipopupoptions.md#optional-onresize)
* [padding](ipopupoptions.md#optional-padding)
* [position](ipopupoptions.md#optional-position)
* [removeOnClose](ipopupoptions.md#optional-removeonclose)
* [resizable](ipopupoptions.md#optional-resizable)
* [title](ipopupoptions.md#optional-title)
* [titlebarColor](ipopupoptions.md#optional-titlebarcolor)
* [width](ipopupoptions.md#optional-width)

## Properties

### `Optional` autoOpen

• **autoOpen**? : *undefined | false | true*

*Defined in [popup.ts:7](../../../lara-typescript/src/plugin-api/popup.ts#L7)*

___

### `Optional` backgroundColor

• **backgroundColor**? : *undefined | string*

*Defined in [popup.ts:27](../../../lara-typescript/src/plugin-api/popup.ts#L27)*

___

### `Optional` closeButton

• **closeButton**? : *undefined | false | true*

*Defined in [popup.ts:15](../../../lara-typescript/src/plugin-api/popup.ts#L15)*

___

### `Optional` closeOnEscape

• **closeOnEscape**? : *undefined | false | true*

*Defined in [popup.ts:8](../../../lara-typescript/src/plugin-api/popup.ts#L8)*

___

### `Optional` color

• **color**? : *undefined | string*

*Defined in [popup.ts:16](../../../lara-typescript/src/plugin-api/popup.ts#L16)*

___

###  content

• **content**: *HTMLElement | string*

*Defined in [popup.ts:6](../../../lara-typescript/src/plugin-api/popup.ts#L6)*

___

### `Optional` dialogClass

• **dialogClass**? : *undefined | string*

*Defined in [popup.ts:18](../../../lara-typescript/src/plugin-api/popup.ts#L18)*

___

### `Optional` draggable

• **draggable**? : *undefined | false | true*

*Defined in [popup.ts:19](../../../lara-typescript/src/plugin-api/popup.ts#L19)*

___

### `Optional` height

• **height**? : *number | string*

*Defined in [popup.ts:25](../../../lara-typescript/src/plugin-api/popup.ts#L25)*

Number in px or "auto"

___

### `Optional` modal

• **modal**? : *undefined | false | true*

*Defined in [popup.ts:17](../../../lara-typescript/src/plugin-api/popup.ts#L17)*

___

### `Optional` onBeforeClose

• **onBeforeClose**? : *undefined | function*

*Defined in [popup.ts:32](../../../lara-typescript/src/plugin-api/popup.ts#L32)*

Triggered when a dialog is about to close. If canceled (by returning false), the dialog will not close.

___

### `Optional` onClose

• **onClose**? : *undefined | function*

*Defined in [popup.ts:30](../../../lara-typescript/src/plugin-api/popup.ts#L30)*

___

### `Optional` onDragStart

• **onDragStart**? : *undefined | function*

*Defined in [popup.ts:35](../../../lara-typescript/src/plugin-api/popup.ts#L35)*

___

### `Optional` onDragStop

• **onDragStop**? : *undefined | function*

*Defined in [popup.ts:36](../../../lara-typescript/src/plugin-api/popup.ts#L36)*

___

### `Optional` onOpen

• **onOpen**? : *undefined | function*

*Defined in [popup.ts:29](../../../lara-typescript/src/plugin-api/popup.ts#L29)*

___

### `Optional` onRemove

• **onRemove**? : *undefined | function*

*Defined in [popup.ts:33](../../../lara-typescript/src/plugin-api/popup.ts#L33)*

___

### `Optional` onResize

• **onResize**? : *undefined | function*

*Defined in [popup.ts:34](../../../lara-typescript/src/plugin-api/popup.ts#L34)*

___

### `Optional` padding

• **padding**? : *undefined | number*

*Defined in [popup.ts:26](../../../lara-typescript/src/plugin-api/popup.ts#L26)*

___

### `Optional` position

• **position**? : *undefined | object*

*Defined in [popup.ts:22](../../../lara-typescript/src/plugin-api/popup.ts#L22)*

Please see: https://api.jqueryui.com/dialog/#option-position

___

### `Optional` removeOnClose

• **removeOnClose**? : *undefined | false | true*

*Defined in [popup.ts:13](../../../lara-typescript/src/plugin-api/popup.ts#L13)*

Removes popup HTMLElement when it is closed by the user.
Otherwise, it will stay hidden and might be reopened programmatically.

___

### `Optional` resizable

• **resizable**? : *undefined | false | true*

*Defined in [popup.ts:20](../../../lara-typescript/src/plugin-api/popup.ts#L20)*

___

### `Optional` title

• **title**? : *undefined | string*

*Defined in [popup.ts:14](../../../lara-typescript/src/plugin-api/popup.ts#L14)*

___

### `Optional` titlebarColor

• **titlebarColor**? : *undefined | string*

*Defined in [popup.ts:28](../../../lara-typescript/src/plugin-api/popup.ts#L28)*

___

### `Optional` width

• **width**? : *undefined | number*

*Defined in [popup.ts:23](../../../lara-typescript/src/plugin-api/popup.ts#L23)*
