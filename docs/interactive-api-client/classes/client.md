[LARA Interactive API Client](../README.md) > [Client](../classes/client.md)

# Class: Client

## Type parameters
#### InteractiveState 
#### AuthoredState 
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

* [connect](client.md#connect)
* [disconnect](client.md#disconnect)
* [getAuthInfo](client.md#getauthinfo)
* [getFirebaseJWT](client.md#getfirebasejwt)
* [setAuthoredState](client.md#setauthoredstate)
* [setGlobalInteractiveState](client.md#setglobalinteractivestate)
* [setHeight](client.md#setheight)
* [setInteractiveState](client.md#setinteractivestate)
* [setNavigation](client.md#setnavigation)
* [setSupportedFeatures](client.md#setsupportedfeatures)

---

## Constructors

<a id="constructor"></a>

###  constructor

⊕ **new Client**(options: *[IClientOptions](../interfaces/iclientoptions.md)<`InteractiveState`, `AuthoredState`, `GlobalInteractiveState`>*): [Client](client.md)

*Defined in [client.ts:27](../../../lara-typescript/src/interactive-api-client/client.ts#L27)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| options | [IClientOptions](../interfaces/iclientoptions.md)<`InteractiveState`, `AuthoredState`, `GlobalInteractiveState`> |

**Returns:** [Client](client.md)

___

## Accessors

<a id="iniframe"></a>

###  InIFrame

**get InIFrame**(): `boolean`

*Defined in [client.ts:106](../../../lara-typescript/src/interactive-api-client/client.ts#L106)*

**Returns:** `boolean`

___
<a id="iframephone"></a>

###  iframePhone

**get iframePhone**(): `undefined` \| `IFrameEndpoint`

*Defined in [client.ts:40](../../../lara-typescript/src/interactive-api-client/client.ts#L40)*

**Returns:** `undefined` \| `IFrameEndpoint`

___

## Methods

<a id="connect"></a>

###  connect

▸ **connect**(): `boolean`

*Defined in [client.ts:44](../../../lara-typescript/src/interactive-api-client/client.ts#L44)*

**Returns:** `boolean`

___
<a id="disconnect"></a>

###  disconnect

▸ **disconnect**(): `boolean`

*Defined in [client.ts:90](../../../lara-typescript/src/interactive-api-client/client.ts#L90)*

**Returns:** `boolean`

___
<a id="getauthinfo"></a>

###  getAuthInfo

▸ **getAuthInfo**(): `Promise`<[IAuthInfo](../interfaces/iauthinfo.md)>

*Defined in [client.ts:138](../../../lara-typescript/src/interactive-api-client/client.ts#L138)*

**Returns:** `Promise`<[IAuthInfo](../interfaces/iauthinfo.md)>

___
<a id="getfirebasejwt"></a>

###  getFirebaseJWT

▸ **getFirebaseJWT**(options: *[IGetFirebaseJwtOptions](../interfaces/igetfirebasejwtoptions.md)*): `Promise`<`string`>

*Defined in [client.ts:155](../../../lara-typescript/src/interactive-api-client/client.ts#L155)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| options | [IGetFirebaseJwtOptions](../interfaces/igetfirebasejwtoptions.md) |

**Returns:** `Promise`<`string`>

___
<a id="setauthoredstate"></a>

###  setAuthoredState

▸ **setAuthoredState**(authoredState: *`AuthoredState`*): `boolean`

*Defined in [client.ts:130](../../../lara-typescript/src/interactive-api-client/client.ts#L130)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| authoredState | `AuthoredState` |

**Returns:** `boolean`

___
<a id="setglobalinteractivestate"></a>

###  setGlobalInteractiveState

▸ **setGlobalInteractiveState**(globalState: *`GlobalInteractiveState`*): `boolean`

*Defined in [client.ts:134](../../../lara-typescript/src/interactive-api-client/client.ts#L134)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| globalState | `GlobalInteractiveState` |

**Returns:** `boolean`

___
<a id="setheight"></a>

###  setHeight

▸ **setHeight**(height: *`number` \| `string`*): `boolean`

*Defined in [client.ts:114](../../../lara-typescript/src/interactive-api-client/client.ts#L114)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| height | `number` \| `string` |

**Returns:** `boolean`

___
<a id="setinteractivestate"></a>

###  setInteractiveState

▸ **setInteractiveState**(interactiveState: *`InteractiveState` \| `string` \| `null`*): `boolean`

*Defined in [client.ts:110](../../../lara-typescript/src/interactive-api-client/client.ts#L110)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| interactiveState | `InteractiveState` \| `string` \| `null` |

**Returns:** `boolean`

___
<a id="setnavigation"></a>

###  setNavigation

▸ **setNavigation**(options: *[INavigationOptions](../interfaces/inavigationoptions.md)*): `boolean`

*Defined in [client.ts:126](../../../lara-typescript/src/interactive-api-client/client.ts#L126)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| options | [INavigationOptions](../interfaces/inavigationoptions.md) |

**Returns:** `boolean`

___
<a id="setsupportedfeatures"></a>

###  setSupportedFeatures

▸ **setSupportedFeatures**(features: *[ISupportedFeatures](../interfaces/isupportedfeatures.md)*): `boolean`

*Defined in [client.ts:118](../../../lara-typescript/src/interactive-api-client/client.ts#L118)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| features | [ISupportedFeatures](../interfaces/isupportedfeatures.md) |

**Returns:** `boolean`

___

