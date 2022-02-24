[@concord-consortium/interactive-api-host](../README.md) › [Globals](../globals.md) › [IRuntimeInitInteractive](iruntimeinitinteractive.md)

# Interface: IRuntimeInitInteractive ‹**InteractiveState, AuthoredState, GlobalInteractiveState**›

## Type parameters

▪ **InteractiveState**

▪ **AuthoredState**

▪ **GlobalInteractiveState**

## Hierarchy

* [IInteractiveStateProps](iinteractivestateprops.md)‹InteractiveState›

  ↳ **IRuntimeInitInteractive**

## Index

### Properties

* [activityName](iruntimeinitinteractive.md#optional-activityname)
* [allLinkedStates](iruntimeinitinteractive.md#optional-alllinkedstates)
* [authInfo](iruntimeinitinteractive.md#authinfo)
* [authoredState](iruntimeinitinteractive.md#authoredstate)
* [classInfoUrl](iruntimeinitinteractive.md#classinfourl)
* [collaboratorUrls](iruntimeinitinteractive.md#collaboratorurls)
* [createdAt](iruntimeinitinteractive.md#optional-createdat)
* [error](iruntimeinitinteractive.md#error)
* [externalReportUrl](iruntimeinitinteractive.md#optional-externalreporturl)
* [globalInteractiveState](iruntimeinitinteractive.md#globalinteractivestate)
* [hasLinkedInteractive](iruntimeinitinteractive.md#optional-haslinkedinteractive)
* [hostFeatures](iruntimeinitinteractive.md#hostfeatures)
* [interactive](iruntimeinitinteractive.md#interactive)
* [interactiveState](iruntimeinitinteractive.md#interactivestate)
* [interactiveStateUrl](iruntimeinitinteractive.md#interactivestateurl)
* [linkedInteractives](iruntimeinitinteractive.md#linkedinteractives)
* [linkedState](iruntimeinitinteractive.md#optional-linkedstate)
* [mode](iruntimeinitinteractive.md#mode)
* [pageName](iruntimeinitinteractive.md#optional-pagename)
* [pageNumber](iruntimeinitinteractive.md#optional-pagenumber)
* [runRemoteEndpoint](iruntimeinitinteractive.md#optional-runremoteendpoint)
* [themeInfo](iruntimeinitinteractive.md#themeinfo)
* [updatedAt](iruntimeinitinteractive.md#optional-updatedat)
* [version](iruntimeinitinteractive.md#version)
* [view](iruntimeinitinteractive.md#optional-view)

## Properties

### `Optional` activityName

• **activityName**? : *undefined | string*

*Inherited from [IInteractiveStateProps](iinteractivestateprops.md).[activityName](iinteractivestateprops.md#optional-activityname)*

___

### `Optional` allLinkedStates

• **allLinkedStates**? : *[IInteractiveStateProps](iinteractivestateprops.md)[]*

*Inherited from [IInteractiveStateProps](iinteractivestateprops.md).[allLinkedStates](iinteractivestateprops.md#optional-alllinkedstates)*

___

###  authInfo

• **authInfo**: *object*

#### Type declaration:

* **email**: *string*

* **loggedIn**: *boolean*

* **provider**: *string*

___

###  authoredState

• **authoredState**: *AuthoredState | null*

___

###  classInfoUrl

• **classInfoUrl**: *string*

___

###  collaboratorUrls

• **collaboratorUrls**: *string[] | null*

___

### `Optional` createdAt

• **createdAt**? : *undefined | string*

*Inherited from [IInteractiveStateProps](iinteractivestateprops.md).[createdAt](iinteractivestateprops.md#optional-createdat)*

___

###  error

• **error**: *any*

___

### `Optional` externalReportUrl

• **externalReportUrl**? : *undefined | string*

*Inherited from [IInteractiveStateProps](iinteractivestateprops.md).[externalReportUrl](iinteractivestateprops.md#optional-externalreporturl)*

___

###  globalInteractiveState

• **globalInteractiveState**: *GlobalInteractiveState | null*

___

### `Optional` hasLinkedInteractive

• **hasLinkedInteractive**? : *undefined | false | true*

*Inherited from [IInteractiveStateProps](iinteractivestateprops.md).[hasLinkedInteractive](iinteractivestateprops.md#optional-haslinkedinteractive)*

___

###  hostFeatures

• **hostFeatures**: *[IHostFeatures](ihostfeatures.md)*

___

###  interactive

• **interactive**: *object*

*Overrides [IInteractiveStateProps](iinteractivestateprops.md).[interactive](iinteractivestateprops.md#interactive)*

#### Type declaration:

* **id**: *string*

* **name**: *string*

___

###  interactiveState

• **interactiveState**: *InteractiveState | null*

*Inherited from [IInteractiveStateProps](iinteractivestateprops.md).[interactiveState](iinteractivestateprops.md#interactivestate)*

___

###  interactiveStateUrl

• **interactiveStateUrl**: *string*

*Overrides [IInteractiveStateProps](iinteractivestateprops.md).[interactiveStateUrl](iinteractivestateprops.md#optional-interactivestateurl)*

___

###  linkedInteractives

• **linkedInteractives**: *[ILinkedInteractive](ilinkedinteractive.md)[]*

___

### `Optional` linkedState

• **linkedState**? : *undefined | object*

*Inherited from [IInteractiveStateProps](iinteractivestateprops.md).[linkedState](iinteractivestateprops.md#optional-linkedstate)*

___

###  mode

• **mode**: *"runtime"*

___

### `Optional` pageName

• **pageName**? : *undefined | string*

*Inherited from [IInteractiveStateProps](iinteractivestateprops.md).[pageName](iinteractivestateprops.md#optional-pagename)*

___

### `Optional` pageNumber

• **pageNumber**? : *undefined | number*

*Inherited from [IInteractiveStateProps](iinteractivestateprops.md).[pageNumber](iinteractivestateprops.md#optional-pagenumber)*

___

### `Optional` runRemoteEndpoint

• **runRemoteEndpoint**? : *undefined | string*

___

###  themeInfo

• **themeInfo**: *[IThemeInfo](ithemeinfo.md)*

___

### `Optional` updatedAt

• **updatedAt**? : *undefined | string*

*Inherited from [IInteractiveStateProps](iinteractivestateprops.md).[updatedAt](iinteractivestateprops.md#optional-updatedat)*

___

###  version

• **version**: *1*

___

### `Optional` view

• **view**? : *undefined | "standalone"*
