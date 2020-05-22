
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

const client = new LaraInteractiveApi.Client<IAuthoredState, IInteractiveState, IGlobalInteractiveState>({
  supportedFeatures: {
    authoredState: true,
    interactiveState: true,
    aspectRatio: 1
  },

  onGetInteractiveState: () => ({ numButtonPresses: this.state.clicks })
})

...

const handleButtonClick = () => this.setState({ clicks: this.state.clicks + 1 });

...

<button onClick={handleButtonClick}>{this.state.clicks}</button>
```

Note: the order of the type variables is important, it is `InteractiveState`, `AuthoredState`, and `IGlobalInteractiveState`. If you do wish to skip a type variable just use `{}` in its place and any type variable left off on the end defaults to `{}`, eg:

`const client = new LaraInteractiveApi.Client<IInteractiveState, {}, IGlobalInteractiveState>({ ...`

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
const { interactiveState, setInteractiveState } = useLaraInteractiveApi<IAuthoredState, IInteractiveState, IGlobalInteractiveState>({
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

### Classes

* [Client](classes/client.md)

### Interfaces

* [IAuthInfo](interfaces/iauthinfo.md)
* [IAuthoringInitInteractive](interfaces/iauthoringinitinteractive.md)
* [IClientOptions](interfaces/iclientoptions.md)
* [IFirebaseJwt](interfaces/ifirebasejwt.md)
* [IGetFirebaseJwtOptions](interfaces/igetfirebasejwtoptions.md)
* [IHookOptions](interfaces/ihookoptions.md)
* [IInteractiveStateProps](interfaces/iinteractivestateprops.md)
* [INavigationOptions](interfaces/inavigationoptions.md)
* [IReportInitInteractive](interfaces/ireportinitinteractive.md)
* [IRuntimeInitInteractive](interfaces/iruntimeinitinteractive.md)
* [ISupportedFeatures](interfaces/isupportedfeatures.md)
* [ISupportedFeaturesRequest](interfaces/isupportedfeaturesrequest.md)

### Type aliases

* [ClientMessage](#clientmessage)
* [DeprecatedIFrameSaverClientMessage](#deprecatediframesaverclientmessage)
* [DeprecatedIFrameSaverServerMessage](#deprecatediframesaverservermessage)
* [GlobalIFrameSaverClientMessage](#globaliframesaverclientmessage)
* [GlobalIFrameSaverServerMessage](#globaliframesaverservermessage)
* [IFrameSaverClientMessage](#iframesaverclientmessage)
* [IInitInteractive](#iinitinteractive)
* [IframePhoneServerMessage](#iframephoneservermessage)
* [IframeSaverServerMessage](#iframesaverservermessage)
* [InitInteractiveMode](#initinteractivemode)
* [ServerMessage](#servermessage)

### Variables

* [InIframe](#iniframe)

### Functions

* [useLaraInteractiveApi](#uselarainteractiveapi)

---

## Type aliases

<a id="clientmessage"></a>

###  ClientMessage

**Ƭ ClientMessage**: *[DeprecatedIFrameSaverClientMessage](#deprecatediframesaverclientmessage) \| [IFrameSaverClientMessage](#iframesaverclientmessage) \| [GlobalIFrameSaverClientMessage](#globaliframesaverclientmessage)*

*Defined in [types.ts:23](../../lara-typescript/src/interactive-api-client/types.ts#L23)*

___
<a id="deprecatediframesaverclientmessage"></a>

###  DeprecatedIFrameSaverClientMessage

**Ƭ DeprecatedIFrameSaverClientMessage**: *"setLearnerUrl"*

*Defined in [types.ts:20](../../lara-typescript/src/interactive-api-client/types.ts#L20)*

___
<a id="deprecatediframesaverservermessage"></a>

###  DeprecatedIFrameSaverServerMessage

**Ƭ DeprecatedIFrameSaverServerMessage**: *"getLearnerUrl" \| "loadInteractive"*

*Defined in [types.ts:21](../../lara-typescript/src/interactive-api-client/types.ts#L21)*

___
<a id="globaliframesaverclientmessage"></a>

###  GlobalIFrameSaverClientMessage

**Ƭ GlobalIFrameSaverClientMessage**: *"interactiveStateGlobal"*

*Defined in [types.ts:15](../../lara-typescript/src/interactive-api-client/types.ts#L15)*

___
<a id="globaliframesaverservermessage"></a>

###  GlobalIFrameSaverServerMessage

**Ƭ GlobalIFrameSaverServerMessage**: *"loadInteractiveGlobal"*

*Defined in [types.ts:16](../../lara-typescript/src/interactive-api-client/types.ts#L16)*

___
<a id="iframesaverclientmessage"></a>

###  IFrameSaverClientMessage

**Ƭ IFrameSaverClientMessage**: *"interactiveState" \| "height" \| "getAuthInfo" \| "supportedFeatures" \| "navigation" \| "getFirebaseJWT" \| "authoredState"*

*Defined in [types.ts:2](../../lara-typescript/src/interactive-api-client/types.ts#L2)*

___
<a id="iinitinteractive"></a>

###  IInitInteractive

**Ƭ IInitInteractive**: *[IRuntimeInitInteractive](interfaces/iruntimeinitinteractive.md)<`InteractiveState`, `AuthoredState`, `GlobalInteractiveState`> \| [IAuthoringInitInteractive](interfaces/iauthoringinitinteractive.md)<`AuthoredState`> \| [IReportInitInteractive](interfaces/ireportinitinteractive.md)<`InteractiveState`, `AuthoredState`>*

*Defined in [types.ts:84](../../lara-typescript/src/interactive-api-client/types.ts#L84)*

___
<a id="iframephoneservermessage"></a>

###  IframePhoneServerMessage

**Ƭ IframePhoneServerMessage**: *"hello"*

*Defined in [types.ts:18](../../lara-typescript/src/interactive-api-client/types.ts#L18)*

___
<a id="iframesaverservermessage"></a>

###  IframeSaverServerMessage

**Ƭ IframeSaverServerMessage**: *"authInfo" \| "getInteractiveState" \| "initInteractive" \| "firebaseJWT"*

*Defined in [types.ts:10](../../lara-typescript/src/interactive-api-client/types.ts#L10)*

___
<a id="initinteractivemode"></a>

###  InitInteractiveMode

**Ƭ InitInteractiveMode**: *"runtime" \| "authoring" \| "report"*

*Defined in [types.ts:89](../../lara-typescript/src/interactive-api-client/types.ts#L89)*

___
<a id="servermessage"></a>

###  ServerMessage

**Ƭ ServerMessage**: *[IframePhoneServerMessage](#iframephoneservermessage) \| [DeprecatedIFrameSaverServerMessage](#deprecatediframesaverservermessage) \| [IframeSaverServerMessage](#iframesaverservermessage) \| [GlobalIFrameSaverServerMessage](#globaliframesaverservermessage)*

*Defined in [types.ts:27](../../lara-typescript/src/interactive-api-client/types.ts#L27)*

___

## Variables

<a id="iniframe"></a>

### `<Const>` InIframe

**● InIframe**: *`boolean`* =  inIframe

*Defined in [in-frame.ts:10](../../lara-typescript/src/interactive-api-client/in-frame.ts#L10)*

___

## Functions

<a id="uselarainteractiveapi"></a>

###  useLaraInteractiveApi

▸ **useLaraInteractiveApi**<`InteractiveState`,`AuthoredState`,`GlobalInteractiveState`>(hookOptions: *[IHookOptions](interfaces/ihookoptions.md)*): `object`

*Defined in [use-api-hook.ts:6](../../lara-typescript/src/interactive-api-client/use-api-hook.ts#L6)*

**Type parameters:**

#### InteractiveState 
#### AuthoredState 
#### GlobalInteractiveState 
**Parameters:**

| Name | Type |
| ------ | ------ |
| hookOptions | [IHookOptions](interfaces/ihookoptions.md) |

**Returns:** `object`

___

