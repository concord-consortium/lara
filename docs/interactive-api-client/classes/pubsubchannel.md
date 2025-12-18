[@concord-consortium/lara-interactive-api](../README.md) › [Globals](../globals.md) › [PubSubChannel](pubsubchannel.md)

# Class: PubSubChannel

## Hierarchy

* **PubSubChannel**

## Index

### Constructors

* [constructor](pubsubchannel.md#constructor)

### Methods

* [dispose](pubsubchannel.md#dispose)
* [getChannelId](pubsubchannel.md#getchannelid)
* [getChannelInfo](pubsubchannel.md#getchannelinfo)
* [publish](pubsubchannel.md#publish)
* [setChannelInfo](pubsubchannel.md#setchannelinfo)
* [subscribe](pubsubchannel.md#subscribe)

## Constructors

###  constructor

\+ **new PubSubChannel**(`client`: [Client](client.md), `channelId`: string, `channelInfo?`: any): *[PubSubChannel](pubsubchannel.md)*

**Parameters:**

Name | Type |
------ | ------ |
`client` | [Client](client.md) |
`channelId` | string |
`channelInfo?` | any |

**Returns:** *[PubSubChannel](pubsubchannel.md)*

## Methods

###  dispose

▸ **dispose**(): *void*

**Returns:** *void*

___

###  getChannelId

▸ **getChannelId**(): *string*

**Returns:** *string*

___

###  getChannelInfo

▸ **getChannelInfo**(): *any*

**Returns:** *any*

___

###  publish

▸ **publish**(`message`: any): *void*

**Parameters:**

Name | Type |
------ | ------ |
`message` | any |

**Returns:** *void*

___

###  setChannelInfo

▸ **setChannelInfo**(`channelInfo`: any): *void*

**Parameters:**

Name | Type |
------ | ------ |
`channelInfo` | any |

**Returns:** *void*

___

###  subscribe

▸ **subscribe**(`handler`: [PubSubMessageHandler](../globals.md#pubsubmessagehandler), `onChannelInfo?`: [PubSubChannelInfoHandler](../globals.md#pubsubchannelinfohandler)): *function*

**Parameters:**

Name | Type |
------ | ------ |
`handler` | [PubSubMessageHandler](../globals.md#pubsubmessagehandler) |
`onChannelInfo?` | [PubSubChannelInfoHandler](../globals.md#pubsubchannelinfohandler) |

**Returns:** *function*

▸ (): *void*
