[@concord-consortium/interactive-api-host](../README.md) › [Globals](../globals.md) › [PubSubManager](pubsubmanager.md)

# Class: PubSubManager

## Hierarchy

* **PubSubManager**

## Index

### Constructors

* [constructor](pubsubmanager.md#constructor)

### Methods

* [addInteractive](pubsubmanager.md#addinteractive)
* [createChannel](pubsubmanager.md#createchannel)
* [publish](pubsubmanager.md#publish)
* [removeInteractive](pubsubmanager.md#removeinteractive)
* [subscribe](pubsubmanager.md#subscribe)
* [unsubscribe](pubsubmanager.md#unsubscribe)

## Constructors

###  constructor

\+ **new PubSubManager**(): *[PubSubManager](pubsubmanager.md)*

**Returns:** *[PubSubManager](pubsubmanager.md)*

## Methods

###  addInteractive

▸ **addInteractive**(`interactiveId`: string, `phone`: IFrameEndpoint): *void*

Add an interactive with its iframe-phone endpoint.

**Parameters:**

Name | Type |
------ | ------ |
`interactiveId` | string |
`phone` | IFrameEndpoint |

**Returns:** *void*

___

###  createChannel

▸ **createChannel**(`channelId`: string, `channelInfo`: any): *void*

Create a channel with channelInfo.
Sets channelInfo only if the channel doesn't already exist.
Sends channelInfo to all current subscribers if channel is new.

**Parameters:**

Name | Type |
------ | ------ |
`channelId` | string |
`channelInfo` | any |

**Returns:** *void*

___

###  publish

▸ **publish**(`publisherId`: string, `channelId`: string, `message`: any): *void*

Publish a message to all subscribers on a channel.

**Parameters:**

Name | Type |
------ | ------ |
`publisherId` | string |
`channelId` | string |
`message` | any |

**Returns:** *void*

___

###  removeInteractive

▸ **removeInteractive**(`interactiveId`: string): *void*

Remove all subscriptions for a given interactive (e.g., when iframe is removed).
Also unregisters the phone endpoint.

**Parameters:**

Name | Type |
------ | ------ |
`interactiveId` | string |

**Returns:** *void*

___

###  subscribe

▸ **subscribe**(`interactiveId`: string, `channelId`: string, `subscriptionId`: string): *void*

Subscribe an interactive to a channel.
If channelInfo already exists for this channel, immediately send it to the new subscriber.

**Parameters:**

Name | Type |
------ | ------ |
`interactiveId` | string |
`channelId` | string |
`subscriptionId` | string |

**Returns:** *void*

___

###  unsubscribe

▸ **unsubscribe**(`interactiveId`: string, `channelId`: string, `subscriptionId`: string): *void*

Unsubscribe an interactive from a channel.

**Parameters:**

Name | Type |
------ | ------ |
`interactiveId` | string |
`channelId` | string |
`subscriptionId` | string |

**Returns:** *void*
