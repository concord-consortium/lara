window.Plugins = {
  /****************************************************************************
   private variables to keep track of our plugins.
  ****************************************************************************/
  _pluginClasses: {},
  _plugins:[],
  _pluginLabels:[],

  _pluginError: function(e, other) {
    console.group('LARA Plugin Error');
    console.error(e);
    console.dir(other);
    console.groupEnd();
  },

  /**************************************************************
  @function initPlugin
  This method is called to initialize the external scripts
  Called at runtime by LARA to create an instance of the plugin
  as would happen in `views/plugin/_show.html.haml`
  @arg {string} label - the the script identifier.
  @arg {IRuntimContext} runtimeContext - context for the plugin

  // Its likely we dont need most of these context values. TBD.
  Interface IRuntimeContext {
    name: string;         // Name of the plugin
    url: string;          // Url from which the plugin was loaded
    pluginId: string;     // Active record ID of the plugin scope id
    authorData: string;   // The authored configuration for this instance
    learnerData: string;  // The saved learner data for this instance
    div: HTMLElement;     // reserved HTMLElement for the plugin output
  }
  **************************************************************/
  initPlugin: function(label, runtimeContext) {
    var constructor = this._pluginClasses[label];
    var config = {};
    var plugin = null;
    if (typeof constructor === 'function') {
      try {
        plugin = new constructor(runtimeContext);
        this._plugins.push(plugin);
        this._pluginLabels.push(label);
        plugin.__LaraPluginContext = runtimeContext;
      }
      catch(e) {
        this._pluginError(e, runtimeContext);
      }
      console.log('Plugin', label, 'is now registered');
    }
    else {
      console.error('No plugin registered for label:', label);
    }
  },


  /**************************************************************
   @function register
   Register a new external script as `label` with `_class `
   @arg label - the identifier of the script
   @arg Class - the Plugin Class being associated with the identifier
   @example: `Plugins.register('debugger', Dubugger)`
   **************************************************************/
  registerPlugin: function(label, _class) {
    if (typeof _class !== 'function') {
      return;
    }
    if(this._pluginClasses[label]) {
      console.error('Duplicate Plugin for label', label);
    } else {
      this._pluginClasses[label] = _class;
    }
  }
};
