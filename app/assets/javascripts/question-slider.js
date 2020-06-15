function toggleQuestions() {
  jQuery('.questions-mod').toggleClass('closed');
  jQuery('.ui-block-1').toggleClass('open');
  if (jQuery('.questions-mod').hasClass('closed')) {
    jQuery('.question-tab span').text('Show Questions');
  } else {
    jQuery('.question-tab span').text('Hide Questions');
  }
}

var ro = new LARA.PageItemAuthoring.ResizeObserver(function (entries, observer) {
  for (var i = 0; i < entries.length; i++) {
    interactiveSizing();
  }
});

ro.observe(document.getElementsByClassName('questions-mod')[0]);
