# LARA Plugin API

### This documentation is meant to be used by LARA Plugin API developers.

This package was created to let LARA Plugin API developers use modern TypeScript environment and allow LARA plugin 
developers to get automatic type checking in their repositories.

#### API development workflow

Basically, it's a typical TypeScript + webpack package, but embedded within LARA code base. 
Before you start development, you need to install dependencies:
```
cd lara-plugin-api
npm install
``` 

Then, you can make necessary code changes and finally you need to build this project:

```
npm run build
```

You can check `package.json` to see what's being called when you run this command. Also, note that the build artifacts 
are automatically copied into parent LARA directories after every build. These files need to be checked in into git 
repository. At the moment, it's JavaScript bundle (`lara/src/assets/lara-plugin-api.js`) and automatically 
generated documentation (`lara/docs/lara-plugin/api`).


#### Documentation and code structure.

This codebase uses TypeScript and [TypeDoc](https://typedoc.org/). Please follow existing patterns and document
new features using TypeDoc format. Note that that the final documentation is meant to be used by LARA plugin developers,
not LARA Plugin API developers. So, it should cover only publicly accessible functions available externally.

If you take a look at package.json `script/build:doc`, you'll notice that documentation is generated only for
`src/lara-plugin-api.ts` and `src/api/*` files, and only for exported variables. So, everything that is meant to be
used by LARA plugin developers should be placed in these directories.

If you need to some private helpers that are used by other parts of the API, they could be placed e.g. in `src/helpers`
or any other directory. That way, they won't be included in the documentation, but they can be used by the API internally.

#### Publishing package to NPM

Note that this package can used by LARA plugins to provide type checking. If you update LARA Plugin API, remember
to bump version number following semver and publish new version to NPM:

```
npm publish --access public
```
