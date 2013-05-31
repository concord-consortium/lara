/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $, modalDialog */


// Constructor for class to represent the custom feedback form fields in the admin
var CustomFeedback = function (el) {
    this.el = $(el);
    return this;
};

CustomFeedback.prototype.show = function (control) {
    if (control.is(':checked')) {
        this.el.show();
    } else {
        this.el.hide();
    }
};

function checkAnswer($question) {
    var q_id = $question.data('check'),
        $answers, answer, answered;
    $answers = $('#' + q_id + ' input:radio:checked');
    if ($answers.length === 0) {
        // Try checkboxes if there are no radio buttons
        $answers = $('#' + q_id + ' input:checkbox:checked');
    }
    // TODO: This only returns one answer; we will need to send all checked answers if there are >1.
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

function addModalClickHandlers () {
    var customFeedbackToggle = $('#embeddable_multiple_choice_custom'),
        customFeedbackPrompts = new CustomFeedback($('.choices .custom-hidden'));

    customFeedbackToggle.click(function () {
        customFeedbackPrompts.show(customFeedbackToggle);
    });
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