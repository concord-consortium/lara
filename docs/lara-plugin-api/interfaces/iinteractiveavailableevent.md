[LARA Plugin API](../README.md) > [IInteractiveAvailableEvent](../interfaces/iinteractiveavailableevent.md)

# Interface: IInteractiveAvailableEvent

Data passed to InteractiveAvailable event handlers.

## Hierarchy

**IInteractiveAvailableEvent**

## Index

### Properties

* [available](iinteractiveavailableevent.md#available)
* [container](iinteractiveavailableevent.md#container)

---

## Properties

<a id="available"></a>

###  available

**● available**: *`boolean`*

<<<<<<< HEAD
*Defined in [types.ts:182](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L182)*
=======
*Defined in [types.ts:182](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L182)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.

Availablility of interactive

___
<a id="container"></a>

###  container

**● container**: *`HTMLElement`*

<<<<<<< HEAD
*Defined in [types.ts:178](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/types.ts#L178)*
=======
*Defined in [types.ts:178](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/types.ts#L178)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.

Interactive container of the interactive that was just started.

___

