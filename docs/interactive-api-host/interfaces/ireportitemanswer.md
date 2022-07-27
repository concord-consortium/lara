[@concord-consortium/interactive-api-host](../README.md) › [Globals](../globals.md) › [IReportItemAnswer](ireportitemanswer.md)

# Interface: IReportItemAnswer

## Hierarchy

* IBaseRequestResponse

  ↳ **IReportItemAnswer**

## Index

### Properties

* [items](ireportitemanswer.md#items)
* [itemsType](ireportitemanswer.md#optional-itemstype)
* [platformUserId](ireportitemanswer.md#platformuserid)
* [requestId](ireportitemanswer.md#requestid)
* [version](ireportitemanswer.md#version)

## Properties

###  items

• **items**: *[IReportItemAnswerItem](../globals.md#ireportitemansweritem)[]*

___

### `Optional` itemsType

• **itemsType**? : *[ReportItemsType](../globals.md#reportitemstype)*

When not provided, host should assume that itemsType is equal to "fullAnswer" (to maintain backward compatibility
with version 2.0.0).

___

###  platformUserId

• **platformUserId**: *string*

___

###  requestId

• **requestId**: *number*

*Inherited from [IAttachmentUrlRequest](iattachmenturlrequest.md).[requestId](iattachmenturlrequest.md#requestid)*

___

###  version

• **version**: *"2.1.0"*
