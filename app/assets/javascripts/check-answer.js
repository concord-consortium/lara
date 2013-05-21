/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $, modalDialog */

function showPrompts() {
    // This is for admin
    if ($('#embeddable_multiple_choice_custom').is(':checked')) {
        $('.choices .custom-hidden').show();
    } else {
        $('.choices .custom-hidden').hide();
    }
}

function checkAnswer($question) {
    var q_id = $question.data('check'),
        $answers, answer, answered;
    $answers = $('#' + q_id + ' input:radio:checked');
    if ($answers.length === 0) {
        // Try checkboxes if there are no radio buttons
        $answers = $('#' + q_id + ' input:checkbox:checked');
    }
    answer = $answers.val();
    answered = answer && answer.length > 0;
    if (!answered) {
        modalDialog(false, 'Please select an answer before checking.');
    }
    else {
        $.getJSON('/embeddable/multiple_choice/' + answer + '/check', function (data) {
            modalDialog(data.choice, data.prompt);
        });
    }
}

function addClickHanders() {
    $('.check_answer_button').click(function() {
        checkAnswer($(this));
    });

    // Enable the check-answer button if answered:
    $('input[type=radio], input[type=checkbox]').click(function () {
        var button_id = $(this).data('button-id');
        $("#" + button_id).removeAttr('disabled');
    });
}

$(document).ready(function () {
    addClickHanders();
});