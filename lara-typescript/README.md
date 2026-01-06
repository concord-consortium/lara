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

### LARA Interactive API

The LARA Interactive API lives in the `interactive-api-client` directory. This API is exposed to interactive developers.
Code organization and documentation is similar in many ways to LARA Plugin API. It is published to NPM as `@concord-consortium/lara-interactive-api`.

To facilitate testing local changes to the `lara-interactive-api` with existing clients:

```
cd lara-typescript
npm run lara-api:link     # creates a global symlink for clients to link to
cd [the client you want to test (e.g. concord-consortium/question-interactives)]
npm link @concord-consortium/lara-interactive-api
```

Note that for local changes to the interactive API to take effect you must build locally after making changes:

```
cd lara-typescript
npm run build
```

To unlink:

```
cd [the client you were testing]
npm unlink --no-save @concord-consortium/lara-interactive-api
npm install               # to restore the use of the published version
cd lara-typescript
npm run lara-api:unlink   # removes the global symlink
```

You can list the current links using:

```
npm run list:links
```

#### Publishing LARA Interactive API package to NPM

If you update LARA Interactive API, remember to bump the version number following semver in
[src/interactive-api-client/package.json](src/interactive-api-client/package.json)
and publish a new version to NPM:

```
publish:interactive-api-client
```

To publish a pre-release for testing, append `-pre.X` (e.g., `1.2.3-pre.1`) to the version number, and use:

```
publish:interactive-api-client:beta
```

Check [src/interactive-api-client/README.md](src/interactive-api-client/README.md) to see how to use this package in external plugins.


### Code that is used by LARA internals

Other API that is meant to be used by LARA itself is exposed to global/window object under `LARA` namespace.

Old-style LARA code (usually HAML pages or some CoffeeScript files) can reference `LARA.Plugins`, `LARA.Events`,
`LARA.InteractiveAPI` and `LARA.PageItemAuthoring` functions directly. Note that every diretory in lara-typescript has
its own `index.ts` file. These are functions that are exported to `LARA.Plugins/Events/InteractiveAPI/etc` modules.
