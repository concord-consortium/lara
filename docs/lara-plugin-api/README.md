[@concord-consortium/lara-plugin-api - v3.2.0](README.md) › [Globals](globals.md)

# @concord-consortium/lara-plugin-api - v3.2.0

## [API documentation](globals.md)

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
LARAPluginAPI.registerPlugin({ runtimeClass: TestPlugin, authoringClass: TestAuthoringPlugin });
// (...)
LARAPluginAPI.addSidebar({ content: "test sidebar" });
// etc.
```

If you do not wish to implement gui authoring mode you can omit the authoringClass in the `registerPlugin` call:

```typescript
LARAPluginAPI.registerPlugin({ runtimeClass: TestPlugin });
```

and then set `"guiAuthoring": false` in the manifest.json for each component of the plugin.  Currently only the [model feedback](https://github.com/concord-consortium/model-feedback) plugin is the only V3 plugin that does not support gui authoring.

#### Plugin manifests

To limit the information need to install a plugin in LARA and to support a flexible and extensible plugin authoring system plugins use a file named `manifest.json` to expose their behavior and settings.  The `manifest` part of the filename is a convention, but it must end in `.json`.  The approved scripts CRUD interface in Lara reads these manifest files to automatically set the form fields and to store the `authoring_metadata` as a serialized json string.  The `authoring_metadata` is then used at authoring time by Lara to determine where to place the plugin, either at the activity, embeddable or embeddable-decoration level.

The `url` field can either be a fully qualified url or a relative one.  Lara automatically converts relative urls to full qualified urls using the path to the manifest file as the start of the relative path.

The `guiPreview` field is used by Lara to enable preview of the decorated embeddable when authoring embeddable-decoration plugins.

```json
{
  "name": "Test Plugin",
  "label": "testPlugin",
  "url": "plugin.js",
  "version": 3,
  "description": "This plugin provides an example manifest.json",
  "authoring_metadata": {
    "components": [
      {
        "label": "activity-component",
        "name": "Activity Level",
        "scope": "activity",
        "guiAuthoring": true
      },
      {
        "label": "embeddable-component",
        "name": "Embeddable Level",
        "scope": "embeddable",
        "guiAuthoring": true
      },
      {
        "label": "embeddable-decoration-component",
        "name": "Embeddable Decoration Level",
        "scope": "embeddable-decoration",
        "decorates": [
          "Embeddable::MultipleChoice",
          "Embeddable::OpenResponse",
          "MwInteractive",
          "ImageInteractive",
          "VideoInteractive"
        ],
        "guiAuthoring": true,
        "guiPreview": true
      }
    ]
  }
}
```

#### Plugin implementation

The LARA Plugin is divided into two regular JavaScript classes (or constructors), the runtime and authoring classes.
There are no special requirements regarding their interfaces at the moment, but it's a subject to change.
Always check the [IPlugin](interfaces/iplugin.md) interface first.

Once the two JavaScript classes are defined the plugin script should call [registerPlugin](#registerplugin) to register the classes with LARA.
The plugin will be initialized by LARA automatically when needed once it is registered. LARA calls its constructor and provides the runtime context
object. The plugin constructor should expect [IPluginRuntimeContext](interfaces/ipluginruntimecontext.md) instance as the only
argument.

Example:
```typescript
class TestPlugin {
  constructor(context: IPluginRuntimeContext) {
    console.log("Test Runtime Plugin initialized, id:", context.pluginId);
  }
}

class TestAuthoringPlugin {
  constructor(context: IPluginAuthoringContext) {
    console.log("Test Authoring Plugin initialized, id:", context.pluginId);
  }
}

LARAPluginAPI.registerPlugin({runtimeClass: TestPlugin, authoringClass: TestAuthoringPlugin});
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
