modulejs.define 'components/itsi_authoring/tiny_mce_config',
->
  menubar: false,
  statusbar: false,
  toolbar_items_size: 'small',
  toolbar: "undo redo | bold italic strikethrough underline | " +
    "aligncenter alignjustify alignleft alignright indent outdent | " +
    "subscript superscript | numlist bullist | link unlink | hr image",
  plugins: 'paste link hr image autoresize',
  paste_as_text: true,
  autoresize_bottom_margin: 5
