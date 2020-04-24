function toggleQuestions() {
  jQuery('.questions-mod').toggleClass('closed');
  jQuery('.ui-block-1').toggleClass('open');
  if (jQuery('.questions-mod').hasClass('closed')) {
    jQuery('.question-tab span').text('Show Questions');
    jQuery('.question-tab div').addClass('flash');
  } else {
    jQuery('.question-tab span').text('Hide Questions');
    jQuery('.question-tab').removeClass('flash');
  }
}

jQuery(document).ready(function() {
  // jQuery('.questions-mod').prepend('<div class="question-toggle"><button onclick="toggleQuestions();">&laquo;</button></div>');
  jQuery('.questions-mod').prepend('<div class="question-tab" onclick="toggleQuestions(); return false;"><span>Hide Questions</span></div>');
});

function flashQuestionsToggle() {
  jQuery('.question-tab').addClass('flash');
}
