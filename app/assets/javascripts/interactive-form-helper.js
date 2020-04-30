function interactive_form_helper(interactive) {

  function el(prefix) {
    var selector = "#" + prefix + "_" + (interactive.id ? interactive.id : "");
    return $(selector);
  }

  function click_to_play(){
    if (el("click_to_play").prop('checked')) {
      el("image_url").attr("required", true);
      el("full_window").removeAttr("disabled");
      el('full_window_label').css("opacity", 1);
      el("click_to_play_prompt").removeAttr("disabled");
      el('click_to_play_prompt_label').css("opacity", 1);
      el("image_url_warning").css("opacity", 1);
      el("image_url").removeAttr("disabled");
      el('image_url_label').css("opacity", 1);
    } else {
      $("#mw_interactive_image_url").removeAttr("required");
      el("full_window").attr("disabled", true);
      el('full_window_label').css("opacity", 0.3);
      el("click_to_play_prompt").attr("disabled", true);
      el('click_to_play_prompt_label').css("opacity", 0.3);
      el("image_url_warning").css("opacity", 0.3);
      el("image_url").attr("disabled", true);
      el('image_url_label').css("opacity", 0.3);
    }
  }

  click_to_play();

  el('enable_learner_state').click(function() {
    el('has_report_url').prop('checked', false);
    if ($(this).prop('checked')) {
      // ungrey
      el('has_report_url').removeAttr("disabled");
      el('show_delete_data_button').removeAttr("disabled");
      el('parent_id').removeAttr("disabled");
      el('enable_learner_state_indent').css("opacity", 1);
    } else {
      // grey
      el('has_report_url').attr("disabled", true);
      el('show_delete_data_button').attr("disabled", true);
      el('parent_id').attr("disabled", true);
      el('enable_learner_state_indent').css("opacity", 0.3);
    }
  });

  if (!interactive.enable_learner_state) {
    // uncheck and grey out the 'has report url' section
    el('has_report_url').prop('checked', false);
    el('has_report_url').attr("disabled", true);
    el('show_delete_data_button').attr("disabled", true);
    el('parent_id').attr("disabled", true);
    el('enable_learner_state_indent').css("opacity", 0.3);
  }

  el("click_to_play").click(click_to_play);

  var available_ratios = interactive.available_aspect_ratios;
  var props = {
    initialState: {
      width: interactive.native_width,
      height: interactive.native_height,
      mode: interactive.aspect_ratio_method
    },
    availableAspectRatios: available_ratios,
    updateValues: function(aspect_ratio_values) {
      $('#width').val( aspect_ratio_values.width);
      $('#height').val(aspect_ratio_values.height);
      $('#method').val(aspect_ratio_values.mode);
    }
  };

  Chooser = React.createElement(modulejs.require('components/common/aspect_ratio_chooser'), props);
  ReactDOM.render(Chooser, $("#aspect_ratio")[0]);
}
