/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $, Node, exitFullScreen, fullScreen, calculateDimensions, scroll_handler */

function setIframeHeight() {
    // This depends on a data-aspect_ratio attribute being set in the HTML.
    var aspectRatio = $('iframe[data-aspect_ratio]').attr('data-aspect_ratio'),
        targetHeight = $('.model, .model-edit').width() / aspectRatio;
    $('iframe[data-aspect_ratio]').height(targetHeight);
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
        .on('ajax:success', function (event, data) {
            var $this = $(this);
            $($this.data('replace')).html(data.html);
            $this.trigger('ajax:replaced');
        });
});

// Everything to run at page load time
$(document).ready(function () {
    // *** add event listeners: ***
    // prepare for scrolling model
    if ($('.model-container').length) {
        calculateDimensions();
        $(document).bind('scroll', scroll_handler());
    }

    // enable check answer when there is an answer
    $('input[type=radio]').click(function () {
        $('#check').removeClass('disabled');
    });
    // // exit from fullscreen event
    // $('#overlay').click(function () {
    //     exitFullScreen(); // Defined in full-screen.js
    // });
    // // enter fullscreen event
    // $('.full-screen-toggle').click(function () {
    //     fullScreen();
    //     return false;
    // });
    // submit multiple choice on change event
    $('.live_submit').on('change',function() {
      $(this).parents('form:first').submit();
    });
    // submit textarea on blur event
    $('textarea.live-submit').on('blur',function() {
      $(this).parents('form:first').submit();
    });

    // Adjust iframe to have correct aspect ratio
    setIframeHeight();

    // Set up sortable lists:
    // Embeddables in page edit
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
    // Pages in activity edit
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
