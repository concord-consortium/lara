[@concord-consortium/interactive-api-host](../README.md) › [Globals](../globals.md) › [IGetReportItemAnswer](igetreportitemanswer.md)

# Interface: IGetReportItemAnswer ‹**InteractiveState, AuthoredState**›

## Type parameters

▪ **InteractiveState**

▪ **AuthoredState**

## Hierarchy

* IBaseRequestResponse

  ↳ **IGetReportItemAnswer**

## Index

### Properties

* [authoredState](igetreportitemanswer.md#authoredstate)
* [interactiveState](igetreportitemanswer.md#interactivestate)
* [itemsType](igetreportitemanswer.md#optional-itemstype)
* [platformUserId](igetreportitemanswer.md#platformuserid)
* [requestId](igetreportitemanswer.md#requestid)
* [version](igetreportitemanswer.md#version)

## Properties

###  authoredState

• **authoredState**: *AuthoredState*

___

###  interactiveState

• **interactiveState**: *InteractiveState*

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
