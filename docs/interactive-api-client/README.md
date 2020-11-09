[@concord-consortium/lara-interactive-api - v0.7.0-pre.1](README.md) › [Globals](globals.md)

# @concord-consortium/lara-interactive-api - v0.7.0-pre.1

## [API documentation](globals.md)

A TypeScript-based API for the LARA Interactive API. This also includes all the types for the API which are shared 
with the server-side Typescript files that implement the LARA-side of the API.

NOTE: this file (in /docs) is auto-generated as part of the `lara-typescript` build using [TypeDoc](https://typedoc.org/) 
by combining the API client's readme file with auto-generated output.  If you wish to edit this document please edit 
`lara-typescript/src/interactive-api-client/README.md`.

## Installation

First install the package:

`npm i --save @concord-consortium/lara-interactive-api`

Then import it into your code:

`import * as interactiveApi from "@concord-consortium/lara-interactive-api"`
or import just necessary functions:
`import { setHeight, useInteractiveState } from "@concord-consortium/lara-interactive-api"`

the API is compiled TypeScript and includes the typings in `.d.ts` files in the package.  These typings are 
automatically loaded by the TypeScript compiler so you do now need to install a separate `@types/...` package.

## Usage

### API functions

All the Interactive API helpers are exported as single functions. For example;

`import { setHeight, setHint, getAuthInfo } from "@concord-consortium/lara-interactive-api"`

Some functions might accept types, e.g. `getInteractiveState<InteractiveState>()`. When there are more types accepted,
the order of the type variables is important, it is `InteractiveState`, `AuthoredState`, `DialogState`, and 
`IGlobalInteractiveState`.  If you do wish to skip a type variable just use `{}` in its place and any type variable 
left off on the end defaults to `{}`, eg:

`const getInitInteractiveMessage<IInteractiveState, {}, {}, IGlobalInteractiveState>();`

### Hooks

If you are using React you will instead want to the use the hooks which wrap the API functions in a more easily 
used form. All the hooks start with `use` prefix. To use the hook first import it:

`import { useInteractiveState } from "@concord-consortium/lara-interactive-api"`

and then call the hook using your type variables in your React component.

Here is a minimal example of a `useInteractiveState` hook:

```
const { interactiveState, setInteractiveState } = useInteractiveState<IInteractiveState>();
...
const handleButtonClick = () => {
  // Functional update, usually safer option:
  setInteractiveState((prevState: InteractiveState) => ({ numButtonPresses: prevState.numButtonPresses + 1 }));
  // Or regular update that can cause troubles when new state is based on the previous one:
  // setInteractiveState({ numButtonPresses: interactiveState.numButtonPresses + 1 });
}
...
<button onClick={handleButtonClick}>{interactiveState.numButtonPresses}</button>
```

Calling the `setInteractiveState` method returned by the hook will both update the state held inside the hook and 
also send the message to LARA. This means that calling `setInteractiveState` will trigger a new React render of your 
components that use the `useInteractiveState` hook. 

The same applies to other state-based hooks and their setters: 
- `useAuthoredState`
- `useGlobalInteractiveState`
