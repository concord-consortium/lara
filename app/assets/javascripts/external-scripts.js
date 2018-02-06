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
    if (typeof ctx.config == 'string'){
      config = JSON.parse(ctx.config);
      delete ctx.config;
    };
    try {
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

ExternalScripts.try = function(funcName, arguments) {
  for(var i=0; i < this._scripts.length; i++) {
    var script = this._scripts[i];
    var name = this.nameForScript(script);
    try {
      if(typeof script[funcName] == 'function') {
        script[funcName].call(script, arguments);
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
