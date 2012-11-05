$(document).ready(function() {
	// prepare for scrolling model
	calcPageDimensions();
	$(document).bind('scroll', $scroll_handler);
	
	// add event listeners
	$('input[type=radio]').click(function(){
		$('#check').removeClass('disabled');
	});
	
	$('#header').click(function(){
		maxHeader();
	});
	$('#overlay').click(function(){
		exitFullScreen();
	});
	$('.full-screen-toggle').click(function(){
		fullScreen();
		return false;
	});
});

var $content_height;
var $content_offset;
var $content_top;
var $content_bottom;
var $last_scroll_pos = $(document).scrollTop();
var $stop_scrolltop;
var $model_width;

var $scroll_handler = function() {
	if ($(document).scrollTop() > 60 && $(document).scrollTop() < 821) {
    	$('div.model').css({
							'position': 'absolute', 
							'top': $(document).scrollTop() + 'px', 
							'width': $model_width
							});
		$value = $content_top + $content_height;
	} else if ($(document).scrollTop() >= 821) {
    	$('div.model').css({
							'position': 'absolute', 
							'top': '821px', 
							'width': $model_width
							});
	} else {
    	$('div.model').css({
							'position': 'absolute', 
							'top': '64px', 
							'width': $model_width
							});
	}
	//alert($(document).scrollTop());
};

function calcPageDimensions(){
  $content_height = $('#content').height();
  $content_offset = $('#content').offset();
  $content_top = $content_offset.top;
  $content_bottom = $(document).height() - ($content_top + $content_height);
  $model_height = $('.other').height();
  $model_width = $('.other').css('width');
}

$(window).resize(function(){
	calcPageDimensions();
});

function checkAnswer() {
	// check for valid answer
	if (!$('input:radio[name=q1]:checked').val()) {
		alert('Please select an answer before checking.');
	} else {
		if ($('input:radio[name=q1]:checked').val() == 50) {
			alert('Correct!');
			$('#next').removeClass('disabled');
		} else {
			alert('That answer is incorrect.');
			$('#next').addClass('disabled');
		}
	}
}

function maxHeader() {
	$('#header').unbind('click').click(function(){
		minHeader();	
	}).animate({'height': '130px'}, 300, function(){
		$('#header nav').fadeIn();	
	});
	$('#header #mw-logo').animate({'height': '78px', 'width': '372px'}, 300);
	$('#header #cc-logo').animate({'height': '56px', 'margin-top': '15px', 'width': '182px'}, 300);
}

function minHeader() {
	$('#header nav').fadeOut();
	$('#header #mw-logo').animate({'height': '50px', 'width': '238px'}, 300);
	$('#header #cc-logo').animate({'height': '40px', 'margin-top': '10px', 'width': '130px'}, 300);
	$('#header').click(function(){
		maxHeader();	
	}).animate({'height': '60px'}, 300);
}

function fullScreen() {
	$(document).unbind('scroll');
	$('#overlay').fadeIn('fast');
	$('.model').fadeOut('fast');
	
	$('.full-screen-toggle').attr('onclick', '').click(function(){
		exitFullScreen();
		return false;
	});
	$('.full-screen-toggle').html('Exit Full Screen');
	$('.model').css({'height': '90%', 'left': '5%', 'margin': '0', 'position': 'fixed', 'top': '5%', 'width': '90%', 'z-index': '100'});
	$('.model iframe').css({'height': '100%', 'width': '100%'});
	$('.model').fadeIn('fast');
}

function showTutorial() {
	$('#overlay').fadeIn('fast');
	$('#tutorial').fadeIn('fast');
}

function exitFullScreen() {
	if (!($('body').hasClass('full'))) {
		$(document).bind('scroll', scrollHandler());
	}
	$('#tutorial').fadeOut('fast');
	$('.model').fadeOut('fast');
	$('.full-screen-toggle').unbind('click').click(function(){
		fullScreen();
		return false;
	});
	$('.full-screen-toggle').html('Full Screen');
	$('.model').css({'height': '510px', 'left': 'auto', 'margin': '13px 0 20px', 'position': 'relative', 'top': 'auto', 'width': '100%', 'z-index': '1'});
	$('#overlay').fadeOut('slow');
	$('.model').fadeIn('fast');
}

function nextQuestion(num) {
	var curr_q = '.q' + (num - 1);
	var next_q = '.q' + num;
	$(curr_q).fadeOut('fast', function(){$(next_q).fadeIn();});
}

function prevQuestion(num) {
	var curr_q = '.q' + (num + 1);
	var next_q = '.q' + num;
	$(curr_q).fadeOut('fast', function(){$(next_q).fadeIn();});
}

function adjustWidth() {
	var model_width;
	var width;
	if ($('.content').css('width') == '960px') {
		model_width = '60%';
		width = '95%';
	} else {
		model_width = '576px';
		width = '960px';		
	}
	
	$('#header div').css('width', width);
	$('.content').css('width', width);
	$('div.model').css('width', model_width);
	$('#footer div').css('width', width);
}
