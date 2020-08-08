window.initSlateEditor = function (wysiwyg, value, index, options) {
  $(wysiwyg).hide();
  $(wysiwyg).parent().css({ 'position': 'relative' });
  $(wysiwyg).parent().append('<div class="wysiwyg-toggle" onclick="toggleWysiwygView(this)">HTML</div>');
  var slateEditorId = "slate-editor-" + index.toString();
  $('<div id="' + slateEditorId + '" class="slate-editor"></div>').insertAfter(wysiwyg);
  $editor = $("#" + slateEditorId);
  $editor.data("useAjax", options.useAjax);

  function renderEditor($this, value) {
    const props = {
      value,
      onValueChange: function(value) {
        $this.triggerHandler("editor.value", [ value ]);
      },
      onContentChange: handleContentChange($this, value)
    };
    LARA.PageItemAuthoring.renderSlateContainer($this[0], props);
  }

  // handle this as a triggerable event so it can be triggered from elsewhere,
  // e.g. toggleWysiwygView() below.
  $editor.on("editor.value", function(event, value) {
    const prevValue = $editor.data("editorValue");
    if (!prevValue || (value !== prevValue)) {
      $(this).data("editorValue", value);
      renderEditor($(this), value);
    }
  });

  $editor.triggerHandler("editor.value", [ LARA.PageItemAuthoring.htmlToSlate(value || "") ]);
};

function handleContentChange(editor, value) {
  var contentHtml = LARA.PageItemAuthoring.slateToHtml(value);
  var textarea = editor.prev("textarea");
  if (editor.data("useAjax")) {
    var e = new Event('input', { bubbles: true });
    setNativeValue($(textarea)[0], contentHtml);
    $(textarea)[0].dispatchEvent(e);
  } else {
    textarea.text(contentHtml);
    textarea.val(contentHtml);
  }
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
  var $editor = $(toggle).siblings('.slate-editor');
  if ($(toggle).text() === "HTML") {
    $(toggle).text("Rich Text");
    // copy value from slate editor to text area
    const htmlValue = LARA.PageItemAuthoring.slateToHtml($editor.data("editorValue"));
    $(toggle).siblings('textarea')[0].value = htmlValue;
  } else {
    $(toggle).text("HTML");
    // copy value from text area to slate editor
    var value = $(toggle).siblings('textarea')[0].value;
    var slateValue = LARA.PageItemAuthoring.htmlToSlate(value);
    $editor.trigger("editor.value", [ slateValue ]);
  }
}
