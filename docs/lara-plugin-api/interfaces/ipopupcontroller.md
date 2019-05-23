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

<<<<<<< HEAD
*Defined in [popup.ts:43](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L43)*
=======
*Defined in [popup.ts:43](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L43)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.

Closes popup (display: none). Also removes HTML element from DOM tree if `removeOnClose` is equal to true.

#### Type declaration
▸(): `void`

**Returns:** `void`

___
<a id="open"></a>

###  open

**● open**: *`function`*

<<<<<<< HEAD
*Defined in [popup.ts:41](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L41)*
=======
*Defined in [popup.ts:41](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L41)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.

Opens popup (makes sense only if autoOpen option is set to false during initialization).

#### Type declaration
▸(): `void`

**Returns:** `void`

___
<a id="remove"></a>

###  remove

**● remove**: *`function`*

<<<<<<< HEAD
*Defined in [popup.ts:45](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/popup.ts#L45)*
=======
*Defined in [popup.ts:45](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/popup.ts#L45)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.

Removes HTML element from DOM tree.

#### Type declaration
▸(): `void`

**Returns:** `void`

___

