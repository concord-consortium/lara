[@concord-consortium/lara-plugin-api - v3.1.2](../README.md) › [Globals](../globals.md) › [IPopupController](ipopupcontroller.md)

# Interface: IPopupController

## Hierarchy

* **IPopupController**

## Index

### Properties

* [close](ipopupcontroller.md#close)
* [open](ipopupcontroller.md#open)
* [remove](ipopupcontroller.md#remove)

## Properties

###  close

• **close**: *function*

*Defined in [popup.ts:43](../../../lara-typescript/src/plugin-api/popup.ts#L43)*

Closes popup (display: none). Also removes HTML element from DOM tree if `removeOnClose` is equal to true.

#### Type declaration:

▸ (): *void*

___

###  open

• **open**: *function*

*Defined in [popup.ts:41](../../../lara-typescript/src/plugin-api/popup.ts#L41)*

Opens popup (makes sense only if autoOpen option is set to false during initialization).

#### Type declaration:

▸ (): *void*

___

###  remove

• **remove**: *function*

*Defined in [popup.ts:45](../../../lara-typescript/src/plugin-api/popup.ts#L45)*

Removes HTML element from DOM tree.

#### Type declaration:

▸ (): *void*
