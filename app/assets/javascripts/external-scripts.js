ExternalScripts = { _scripts: [] };

ExternalScripts.register = function(_constructor, env) {
  try {
    var config = {};
    if (typeof env.config == 'string'){
      config = JSON.parse(env.config);
      delete env.config;
    };
    var script = new _constructor(config, env);
    this._scripts.push(script);
    console.group("ExternalScripts: Register");
      console.dir(env);
      console.dir(config);
    console.groupEnd();
  }
  catch(e) {
    console.group("External Script Error");
    console.error(e);
    console.groupEnd();
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
        console.error("script " + name + " doesn't respond to  " + funcName);
      }
    }
    catch (exception) {
      console.error("Error calling " + funcName + " on "+ name);
      console.error(exception);
    }
  }
}

ExternalScripts.handleLogEvent = function(evt, logger) {
  this.try('handleEvent', evt, logger);
};
