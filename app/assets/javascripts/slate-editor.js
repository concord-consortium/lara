window.initSlateEditor = function (wysiwyg, value, index) {
  var slateEditorId = "slate-editor-" + index.toString();
  $(wysiwyg).hide();
  $('<div id="' + slateEditorId + '" class="slate-editor"></div>').insertAfter(wysiwyg);

  var contentValue = LARA.PageItemAuthoring.htmlToSlate(value);
  var root = document.getElementById(slateEditorId);
  var props = { onFocus: setCurrentEditor, value: contentValue, onValueChange: updateSlateEditor };
  LARA.PageItemAuthoring.renderSlateContainer(root, props);

};

function setCurrentEditor (editor) {
  currentSlateEditorId = $(editor.el).parent().parent().attr("id");
  $(document).data("currentSlateEditorId", currentSlateEditorId);
}

function updateSlateEditor (editorValue) {
  var slateEditorId = $(document).data("currentSlateEditorId");
  var root = document.getElementById(slateEditorId);
  var props = { onFocus: setCurrentEditor, value: editorValue, onValueChange: updateSlateEditor };
  LARA.PageItemAuthoring.renderSlateContainer(root, props);

  var prevValue = $(root).data("prevValue");
  //console.log(prevValue);
  //console.log(editorValue);
  if (prevValue && editorValue.document !== prevValue.document) {
    //console.log("Calling slateToHtml()");
    var contentHtml = LARA.PageItemAuthoring.slateToHtml(editorValue);
    //console.log("Called slateToHtml()");
    $(root).siblings("textarea").text(contentHtml);
    $(root).siblings("textarea").val(contentHtml);
    console.log("Copied content to textarea.");
  }
  $(root).data("prevValue", editorValue);
}
