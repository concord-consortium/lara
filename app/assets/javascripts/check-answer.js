/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $, modal */

function showPrompts() {
    // This is for admin
    if ($('#embeddable_multiple_choice_custom').is(':checked')) {
        $('.choices .custom-hidden').show();
    } else {
        $('.choices .custom-hidden').hide();
    }
}

function checkAnswer(q_id) {
    // check for valid answer
    if (!$('#' + q_id + ' input:radio:checked').val()) {
        alert('Please select an answer before checking.');
    }
    else {
        var a_id          = $('input:radio:checked').val();

        $.getJSON('/embeddable/multiple_choice/' + a_id + '/check', function (data) {
            modal(data.choice, data.prompt);
        });
    }
}