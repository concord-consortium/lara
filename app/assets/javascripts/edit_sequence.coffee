class ThumbnailPreview
  constructor: (@$preview, @$toggle, @$field) ->
    @scheduled_job      = null
    @previous_value     = null
    @setupEvents()
    @updatePreview()

  updatePreview: () ->
    @$preview.find("img").attr('src', @$field.val())

  setupEvents: () ->
    @$toggle.click (e) =>
      @$preview.toggle()
    @$field.change (e) =>
      @updatePreview()

$(document).ready ->
  window.ThumbnailPreview = ThumbnailPreview
  new ThumbnailPreview($("#thumbnail_preview"), $("#toggle_thumbnail_preview"), $(".thumbnail_source"))
