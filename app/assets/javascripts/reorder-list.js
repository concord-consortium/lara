/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $ */

var embeddables, pages, activities;

// Object to handle sizing of interactive object
var ReorderableList = function (container, url_string) {
    this.container = container;
    this.url_string = url_string;
    this.container.sortable({ handle: '.drag_handle',
        opacity: 0.8,
        tolerance: 'pointer',
        update: function () {
            var container = this.container,
                url_string = this.url_string;
            $.ajax({
                type: "GET",
                url: url_string,
                data: container.sortable("serialize")
            });
        }
    });
};

// Setup
$(document).ready(function () {
    embeddables  =  new ReorderableList($("#sort_embeddables"), 'reorder_embeddables');
    pages        =  new ReorderableList($('#sort-pages'), 'reorder_pages');
    // TODO: Set up activity reordering within sequences
    activities   =  new ReorderableList();
});
