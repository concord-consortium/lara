[LARA Interactive API Client](../README.md) › [Globals](../globals.md) › [IRuntimeInitInteractive](iruntimeinitinteractive.md)

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
* [globalInteractiveState](iruntimeinitinteractive.md#globalinteractivestate)
* [hasLinkedInteractive](iruntimeinitinteractive.md#optional-haslinkedinteractive)
* [interactive](iruntimeinitinteractive.md#interactive)
* [interactiveState](iruntimeinitinteractive.md#interactivestate)
* [interactiveStateUrl](iruntimeinitinteractive.md#interactivestateurl)
* [linkedInteractives](iruntimeinitinteractive.md#linkedinteractives)
* [linkedState](iruntimeinitinteractive.md#optional-linkedstate)
* [mode](iruntimeinitinteractive.md#mode)
* [pageName](iruntimeinitinteractive.md#optional-pagename)
* [pageNumber](iruntimeinitinteractive.md#optional-pagenumber)
* [themeInfo](iruntimeinitinteractive.md#themeinfo)
* [updatedAt](iruntimeinitinteractive.md#optional-updatedat)
* [version](iruntimeinitinteractive.md#version)

## Properties

### `Optional` activityName

• **activityName**? : *undefined | string*

*Inherited from [IInteractiveStateProps](iinteractivestateprops.md).[activityName](iinteractivestateprops.md#optional-activityname)*

*Defined in [types.ts:15](../../../lara-typescript/src/interactive-api-client/types.ts#L15)*

___

### `Optional` allLinkedStates

• **allLinkedStates**? : *[IInteractiveStateProps](iinteractivestateprops.md)[]*

*Inherited from [IInteractiveStateProps](iinteractivestateprops.md).[allLinkedStates](iinteractivestateprops.md#optional-alllinkedstates)*

*Defined in [types.ts:5](../../../lara-typescript/src/interactive-api-client/types.ts#L5)*

___

###  authInfo

• **authInfo**: *object*

*Defined in [types.ts:32](../../../lara-typescript/src/interactive-api-client/types.ts#L32)*

#### Type declaration:

* **email**: *string*

* **loggedIn**: *boolean*

* **provider**: *string*

___

###  authoredState

• **authoredState**: *AuthoredState | null*

*Defined in [types.ts:23](../../../lara-typescript/src/interactive-api-client/types.ts#L23)*

___

###  classInfoUrl

• **classInfoUrl**: *string*

*Defined in [types.ts:27](../../../lara-typescript/src/interactive-api-client/types.ts#L27)*

___

###  collaboratorUrls

• **collaboratorUrls**: *string[] | null*

*Defined in [types.ts:26](../../../lara-typescript/src/interactive-api-client/types.ts#L26)*

___

### `Optional` createdAt

• **createdAt**? : *undefined | string*

*Inherited from [IInteractiveStateProps](iinteractivestateprops.md).[createdAt](iinteractivestateprops.md#optional-createdat)*

*Defined in [types.ts:6](../../../lara-typescript/src/interactive-api-client/types.ts#L6)*

___

###  error

• **error**: *any*

*Defined in [types.ts:21](../../../lara-typescript/src/interactive-api-client/types.ts#L21)*

___

###  globalInteractiveState

• **globalInteractiveState**: *GlobalInteractiveState | null*

*Defined in [types.ts:24](../../../lara-typescript/src/interactive-api-client/types.ts#L24)*

___

### `Optional` hasLinkedInteractive

• **hasLinkedInteractive**? : *undefined | false | true*

*Inherited from [IInteractiveStateProps](iinteractivestateprops.md).[hasLinkedInteractive](iinteractivestateprops.md#optional-haslinkedinteractive)*

*Defined in [types.ts:3](../../../lara-typescript/src/interactive-api-client/types.ts#L3)*

___

###  interactive

• **interactive**: *object*

*Overrides [IInteractiveStateProps](iinteractivestateprops.md).[interactive](iinteractivestateprops.md#interactive)*

*Defined in [types.ts:28](../../../lara-typescript/src/interactive-api-client/types.ts#L28)*

#### Type declaration:

* **id**: *number*

* **name**: *string*

___

###  interactiveState

• **interactiveState**: *InteractiveState | null*

*Inherited from [IInteractiveStateProps](iinteractivestateprops.md).[interactiveState](iinteractivestateprops.md#interactivestate)*

*Defined in [types.ts:2](../../../lara-typescript/src/interactive-api-client/types.ts#L2)*

___

###  interactiveStateUrl

• **interactiveStateUrl**: *string*

*Overrides [IInteractiveStateProps](iinteractivestateprops.md).[interactiveStateUrl](iinteractivestateprops.md#optional-interactivestateurl)*

*Defined in [types.ts:25](../../../lara-typescript/src/interactive-api-client/types.ts#L25)*

___

###  linkedInteractives

• **linkedInteractives**: *[ILinkedRuntimeInteractive](ilinkedruntimeinteractive.md)[]*

*Defined in [types.ts:37](../../../lara-typescript/src/interactive-api-client/types.ts#L37)*

___

### `Optional` linkedState

• **linkedState**? : *undefined | object*

*Inherited from [IInteractiveStateProps](iinteractivestateprops.md).[linkedState](iinteractivestateprops.md#optional-linkedstate)*

*Defined in [types.ts:4](../../../lara-typescript/src/interactive-api-client/types.ts#L4)*

___

###  mode

• **mode**: *"runtime"*

*Defined in [types.ts:22](../../../lara-typescript/src/interactive-api-client/types.ts#L22)*

___

### `Optional` pageName

• **pageName**? : *undefined | string*

*Inherited from [IInteractiveStateProps](iinteractivestateprops.md).[pageName](iinteractivestateprops.md#optional-pagename)*

*Defined in [types.ts:14](../../../lara-typescript/src/interactive-api-client/types.ts#L14)*

___

### `Optional` pageNumber

• **pageNumber**? : *undefined | number*

*Inherited from [IInteractiveStateProps](iinteractivestateprops.md).[pageNumber](iinteractivestateprops.md#optional-pagenumber)*

*Defined in [types.ts:13](../../../lara-typescript/src/interactive-api-client/types.ts#L13)*

___

###  themeInfo

• **themeInfo**: *[IThemeInfo](ithemeinfo.md)*

*Defined in [types.ts:38](../../../lara-typescript/src/interactive-api-client/types.ts#L38)*

___

### `Optional` updatedAt

• **updatedAt**? : *undefined | string*

*Inherited from [IInteractiveStateProps](iinteractivestateprops.md).[updatedAt](iinteractivestateprops.md#optional-updatedat)*

*Defined in [types.ts:7](../../../lara-typescript/src/interactive-api-client/types.ts#L7)*

___

###  version

• **version**: *1*

*Defined in [types.ts:20](../../../lara-typescript/src/interactive-api-client/types.ts#L20)*
