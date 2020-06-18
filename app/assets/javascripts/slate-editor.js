window.initSlateEditor = function (wysiwyg, value, index, options) {
  $(wysiwyg).hide();
  $(wysiwyg).parent().css({ 'position': 'relative' });
  $(wysiwyg).parent().append('<div class="wysiwyg-toggle" onclick="toggleWysiwygView(this)">HTML</div>');
  var slateEditorId = "slate-editor-" + index.toString();
  $('<div id="' + slateEditorId + '" class="slate-editor"></div>').insertAfter(wysiwyg);
  $("#" + slateEditorId).data("useAjax", options.useAjax);

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
  console.log('updateSlateEditor triggered');
  var slateEditorId = $(document).data("currentSlateEditorId");
  var root = document.getElementById(slateEditorId);
  var props = { onFocus: setCurrentEditor, value: editorValue, onValueChange: updateSlateEditor };
  LARA.PageItemAuthoring.renderSlateContainer(root, props);

  var prevValue = $(root).data("prevValue");
  if (prevValue && editorValue.document !== prevValue.document) {
    var contentHtml = LARA.PageItemAuthoring.slateToHtml(editorValue);
    var textarea = $(root).prev("textarea");
    if ($(root).data("useAjax")) {
      var e = new Event('input', { bubbles: true });
      setNativeValue($(textarea)[0], contentHtml);
      $(textarea)[0].dispatchEvent(e);
    } else {
      textarea.text(contentHtml);
      textarea.val(contentHtml);
    }
  }
  $(root).data("prevValue", editorValue);
}

function setNativeValue(element, value) {
  var valueSetter = Object.getOwnPropertyDescriptor(element, 'value').set;
  var prototype = Object.getPrototypeOf(element);
  var prototypeValueSetter = Object.getOwnPropertyDescriptor(prototype, 'value').set;

  if (valueSetter && valueSetter !== prototypeValueSetter) {
  	prototypeValueSetter.call(element, value);
  } else {
    valueSetter.call(element, value);
  }
}

function toggleWysiwygView(toggle) {
  $(toggle).siblings('textarea').toggle();
  $(toggle).siblings('.slate-editor').toggle();
  if ($(toggle).text() === "HTML") {
    $(toggle).text("Rich Text");
  } else {
    $(toggle).text("HTML");
    var value = $(toggle).siblings('textarea')[0].value;
    var contentValue = LARA.PageItemAuthoring.htmlToSlate(value);
    var slateEditorId = $(toggle).siblings('.slate-editor').attr('id');
    var root = document.getElementById(slateEditorId);
    var props = { onFocus: setCurrentEditor, value: contentValue, onValueChange: updateSlateEditor };
    LARA.PageItemAuthoring.renderSlateContainer(root, props);
  }
}

function prepareWysiwygContent (content) {
  var cleanContent = content.replace(/(\r\n|\n|\r)/gm, "");
  cleanContent = cleanContent.replace(/\s\s+/g, " ");
  cleanContent = cleanContent.replace(/>\s</g, "><");
  cleanContent = cleanContent.replace(/<[^/>][^>]*><\/[^>]+>/g, "");
  return cleanContent;
}
