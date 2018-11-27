ExternalScripts = {
  _classes: {},
  _scripts:[],
  _script_labels:[]
};

ExternalScripts._notRegistered = function(label) {
  console.error("No external script registered for " + label);
};

ExternalScripts._externalScriptError = function(e, other) {
  console.group("External Script Error");
  console.error(e);
  console.dir(other);
  console.groupEnd();
};

/**************************************************************
@function init
This method is called to initialize the external scripts
Called from the LARA partial `_lightweight.html.haml`
@arg {string} label - the the script identifier.
@arg {any} ctx - context object {} for the script, includes
      scriptLabel -- same as label above
      scriptUrl -- where the script was loaded from.
      embeddableId -- the embeddableId of the script.
      config -- author configuration.
**************************************************************/
ExternalScripts.init = function(_label, ctx) {
  var constructor = this._classes[_label];
  var config = {};
  var script = null;
  if (typeof constructor == 'function') {
    try {
      if (typeof ctx.config == 'string'){
        config = JSON.parse(ctx.config);
        delete ctx.config;
      }
      script = new constructor(config, ctx);
      this._scripts.push(script);
      this._script_labels.push(_label);
    }
    catch(e) {
      this._externalScriptError(e, ctx);
    }
  }
  else {
    this._notRegistered(_label);
  }
}

/**************************************************************
 @function register
 Register a new external script as `label` with `_class `
 @arg label - the identifier of the sctipt
 @arg Class - the Plugin Class being associated with the identifier
 @example: `ExternalScripts.register('debugger', Dubugger)`
 **************************************************************/
ExternalScripts.register = function(_label, _class) {
  if(typeof _class == 'function') {
    if(this._classes[_label]) {
      console.error("Duplicate script constructor for label " + _label);
    }
    else {
      this._classes[_label] = _class;
    }
  }
};

ExternalScripts.nameForScript = function(script) {
  return(script.name || "(unknown)");
}


/**************************************************************
 @function try
 @arg {string} functionName - name of the function to invoke
 @arg {any[]} args - remaining arguments
 @example `ExternalScripts.try('handleEvent', evt, logger)`
 **************************************************************/
ExternalScripts.try = function() {
  // Convert arguments to an array we can safely manipulate:
  // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/arguments
  var args = (arguments.length === 1 ? [arguments[0]] : Array.apply(null, arguments));
  var funcName = args.shift();
  for(var i=0; i < this._scripts.length; i++) {
    var script = this._scripts[i];
    var name = this.nameForScript(script);
    try {
      if(typeof script[funcName] == 'function') {
        // script[funcName].apply(script,args) was insufficient …
        script[funcName].bind(script).apply(script,args);
      }
    }
    catch (exception) {
      this._externalScriptError(exception, {name: name, funcName: funcName});
    }
  }
}

/**************************************************************
 @function handleLogEvent
 Tell registered scripts to invoke `handleLogEvent` if they can.
 *******************************************************~*******/
ExternalScripts.handleLogEvent = function(evt, logger) {
  this.try('handleEvent', evt, logger);
};
