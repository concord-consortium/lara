window.initSlateEditor = function (selector, value) {
  // addSlateEditor(selector, value);
};

function addSlateEditor(selector, value) {
  // hide .wysiwyg editor
  // selector.hide();

  // add #slate-editor div immediately after .wysiwyg editor
  // $('<div id="slate-editor"></div>').insertAfter('.wysiwyg-minimal');

  // attach Slate Editor to #slate-editor div
  // var contentValue = LARA.PageItemAuthoring.htmlToSlate("#{content_value}");
  // console.log(contentValue);
  // var root = document.getElementById('slate-editor');
  // var props = { value: contentValue, onValueChange: updateSlateEditor };
  // LARA.PageItemAuthoring.renderSlateContainer(root, props);

}

function updateSlateEditor (editorValue) {
  var root = document.getElementById('slate-editor');
  var props = { value: editorValue, onValueChange: updateSlateEditor };
  LARA.PageItemAuthoring.renderSlateContainer(root, props);

  var prevValue = $(root).data("prevValue");
  console.log(prevValue);
  console.log(editorValue);
  if (prevValue && editorValue.document !== prevValue.document) {
    console.log("Calling slateToHtml()");
    var contentHtml = LARA.PageItemAuthoring.slateToHtml(editorValue);
    console.log("Called slateToHtml()");
    $('#content-editor').text(contentHtml);
    console.log("Copied content to textarea.");
  }
  $(root).data("prevValue", editorValue);
}
