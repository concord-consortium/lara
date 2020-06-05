function toggleQuestions() {
  jQuery('.questions-mod').toggleClass('closed');
  jQuery('.ui-block-1').toggleClass('open');
  if (jQuery('.questions-mod').hasClass('closed')) {
    jQuery('.question-tab span').text('Show Questions');
  } else {
    jQuery('.question-tab span').text('Hide Questions');
  }
  interactiveSizing();
}
