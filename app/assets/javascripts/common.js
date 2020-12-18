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
    $('#preview-options-select').on('change', function() {
      previewOptionSelected(this.value);
    });
});

// Everything to run at page load time
$(document).ready(function () {
    // check if accordion state was set and recreate state accordingly
    if (sessionStorage) {
      var infoAssessAccordionState = JSON.parse(sessionStorage.getItem("info_assess_block_accordion_state"));
      if (infoAssessAccordionState && infoAssessAccordionState.activated && infoAssessAccordionState.url === window.location.href) {
        rebuildAccordionState("info_assess_block", infoAssessAccordionState);
      }
      var interactiveAccordionState = JSON.parse(sessionStorage.getItem("interactive_box_accordion_state"));
      if (interactiveAccordionState && interactiveAccordionState.activated && interactiveAccordionState.url === window.location.href) {
        rebuildAccordionState("interactive_box", interactiveAccordionState);
      }
    }

    // *** add event listeners: ***
    // NOTE that there are other event listeners set up in other .js files

    // Set up sortable lists:
    // TODO: Refactor this into an object
    // Embeddables in page edit
    $('.show-hide-toggle').click(function() {
      var containerId = $(this).parent().attr('id');
      var accordionState = {};
      console.log('containerId: ' + containerId);
      if ($(this).text().match('Close All')) {
        $('#' + containerId + ' .accordion_embeddable').accordion({ active: false,
          collapsible: true,
          header: 'h3',
          heightStyle: 'content',
          activate: function( event, ui ) {
            $(this).toggleClass('ui-active');
            if (sessionStorage) {
              var accordionState = JSON.parse(sessionStorage.getItem(containerId + "_accordion_state"));
              saveAccordionState(containerId, accordionState);
            }
          }
        });
        $(this).text('Open All');
        // save accordion state for page reload
        if (sessionStorage) {
          accordionState = {
            "activated": true,
            "url": window.location.href,
            "open_items": []
          };
          saveAccordionState(containerId, accordionState);
        }
      } else {
        $('#' + containerId + ' .accordion_embeddable').accordion('destroy');
        $(this).text('Close All');
        // save accordion state for page reload
        if (sessionStorage) {
          accordionState = {
            "activated": false,
            "url": window.location.href,
            "open_items": []
          };
          saveAccordionState(containerId, accordionState);
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

function rebuildAccordionState(accordionContainerId, accordionState) {
  $('#' + accordionContainerId + ' .accordion_embeddable').accordion({ active: false,
    collapsible: true,
    header: 'h3',
    heightStyle: 'content',
    activate: function( event, ui ) {
      $(this).toggleClass('ui-active');
      saveAccordionState(accordionContainerId, accordionState);
    }
  });
  for (var i = 0; i < accordionState.open_items.length; i++) {
    var childNum = accordionState.open_items[i] + 1;
    $('#' + accordionContainerId + ' .accordion_embeddable:nth-child(' + childNum + ') .ui-accordion-header').click();
  }
  $('#' + accordionContainerId + ' .show-hide-toggle').text('Open All');
}

function saveAccordionState(accordionContainerId, accordionState) {
  var openItems = [];
  $('#' + accordionContainerId + ' .accordion_embeddable').each(function(index) {
    if ($(this).hasClass('ui-active')) {
      openItems.push(index);
    }
  });
  sessionStorage.setItem(accordionContainerId + "_accordion_state",
    JSON.stringify({
      "activated": accordionState.activated,
      "url": accordionState.url,
      "open_items": openItems
    })
  );
}

function previewOptionSelected(previewURL) {
  if (previewURL !== '') {
    window.open(previewURL, '_blank');
  }
}