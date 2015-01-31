function Logger(options) {
  this._server      = options.server;
  this._defaultData = options.defaultData;
}

Logger.prototype.log = function(data) {
  if (typeof(data) === 'string') {
    data = {event: data};
  }
  data.time = Math.round(Date.now() / 1000); // millisecons to seconds, server expects epoch.
  this._post(data);
};

Logger.prototype._post = function(data) {
  var processedData = this._processData(data);
  $.ajax({
    url: this._server,
    type: "POST",
    crossDomain: true,
    data: JSON.stringify(processedData),
    contentType: 'application/json'
  });
};

Logger.prototype._processData = function(data) {
  return $.extend(true, {}, this._defaultData, data);
};

(function() {
  // Logger configuration and metadata is provided in Rails controller through Gon gem.
  // See: https://github.com/gazay/gon
  var loggerConfig = window.gon && window.gon.loggerConfig;
  if (!loggerConfig) {
    // Exit if logger configuration isn't provided.
    return;
  }

  var logger = new Logger({
    server:      loggerConfig.server,
    defaultData: loggerConfig.data
  });

  switch(loggerConfig.action) {
    case 'sequences#show':
      logger.log('open sequence index');
      break;

    case 'lightweight_activities#show':
    case 'lightweight_activities#preview':
      logger.log('open activity index');
      break;

    case 'lightweight_activities#summary':
      logger.log('open activity report');
      break;

    case 'interactive_pages#show':
    case 'interactive_pages#preview':
      logger.log('open activity page');
      break;
  }
}());
