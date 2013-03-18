/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $, Node */

// TODO: These variable names should be refactored to follow convention, i.e. only prepend with $ when it contains a jQuery object
var $content_box;
var $content_height;
var $content_top;
var $content_bottom;
var $model_width;
var $model_height;
var $model_start;
var $model_lowest;
var $header_height;
var $scroll_start;
var $scroll_end;

var fullScreen, exitFullScreen, minHeader, maxHeader;

var $scroll_handler = function () {
    // Don't do anything if the model is taller than the info/assessment block.
    if ($content_height > $model_height) {
        if (($(document).scrollTop() > $scroll_start) && ($(document).scrollTop() < $scroll_end)) {
            // Case 1: moving with scroll: scrolling below header but not at bottom of info/assessment block
            // console.debug('Moving: ' + $(document).scrollTop() + ', set to ' + ($model_start + ($(document).scrollTop() - $scroll_start)));
            $('.model-container').css({'position': 'absolute', 'top': ($model_start + ($(document).scrollTop() - $scroll_start)) + 'px', 'width': $model_width});
        } else if ($(document).scrollTop() >= $scroll_end) {
            // Case 2: fixed to bottom
            // console.debug('Bottom: ' + $(document).scrollTop() + ', set to ' + $model_lowest);
            $('.model-container').css({'position': 'absolute', 'top': $model_lowest + 'px', 'width': $model_width});
        } else {
            // Case 3: fixed to top: scrolling shows some bit of header
            // console.debug('Top: ' + $(document).scrollTop() + ', set to ' + $model_start);
            $('.model-container').css({'position': 'absolute', 'top': $model_start + 'px', 'width': $model_width});
        }
    }
};

function calculateDimensions() {
    if ($('.text') && $('.model-container')) {
        // Content starts at the bottom of the header, so this is the height of the header too.
        // Handy as a marker for when to start scrolling.
        $header_height = $('#content').offset().top;
        // Height of info/assessment block
        $content_box = $('.text').height();
        $content_height = $content_box - parseInt($('.text').css('padding-top'), 10) - parseInt($('.text').css('padding-bottom'), 10);
        // Top of info/assessment block (starting position of interactive, topmost location)
        $content_top = $('.text').offset().top;
        // Bottom location of info/assessment block
        $content_bottom = $(document).height() - ($content_top + $content_height);
        // Interactive dimensions
        $model_height = $('.model-container').height();
        $model_width = $('.model-container').css('width');
        // Scroll starts here
        $scroll_start = $header_height;
        $model_start = ($content_top - $header_height);
        // Scroll ends here
        // The travel space available to the model is the height of the content block minus the height of the interactive, so the scroll-end is scroll start plus that value.
        $scroll_end = $scroll_start + ($content_height - $model_height);
        // Interactive lowest position: highest of the stop point plus start point (pretty much where you are at the end of the scroll) or fixed-to-top value
        $model_lowest = Math.max(($model_start + ($scroll_end - $scroll_start)), $model_start);
    }
}

$(window).resize(function () {
    calculateDimensions();
});

function showPrompts() {
    if ($('#custom').is(':checked')) {
        $('.choices .custom-hidden').show();
    } else {
        $('.choices .custom-hidden').hide();
    }
}

function checkAnswer(q_id) {
    // check for valid answer
    if (!$('input:radio[name="questions[' + q_id + ']"]:checked').val()) {
        alert('Please select an answer before checking.');
    } else {
        var a_id = $('input:radio[name="questions[' + q_id + ']"]:checked').val().match(/embeddable__multiple_choice_choice_(\d+)/)[1];
        $.getJSON('/embeddable/multiple_choice/' + a_id + '/check', function (data) {
            var $modal = $('#modal'),
                modal_close = '<div class="close">Close</div>',
                $modal_container = $('#modal-container'),
                response;
            if (data.prompt) {
                response = data.prompt;
            } else if (data.choice) {
                response = 'Yes! You are correct.';
            } else {
                response = 'Sorry, that is incorrect.';
            }
            $modal.html('<div class="check-answer"><p class="response">' + response + '</p></div>')
                  .prepend(modal_close)
                  .css('top', $(window).scrollTop() + 40)
                  .show();
            $modal_container.show();
        });
    }
}

maxHeader = function () {
    $('#header').unbind('click').click(function () {
        minHeader();
    }).animate({'height': '130px'}, 300, function () {
        $('#header nav').fadeIn();
    });
    $('#header #mw-logo').animate({'height': '78px', 'width': '372px'}, 300);
    $('#header #cc-logo').animate({'height': '56px', 'margin-top': '15px', 'width': '182px'}, 300);
};

minHeader = function () {
    $('#header nav').fadeOut();
    $('#header #mw-logo').animate({'height': '50px', 'width': '238px'}, 300);
    $('#header #cc-logo').animate({'height': '40px', 'margin-top': '10px', 'width': '130px'}, 300);
    $('#header').click(function () {
        maxHeader();
    }).animate({'height': '60px'}, 300);
};

function showTutorial() {
    $('#overlay').fadeIn('fast');
    $('#tutorial').fadeIn('fast');
}

function setIframeHeight() {
    // This depends on a data-aspect_ratio attribute being set in the HTML.
    var aspectRatio = $('iframe[data-aspect_ratio]').attr('data-aspect_ratio'),
        targetHeight = $('.model, .model-edit').width() / aspectRatio;
    $('iframe[data-aspect_ratio]').height(targetHeight);
}

fullScreen = function () {
    $(document).unbind('scroll');
    $('#overlay').fadeIn('fast');
    $('.model').fadeOut('fast');

    $('.full-screen-toggle').attr('onclick', '').click(function () {
        exitFullScreen();
        return false;
    });
    $('.full-screen-toggle').html('Exit Full Screen');
    $('.model').css({'height': '90%', 'left': '5%', 'margin': '0', 'position': 'fixed', 'top': '5%', 'width': '90%', 'z-index': '100'});
    $('.model iframe').css({'height': '100%', 'width': '100%'});
    $('.model').fadeIn('fast');
};

exitFullScreen = function () {
    if (!($('body').hasClass('full'))) {
        $(document).bind('scroll', $scroll_handler());
    }
    $('#tutorial').fadeOut('fast');
    $('.model').fadeOut('fast');
    $('.full-screen-toggle').unbind('click').click(function () {
        fullScreen();
        return false;
    });
    $('.full-screen-toggle').html('Full Screen');
    $('.model').css({'height': '510px', 'left': 'auto', 'margin': '13px 0 20px', 'position': 'relative', 'top': 'auto', 'width': '100%', 'z-index': '1'});
    $('#overlay').fadeOut('slow');
    $('.model').fadeIn('fast');
};

function nextQuestion(num) {
    var curr_q = '.q' + (num - 1),
        next_q = '.q' + num;
    $(curr_q).fadeOut('fast', function () { $(next_q).fadeIn(); });
}

function prevQuestion(num) {
    var curr_q = '.q' + (num + 1),
        next_q = '.q' + num;
    $(curr_q).fadeOut('fast', function () { $(next_q).fadeIn(); });
}

function adjustWidth() {
    var model_width, width;
    if ($('.content').css('width') === '960px') {
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

// For each data-storage_key in the page, stores the current response
function storeResponses () {
    console.log('Storing answers locally.');
    $('[data-storage_key]').each( function () {
        var storageKey, questionText, answerText = '';
        storageKey = $(this).data('storage_key');
        // This is the question
        $(this).find(".prompt").contents().filter( function () { questionText = this.textContent; });
        // This is the MC answer
        if ($(this).find("input:radio:checked").length > 0) {
            $(this).find("input:radio:checked").parent().contents().filter( function () { if (this.nodeType === Node.TEXT_NODE) { answerText += this.textContent; } } );
        }
        // This is the OR answer
        if ($(this).find("textarea").length > 0) {
            answerText = $(this).find("textarea").val();
        }
        if (answerText) {
            answerText.trim();
        }
        if (answerText) {
            localStorage.setItem(storageKey, JSON.stringify({ 'question': questionText, 'answer': answerText }));
        }
    });
}

// Returns an object with 'question' and 'answer' attributes
function getResponse (answerKey) {
    return JSON.parse(localStorage.getItem(answerKey));
}

// Update the modal edit window with a returned partial
$(function () {
    $('[data-remote][data-replace]')
        .data('type', 'html')
        .live('ajax:success', function (event, data) {
            var $this = $(this);
            $($this.data('replace')).html(data.html);
            $this.trigger('ajax:replaced');
        });
});

$(document).ready(function () {
    // prepare for scrolling model
    if ($('.model-container').length) {
        calculateDimensions();
        $(document).bind('scroll', $scroll_handler);
    }

    // add event listeners
    $('input[type=radio]').click(function () {
        $('#check').removeClass('disabled');
    });

    $('#header').click(function () {
        maxHeader();
    });
    $('#overlay').click(function () {
        exitFullScreen();
    });
    $('.full-screen-toggle').click(function () {
        fullScreen();
        return false;
    });

    // Adjust iframe to have correct aspect ratio
    setIframeHeight();

    // Set up sortable list
    $('#sort_embeddables').sortable({ handle: '.drag_handle',
        opacity: 0.8,
        tolerance: 'pointer',
        update: function () {
            $.ajax({
                type: "GET",
                url: "reorder_embeddables",
                data: $("#sort_embeddables").sortable("serialize")
            });
        }
    });
    $('#sort-pages').sortable({ handle: '.drag_handle',
        opacity: 0.8,
        tolerance: 'pointer',
        update: function () {
            $.ajax({
                type: "GET",
                url: "reorder_pages",
                data: $('#sort-pages').sortable("serialize")
            });
        }
    });

    // Set up to store responses
    if (localStorage && $("[data-storage_key]").length) {
        $(window).unload(function () {
            storeResponses();
        });
    }

    // Display response summary
    if ($('body.summary [data-storage_key]').length) {
        $('[data-storage_key]').each( function () {
            var qResponse = getResponse($(this).data('storage_key'));
            if (qResponse) {
                $(this).html('<p class="question">' + qResponse.question + '</p><p class="response">' + qResponse.answer + '</p>'); 
            }
        });
    }
});

