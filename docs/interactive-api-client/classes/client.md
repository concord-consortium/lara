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

* [inIFrame](client.md#iniframe)

### Methods

* [addListener](client.md#addlistener)
* [connect](client.md#connect)
* [disconnect](client.md#disconnect)
* [getAuthInfo](client.md#getauthinfo)
* [getFirebaseJWT](client.md#getfirebasejwt)
* [post](client.md#post)
* [removeListener](client.md#removelistener)
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

*Defined in [client.ts:25](../../../lara-typescript/src/interactive-api-client/client.ts#L25)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| options | [IClientOptions](../interfaces/iclientoptions.md)<`InteractiveState`, `AuthoredState`, `GlobalInteractiveState`> |

**Returns:** [Client](client.md)

___

## Accessors

<a id="iniframe"></a>

###  inIFrame

**get inIFrame**(): `boolean`

*Defined in [client.ts:99](../../../lara-typescript/src/interactive-api-client/client.ts#L99)*

**Returns:** `boolean`

___

## Methods

<a id="addlistener"></a>

###  addListener

▸ **addListener**(message: *[ServerMessage](../#servermessage)*, callback: *`iframePhone.ListenerCallback`*, requestId?: *`undefined` \| `number`*): `boolean`

*Defined in [client.ts:170](../../../lara-typescript/src/interactive-api-client/client.ts#L170)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| message | [ServerMessage](../#servermessage) |
| callback | `iframePhone.ListenerCallback` |
| `Optional` requestId | `undefined` \| `number` |

**Returns:** `boolean`

___
<a id="connect"></a>

###  connect

▸ **connect**(): `boolean`

*Defined in [client.ts:37](../../../lara-typescript/src/interactive-api-client/client.ts#L37)*

**Returns:** `boolean`

___
<a id="disconnect"></a>

###  disconnect

▸ **disconnect**(): `boolean`

*Defined in [client.ts:83](../../../lara-typescript/src/interactive-api-client/client.ts#L83)*

**Returns:** `boolean`

___
<a id="getauthinfo"></a>

###  getAuthInfo

▸ **getAuthInfo**(): `Promise`<[IAuthInfo](../interfaces/iauthinfo.md)>

*Defined in [client.ts:131](../../../lara-typescript/src/interactive-api-client/client.ts#L131)*

**Returns:** `Promise`<[IAuthInfo](../interfaces/iauthinfo.md)>

___
<a id="getfirebasejwt"></a>

###  getFirebaseJWT

▸ **getFirebaseJWT**(options: *[IGetFirebaseJwtOptions](../interfaces/igetfirebasejwtoptions.md)*): `Promise`<`string`>

*Defined in [client.ts:144](../../../lara-typescript/src/interactive-api-client/client.ts#L144)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| options | [IGetFirebaseJwtOptions](../interfaces/igetfirebasejwtoptions.md) |

**Returns:** `Promise`<`string`>

___
<a id="post"></a>

###  post

▸ **post**(message: *[ClientMessage](../#clientmessage)*, content?: *`InteractiveState` \| `AuthoredState` \| `GlobalInteractiveState` \| `object` \| `string` \| `number` \| `null`*): `boolean`

*Defined in [client.ts:162](../../../lara-typescript/src/interactive-api-client/client.ts#L162)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| message | [ClientMessage](../#clientmessage) |
| `Optional` content | `InteractiveState` \| `AuthoredState` \| `GlobalInteractiveState` \| `object` \| `string` \| `number` \| `null` |

**Returns:** `boolean`

___
<a id="removelistener"></a>

###  removeListener

▸ **removeListener**(message: *[ServerMessage](../#servermessage)*, requestId?: *`undefined` \| `number`*): `boolean`

*Defined in [client.ts:200](../../../lara-typescript/src/interactive-api-client/client.ts#L200)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| message | [ServerMessage](../#servermessage) |
| `Optional` requestId | `undefined` \| `number` |

**Returns:** `boolean`

___
<a id="setauthoredstate"></a>

###  setAuthoredState

▸ **setAuthoredState**(authoredState: *`AuthoredState`*): `boolean`

*Defined in [client.ts:123](../../../lara-typescript/src/interactive-api-client/client.ts#L123)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| authoredState | `AuthoredState` |

**Returns:** `boolean`

___
<a id="setglobalinteractivestate"></a>

###  setGlobalInteractiveState

▸ **setGlobalInteractiveState**(globalState: *`GlobalInteractiveState`*): `boolean`

*Defined in [client.ts:127](../../../lara-typescript/src/interactive-api-client/client.ts#L127)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| globalState | `GlobalInteractiveState` |

**Returns:** `boolean`

___
<a id="setheight"></a>

###  setHeight

▸ **setHeight**(height: *`number` \| `string`*): `boolean`

*Defined in [client.ts:107](../../../lara-typescript/src/interactive-api-client/client.ts#L107)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| height | `number` \| `string` |

**Returns:** `boolean`

___
<a id="setinteractivestate"></a>

###  setInteractiveState

▸ **setInteractiveState**(interactiveState: *`InteractiveState` \| `string` \| `null`*): `boolean`

*Defined in [client.ts:103](../../../lara-typescript/src/interactive-api-client/client.ts#L103)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| interactiveState | `InteractiveState` \| `string` \| `null` |

**Returns:** `boolean`

___
<a id="setnavigation"></a>

###  setNavigation

▸ **setNavigation**(options: *[INavigationOptions](../interfaces/inavigationoptions.md)*): `boolean`

*Defined in [client.ts:119](../../../lara-typescript/src/interactive-api-client/client.ts#L119)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| options | [INavigationOptions](../interfaces/inavigationoptions.md) |

**Returns:** `boolean`

___
<a id="setsupportedfeatures"></a>

###  setSupportedFeatures

▸ **setSupportedFeatures**(features: *[ISupportedFeatures](../interfaces/isupportedfeatures.md)*): `boolean`

*Defined in [client.ts:111](../../../lara-typescript/src/interactive-api-client/client.ts#L111)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| features | [ISupportedFeatures](../interfaces/isupportedfeatures.md) |

**Returns:** `boolean`

___

