# LARA Interactive API

### This documentation is meant to be used by LARA interactive developers.

#### Setup and webpack configuration

The API is available under `window.LARA.InteractiveAPI` object / namespace once the plugin is initialized by LARA.

However, if the interactive is implemented using TypeScript, the best way to get type checking and hints in your IDE is to
install [LARA Plugin API NPM package](https://www.npmjs.com/package/@concord-consortium/lara-interactive-api):

```
npm i --save-dev @concord-consortium/lara-interactive-api
```

Then, you need to configure [webpack externals](https://webpack.js.org/configuration/externals/), so webpack does not
bundle the API code but looks for global `window.LARA.InteractiveAPI` object instead (and do the same for React if the
plugin uses it).

Example of **webpack.config.js**:
```
  externals: {
    // LARA Plugin API implementation is exported to the window.LARA.InteractiveAPI namespace.
    '@concord-consortium/lara-interactive-api': 'LARA.InteractiveAPI',
    // Use React and ReactDOM provided by LARA, do not bundle an own copy.
    'react': 'React',
    'react-dom': 'ReactDOM',
  }
```

Finally, you can import the API anywhere in your code and benefit from automatic type checking:

```typescript
import * as LARAInteractiveAPI from "@concord-consortium/lara-interactive-api";
// TODO: add examples
```

