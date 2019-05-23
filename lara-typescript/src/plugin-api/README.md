# LARA Plugin API

### This documentation is meant to be used by LARA Plugin developers.

#### Setup and webpack configuration

LARA API will be available under `window.LARA.PluginAPI_V3` object / namespace once the plugin is initialized by LARA. 

However, if the plugin is implemented using TypeScript, the best way to get type checking and hints in your IDE is to 
install [LARA Plugin API NPM package](https://www.npmjs.com/package/@concord-consortium/lara-plugin-api):

```
npm i --save-dev @concord-consortium/lara-plugin-api
```

Then, you need to configure [webpack externals](https://webpack.js.org/configuration/externals/), so webpack does not 
bundle Plugin API code but looks for global `window.LARA.PluginAPI_V3` object instead (and do the same for React if the 
plugin uses it).

Example of **webpack.config.js**:
```
  externals: {
    // LARA Plugin API implementation is exported to the window.LARA.PluginAPI_V3 namespace.
    '@concord-consortium/lara-plugin-api': 'LARA.PluginAPI_V3',
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


#### Plugin styling

Note that LARA Plugins will be executed in LARA context which includes a lot of different CSS styles and rules.
Sometimes it might be okay for plugin to inherit these styles and overwrite when necessary. In other cases, 
it might be useful for plugin to reset and normalize its containers, so it's less dependant on LARA styles.
Also, LARA styles obviously casue plugin content to be rendered differently in LARA and in some external 
demo or authoring pages provided by plugin.

To avoid these inconsistencies, plugins can use CSS reset/normalize helpers provided by LARA.
Reset CSS rules are simply applied to all the containers with `normalized-container` class name. 
Plugins can use this case in its top-level container, e.g.:

```javascript
render() {
  return (
    <div className="normalized-container">
      My plugin content
    </div>
  );
}
```

Also, these reset styles are part of the NPM package, so plugins can include them in demo and authoring pages 
to ensure that rendering is consistent:

```javascript
import "@concord-consortium/lara-plugin-api/normalize.css";
```
