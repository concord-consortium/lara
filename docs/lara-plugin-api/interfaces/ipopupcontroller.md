[LARA Plugin API](../README.md) > [IPopupController](../interfaces/ipopupcontroller.md)

# Interface: IPopupController

## Hierarchy

**IPopupController**

## Index

### Properties

* [close](ipopupcontroller.md#close)
* [open](ipopupcontroller.md#open)
* [remove](ipopupcontroller.md#remove)

---

## Properties

<a id="close"></a>

###  close

**● close**: *`function`*

*Defined in [api/popup.ts:42](https://github.com/concord-consortium/lara/blob/30e7426a/lara-plugin-api/src/api/popup.ts#L42)*

Closes popup (display: none). Also removes HTML element from DOM tree if `removeOnClose` is equal to true.

#### Type declaration
▸(): `void`

**Returns:** `void`

___
<a id="open"></a>

###  open

**● open**: *`function`*

*Defined in [api/popup.ts:40](https://github.com/concord-consortium/lara/blob/30e7426a/lara-plugin-api/src/api/popup.ts#L40)*

Opens popup (makes sense only if autoOpen option is set to false during initialization).

#### Type declaration
▸(): `void`

**Returns:** `void`

___
<a id="remove"></a>

###  remove

**● remove**: *`function`*

*Defined in [api/popup.ts:44](https://github.com/concord-consortium/lara/blob/30e7426a/lara-plugin-api/src/api/popup.ts#L44)*

Removes HTML element from DOM tree.

#### Type declaration
▸(): `void`

**Returns:** `void`

___

