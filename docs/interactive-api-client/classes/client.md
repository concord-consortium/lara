[LARA Interactive API Client](../README.md) > [Client](../classes/client.md)

# Class: Client

## Type parameters
#### InteractiveState 
#### AuthoredState 
#### DialogState 
#### GlobalInteractiveState 
## Hierarchy

**Client**

## Index

### Constructors

* [constructor](client.md#constructor)

### Accessors

* [InIFrame](client.md#iniframe)
* [iframePhone](client.md#iframephone)

### Methods

* [closeModal](client.md#closemodal)
* [connect](client.md#connect)
* [disconnect](client.md#disconnect)
* [getAuthInfo](client.md#getauthinfo)
* [getFirebaseJWT](client.md#getfirebasejwt)
* [getInteractiveList](client.md#getinteractivelist)
* [getInteractiveSnapshot](client.md#getinteractivesnapshot)
* [getLibraryInteractiveList](client.md#getlibraryinteractivelist)
* [setAuthoredState](client.md#setauthoredstate)
* [setAuthoringCustomReportFields](client.md#setauthoringcustomreportfields)
* [setAuthoringMetadata](client.md#setauthoringmetadata)
* [setGlobalInteractiveState](client.md#setglobalinteractivestate)
* [setHeight](client.md#setheight)
* [setHint](client.md#sethint)
* [setInteractiveState](client.md#setinteractivestate)
* [setLinkedInteractives](client.md#setlinkedinteractives)
* [setNavigation](client.md#setnavigation)
* [setRuntimeCustomReportValues](client.md#setruntimecustomreportvalues)
* [setRuntimeMetadata](client.md#setruntimemetadata)
* [setSupportedFeatures](client.md#setsupportedfeatures)
* [showModal](client.md#showmodal)

---

## Constructors

<a id="constructor"></a>

###  constructor

⊕ **new Client**(options: *[IClientOptions](../interfaces/iclientoptions.md)<`InteractiveState`, `AuthoredState`, `DialogState`, `GlobalInteractiveState`>*): [Client](client.md)

*Defined in [client.ts:29](../../../lara-typescript/src/interactive-api-client/client.ts#L29)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| options | [IClientOptions](../interfaces/iclientoptions.md)<`InteractiveState`, `AuthoredState`, `DialogState`, `GlobalInteractiveState`> |

**Returns:** [Client](client.md)

___

## Accessors

<a id="iniframe"></a>

###  InIFrame

**InIFrame**: 

*Defined in [client.ts:132](../../../lara-typescript/src/interactive-api-client/client.ts#L132)*

___
<a id="iframephone"></a>

###  iframePhone

**iframePhone**: 

*Defined in [client.ts:42](../../../lara-typescript/src/interactive-api-client/client.ts#L42)*

___

## Methods

<a id="closemodal"></a>

###  closeModal

▸ **closeModal**(options: *[ICloseModal](../interfaces/iclosemodal.md)*): `void`

*Defined in [client.ts:245](../../../lara-typescript/src/interactive-api-client/client.ts#L245)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| options | [ICloseModal](../interfaces/iclosemodal.md) |

**Returns:** `void`

___
<a id="connect"></a>

###  connect

▸ **connect**(): `boolean`

*Defined in [client.ts:46](../../../lara-typescript/src/interactive-api-client/client.ts#L46)*

**Returns:** `boolean`

___
<a id="disconnect"></a>

###  disconnect

▸ **disconnect**(): `boolean`

*Defined in [client.ts:116](../../../lara-typescript/src/interactive-api-client/client.ts#L116)*

**Returns:** `boolean`

___
<a id="getauthinfo"></a>

###  getAuthInfo

▸ **getAuthInfo**(): `Promise`<[IAuthInfo](../interfaces/iauthinfo.md)>

*Defined in [client.ts:168](../../../lara-typescript/src/interactive-api-client/client.ts#L168)*

**Returns:** `Promise`<[IAuthInfo](../interfaces/iauthinfo.md)>

___
<a id="getfirebasejwt"></a>

###  getFirebaseJWT

▸ **getFirebaseJWT**(options: *[IGetFirebaseJwtOptions](../interfaces/igetfirebasejwtoptions.md)*): `Promise`<`string`>

*Defined in [client.ts:185](../../../lara-typescript/src/interactive-api-client/client.ts#L185)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| options | [IGetFirebaseJwtOptions](../interfaces/igetfirebasejwtoptions.md) |

**Returns:** `Promise`<`string`>

___
<a id="getinteractivelist"></a>

###  getInteractiveList

▸ **getInteractiveList**(options: *[IGetInteractiveListRequest](../interfaces/igetinteractivelistrequest.md)*): `void`

*Defined in [client.ts:252](../../../lara-typescript/src/interactive-api-client/client.ts#L252)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| options | [IGetInteractiveListRequest](../interfaces/igetinteractivelistrequest.md) |

**Returns:** `void`

___
<a id="getinteractivesnapshot"></a>

###  getInteractiveSnapshot

▸ **getInteractiveSnapshot**(options: *[IGetInteractiveSnapshotRequest](../interfaces/igetinteractivesnapshotrequest.md)*): `void`

*Defined in [client.ts:273](../../../lara-typescript/src/interactive-api-client/client.ts#L273)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| options | [IGetInteractiveSnapshotRequest](../interfaces/igetinteractivesnapshotrequest.md) |

**Returns:** `void`

___
<a id="getlibraryinteractivelist"></a>

###  getLibraryInteractiveList

▸ **getLibraryInteractiveList**(options: *[IGetLibraryInteractiveListRequest](../interfaces/igetlibraryinteractivelistrequest.md)*): `void`

*Defined in [client.ts:266](../../../lara-typescript/src/interactive-api-client/client.ts#L266)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| options | [IGetLibraryInteractiveListRequest](../interfaces/igetlibraryinteractivelistrequest.md) |

**Returns:** `void`

___
<a id="setauthoredstate"></a>

###  setAuthoredState

▸ **setAuthoredState**(authoredState: *`AuthoredState`*): `boolean`

*Defined in [client.ts:160](../../../lara-typescript/src/interactive-api-client/client.ts#L160)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| authoredState | `AuthoredState` |

**Returns:** `boolean`

___
<a id="setauthoringcustomreportfields"></a>

###  setAuthoringCustomReportFields

▸ **setAuthoringCustomReportFields**(fields: *[IAuthoringCustomReportFields](../interfaces/iauthoringcustomreportfields.md)*): `void`

*Defined in [client.ts:224](../../../lara-typescript/src/interactive-api-client/client.ts#L224)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| fields | [IAuthoringCustomReportFields](../interfaces/iauthoringcustomreportfields.md) |

**Returns:** `void`

___
<a id="setauthoringmetadata"></a>

###  setAuthoringMetadata

▸ **setAuthoringMetadata**(metadata: *[IAuthoringMetadata](../#iauthoringmetadata)*): `void`

*Defined in [client.ts:210](../../../lara-typescript/src/interactive-api-client/client.ts#L210)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| metadata | [IAuthoringMetadata](../#iauthoringmetadata) |

**Returns:** `void`

___
<a id="setglobalinteractivestate"></a>

###  setGlobalInteractiveState

▸ **setGlobalInteractiveState**(globalState: *`GlobalInteractiveState`*): `boolean`

*Defined in [client.ts:164](../../../lara-typescript/src/interactive-api-client/client.ts#L164)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| globalState | `GlobalInteractiveState` |

**Returns:** `boolean`

___
<a id="setheight"></a>

###  setHeight

▸ **setHeight**(height: *`number` \| `string`*): `boolean`

*Defined in [client.ts:140](../../../lara-typescript/src/interactive-api-client/client.ts#L140)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| height | `number` \| `string` |

**Returns:** `boolean`

___
<a id="sethint"></a>

###  setHint

▸ **setHint**(hint: *`string`*): `boolean`

*Defined in [client.ts:144](../../../lara-typescript/src/interactive-api-client/client.ts#L144)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| hint | `string` |

**Returns:** `boolean`

___
<a id="setinteractivestate"></a>

###  setInteractiveState

▸ **setInteractiveState**(interactiveState: *`InteractiveState` \| `string` \| `null`*): `boolean`

*Defined in [client.ts:136](../../../lara-typescript/src/interactive-api-client/client.ts#L136)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| interactiveState | `InteractiveState` \| `string` \| `null` |

**Returns:** `boolean`

___
<a id="setlinkedinteractives"></a>

###  setLinkedInteractives

▸ **setLinkedInteractives**(options: *[ISetLinkedInteractives](../interfaces/isetlinkedinteractives.md)*): `void`

*Defined in [client.ts:259](../../../lara-typescript/src/interactive-api-client/client.ts#L259)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| options | [ISetLinkedInteractives](../interfaces/isetlinkedinteractives.md) |

**Returns:** `void`

___
<a id="setnavigation"></a>

###  setNavigation

▸ **setNavigation**(options: *[INavigationOptions](../interfaces/inavigationoptions.md)*): `boolean`

*Defined in [client.ts:156](../../../lara-typescript/src/interactive-api-client/client.ts#L156)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| options | [INavigationOptions](../interfaces/inavigationoptions.md) |

**Returns:** `boolean`

___
<a id="setruntimecustomreportvalues"></a>

###  setRuntimeCustomReportValues

▸ **setRuntimeCustomReportValues**(values: *[IRuntimeCustomReportValues](../interfaces/iruntimecustomreportvalues.md)*): `void`

*Defined in [client.ts:231](../../../lara-typescript/src/interactive-api-client/client.ts#L231)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| values | [IRuntimeCustomReportValues](../interfaces/iruntimecustomreportvalues.md) |

**Returns:** `void`

___
<a id="setruntimemetadata"></a>

###  setRuntimeMetadata

▸ **setRuntimeMetadata**(metadata: *[IRuntimeMetadata](../#iruntimemetadata)*): `void`

*Defined in [client.ts:217](../../../lara-typescript/src/interactive-api-client/client.ts#L217)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| metadata | [IRuntimeMetadata](../#iruntimemetadata) |

**Returns:** `void`

___
<a id="setsupportedfeatures"></a>

###  setSupportedFeatures

▸ **setSupportedFeatures**(features: *[ISupportedFeatures](../interfaces/isupportedfeatures.md)*): `boolean`

*Defined in [client.ts:148](../../../lara-typescript/src/interactive-api-client/client.ts#L148)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| features | [ISupportedFeatures](../interfaces/isupportedfeatures.md) |

**Returns:** `boolean`

___
<a id="showmodal"></a>

###  showModal

▸ **showModal**(options: *[IShowModal](../#ishowmodal)*): `void`

*Defined in [client.ts:238](../../../lara-typescript/src/interactive-api-client/client.ts#L238)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| options | [IShowModal](../#ishowmodal) |

**Returns:** `void`

___

