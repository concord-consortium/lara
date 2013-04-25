/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $, Node, scroll_handler */

var content_box;
var content_height;
var content_top;
var content_bottom;
var model_width;
var model_height;
var model_start;
var model_lowest;
var header_height;
var scroll_start;
var scroll_end;

var minHeader, maxHeader, response_key;

function scroll_handler () {
    // Don't do anything if the model is taller than the info/assessment block.
    if (content_height > model_height) {
        if (($(document).scrollTop() > scroll_start) && ($(document).scrollTop() < scroll_end)) {
            // Case 1: moving with scroll: scrolling below header but not at bottom of info/assessment block
            // console.debug('Moving: ' + $(document).scrollTop() + ', set to ' + (model_start + ($(document).scrollTop() - scroll_start)));
            $('.model-container').css({'position': 'absolute', 'top': (model_start + ($(document).scrollTop() - scroll_start)) + 'px', 'width': model_width});
        } else if ($(document).scrollTop() >= scroll_end) {
            // Case 2: fixed to bottom
            // console.debug('Bottom: ' + $(document).scrollTop() + ', set to ' + model_lowest);
            $('.model-container').css({'position': 'absolute', 'top': model_lowest + 'px', 'width': model_width});
        } else {
            // Case 3: fixed to top: scrolling shows some bit of header
            // console.debug('Top: ' + $(document).scrollTop() + ', set to ' + model_start);
            $('.model-container').css({'position': 'absolute', 'top': model_start + 'px', 'width': model_width});
        }
    }
}

// Sets up values for the scroll handler. Something in here is broken at the moment.
function calculateDimensions() {
    if ($('.text') && $('.model-container')) {
        // Content starts at the bottom of the header, so this is the height of the header too.
        // Handy as a marker for when to start scrolling.
        header_height = $('#content').offset().top;
        // Height of info/assessment block
        content_box = $('.text').height();
        content_height = content_box - parseInt($('.text').css('padding-top'), 10) - parseInt($('.text').css('padding-bottom'), 10);
        // Top of info/assessment block (starting position of interactive, topmost location)
        content_top = $('.text').offset().top;
        // Bottom location of info/assessment block
        content_bottom = $(document).height() - (content_top + content_height);
        // Interactive dimensions
        model_height = $('.model-container').height();
        model_width = $('.model-container').css('width');
        // Scroll starts here
        scroll_start = header_height;
        model_start = (content_top - header_height);
        // Scroll ends here
        // The travel space available to the model is the height of the content block minus the height of the interactive, so the scroll-end is scroll start plus that value.
        scroll_end = scroll_start + (content_height - model_height);
        // Interactive lowest position: highest of the stop point plus start point (pretty much where you are at the end of the scroll) or fixed-to-top value
        model_lowest = Math.max((model_start + (scroll_end - scroll_start)), model_start);
    }
}

$(window).resize(function () {
    calculateDimensions();
});
