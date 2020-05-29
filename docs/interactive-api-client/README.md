
LARA Interactive API Client
===========================

A TypeScript-based client for the LARA Interactive API. This also includes all the types for the API which are shared with the server-side Typescript files that implement the LARA-side of the API.

NOTE: this file (in /docs) is auto-generated as part of the `lara-typescript` build using [TypeDoc](https://typedoc.org/) by combining the API client's readme file with auto-generated output. If you wish to edit this document please edit `lara-typescript/src/interactive-api-client/README.md`.

Installation
------------

First install the package:

`npm i --save @concord-consortium/lara-interactive-api`

Then import it into your code:

`import LaraInteractiveApi from "@concord-consortium/lara-interactive-api"`

the client is compiled TypeScript and includes the typings in `.d.ts` files in the package. These typings are automatically loaded by the TypeScript compiler so you do now need to install a separate `@types/...` package.

Usage
-----

### Client Class

The `Client` class uses type variables in the constructor to specify the shape of the authored state, interactive state and global interactive state of the interactive using the class. Each type variable is optional and defaults to the empty object (`{}`). These type variables allow for strict type checking of the `setAuthoredState`, `setInteractiveState` and `setGlobalInteractiveState` helper methods in the client instance.

All parameters to the constructor are in a single options object, with the only required option being the features supported by the interactive.

Here is a minimal example of a client that supports no features and has no authored or interactive state:

`const client = new LaraInteractiveApi.Client({ supportedFeatures: {}})`

and there is maximal example of a client that supports all types of state:

```
interface IState {
  clicks: number;
}

interface IAuthoredState {
  showButtons: boolean;
}

interface IInteractiveState {
  numButtonPresses: number;
}

interface IGlobalInteractiveState {
  backgroundColor: string;
}

const client = new LaraInteractiveApi.Client<IInteractiveState, IAuthoredState, IDialogState, IGlobalInteractiveState>({
  supportedFeatures: {
    authoredState: true,
    interactiveState: true,
    aspectRatio: 1,
    customMessages: {
      handles: ["plugin:teacher-edition-tips:showThing"];
    }
  },

  onGetInteractiveState: () => ({ numButtonPresses: this.state.clicks })
})

...

const handleButtonClick = () => this.setState({ clicks: this.state.clicks + 1 });

...

<button onClick={handleButtonClick}>{this.state.clicks}</button>
```

Note: the order of the type variables is important, it is `InteractiveState`, `AuthoredState`, `DialogState`, and `IGlobalInteractiveState`. If you do wish to skip a type variable just use `{}` in its place and any type variable left off on the end defaults to `{}`, eg:

`const client = new LaraInteractiveApi.Client<IInteractiveState, {}, {}, IGlobalInteractiveState>({ ...`

Along with the required `supportedFeatures` option there are a few optional options:

1.  `startDisconnected?: boolean;` - if `true` the client does not automatically connect to Lara.
2.  `onHello?: () => void;` - a callback called when the underlying `hello` message in `iframe-phone` is received.
3.  `onInitInteractive?: (initMessage: IInitInteractive<InteractiveState, AuthoredState, GlobalInteractiveState>) => void;` - a callback called when the `initInteractive` message is received from Lara. You can use this to store the initial states of the interactive.
4.  `onGetInteractiveState?: () => InteractiveState \| string \| null;` - a callback called when Lara asks for the interactive state. Note: this callback is called many times during the lifetime of the interactive as Lara polls for state changes.
5.  `onGlobalInteractiveStateUpdated?: (globalState: GlobalInteractiveState) => void;` - a callback called when another interactive changes the global interactive state. Note: by design Lara does not invoke this on the interactive that invokes the change.

Once constructed you can use the generated documentation to see the helper methods added to the class that allow for interaction with Lara.

### Hook

If you are using React you will instead want to the use the hook which wraps the client in a more easily used form. To use the hook first import it:

`import { useLaraInteractiveApi } from "@concord-consortium/lara-interactive-api"`

and then call the hook using your type variables in your React component.

Here is a minimal example of a hook that supports no features and has no authored or interactive state that to gets the user info:

```
import { IAuthInfo } from "@concord-consortium/lara-interactive-api";

....

const { getAuthInfo } = useLaraInteractiveApi({ supportedFeatures: {} });
const [authInfo, setAuthInfo] = useState<IAuthInfo\|undefined>();
const [error, setError] = useState<any>();

useEffect(() => {
  getAuthInfo()
    .then(setAuthInfo)
    .catch(setError);
}, []);
```

and there is maximal example of a hook that supports all types of state (using the same interfaces as the client example above):

```
const { interactiveState, setInteractiveState } = useLaraInteractiveApi<IInteractiveState, IAuthoredState, IGlobalInteractiveState>({
  supportedFeatures: {
    authoredState: true,
    interactiveState: true,
    aspectRatio: 1
  }
});

...

const handleButtonClick = () => setInteractiveState({ numButtonPresses: interactiveState.numButtonPresses + 1 })

...

<button onClick={handleButtonClick}>{interactiveState.numButtonPresses}</button>
```

Calling the `setAuthoredState`, `setInteractiveState` and `setGlobalInteractiveState` methods returned by the hook will both update the state held inside the hook and also send the message to Lara. This allows you to use the update the interactive state and use it in your render result. You also do not have to supply an `onGetInteractiveState` callback as the hook handles that for you using the current local hook state.

## Index

### Interfaces

* [IAggregateInitInteractive](interfaces/iaggregateinitinteractive.md)
* [IAuthInfo](interfaces/iauthinfo.md)
* [IAuthoringCustomReportField](interfaces/iauthoringcustomreportfield.md)
* [IAuthoringCustomReportFields](interfaces/iauthoringcustomreportfields.md)
* [IAuthoringInitInteractive](interfaces/iauthoringinitinteractive.md)
* [IAuthoringInteractiveMetadata](interfaces/iauthoringinteractivemetadata.md)
* [IAuthoringMetadataBase](interfaces/iauthoringmetadatabase.md)
* [IAuthoringMultipleChoiceChoiceMetadata](interfaces/iauthoringmultiplechoicechoicemetadata.md)
* [IAuthoringMultipleChoiceMetadata](interfaces/iauthoringmultiplechoicemetadata.md)
* [IAuthoringOpenResponseMetadata](interfaces/iauthoringopenresponsemetadata.md)
* [IBaseShowModal](interfaces/ibaseshowmodal.md)
* [IClientOptions](interfaces/iclientoptions.md)
* [ICloseModal](interfaces/iclosemodal.md)
* [IClosedModal](interfaces/iclosedmodal.md)
* [IContextMember](interfaces/icontextmember.md)
* [IContextMembership](interfaces/icontextmembership.md)
* [ICustomMessage](interfaces/icustommessage.md)
* [IDialogInitInteractive](interfaces/idialoginitinteractive.md)
* [IGetAuthInfoRequest](interfaces/igetauthinforequest.md)
* [IGetAuthInfoResponse](interfaces/igetauthinforesponse.md)
* [IGetFirebaseJwtOptions](interfaces/igetfirebasejwtoptions.md)
* [IGetFirebaseJwtRequest](interfaces/igetfirebasejwtrequest.md)
* [IGetFirebaseJwtResponse](interfaces/igetfirebasejwtresponse.md)
* [IGetInteractiveListOptions](interfaces/igetinteractivelistoptions.md)
* [IGetInteractiveListRequest](interfaces/igetinteractivelistrequest.md)
* [IGetInteractiveListResponse](interfaces/igetinteractivelistresponse.md)
* [IGetInteractiveSnapshotOptions](interfaces/igetinteractivesnapshotoptions.md)
* [IGetInteractiveSnapshotRequest](interfaces/igetinteractivesnapshotrequest.md)
* [IGetInteractiveSnapshotResponse](interfaces/igetinteractivesnapshotresponse.md)
* [IGetLibraryInteractiveListOptions](interfaces/igetlibraryinteractivelistoptions.md)
* [IGetLibraryInteractiveListRequest](interfaces/igetlibraryinteractivelistrequest.md)
* [IGetLibraryInteractiveListResponse](interfaces/igetlibraryinteractivelistresponse.md)
* [IHookOptions](interfaces/ihookoptions.md)
* [IInteractiveListResponseItem](interfaces/iinteractivelistresponseitem.md)
* [IInteractiveStateProps](interfaces/iinteractivestateprops.md)
* [ILibraryInteractiveListResponseItem](interfaces/ilibraryinteractivelistresponseitem.md)
* [ILinkedAuthoredInteractive](interfaces/ilinkedauthoredinteractive.md)
* [ILinkedRuntimeInteractive](interfaces/ilinkedruntimeinteractive.md)
* [INavigationOptions](interfaces/inavigationoptions.md)
* [IReportInitInteractive](interfaces/ireportinitinteractive.md)
* [IRuntimeCustomReportValues](interfaces/iruntimecustomreportvalues.md)
* [IRuntimeInitInteractive](interfaces/iruntimeinitinteractive.md)
* [IRuntimeInteractiveMetadata](interfaces/iruntimeinteractivemetadata.md)
* [IRuntimeMetadataBase](interfaces/iruntimemetadatabase.md)
* [IRuntimeMultipleChoiceMetadata](interfaces/iruntimemultiplechoicemetadata.md)
* [ISetLinkedInteractives](interfaces/isetlinkedinteractives.md)
* [IShowAlert](interfaces/ishowalert.md)
* [IShowDialog](interfaces/ishowdialog.md)
* [IShowLightbox](interfaces/ishowlightbox.md)
* [ISupportedFeatures](interfaces/isupportedfeatures.md)
* [ISupportedFeaturesRequest](interfaces/isupportedfeaturesrequest.md)
* [IThemeInfo](interfaces/ithemeinfo.md)

### Type aliases

* [ChoiceId](#choiceid)
* [ClientEvents](#clientevents)
* [ClientMessage](#clientmessage)
* [DeprecatedIFrameSaverClientMessage](#deprecatediframesaverclientmessage)
* [DeprecatedIFrameSaverServerMessage](#deprecatediframesaverservermessage)
* [GlobalIFrameSaverClientMessage](#globaliframesaverclientmessage)
* [GlobalIFrameSaverServerMessage](#globaliframesaverservermessage)
* [IAuthoringMetadata](#iauthoringmetadata)
* [IFrameSaverClientMessage](#iframesaverclientmessage)
* [IInitInteractive](#iinitinteractive)
* [IRuntimeMetadata](#iruntimemetadata)
* [IShowModal](#ishowmodal)
* [IframePhoneServerMessage](#iframephoneservermessage)
* [IframeSaverServerMessage](#iframesaverservermessage)
* [InitInteractiveMode](#initinteractivemode)
* [InteractiveAuthoredId](#interactiveauthoredid)
* [InteractiveRuntimeId](#interactiveruntimeid)
* [ServerMessage](#servermessage)

### Functions

* [addAuthoredStateListener](#addauthoredstatelistener)
* [addGlobalInteractiveStateListener](#addglobalinteractivestatelistener)
* [addInteractiveStateListener](#addinteractivestatelistener)
* [getAuthInfo](#getauthinfo)
* [getAuthoredState](#getauthoredstate)
* [getClient](#getclient)
* [getFirebaseJWT](#getfirebasejwt)
* [getGlobalInteractiveState](#getglobalinteractivestate)
* [getInitInteractiveMessage](#getinitinteractivemessage)
* [getInteractiveState](#getinteractivestate)
* [inIframe](#iniframe)
* [removeAuthoredStateListener](#removeauthoredstatelistener)
* [removeGlobalInteractiveStateListener](#removeglobalinteractivestatelistener)
* [removeInteractiveStateListener](#removeinteractivestatelistener)
* [setAuthoredState](#setauthoredstate)
* [setGlobalInteractiveState](#setglobalinteractivestate)
* [setHeight](#setheight)
* [setHint](#sethint)
* [setInIframe](#setiniframe)
* [setInteractiveState](#setinteractivestate)
* [setNavigation](#setnavigation)
* [setSupportedFeatures](#setsupportedfeatures)
* [useAuthoredState](#useauthoredstate)
* [useGlobalInteractiveState](#useglobalinteractivestate)
* [useInitMessage](#useinitmessage)
* [useInteractiveState](#useinteractivestate)

---

## Type aliases

<a id="choiceid"></a>

###  ChoiceId

**Ƭ ChoiceId**: *`string` \| `number`*

*Defined in [types.ts:221](../../lara-typescript/src/interactive-api-client/types.ts#L221)*

___
<a id="clientevents"></a>

###  ClientEvents

**Ƭ ClientEvents**: *"interactiveStateUpdated" \| "globalInteractiveStateUpdated" \| "authoredStateUpdated" \| "initInteractive"*

*Defined in [types.ts:176](../../lara-typescript/src/interactive-api-client/types.ts#L176)*

___
<a id="clientmessage"></a>

###  ClientMessage

**Ƭ ClientMessage**: *[DeprecatedIFrameSaverClientMessage](#deprecatediframesaverclientmessage) \| [IFrameSaverClientMessage](#iframesaverclientmessage) \| [GlobalIFrameSaverClientMessage](#globaliframesaverclientmessage)*

*Defined in [types.ts:172](../../lara-typescript/src/interactive-api-client/types.ts#L172)*

___
<a id="deprecatediframesaverclientmessage"></a>

###  DeprecatedIFrameSaverClientMessage

**Ƭ DeprecatedIFrameSaverClientMessage**: *"setLearnerUrl"*

*Defined in [types.ts:169](../../lara-typescript/src/interactive-api-client/types.ts#L169)*

___
<a id="deprecatediframesaverservermessage"></a>

###  DeprecatedIFrameSaverServerMessage

**Ƭ DeprecatedIFrameSaverServerMessage**: *"getLearnerUrl" \| "loadInteractive"*

*Defined in [types.ts:170](../../lara-typescript/src/interactive-api-client/types.ts#L170)*

___
<a id="globaliframesaverclientmessage"></a>

###  GlobalIFrameSaverClientMessage

**Ƭ GlobalIFrameSaverClientMessage**: *"interactiveStateGlobal"*

*Defined in [types.ts:164](../../lara-typescript/src/interactive-api-client/types.ts#L164)*

___
<a id="globaliframesaverservermessage"></a>

###  GlobalIFrameSaverServerMessage

**Ƭ GlobalIFrameSaverServerMessage**: *"loadInteractiveGlobal"*

*Defined in [types.ts:165](../../lara-typescript/src/interactive-api-client/types.ts#L165)*

___
<a id="iauthoringmetadata"></a>

###  IAuthoringMetadata

**Ƭ IAuthoringMetadata**: *[IAuthoringOpenResponseMetadata](interfaces/iauthoringopenresponsemetadata.md) \| [IAuthoringInteractiveMetadata](interfaces/iauthoringinteractivemetadata.md) \| [IAuthoringMultipleChoiceMetadata](interfaces/iauthoringmultiplechoicemetadata.md)*

*Defined in [types.ts:245](../../lara-typescript/src/interactive-api-client/types.ts#L245)*

___
<a id="iframesaverclientmessage"></a>

###  IFrameSaverClientMessage

**Ƭ IFrameSaverClientMessage**: *"interactiveState" \| "height" \| "hint" \| "getAuthInfo" \| "supportedFeatures" \| "navigation" \| "getFirebaseJWT" \| "authoredState" \| "authoringMetadata" \| "runtimeMetadata" \| "authoringCustomReportFields" \| "runtimeCustomReportValues" \| "showModal" \| "closeModal" \| "getInteractiveList" \| "setLinkedInteractives" \| "getLibraryInteractiveList" \| "getInteractiveSnapshot"*

*Defined in [types.ts:132](../../lara-typescript/src/interactive-api-client/types.ts#L132)*

___
<a id="iinitinteractive"></a>

###  IInitInteractive

**Ƭ IInitInteractive**: *[IRuntimeInitInteractive](interfaces/iruntimeinitinteractive.md)<`InteractiveState`, `AuthoredState`, `GlobalInteractiveState`> \| [IAuthoringInitInteractive](interfaces/iauthoringinitinteractive.md)<`AuthoredState`> \| [IReportInitInteractive](interfaces/ireportinitinteractive.md)<`InteractiveState`, `AuthoredState`> \| [IDialogInitInteractive](interfaces/idialoginitinteractive.md)<`InteractiveState`, `AuthoredState`, `DialogState`>*

*Defined in [types.ts:95](../../lara-typescript/src/interactive-api-client/types.ts#L95)*

___
<a id="iruntimemetadata"></a>

###  IRuntimeMetadata

**Ƭ IRuntimeMetadata**: *[IRuntimeInteractiveMetadata](interfaces/iruntimeinteractivemetadata.md) \| [IRuntimeMultipleChoiceMetadata](interfaces/iruntimemultiplechoicemetadata.md)*

*Defined in [types.ts:260](../../lara-typescript/src/interactive-api-client/types.ts#L260)*

___
<a id="ishowmodal"></a>

###  IShowModal

**Ƭ IShowModal**: *[IShowAlert](interfaces/ishowalert.md) \| [IShowLightbox](interfaces/ishowlightbox.md) \| [IShowDialog](interfaces/ishowdialog.md)*

*Defined in [types.ts:301](../../lara-typescript/src/interactive-api-client/types.ts#L301)*

___
<a id="iframephoneservermessage"></a>

###  IframePhoneServerMessage

**Ƭ IframePhoneServerMessage**: *"hello"*

*Defined in [types.ts:167](../../lara-typescript/src/interactive-api-client/types.ts#L167)*

___
<a id="iframesaverservermessage"></a>

###  IframeSaverServerMessage

**Ƭ IframeSaverServerMessage**: *"authInfo" \| "getInteractiveState" \| "initInteractive" \| "firebaseJWT" \| "closedModal" \| "customMessage" \| "interactiveList" \| "libraryInteractiveList" \| "interactiveSnapshot" \| "contextMembership"*

*Defined in [types.ts:152](../../lara-typescript/src/interactive-api-client/types.ts#L152)*

___
<a id="initinteractivemode"></a>

###  InitInteractiveMode

**Ƭ InitInteractiveMode**: *"runtime" \| "authoring" \| "report" \| "dialog"*

*Defined in [types.ts:101](../../lara-typescript/src/interactive-api-client/types.ts#L101)*

___
<a id="interactiveauthoredid"></a>

###  InteractiveAuthoredId

**Ƭ InteractiveAuthoredId**: *`string`*

*Defined in [types.ts:56](../../lara-typescript/src/interactive-api-client/types.ts#L56)*

___
<a id="interactiveruntimeid"></a>

###  InteractiveRuntimeId

**Ƭ InteractiveRuntimeId**: *`string`*

*Defined in [types.ts:48](../../lara-typescript/src/interactive-api-client/types.ts#L48)*

___
<a id="servermessage"></a>

###  ServerMessage

**Ƭ ServerMessage**: *[IframePhoneServerMessage](#iframephoneservermessage) \| [DeprecatedIFrameSaverServerMessage](#deprecatediframesaverservermessage) \| [IframeSaverServerMessage](#iframesaverservermessage) \| [GlobalIFrameSaverServerMessage](#globaliframesaverservermessage)*

*Defined in [types.ts:181](../../lara-typescript/src/interactive-api-client/types.ts#L181)*

___

## Functions

<a id="addauthoredstatelistener"></a>

### `<Const>` addAuthoredStateListener

▸ **addAuthoredStateListener**<`AuthoredState`>(listener: *`function`*): `void`

*Defined in [api.ts:115](../../lara-typescript/src/interactive-api-client/api.ts#L115)*

**Type parameters:**

#### AuthoredState 
**Parameters:**

| Name | Type |
| ------ | ------ |
| listener | `function` |

**Returns:** `void`

___
<a id="addglobalinteractivestatelistener"></a>

### `<Const>` addGlobalInteractiveStateListener

▸ **addGlobalInteractiveStateListener**<`GlobalInteractiveState`>(listener: *`function`*): `void`

*Defined in [api.ts:124](../../lara-typescript/src/interactive-api-client/api.ts#L124)*

**Type parameters:**

#### GlobalInteractiveState 
**Parameters:**

| Name | Type |
| ------ | ------ |
| listener | `function` |

**Returns:** `void`

___
<a id="addinteractivestatelistener"></a>

### `<Const>` addInteractiveStateListener

▸ **addInteractiveStateListener**<`InteractiveState`>(listener: *`function`*): `void`

*Defined in [api.ts:106](../../lara-typescript/src/interactive-api-client/api.ts#L106)*

**Type parameters:**

#### InteractiveState 
**Parameters:**

| Name | Type |
| ------ | ------ |
| listener | `function` |

**Returns:** `void`

___
<a id="getauthinfo"></a>

### `<Const>` getAuthInfo

▸ **getAuthInfo**(): `Promise`<[IAuthInfo](interfaces/iauthinfo.md)>

*Defined in [api.ts:70](../../lara-typescript/src/interactive-api-client/api.ts#L70)*

**Returns:** `Promise`<[IAuthInfo](interfaces/iauthinfo.md)>

___
<a id="getauthoredstate"></a>

### `<Const>` getAuthoredState

▸ **getAuthoredState**<`AuthoredState`>(): `AuthoredState` \| `null`

*Defined in [api.ts:30](../../lara-typescript/src/interactive-api-client/api.ts#L30)*

**Type parameters:**

#### AuthoredState 

**Returns:** `AuthoredState` \| `null`

___
<a id="getclient"></a>

### `<Const>` getClient

▸ **getClient**(): `Client`

*Defined in [client.ts:18](../../lara-typescript/src/interactive-api-client/client.ts#L18)*

**Returns:** `Client`

___
<a id="getfirebasejwt"></a>

### `<Const>` getFirebaseJWT

▸ **getFirebaseJWT**(options: *[IGetFirebaseJwtOptions](interfaces/igetfirebasejwtoptions.md)*): `Promise`<`string`>

*Defined in [api.ts:85](../../lara-typescript/src/interactive-api-client/api.ts#L85)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| options | [IGetFirebaseJwtOptions](interfaces/igetfirebasejwtoptions.md) |

**Returns:** `Promise`<`string`>

___
<a id="getglobalinteractivestate"></a>

### `<Const>` getGlobalInteractiveState

▸ **getGlobalInteractiveState**<`GlobalInteractiveState`>(): `GlobalInteractiveState` \| `null`

*Defined in [api.ts:40](../../lara-typescript/src/interactive-api-client/api.ts#L40)*

**Type parameters:**

#### GlobalInteractiveState 

**Returns:** `GlobalInteractiveState` \| `null`

___
<a id="getinitinteractivemessage"></a>

### `<Const>` getInitInteractiveMessage

▸ **getInitInteractiveMessage**<`InteractiveState`,`AuthoredState`,`DialogState`,`GlobalInteractiveState`>(): `Promise`<[IInitInteractive](#iinitinteractive)<`InteractiveState`, `AuthoredState`, `DialogState`, `GlobalInteractiveState`> \| `null`>

*Defined in [api.ts:7](../../lara-typescript/src/interactive-api-client/api.ts#L7)*

**Type parameters:**

#### InteractiveState 
#### AuthoredState 
#### DialogState 
#### GlobalInteractiveState 

**Returns:** `Promise`<[IInitInteractive](#iinitinteractive)<`InteractiveState`, `AuthoredState`, `DialogState`, `GlobalInteractiveState`> \| `null`>

___
<a id="getinteractivestate"></a>

### `<Const>` getInteractiveState

▸ **getInteractiveState**<`InteractiveState`>(): `InteractiveState` \| `null`

*Defined in [api.ts:20](../../lara-typescript/src/interactive-api-client/api.ts#L20)*

**Type parameters:**

#### InteractiveState 

**Returns:** `InteractiveState` \| `null`

___
<a id="iniframe"></a>

### `<Const>` inIframe

▸ **inIframe**(): `boolean`

*Defined in [in-frame.ts:14](../../lara-typescript/src/interactive-api-client/in-frame.ts#L14)*

**Returns:** `boolean`

___
<a id="removeauthoredstatelistener"></a>

### `<Const>` removeAuthoredStateListener

▸ **removeAuthoredStateListener**<`AuthoredState`>(listener: *`function`*): `void`

*Defined in [api.ts:119](../../lara-typescript/src/interactive-api-client/api.ts#L119)*

**Type parameters:**

#### AuthoredState 
**Parameters:**

| Name | Type |
| ------ | ------ |
| listener | `function` |

**Returns:** `void`

___
<a id="removeglobalinteractivestatelistener"></a>

### `<Const>` removeGlobalInteractiveStateListener

▸ **removeGlobalInteractiveStateListener**<`GlobalInteractiveState`>(listener: *`function`*): `void`

*Defined in [api.ts:129](../../lara-typescript/src/interactive-api-client/api.ts#L129)*

**Type parameters:**

#### GlobalInteractiveState 
**Parameters:**

| Name | Type |
| ------ | ------ |
| listener | `function` |

**Returns:** `void`

___
<a id="removeinteractivestatelistener"></a>

### `<Const>` removeInteractiveStateListener

▸ **removeInteractiveStateListener**<`InteractiveState`>(listener: *`function`*): `void`

*Defined in [api.ts:111](../../lara-typescript/src/interactive-api-client/api.ts#L111)*

**Type parameters:**

#### InteractiveState 
**Parameters:**

| Name | Type |
| ------ | ------ |
| listener | `function` |

**Returns:** `void`

___
<a id="setauthoredstate"></a>

### `<Const>` setAuthoredState

▸ **setAuthoredState**<`AuthoredState`>(newAuthoredState: *`AuthoredState`*): `void`

*Defined in [api.ts:34](../../lara-typescript/src/interactive-api-client/api.ts#L34)*

**Type parameters:**

#### AuthoredState 
**Parameters:**

| Name | Type |
| ------ | ------ |
| newAuthoredState | `AuthoredState` |

**Returns:** `void`

___
<a id="setglobalinteractivestate"></a>

### `<Const>` setGlobalInteractiveState

▸ **setGlobalInteractiveState**<`GlobalInteractiveState`>(newGlobalState: *`GlobalInteractiveState`*): `void`

*Defined in [api.ts:44](../../lara-typescript/src/interactive-api-client/api.ts#L44)*

**Type parameters:**

#### GlobalInteractiveState 
**Parameters:**

| Name | Type |
| ------ | ------ |
| newGlobalState | `GlobalInteractiveState` |

**Returns:** `void`

___
<a id="setheight"></a>

### `<Const>` setHeight

▸ **setHeight**(height: *`number` \| `string`*): `void`

*Defined in [api.ts:58](../../lara-typescript/src/interactive-api-client/api.ts#L58)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| height | `number` \| `string` |

**Returns:** `void`

___
<a id="sethint"></a>

### `<Const>` setHint

▸ **setHint**(height: *`string`*): `void`

*Defined in [api.ts:62](../../lara-typescript/src/interactive-api-client/api.ts#L62)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| height | `string` |

**Returns:** `void`

___
<a id="setiniframe"></a>

### `<Const>` setInIframe

▸ **setInIframe**(value: *`boolean`*): `void`

*Defined in [in-frame.ts:10](../../lara-typescript/src/interactive-api-client/in-frame.ts#L10)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| value | `boolean` |

**Returns:** `void`

___
<a id="setinteractivestate"></a>

### `<Const>` setInteractiveState

▸ **setInteractiveState**<`InteractiveState`>(newInteractiveState: *`InteractiveState` \| `null`*): `void`

*Defined in [api.ts:24](../../lara-typescript/src/interactive-api-client/api.ts#L24)*

**Type parameters:**

#### InteractiveState 
**Parameters:**

| Name | Type |
| ------ | ------ |
| newInteractiveState | `InteractiveState` \| `null` |

**Returns:** `void`

___
<a id="setnavigation"></a>

### `<Const>` setNavigation

▸ **setNavigation**(options: *[INavigationOptions](interfaces/inavigationoptions.md)*): `void`

*Defined in [api.ts:66](../../lara-typescript/src/interactive-api-client/api.ts#L66)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| options | [INavigationOptions](interfaces/inavigationoptions.md) |

**Returns:** `void`

___
<a id="setsupportedfeatures"></a>

### `<Const>` setSupportedFeatures

▸ **setSupportedFeatures**(features: *[ISupportedFeatures](interfaces/isupportedfeatures.md)*): `void`

*Defined in [api.ts:50](../../lara-typescript/src/interactive-api-client/api.ts#L50)*

**Parameters:**

| Name | Type |
| ------ | ------ |
| features | [ISupportedFeatures](interfaces/isupportedfeatures.md) |

**Returns:** `void`

___
<a id="useauthoredstate"></a>

### `<Const>` useAuthoredState

▸ **useAuthoredState**<`AuthoredState`>(): `object`

*Defined in [hooks.ts:28](../../lara-typescript/src/interactive-api-client/hooks.ts#L28)*

**Type parameters:**

#### AuthoredState 

**Returns:** `object`

___
<a id="useglobalinteractivestate"></a>

### `<Const>` useGlobalInteractiveState

▸ **useGlobalInteractiveState**<`GlobalInteractiveState`>(): `object`

*Defined in [hooks.ts:51](../../lara-typescript/src/interactive-api-client/hooks.ts#L51)*

**Type parameters:**

#### GlobalInteractiveState 

**Returns:** `object`

___
<a id="useinitmessage"></a>

### `<Const>` useInitMessage

▸ **useInitMessage**<`InteractiveState`,`AuthoredState`,`DialogState`,`GlobalInteractiveState`>(): `null` \| [IRuntimeInitInteractive](interfaces/iruntimeinitinteractive.md)<`InteractiveState`, `AuthoredState`, `GlobalInteractiveState`> \| [IAuthoringInitInteractive](interfaces/iauthoringinitinteractive.md)<`AuthoredState`> \| [IReportInitInteractive](interfaces/ireportinitinteractive.md)<`InteractiveState`, `AuthoredState`> \| [IDialogInitInteractive](interfaces/idialoginitinteractive.md)<`InteractiveState`, `AuthoredState`, `DialogState`>

*Defined in [hooks.ts:74](../../lara-typescript/src/interactive-api-client/hooks.ts#L74)*

**Type parameters:**

#### InteractiveState 
#### AuthoredState 
#### DialogState 
#### GlobalInteractiveState 

**Returns:** `null` \| [IRuntimeInitInteractive](interfaces/iruntimeinitinteractive.md)<`InteractiveState`, `AuthoredState`, `GlobalInteractiveState`> \| [IAuthoringInitInteractive](interfaces/iauthoringinitinteractive.md)<`AuthoredState`> \| [IReportInitInteractive](interfaces/ireportinitinteractive.md)<`InteractiveState`, `AuthoredState`> \| [IDialogInitInteractive](interfaces/idialoginitinteractive.md)<`InteractiveState`, `AuthoredState`, `DialogState`>

___
<a id="useinteractivestate"></a>

### `<Const>` useInteractiveState

▸ **useInteractiveState**<`InteractiveState`>(): `object`

*Defined in [hooks.ts:5](../../lara-typescript/src/interactive-api-client/hooks.ts#L5)*

**Type parameters:**

#### InteractiveState 

**Returns:** `object`

___

