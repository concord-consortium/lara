/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $  */

// Update the modal edit window with a returned partial
$(function () {
    $('[data-remote][data-replace]')
        .data('type', 'html')
        .on('ajax:success', function (event, data) {
            var $this = $(this);
            $($this.data('replace')).html(JSON.parse(data).html);
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
    $('.accordion_embeddables').accordion({ active: false,
      collapsible: true,
      header: 'h3',
      heightStyle: 'content'
    });
    $('.sortable_embeddables').sortable({ handle: 'h3',
        items: '.authorable',
        opacity: 0.8,
        tolerance: 'pointer',
        update: function (event, ui) {
            $.ajax({
                type: "GET",
                url: "reorder_embeddables",
                data: ui.item.closest(".sortable_embeddables").sortable("serialize")
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
    // Activities in sequence edit
    $('#sort-activities').sortable({ handle: '.drag_handle',
        opacity: 0.8,
        tolerance: 'pointer',
        update: function () {
            $.ajax({
                type: 'GET',
                url: 'reorder_activities',
                data: $('#sort-activities').sortable('serialize')
            });
        }
    });
});
