class ThumbnailPreview
  constructor: (@$preview, @$toggle, @$field) ->
    @scheduled_job      = null
    @previous_value     = null
    @setupEvents()
  setupEvents: () ->
    @$toggle.click (e) =>
      @$preview.toggle()
    @$field.change (e) =>
      console.log("update")
      @$preview.find("img").attr('src',e.target.value)


$(document).ready ->
  window.ThumbnailPreview = ThumbnailPreview
  new ThumbnailPreview($("#thumbnail_preview"), $("#toggle_thumbnail_preview"), $("#sequence_thumbnail_url"))
