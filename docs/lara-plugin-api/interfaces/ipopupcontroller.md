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

*Defined in [popup.ts:43](https://github.com/concord-consortium/lara/blob/90403de1/lara-typescript/src/plugin-api/popup.ts#L43)*

Closes popup (display: none). Also removes HTML element from DOM tree if `removeOnClose` is equal to true.

#### Type declaration
▸(): `void`

**Returns:** `void`

___
<a id="open"></a>

###  open

**● open**: *`function`*

*Defined in [popup.ts:41](https://github.com/concord-consortium/lara/blob/90403de1/lara-typescript/src/plugin-api/popup.ts#L41)*

Opens popup (makes sense only if autoOpen option is set to false during initialization).

#### Type declaration
▸(): `void`

**Returns:** `void`

___
<a id="remove"></a>

###  remove

**● remove**: *`function`*

*Defined in [popup.ts:45](https://github.com/concord-consortium/lara/blob/90403de1/lara-typescript/src/plugin-api/popup.ts#L45)*

Removes HTML element from DOM tree.

#### Type declaration
▸(): `void`

**Returns:** `void`

___

