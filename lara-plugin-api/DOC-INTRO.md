# LARA Plugin API

#### This document is meant to be used by LARA Plugin developers.

LARA Plugin is a regular JavaScript class (or constructor). There are no special requirements regarding its interface 
at the moment, but it's a subject to change. Always check [IPlugin](interfaces/iplugin.md) interface first.

The first thing that should be done by plugin script is call to [registerPlugin](#registerplugin).

Later, the Plugin will be initialized by LARA automatically. LARA calls its constructor and provide the runtime context 
object. The plugin constructor should expect [IRuntimeContext](interfaces/iruntimecontext.md) instance as the only 
argument.

Example:
```typescript
class TestPlugin {
  constructor(context: IRuntimeContext) {
    this.context = context;
    console.log('Plugin initialized');
  }
}  

LARA.registerPlugin("testPlugin", TestPlugin);
```

Plugins can use all the functions documented below to modify LARA or provide custom features.
