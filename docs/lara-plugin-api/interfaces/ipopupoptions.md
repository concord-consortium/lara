[@concord-consortium/lara-plugin-api - v3.2.0](../README.md) › [Globals](../globals.md) › [IPopupOptions](ipopupoptions.md)

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

___

### `Optional` backgroundColor

• **backgroundColor**? : *undefined | string*

___

### `Optional` closeButton

• **closeButton**? : *undefined | false | true*

___

### `Optional` closeOnEscape

• **closeOnEscape**? : *undefined | false | true*

___

### `Optional` color

• **color**? : *undefined | string*

___

###  content

• **content**: *HTMLElement | string*

___

### `Optional` dialogClass

• **dialogClass**? : *undefined | string*

___

### `Optional` draggable

• **draggable**? : *undefined | false | true*

___

### `Optional` height

• **height**? : *number | string*

Number in px or "auto"

___

### `Optional` modal

• **modal**? : *undefined | false | true*

___

### `Optional` onBeforeClose

• **onBeforeClose**? : *undefined | function*

Triggered when a dialog is about to close. If canceled (by returning false), the dialog will not close.

___

### `Optional` onClose

• **onClose**? : *undefined | function*

___

### `Optional` onDragStart

• **onDragStart**? : *undefined | function*

___

### `Optional` onDragStop

• **onDragStop**? : *undefined | function*

___

### `Optional` onOpen

• **onOpen**? : *undefined | function*

___

### `Optional` onRemove

• **onRemove**? : *undefined | function*

___

### `Optional` onResize

• **onResize**? : *undefined | function*

___

### `Optional` padding

• **padding**? : *undefined | number*

___

### `Optional` position

• **position**? : *undefined | object*

Please see: https://api.jqueryui.com/dialog/#option-position

___

### `Optional` removeOnClose

• **removeOnClose**? : *undefined | false | true*

Removes popup HTMLElement when it is closed by the user.
Otherwise, it will stay hidden and might be reopened programmatically.

___

### `Optional` resizable

• **resizable**? : *undefined | false | true*

___

### `Optional` title

• **title**? : *undefined | string*

___

### `Optional` titlebarColor

• **titlebarColor**? : *undefined | string*

___

### `Optional` width

• **width**? : *undefined | number*
