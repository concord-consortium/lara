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

var AnswerChecker = function ($question) {
    // The question is the div containing the form and options.
    // From that we extract the question ID and answers
    this.q_id = $question.data('check');
    this.answers = $('#' + this.q_id + ' input:radio:checked');
    if (this.answers.length === 0) {
        // Try checkboxes if there are no checked radio buttons
        this.answers = $('#' + this.q_id + ' input:checkbox:checked');
    }
    // console.log(this.answers);
    console.log('There are ' + this.answers.length + ' answers found by the constructor.');
    // TODO: This only returns one answer; we will need to send all checked answers if there are >1.
    // Extract the answer value
    this.answer = this.answers.val();
};

AnswerChecker.prototype.check = function () {
    // If there are answers, send them to the server and use the response in a modal dialog
    if (this.answer && (this.answer.length > 0)) {
        $.getJSON('/embeddable/multiple_choice/' + this.answer + '/check', function (data) {
            modalDialog(data.choice, data.prompt);
        });
    }
    else {
        modalDialog(false, 'Please select an answer before checking.');
    }
};

// Adds some click handlers to DOM elements which don't exist at page load
function addModalClickHandlers () {
    var customFeedbackToggle = $('#embeddable_multiple_choice_custom'),
        customFeedbackPrompts = new CustomFeedback($('.choices .custom-hidden'));

    customFeedbackToggle.click(function () {
        customFeedbackPrompts.show(customFeedbackToggle);
    });
}

function addClickHanders() {
    $('.check_answer_button').click(function() {
        new AnswerChecker($(this)).check();
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