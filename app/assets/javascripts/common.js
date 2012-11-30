/*jslint browser: true, sloppy: true, todo: true, devel: true */
/*global $ */

var $content_box;
var $content_height;
var $content_top;
var $content_bottom;
var $model_width;
var $model_height;
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
            console.debug('Moving: ' + $(document).scrollTop() + ', set to ' + ($(document).scrollTop() + $scroll_start + 35));
            $('.model-container').css({'position': 'absolute', 'top': ($(document).scrollTop() + $scroll_start + 35) + 'px', 'width': $model_width});
        } else if ($(document).scrollTop() >= $scroll_end) {
            // Case 2: fixed to bottom
            console.debug('Bottom: ' + $(document).scrollTop() + ', set to ' + $model_lowest);
            $('.model-container').css({'position': 'absolute', 'top': $model_lowest + 'px', 'width': $model_width});
        } else {
            // Case 3: fixed to top: scrolling shows some bit of header
            console.debug('Top: ' + $(document).scrollTop() + ', set to ' + ($content_top - $header_height));
            $('.model-container').css({'position': 'absolute', 'top': ($content_top - $header_height) + 'px', 'width': $model_width});
        }
    }
};

function calculateDimensions() {
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
    // FIXME: I don't like this 35 magic number but it fixes a lot of problems
    $model_height = $('.model-container').height() + 35; // 25 is the height of the blue bar
    $model_width = $('.model-container').css('width');
    // Scroll starts here
    $scroll_start = $header_height;
    // Scroll ends here
    // The travel space available to the model is the height of the content block minus the height of the interactive, so the scroll-end is scroll start plus that value. (The 35 here puts back the extra added to $model_height)
    $scroll_end = $scroll_start + ($content_height - $model_height) + 35;
    // Interactive lowest position: highest of the stop point plus start point (pretty much where you are at the end of the scroll) or fixed-to-top value
    $model_lowest = Math.max(($scroll_end + $scroll_start + 35), ($content_top - $header_height));
}

$(window).resize(function () {
    calculateDimensions();
});

function checkAnswer() {
    // check for valid answer
    if (!$('input:radio[name=q1]:checked').val()) {
        alert('Please select an answer before checking.');
    } else {
        // TODO: $.ajax call to find correct answer for this question
        if ($('input:radio[name=q1]:checked').val() === 50) {
            // TODO: Use custom question response here if provided
            // TODO: Replace alert() with lightbox (look at modals.js.coffee for how)
            alert('Yes! You are correct.');
            $('#next').removeClass('disabled');
        } else {
            // TODO: Use custom question response here if provided
            alert('Sorry, that is incorrect.');
            $('#next').addClass('disabled');
        }
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
});

