window.TinyMCEConfig = {
  menubar: false,
  statusbar: false,
  toolbar_items_size: 'small',
  toolbar: "undo redo | bold italic strikethrough underline | " +
           "aligncenter alignjustify alignleft alignright indent outdent | " +
           "subscript superscript | numlist bullist | link unlink | hr image | code",
  plugins: 'paste link hr image autoresize code',
  paste_as_text: true,
  autoresize_bottom_margin: 5
};

window.TinyMCEConfigMinimal = Object.assign({}, window.TinyMCEConfig, {
  toolbar: "bold italic strikethrough underline indent outdent " +
           "subscript superscript numlist bullist link unlink hr image"
});

window.initTinyMCE = function (selector, config) {
  // Cleanup previous instances first. If TinyMCE is added twice to the same element, it doesn't work.
  tinymce.remove(selector);
  $(selector).tinymce(config)
};
