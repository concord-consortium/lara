# LARA Plugin API

### This documentation is meant to be used by LARA Plugin developers.

#### Setup and webpack configuration

LARA API will be available under `window.LARA.PluginAPI` object / namespace once the plugin is initialized by LARA. 

However, if the plugin is implemented using TypeScript, the best way to get type checking and hints in your IDE is to 
install [LARA Plugin API NPM package](https://www.npmjs.com/package/@concord-consortium/lara-plugin-api):

```
npm i --save-dev @concord-consortium/lara-plugin-api
```

Then, you need to configure [webpack externals](https://webpack.js.org/configuration/externals/), so webpack does not 
bundle Plugin API code but looks for global `window.LARA.PluginAPI` object instead (and do the same for React if the 
plugin uses it).

Example of **webpack.config.js**:
```
  externals: {
    // LARA Plugin API implementation is exported to the window.LARA.PluginAPI namespace.
    '@concord-consortium/lara-plugin-api': 'LARA.PluginAPI',
    // Use React and ReactDOM provided by LARA, do not bundle an own copy.  
    'react': 'React',
    'react-dom': 'ReactDOM',
  }
```

Finally, you can import LARA Plugin API anywhere in your code and benefit from automatic type checking:

```typescript
import * as LARAPluginAPI from "@concord-consortium/lara-plugin-api";
// (...)
LARAPluginAPI.registerPlugin("test", Test);
// (...)
LARAPluginAPI.addSidebar({ content: "test sidebar" });
// etc.
```

#### Plugin implementation

LARA Plugin is a regular JavaScript class (or constructor). There are no special requirements regarding its interface 
at the moment, but it's a subject to change. Always check [IPlugin](interfaces/iplugin.md) interface first.

The first thing that should be done by plugin script is call to [registerPlugin](#registerplugin).

The Plugin will be initialized by LARA automatically. LARA calls its constructor and provides the runtime context 
object. The plugin constructor should expect [IPluginRuntimeContext](interfaces/ipluginruntimecontext.md) instance as the only 
argument.

Example:
```typescript
class TestPlugin {
  constructor(context: IPluginRuntimeContext) {
    console.log("Plugin initialized, id:", context.pluginId);
  }
}  

LARAPluginAPI.registerPlugin("testPlugin", TestPlugin);
```

[registerPlugin](#registerplugin) should be called only once, but note that LARA might instantiate multiple instances
of the same plugin (e.g. if the activity author adds multiple plugin instances to a page).

Plugins can use all the functions documented below to modify LARA runtime or provide custom features. This documentation
is generated automatically from TypeScript definitions and comments.
