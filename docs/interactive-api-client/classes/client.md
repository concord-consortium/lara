[@concord-consortium/lara-interactive-api](../README.md) › [Globals](../globals.md) › [Client](client.md)

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

* [addCustomMessageListener](client.md#addcustommessagelistener)
* [addDecorateContentListener](client.md#adddecoratecontentlistener)
* [addGetReportItemAnswerListener](client.md#addgetreportitemanswerlistener)
* [addListener](client.md#addlistener)
* [getNextRequestId](client.md#getnextrequestid)
* [post](client.md#post)
* [removeCustomMessageListener](client.md#removecustommessagelistener)
* [removeDecorateContentListener](client.md#removedecoratecontentlistener)
* [removeGetReportItemAnswerListener](client.md#removegetreportitemanswerlistener)
* [removeListener](client.md#removelistener)
* [setSupportedFeatures](client.md#setsupportedfeatures)

## Constructors

###  constructor

\+ **new Client**(): *[Client](client.md)*

**Returns:** *[Client](client.md)*

## Properties

###  managedState

• **managedState**: *ManagedState‹›* = new ManagedState()

___

###  phone

• **phone**: *IFrameEndpoint* = iframePhone.getIFrameEndpoint()

## Methods

###  addCustomMessageListener

▸ **addCustomMessageListener**(`callback`: [ICustomMessageHandler](../globals.md#icustommessagehandler), `handles?`: [ICustomMessagesHandledMap](../globals.md#icustommessageshandledmap)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`callback` | [ICustomMessageHandler](../globals.md#icustommessagehandler) |
`handles?` | [ICustomMessagesHandledMap](../globals.md#icustommessageshandledmap) |

**Returns:** *void*

___

###  addDecorateContentListener

▸ **addDecorateContentListener**(`callback`: [ITextDecorationHandler](../globals.md#itextdecorationhandler)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`callback` | [ITextDecorationHandler](../globals.md#itextdecorationhandler) |

**Returns:** *void*

___

###  addGetReportItemAnswerListener

▸ **addGetReportItemAnswerListener**(`callback`: [IGetReportItemAnswerHandler](../globals.md#igetreportitemanswerhandler)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`callback` | [IGetReportItemAnswerHandler](../globals.md#igetreportitemanswerhandler) |

**Returns:** *void*

___

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

###  removeCustomMessageListener

▸ **removeCustomMessageListener**(): *boolean*

**Returns:** *boolean*

___

###  removeDecorateContentListener

▸ **removeDecorateContentListener**(): *boolean*

**Returns:** *boolean*

___

###  removeGetReportItemAnswerListener

▸ **removeGetReportItemAnswerListener**(): *boolean*

**Returns:** *boolean*

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

###  setSupportedFeatures

▸ **setSupportedFeatures**(`request`: [ISupportedFeaturesRequest](../interfaces/isupportedfeaturesrequest.md)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`request` | [ISupportedFeaturesRequest](../interfaces/isupportedfeaturesrequest.md) |

**Returns:** *void*
