function LoggerUtils(logger) {
  this._logger = logger;
  this.iframePhoneRpcEndpoints = [];
};

LoggerUtils.instance = function(loggerConfig) {
  return new LoggerUtils(new Logger({
    server     : loggerConfig.server,
    defaultData: loggerConfig.data
  }));
};

LoggerUtils.submittedQuestionLogging = function(data) {
  var loggerConfig = window.gon && window.gon.loggerConfig;
  if (!loggerConfig) {
    return;
  };

  var logger_utils = LoggerUtils.instance(loggerConfig);
  logger_utils._submittedQuestionLogging(data);
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

LoggerUtils.prototype._submittedQuestionLogging = function(data) {
  var data_object            = {event: 'submit question'};
  question_type              = this._getQuestionType(data),
  question_id                = data.split('_').slice(-1)[0],
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

  $('.interactive').each(function() {
    // this == an iframe.interactive
    self._logInteractiveEvents(this);
  });
};

LoggerUtils.prototype._logInteractiveEvents = function(iframe) {

  var handler = function(cmd) {
    var str;
    var index;
    var eventName;
    var eventValue;
    var parameters;

    if (cmd && cmd.action === 'logAction' && cmd.args) {
      str = cmd.args.formatStr;

      index = str.indexOf(':');

      if ( index >= 0) {
        eventName = str.slice(0, index);
        eventValue = str.slice(index + 1);
        try {
          parameters = JSON.parse(eventValue);
        } catch (e) {
          // noop
        }

        this._logger.log({
          event: eventName,
          event_value: eventValue,
          parameters: parameters,
          interactive_id: $(iframe).data().id,
          interactive_url: iframe.src
        });
      }
    }
  }.bind(this);

  var iframePhoneRpc;
  for (i = 0; i < IFrameSaver.instances.length; i++) {
    instance = IFrameSaver.instances[i];
    if (instance.iframePhone.getTargetWindow() === iframe.contentWindow) {
      iframePhoneRpc = instance.iframePhoneRpc;
      // TODO: patch into call chain?
      iframePhoneRpc.handler = handler;
      break;
    }
  }

  // NOTE: in this initial form, we can reuse IframePhone instance created by
  // IFrameSaver (let's agree on caps btw?) but other code can't reuse our instances
  // (Creating >1 IframePhone instance pointed at the same iframe breaks message queuing)

  if ( ! iframePhoneRpc ) {
    iframePhoneRpc = new iframePhone.IframePhoneRpcEndpoint(handler, 'lara-logging', iframe);
    iframePhoneRpc.call({ message: 'lara-logging-present' });
  }

  this.iframePhoneRpcEndpoints.push(iframePhoneRpc);
};


function Logger(options) {
  this._server = options.server;
  this._defaultData = options.defaultData;
}

Logger.prototype.log = function(data) {
  if (typeof(data) === 'string') {
    data = {event: data};
  }
  data.time = Date.now(); // millisecons
  this._post(data);
};

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


$(document).ready(function() {
  // Logger configuration and metadata is provided in Rails controller through Gon gem.
  // See: https://github.com/gazay/gon
  var loggerConfig = window.gon && window.gon.loggerConfig;
  if (!loggerConfig) {
    // Exit if logger configuration isn't provided.
    return;
  }

  var logger_utils = LoggerUtils.instance(loggerConfig);

  switch (loggerConfig.action) {
    case 'sequences#show':
      logger_utils.sequenceIndexLogging();
      break;

    case 'lightweight_activities#show':
    case 'lightweight_activities#preview':
      logger_utils.activityIndexLogging();
      break;

    case 'lightweight_activities#summary':
      logger_utils.activitySummaryLogging();
      break;

    case 'interactive_pages#show':
    case 'interactive_pages#preview':
    case 'lightweight_activities#single_page':
      logger_utils.interactivePageLogging();
      break;
  }

});