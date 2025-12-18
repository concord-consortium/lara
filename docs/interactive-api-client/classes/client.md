[@concord-consortium/lara-interactive-api](../README.md) › [Globals](../globals.md) › [Client](client.md)

# Class: Client

This class is intended to provide basic helpers (like `post()` or `add/removeListener`), maintain client-specific
state, and generally be as minimal as possible. Most of the client-specific helpers and logic can be implemented
in api.ts or hooks.ts (or both so the client app has choice).

## Hierarchy

* **Client**

## Index

### Constructors

* [constructor](client.md#constructor)

### Properties

* [customMessagesHandled](client.md#custommessageshandled)
* [managedState](client.md#managedstate)
* [phone](client.md#phone)

### Methods

* [addListener](client.md#addlistener)
* [createPubSubChannel](client.md#createpubsubchannel)
* [getNextRequestId](client.md#getnextrequestid)
* [post](client.md#post)
* [removeListener](client.md#removelistener)
* [setOnUnload](client.md#setonunload)
* [setSupportedFeatures](client.md#setsupportedfeatures)

## Constructors

###  constructor

\+ **new Client**(): *[Client](client.md)*

**Returns:** *[Client](client.md)*

## Properties

###  customMessagesHandled

• **customMessagesHandled**: *[ICustomMessagesHandledMap](../globals.md#icustommessageshandledmap)*

___

###  managedState

• **managedState**: *ManagedState‹›* = new ManagedState()

___

###  phone

• **phone**: *IFrameEndpoint* = iframePhone.getIFrameEndpoint()

## Methods

###  addListener

▸ **addListener**(`message`: [ServerMessage](../globals.md#servermessage), `callback`: iframePhone.ListenerCallback, `requestId?`: undefined | number): *boolean*

**Parameters:**

Name | Type |
------ | ------ |
`message` | [ServerMessage](../globals.md#servermessage) |
`callback` | iframePhone.ListenerCallback |
`requestId?` | undefined &#124; number |

**Returns:** *boolean*

___

###  createPubSubChannel

▸ **createPubSubChannel**(`channelId`: string, `channelInfo?`: any): *[PubSubChannel](pubsubchannel.md)*

**Parameters:**

Name | Type |
------ | ------ |
`channelId` | string |
`channelInfo?` | any |

**Returns:** *[PubSubChannel](pubsubchannel.md)*

___

###  getNextRequestId

▸ **getNextRequestId**(): *number*

**Returns:** *number*

___

###  post

▸ **post**(`message`: [ClientMessage](../globals.md#clientmessage), `content?`: any): *void*

**Parameters:**

Name | Type |
------ | ------ |
`message` | [ClientMessage](../globals.md#clientmessage) |
`content?` | any |

**Returns:** *void*

___

###  removeListener

▸ **removeListener**(`message`: [ServerMessage](../globals.md#servermessage), `requestId?`: undefined | number, `callback?`: iframePhone.ListenerCallback): *boolean*

**Parameters:**

Name | Type |
------ | ------ |
`message` | [ServerMessage](../globals.md#servermessage) |
`requestId?` | undefined &#124; number |
`callback?` | iframePhone.ListenerCallback |

**Returns:** *boolean*

___

###  setOnUnload

▸ **setOnUnload**(`onUnload?`: [OnUnloadFunction](../globals.md#onunloadfunction)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`onUnload?` | [OnUnloadFunction](../globals.md#onunloadfunction) |

**Returns:** *void*

___

###  setSupportedFeatures

▸ **setSupportedFeatures**(`request`: [ISupportedFeaturesRequest](../interfaces/isupportedfeaturesrequest.md)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`request` | [ISupportedFeaturesRequest](../interfaces/isupportedfeaturesrequest.md) |

**Returns:** *void*
