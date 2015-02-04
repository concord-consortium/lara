var Logger_Utils = {
  get_question_type : function get_question_type(action){  
    if(action.indexOf("multiple_choice_answer") != -1){
      return "multiple_choice_answer";    
    } else if (action.indexOf("open_response_answer") != -1){
      return "open_response_answer";    
    } else if (action.indexOf("image_question_answer") != -1){
      return "image_question_answer";    
    } else return "embeddable_question";
  },
  log_submitted_question:function log_submitted_question(data){
	if (!window.gon.loggerConfig) {
	  return;
	}
	var logger = new Logger({
	  server:      window.gon.loggerConfig.server,
	  defaultData: window.gon.loggerConfig.data
	}),
	data_object = {event: 'submit question'},
    question_type = Logger_Utils.get_question_type(data);
	data_object[question_type] = data.split('_').slice(-1)[0];
	  logger.log(data_object);
 },
 log_interactive_simulation:function(){
 	
 	if (!window.gon.loggerConfig) {
	  return;
	}
 	var myConfObj = {
	  iframeMouseOver : false
	},
	logger = new Logger({
	  server:      window.gon.loggerConfig.server,
	  defaultData: window.gon.loggerConfig.data
	});
	window.addEventListener('blur',function(){
	  if(myConfObj.iframeMouseOver){
	    logger.log({
		 event:"clicked in the simulation window", 
		 interactive_id: $('#interactive').data().id
		});
	  }
	});
	document.getElementById('interactive').addEventListener('mouseover',function(){
	   myConfObj.iframeMouseOver = true;
	});
	document.getElementById('interactive').addEventListener('mouseout',function(){
	    myConfObj.iframeMouseOver = false;
	});
 }
};


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

$(document).ready(function() {
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

  var last_focus_in;
  $('.live_submit').off('mousedown.logging').on('mousedown.logging',function(event){
 	$(this).off('focusout.logging');
  });
  $('.live_submit').off('focusin.logging').on('focusin.logging',function(event) {
    var focusin_id = event.currentTarget.id;
    if(last_focus_in != focusin_id){      
      logger.log(generate_question_data('focus in',focusin_id));
      last_focus_in = focusin_id;
    }
    $(this).off('focusout.logging').on('focusout.logging',function(event) {
	  var focusout_id = event.currentTarget.id;
	  logger.log(generate_question_data('focus out',focusout_id));
	  last_focus_in = null;
	});
  });
  
  window.onbeforeunload = function(){
  	if(loggerConfig.data.page_id){
  	  logger.log('page exit');	
  	}
  };
  
  Logger_Utils.log_interactive_simulation();
  
  function generate_question_data(type,id){
  	 data = {};
     data['event'] = type;
     data[Logger_Utils.get_question_type(id)] = id.split('_').slice(-1)[0];
     return data;
  }
  
}());
