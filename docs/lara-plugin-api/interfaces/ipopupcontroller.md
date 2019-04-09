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

*Defined in [lara-plugin-api.ts:48](https://github.com/concord-consortium/lara/blob/c356eaff/lara-plugin-api/src/lara-plugin-api.ts#L48)*

Closes popup (display: none). Also removes HTML element from DOM tree if `removeOnClose` is equal to true.

#### Type declaration
▸(): `void`

**Returns:** `void`

___
<a id="open"></a>

###  open

**● open**: *`function`*

*Defined in [lara-plugin-api.ts:46](https://github.com/concord-consortium/lara/blob/c356eaff/lara-plugin-api/src/lara-plugin-api.ts#L46)*

Opens popup (makes sense only if autoOpen option is set to false during initialization).

#### Type declaration
▸(): `void`

**Returns:** `void`

___
<a id="remove"></a>

###  remove

**● remove**: *`function`*

*Defined in [lara-plugin-api.ts:50](https://github.com/concord-consortium/lara/blob/c356eaff/lara-plugin-api/src/lara-plugin-api.ts#L50)*

Removes HTML element from DOM tree.

#### Type declaration
▸(): `void`

**Returns:** `void`

___

