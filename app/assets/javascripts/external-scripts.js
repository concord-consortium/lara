ExternalScripts = {
  _constructors: {},
  _scripts:[],
  _script_labels:[]
};

ExternalScripts.notRegistered = function(label) {
  console.error("No external script registered for " + label);
};

ExternalScripts.externalScriptError = function(e, other) {
  console.group("External Script Error");
  console.error(e);
  console.dir(other);
  console.groupEnd();
};

ExternalScripts.init = function(_label, ctx) {
  var constructor = this._constructors[_label];
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
      this.externalScriptError(e, ctx);
    }
  }
  else {
    this.notRegistered(_label);
  }
}

ExternalScripts.config = function(_label, ctx) {
  var constructor = this._constructors[_label];
  var script = null;
  if (typeof constructor == 'function') {
    if (typeof constructor.config == 'function'){
      try {
        script = constructor.config(ctx);
      }
      catch(e) {
        this.externalScriptError(e, ctx);
      }
    }
    else {
      console.log("No configuration for " + _label);
    }
  }
  else {
    this.notRegistered(_label);
  }
}


ExternalScripts.register = function(_label, _constructor) {
  if(typeof _constructor == 'function') {
    if(this._constructors[_label]) {
      console.error("Duplicate script constructor for label " + _label);
    }
    else {
      this._constructors[_label] = _constructor;
    }
  }
};

ExternalScripts.nameForScript = function(script) {
  return(script.name || "(unknown)");
}

ExternalScripts.try = function() {
  // Convert arguments to an array we can safely manipulate:
  // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/arguments
  const args = (arguments.length === 1 ? [arguments[0]] : Array.apply(null, arguments));
  const funcName = args.shift();
  for(var i=0; i < this._scripts.length; i++) {
    var script = this._scripts[i];
    var name = this.nameForScript(script);
    try {
      if(typeof script[funcName] == 'function') {
        // script[funcName].apply(script,args) was insufficient …
        script[funcName].bind(script).apply(script,args);
      }
      else {
        this.externalScriptError("script " + name + " doesn't respond to  " + funcName);
      }
    }
    catch (exception) {
      this.externalScriptError(exception, {name: name, funcName: funcName});
    }
  }
}

ExternalScripts.handleLogEvent = function(evt, logger) {
  this.try('handleEvent', evt, logger);
};
