[LARA Interactive API Client](../README.md) › [Globals](../globals.md) › [Client](client.md)

# Class: Client

## Hierarchy

* **Client**

## Index

### Constructors

* [constructor](client.md#constructor)

### Properties

* [managedState](client.md#managedstate)
* [phone](client.md#phone)

### Methods

* [addListener](client.md#addlistener)
* [getNextRequestId](client.md#getnextrequestid)
* [post](client.md#post)
* [removeListener](client.md#removelistener)

## Constructors

###  constructor

\+ **new Client**(): *[Client](client.md)*

*Defined in [client.ts:34](../../../lara-typescript/src/interactive-api-client/client.ts#L34)*

**Returns:** *[Client](client.md)*

## Properties

###  managedState

• **managedState**: *[ManagedState](managedstate.md)‹›* = new ManagedState()

*Defined in [client.ts:31](../../../lara-typescript/src/interactive-api-client/client.ts#L31)*

___

###  phone

• **phone**: *IFrameEndpoint* = iframePhone.getIFrameEndpoint()

*Defined in [client.ts:30](../../../lara-typescript/src/interactive-api-client/client.ts#L30)*

## Methods

###  addListener

▸ **addListener**(`message`: [ServerMessage](../globals.md#servermessage), `callback`: iframePhone.ListenerCallback, `requestId?`: undefined | number): *boolean*

*Defined in [client.ts:54](../../../lara-typescript/src/interactive-api-client/client.ts#L54)*

**Parameters:**

Name | Type |
------ | ------ |
`message` | [ServerMessage](../globals.md#servermessage) |
`callback` | iframePhone.ListenerCallback |
`requestId?` | undefined &#124; number |

**Returns:** *boolean*

___

###  getNextRequestId

▸ **getNextRequestId**(): *number*

*Defined in [client.ts:46](../../../lara-typescript/src/interactive-api-client/client.ts#L46)*

**Returns:** *number*

___

###  post

▸ **post**(`message`: [ClientMessage](../globals.md#clientmessage), `content?`: any): *void*

*Defined in [client.ts:50](../../../lara-typescript/src/interactive-api-client/client.ts#L50)*

**Parameters:**

Name | Type |
------ | ------ |
`message` | [ClientMessage](../globals.md#clientmessage) |
`content?` | any |

**Returns:** *void*

___

###  removeListener

▸ **removeListener**(`message`: [ServerMessage](../globals.md#servermessage), `requestId?`: undefined | number): *boolean*

*Defined in [client.ts:91](../../../lara-typescript/src/interactive-api-client/client.ts#L91)*

**Parameters:**

Name | Type |
------ | ------ |
`message` | [ServerMessage](../globals.md#servermessage) |
`requestId?` | undefined &#124; number |

**Returns:** *boolean*
