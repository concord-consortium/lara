window.initSlateEditor = function (wysiwyg, value, index, options) {
  $(wysiwyg).hide();
  $(wysiwyg).parent().css({ 'position': 'relative' });
  $(wysiwyg).parent().append('<div class="wysiwyg-toggle" onclick="toggleWysiwygView(this)">HTML</div>');
  var slateEditorId = "slate-editor-" + index.toString();
  $('<div id="' + slateEditorId + '" class="slate-editor"></div>').insertAfter(wysiwyg);
  $editor = $("#" + slateEditorId);
  $editor.data("editorId", slateEditorId);
  $editor.data("useAjax", options.useAjax);
  $editor.data("renderCount", 0);

  function renderEditor($this, value) {
    // note: I added this recursive render detector because earlier versions of the code
    // had that problem. I haven't seen it recur with this refactored code, so we can
    // remove it at some point if we don't see any reoccurrence of the phenomenon.
    let renderCount = $this.data("renderCount");
    if (renderCount === 0) {
      $this.data("renderCount", ++renderCount);
      const props = {
        value,
        onValueChange: function(value) {
          $this.triggerHandler("editor.value", [ value ]);
        },
        onContentChange: function(value) {
          // argument is now the same value as onValueChange
          console.log("NewContent:", LARA.PageItemAuthoring.slateToHtml(value));
        }
      };
      LARA.PageItemAuthoring.renderSlateContainer($this[0], props);
      $this.data("renderCount", --renderCount);
    }
    else {
      console.log("editor.value render circularity detected!")
    }
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

// function updateSlateEditor (editorValue) {
//   var slateEditorId = $(document).data("currentSlateEditorId");
//   var root = document.getElementById(slateEditorId);
//   if (!root) return;
//   var prevValue = $(root).data("prevValue");
//   if (editorValue === prevValue) return;
//   var props = { onFocus: setCurrentEditor, value: editorValue, onValueChange: updateSlateEditor };
//   LARA.PageItemAuthoring.renderSlateContainer(root, props);

//   if (prevValue && editorValue.document !== prevValue.document) {
//     // var contentHtml = LARA.PageItemAuthoring.slateToHtml(editorValue);
//     // var textarea = $(root).prev("textarea");
//     // if ($(root).data("useAjax")) {
//     //   var e = new Event('input', { bubbles: true });
//     //   setNativeValue($(textarea)[0], contentHtml);
//     //   $(textarea)[0].dispatchEvent(e);
//     // } else {
//     //   textarea.text(contentHtml);
//     //   textarea.val(contentHtml);
//     // }
//   }
//   $(root).data("prevValue", editorValue);
// }

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

// this function should not be necessary any more
function prepareWysiwygContent (content) {
  return content;
  // var cleanContent = content.replace(/(\r\n|\n|\r)/gm, "");
  // cleanContent = cleanContent.replace(/\s\s+/g, " ");
  // cleanContent = cleanContent.replace(/>\s</g, "><");
  // cleanContent = cleanContent.replace(/<[^/>][^>]*><\/[^>]+>/g, "");
  // return cleanContent;
}
