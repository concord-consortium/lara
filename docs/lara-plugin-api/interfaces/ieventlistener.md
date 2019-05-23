[LARA Plugin API](../README.md) > [IEventListener](../interfaces/ieventlistener.md)

# Interface: IEventListener

## Hierarchy

**IEventListener**

## Index

### Properties

* [listener](ieventlistener.md#listener)
* [type](ieventlistener.md#type)

---

## Properties

<a id="listener"></a>

###  listener

**● listener**: *`function`*

<<<<<<< HEAD
*Defined in [decorate-content.ts:5](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/decorate-content.ts#L5)*
=======
*Defined in [decorate-content.ts:5](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/decorate-content.ts#L5)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.

#### Type declaration
▸(evt: *`Event`*): `void`

**Parameters:**

| Name | Type |
| ------ | ------ |
| evt | `Event` |

**Returns:** `void`

___
<a id="type"></a>

###  type

**● type**: *`string`*

<<<<<<< HEAD
*Defined in [decorate-content.ts:4](https://github.com/concord-consortium/lara/blob/7771e1f1/lara-typescript/src/plugin-api/decorate-content.ts#L4)*
=======
*Defined in [decorate-content.ts:4](https://github.com/concord-consortium/lara/blob/5ed958f8/lara-typescript/src/plugin-api/decorate-content.ts#L4)*
>>>>>>> Added v3 plugin label override with internal label [#166193888]The plugin system now ignores the label provided by the plugin when itregisters and instead uses an internally generated label set before eachplugin is loaded.  This allows multiple copies of the same plugin to existon a page.

___

