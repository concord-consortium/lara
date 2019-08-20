# LARA TypeScript codebase

### This documentation is meant to be used by LARA developers.

This package was created to let LARA developers use modern TypeScript environment and allow LARA plugin
developers to get automatic type checking in their repositories.

#### Development workflow

Basically, it's a typical TypeScript + webpack package, but embedded within LARA code base.
Before you start development, you need to install dependencies:
```
cd lara-typescript
npm install
```

Then, you can make necessary code changes and finally you need to build this project:

```
npm run build
```

You can check `package.json` to see what's being called when you run this command. Also, note that the build artifacts
are automatically copied into parent LARA directories after every build. These files need to be checked in into git
repository. At the moment, it's JavaScript bundle (`lara/src/assets/lara-typescript.js`) and automatically
generated documentation of the Plugin API (`lara/docs/lara-plugin-api`).

### LARA Plugin API

Files under `src/plugin-api` need to be treated specially. This is part of the API which is exposed to plugin developers.

#### Documentation and code structure.

This codebase uses TypeScript and [TypeDoc](https://typedoc.org/). Please follow existing patterns and document
new features using TypeDoc format. Note that that the final documentation is meant to be used by LARA plugin developers,
not LARA Plugin API developers. So, it should cover only publicly accessible functions available externally.

If you take a look at package.json `script/build:doc`, you'll notice that documentation is generated only for
`src/plugin-api/*` files, and only for exported variables. So, everything that is meant to be used by LARA plugin
developers should be placed in these directories.

If you need to some private helpers that are used by other parts of the API, they could be placed e.g. in `src/helpers`
or any other directory. That way, they won't be included in the documentation, but they can be used by the API
internally. Or, if the helper is used only by one module, it can be implemented there,
but just not exported - generated documentation skips non-exported properties and functions.

#### Publishing LARA Plugin API typings package to NPM

Note that typings generated from this code can be used by LARA plugins to provide type checking.
If you update LARA Plugin API, remember to bump version number following semver in
[src/plugin-api/package.json](src/plugin-api/package.json)
and publish a new version to NPM:

```
npm run publish:plugin-api
```

Check [src/plugin-api/README.md](src/plugin-api/README.md) to see how to use this package in external plugins.

#### Working with a locally changed plugin api

If you are making changes to the lara-plugin-api it is useful to test those changes out
with a plugin before publishing the lara-plugin-api package.  This can be done by

```
cd lara-typescript/src/plugin-api
npm link
cd [the plugin you want to test]
npm link @concord-consortium/lara-plugin-api
```

When you are done you unlink with

```
cd lara-typescript/src/plugin-api
npm unlink
cd [the plugin you want to test]
npm unlink @concord-consortium/lara-plugin-api
```

### LARA Internal API

Other code that is meant to be used by LARA itself is exposed as Internal API. It's available under global
namespace `LARA.InternalAPI` and implemented in `src/internal-api`.

Old-style LARA code can reference `LARA.InternalAPI` functions directly.
