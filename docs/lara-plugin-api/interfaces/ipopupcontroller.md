[@concord-consortium/lara-plugin-api - v3.2.0](../README.md) › [Globals](../globals.md) › [IPopupController](ipopupcontroller.md)

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

Closes popup (display: none). Also removes HTML element from DOM tree if `removeOnClose` is equal to true.

#### Type declaration:

▸ (): *void*

___

###  open

• **open**: *function*

Opens popup (makes sense only if autoOpen option is set to false during initialization).

#### Type declaration:

▸ (): *void*

___

###  remove

• **remove**: *function*

Removes HTML element from DOM tree.

#### Type declaration:

▸ (): *void*
