/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $  */

function setIframeHeight() {
    // This depends on a data-aspect_ratio attribute being set in the HTML.
    var $iframe = $('iframe[data-aspect_ratio]'),
        aspectRatio = $iframe.attr('data-aspect_ratio'),
        currWidth = $iframe.width(),
        targetHeight = currWidth/aspectRatio;
    $('iframe[data-aspect_ratio]').height(targetHeight);
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
    // Click-handler for check answer moved to check-answer.js
    // Adjust interactive iframe to have correct aspect ratio
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
