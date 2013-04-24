/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $, Node */

function showPrompts() {
    if ($('#embeddable_multiple_choice_custom').is(':checked')) {
        $('.choices .custom-hidden').show();
    } else {
        $('.choices .custom-hidden').hide();
    }
}

// TODO: This is broken with the changes to saving
function checkAnswer(q_id) {
    // check for valid answer
    if (!$('#' + q_id + ' input:radio:checked').val()) {
        alert('Please select an answer before checking.');
    } else {
        var a_id = $('input:radio:checked').val();
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

