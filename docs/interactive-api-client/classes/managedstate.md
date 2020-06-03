[LARA Interactive API Client](../README.md) › [Globals](../globals.md) › [ManagedState](managedstate.md)

# Class: ManagedState

## Hierarchy

* **ManagedState**

## Index

### Accessors

* [authoredState](managedstate.md#authoredstate)
* [globalInteractiveState](managedstate.md#globalinteractivestate)
* [initMessage](managedstate.md#initmessage)
* [interactiveState](managedstate.md#interactivestate)

### Methods

* [emit](managedstate.md#emit)
* [off](managedstate.md#off)
* [on](managedstate.md#on)
* [once](managedstate.md#once)

## Accessors

###  authoredState

• **get authoredState**(): *any*

*Defined in [managed-state.ts:39](../../../lara-typescript/src/interactive-api-client/managed-state.ts#L39)*

**Returns:** *any*

• **set authoredState**(`value`: any): *void*

*Defined in [managed-state.ts:43](../../../lara-typescript/src/interactive-api-client/managed-state.ts#L43)*

**Parameters:**

Name | Type |
------ | ------ |
`value` | any |

**Returns:** *void*

___

###  globalInteractiveState

• **get globalInteractiveState**(): *any*

*Defined in [managed-state.ts:51](../../../lara-typescript/src/interactive-api-client/managed-state.ts#L51)*

**Returns:** *any*

• **set globalInteractiveState**(`value`: any): *void*

*Defined in [managed-state.ts:55](../../../lara-typescript/src/interactive-api-client/managed-state.ts#L55)*

**Parameters:**

Name | Type |
------ | ------ |
`value` | any |

**Returns:** *void*

___

###  initMessage

• **get initMessage**(): *any*

*Defined in [managed-state.ts:17](../../../lara-typescript/src/interactive-api-client/managed-state.ts#L17)*

**Returns:** *any*

• **set initMessage**(`value`: any): *void*

*Defined in [managed-state.ts:21](../../../lara-typescript/src/interactive-api-client/managed-state.ts#L21)*

**Parameters:**

Name | Type |
------ | ------ |
`value` | any |

**Returns:** *void*

___

###  interactiveState

• **get interactiveState**(): *any*

*Defined in [managed-state.ts:27](../../../lara-typescript/src/interactive-api-client/managed-state.ts#L27)*

**Returns:** *any*

• **set interactiveState**(`value`: any): *void*

*Defined in [managed-state.ts:31](../../../lara-typescript/src/interactive-api-client/managed-state.ts#L31)*

**Parameters:**

Name | Type |
------ | ------ |
`value` | any |

**Returns:** *void*

## Methods

###  emit

▸ **emit**(`event`: [ClientEvent](../globals.md#clientevent), `content?`: any): *void*

*Defined in [managed-state.ts:63](../../../lara-typescript/src/interactive-api-client/managed-state.ts#L63)*

**Parameters:**

Name | Type |
------ | ------ |
`event` | [ClientEvent](../globals.md#clientevent) |
`content?` | any |

**Returns:** *void*

___

###  off

▸ **off**(`event`: [ClientEvent](../globals.md#clientevent), `handler`: any): *void*

*Defined in [managed-state.ts:71](../../../lara-typescript/src/interactive-api-client/managed-state.ts#L71)*

**Parameters:**

Name | Type |
------ | ------ |
`event` | [ClientEvent](../globals.md#clientevent) |
`handler` | any |

**Returns:** *void*

___

###  on

▸ **on**(`event`: [ClientEvent](../globals.md#clientevent), `handler`: any): *void*

*Defined in [managed-state.ts:67](../../../lara-typescript/src/interactive-api-client/managed-state.ts#L67)*

**Parameters:**

Name | Type |
------ | ------ |
`event` | [ClientEvent](../globals.md#clientevent) |
`handler` | any |

**Returns:** *void*

___

###  once

▸ **once**(`event`: [ClientEvent](../globals.md#clientevent), `handler`: any): *void*

*Defined in [managed-state.ts:75](../../../lara-typescript/src/interactive-api-client/managed-state.ts#L75)*

**Parameters:**

Name | Type |
------ | ------ |
`event` | [ClientEvent](../globals.md#clientevent) |
`handler` | any |

**Returns:** *void*
