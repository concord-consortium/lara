/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $  */

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
    // NOTE that there are other event listeners set up in other .js files

    // Set up sortable lists:
    // TODO: Refactor this into an object
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

    // WYSIWYG editing, if that's needed
    $('.wysiwyg-text').wysiwyg({
        "controls": {
            "html": {
                "visible": true
            },
            "h1": {
                "visible": false
            },
            "h2": {
                "visible": false
            },
            "h3": {
                "visible": false
            }
        }
    });

});
