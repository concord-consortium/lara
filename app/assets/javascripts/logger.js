function LoggerUtils(logger) {
  this._logger = logger;
};

LoggerUtils.instances = {};

LoggerUtils.instance = function(loggerConfig) {
  var key = JSON.stringify(loggerConfig);
  LoggerUtils.instances[key] = LoggerUtils.instances[key] || new LoggerUtils(new Logger({
    server     : loggerConfig.server,
    defaultData: loggerConfig.data
  }));
  return LoggerUtils.instances[key];
};

LoggerUtils.prototype.log = function(data) {
  this._logger.log(data);
};

LoggerUtils.submittedQuestionLogging = function(data,autoSave) {
  var loggerConfig = window.gon && window.gon.loggerConfig;
  if (!loggerConfig) {
    return;
  };

  var logger_utils = LoggerUtils.instance(loggerConfig);
  logger_utils._submittedQuestionLogging(data,autoSave);
};

LoggerUtils.logInteractiveEvents = function(iframe){
  var loggerConfig = window.gon && window.gon.loggerConfig;
  if (!loggerConfig) {
    return;
  };

  var logger_utils = LoggerUtils.instance(loggerConfig);
  logger_utils._logInteractiveEventsRPCFormat($(iframe)[0]);
  logger_utils._logInteractiveEvents($(iframe)[0]);
};

LoggerUtils.enableLabLogging = function(iframeEl) {
  // WARNING: old logging format, not necessary in Lab >= 1.9.0
  // TODO: remove when Lab 1.9.0 is released
  var labRpc = LARA.InteractiveAPI.IframePhoneManager.getRpcEndpoint(iframeEl, 'lara-logging');
  labRpc.call({message: 'lara-logging-present'});
};

LoggerUtils.prototype.sequenceIndexLogging = function() {
  this._logger.log('open sequence index');
};

LoggerUtils.prototype.activityIndexLogging = function() {
  this._logger.log('open activity index');
};

LoggerUtils.prototype.interactivePageLogging = function(action) {
  this._logger.log('open activity page');
  this._interactiveSimulationLogging();
};

LoggerUtils.prototype.activitySummaryLogging = function() {
  this._logger.log('open activity report');
};
LoggerUtils.pageExitLogging = function() {
  var loggerConfig = window.gon && window.gon.loggerConfig;
  if (!loggerConfig) {
    return;
  }

  var logger_utils = LoggerUtils.instance(loggerConfig);
  logger_utils._pageExitLogging();
};
LoggerUtils.prototype._pageExitLogging = function() {
  this._logger.log('exit page');
};

LoggerUtils.prototype._getQuestionType = function(action) {
  if (action.indexOf("multiple_choice_answer") != -1) {
    return "multiple_choice_answer";
  } else if (action.indexOf("open_response_answer") != -1) {
    return "open_response_answer";
  } else if (action.indexOf("image_question_answer") != -1) {
    return "image_question_answer";
  } else return "embeddable_question";
};

LoggerUtils.prototype._submittedQuestionLogging = function(data,autoSave) {
  var data_object                = autoSave ? {event: 'answer saved'} : {event : 'submit answer'},
      question_type              = this._getQuestionType(data),
      question_id                = data.split('_').slice(-1)[0];

  data_object[question_type] = question_id;
  this._logger.log(data_object);
};

LoggerUtils.prototype._interactiveSimulationLogging = function() {
  // work around for bindig click event on cross site iframe
  var self  = this;
  $(window).on('blur', function() {
    $.each($('.interactive'),function(index,value){
      if ($(value).data().iframe_mouseover){
      	self._logger.log({
          event         : "clicked in the simulation window",
          interactive_id: $(value).data().id
        });
      }
    });
  });
  $('.interactive').on('mouseover', function() {
    $(this).data().iframe_mouseover = true;
  });
  $('.interactive').on('mouseout', function() {
    $(this).data().iframe_mouseover = false;
  });
};

// WARNING: old logging format, not necessary in Lab >= 1.9.0
// TODO: remove when Lab 1.9.0 is released
LoggerUtils.prototype._logInteractiveEventsRPCFormat = function(iframe) {

  var handler = function(cmd) {
    var str;
    var index;
    var eventName;
    var eventValue;
    var parameters;

    if (cmd && cmd.action === 'logAction' && cmd.args) {
      str = cmd.args.formatStr;

      index = str.indexOf(':');

      if (index >= 0) {
        eventName = str.slice(0, index);
        eventValue = str.slice(index + 1);
        try {
          parameters = JSON.parse(eventValue);
        } catch (e) {
          // noop
        }
      } else {
        eventName = str;
      }

      this._logger.log({
        event: eventName,
        event_value: eventValue,
        parameters: parameters,
        interactive_id: $(iframe).data().id,
        interactive_url: iframe.src
      });
    }
  }.bind(this);

  // Setup handler for incoming logs.
  LARA.InteractiveAPI.IframePhoneManager.getRpcEndpoint(iframe, 'lara-logging').handler = handler;
  // Notify Lab that logging is supported.
  LoggerUtils.enableLabLogging(iframe);
};

LoggerUtils.prototype._logInteractiveEvents = function(iframe) {
  var phone = LARA.InteractiveAPI.IframePhoneManager.getPhone(iframe);
  phone.addListener('log', function (content) {
    this._logger.log({
      event: content.action,
      event_value: content.value,
      parameters: content.data,
      interactive_id: $(iframe).data().id,
      interactive_url: iframe.src
    });
  }.bind(this));
};

function Logger(options) {
  this._server = options.server;
  this._defaultData = options.defaultData;
  this._eventQueue = [];
}


Logger.prototype.log = function(data) {
  if (typeof(data) === 'string') {
    data = {event: data};
  }
  data.time = Date.now(); // millisecons
  if (( typeof ExternalScripts != "undefined") && ExternalScripts.handleLogEvent) {
    ExternalScripts.handleLogEvent(data, this);
  };
  this._emitEvent(data);
  this._post(data);
};

Logger.prototype._emitEvent = function(data) {
  if (this._canEmitEvent()) {
    this._drainEventQueue();
    window.LARA.Events.emitLog(data);
  }
  else {
    // if it is not yet available, queue the data until it is available
    this._eventQueue.push(data);
    this._waitToDrainEventQueue();
  }
}

Logger.prototype._canEmitEvent = function() {
   // window.LARA.Events.emitLog is defined in lara-typescript and may not be available yet
   return !!(window.LARA && window.LARA.Events && window.LARA.Events.emitLog);
}

Logger.prototype._waitToDrainEventQueue = function () {
  if (this._canEmitEvent()) {
    this._drainEventQueue();
  }
  else {
    setTimeout(this._waitToDrainEventQueue.bind(this), 1);
  }
}

Logger.prototype._drainEventQueue = function () {
  if (this._eventQueue.length > 0) {
    this._eventQueue.forEach(function (item) {
      window.LARA.Events.emitLog(item);
    })
    this._eventQueue = [];
  }
}

Logger.prototype._post = function(data) {
  var processedData = this._processData(data);
  $.ajax({
    url        : this._server,
    type       : "POST",
    crossDomain: true,
    data       : JSON.stringify(processedData),
    contentType: 'application/json'
    });
};

Logger.prototype._processData = function(data) {
  return $.extend(true, {}, this._defaultData, data);
};

var EmbeddableQuestionsLogging = function(question) {
  var loggerConfig = window.gon && window.gon.loggerConfig;
  if (!loggerConfig) {
    return;
  }

  this.question_type   = question.type;
  this.question_id     = question.id;
  this.question_dom_id = question.dom_id;

  this._logger = new Logger({
    server     : loggerConfig.server,
    defaultData: loggerConfig.data
  });

  this.bind_logger();
};

EmbeddableQuestionsLogging.prototype._generateQuestionData = function(event_type) {
  data                     = {};
  data['event']            = event_type;
  data[this.question_type] = this.question_id;
  return data;
};

EmbeddableQuestionsLogging.prototype.bind_logger = function() {
  var self     = this,
      focus_in = false;
  $("#" + this.question_dom_id).off('mousedown.logging').on('mousedown.logging',function(event){
    $(this).off('focusout.logging');
  });
  $("#" + this.question_dom_id).off('mouseup.logging').on('mouseup.logging',function(event){
    $(event.target).focus();
  });
  $("#" + this.question_dom_id).off('focusin.logging').on('focusin.logging', function(event) {
    if(!focus_in){
      self._logger.log(self._generateQuestionData('focus in'));
    }
    $(this).off('focusout.logging').on('focusout.logging', function(event) {
      self._logger.log(self._generateQuestionData('focus out'));
      $(this).off('focusout.logging');
      focus_in = false;
    });
    focus_in = true;
  });
};

// Logger configuration and metadata is provided in Rails controller through Gon gem.
// See: https://github.com/gazay/gon
var loggerConfig = window.gon && window.gon.loggerConfig;
if (loggerConfig) {
  var loggerUtils = LoggerUtils.instance(loggerConfig);

  switch (loggerConfig.action) {
    case 'sequences#show':
      loggerUtils.sequenceIndexLogging();
      break;

    case 'lightweight_activities#show':
    case 'lightweight_activities#preview':
      loggerUtils.activityIndexLogging();
      break;

    case 'lightweight_activities#summary':
      loggerUtils.activitySummaryLogging();
      break;

    case 'interactive_pages#show':
    case 'interactive_pages#preview':
    case 'lightweight_activities#single_page':
      loggerUtils.interactivePageLogging();
      break;
  }
  window.loggerUtils = loggerUtils;
}
