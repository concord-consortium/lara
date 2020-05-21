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
    // check if accordion state was set and recreate state accordingly
    if (sessionStorage) {
      var accordionState = JSON.parse(sessionStorage.getItem("accordion_state"));
      console.log(accordionState);
      if (accordionState.activated) {
        $('.accordion_embeddable').accordion({ active: false,
          collapsible: true,
          header: 'h3',
          heightStyle: 'content',
          activate: function( event, ui ) {
            $(this).toggleClass('ui-active');
            saveAccordionState(accordionState);
          }
        });
        for (var i = 0; i < accordionState.open_items.length; i++) {
          var childNum = accordionState.open_items[i] + 1;
          $('.accordion_embeddable:nth-child(' + childNum + ') .ui-accordion-header').click();
        }
        $('.show-hide-toggle').text('Open All');
      }
    }

    // *** add event listeners: ***
    // NOTE that there are other event listeners set up in other .js files

    // Set up sortable lists:
    // TODO: Refactor this into an object
    // Embeddables in page edit
    $('.show-hide-toggle').click(function() {
      if ($(this).text().match('Close All')) {
        $('.accordion_embeddable').accordion({ active: false,
          collapsible: true,
          header: 'h3',
          heightStyle: 'content',
          activate: function( event, ui ) {
            $(this).toggleClass('ui-active');
            if (sessionStorage) {
              var accordionState = JSON.parse(sessionStorage.getItem("accordion_state"));
              saveAccordionState(accordionState);
            }
          }
        });
        $(this).text('Open All');
        // save accordion state for page reload
        if (sessionStorage) {
          var accordionState = {
            "activated": true,
            "container": $(this).parent()
          };
          saveAccordionState(accordionState);
        }
      } else {
        $('.accordion_embeddable').accordion('destroy');
        $(this).text('Close All');
        // save accordion state for page reload
        if (sessionStorage) {
          var accordionState = {
            "activated": false,
            "container": $(this).parent()
          };
          saveAccordionState(accordionState);
        }
      }
    });

    $('.sortable_embeddables').sortable({ handle: 'h3.embeddable_heading',
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

function saveAccordionState(accordionState) {
  var openItems = [];
  $('.accordion_embeddable').each(function(index) {
    if ($(this).hasClass('ui-active')) {
      openItems.push(index);
    }
  });
  sessionStorage.setItem("accordion_state",
    JSON.stringify({
      "activated": accordionState.activated,
      "container": accordionState.container,
      "open_items": openItems
    })
  );
}
