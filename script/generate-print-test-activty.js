#!/usr/bin/env node

'use strict';

var activity = {
  "description": "An activity to test printing interactives in various ways.",
  "editor_mode": 0,
  "layout": 0,
  "name": "Interactive Print Test",
  "notes": "",
  "project_id": 4,
  "related": "",
  "thumbnail_url": "",
  "time_to_complete": null,
  "theme_name": "Interactions",
  "type": "LightweightActivity",
  "export_site": "Lightweight Activities Runtime and Authoring",
  "pages": []
};

var pageTemplate = {
      "additional_sections": {},
      "embeddable_display_mode": "stacked",
      "is_completion": false,
      "is_hidden": false,
      "layout": "l-6040",
      "name": null,
      "position": 1,
      "show_info_assessment": true,
      "show_interactive": true,
      "show_header": true,
      "show_sidebar": false,
      "sidebar": null,
      "sidebar_title": "Did you know?",
      "text": "Introduction: Interactive with no image defined.",
      "interactives": [
        {
          "authored_state": null,
          "click_to_play": false,
          "enable_learner_state": false,
          "full_window": false,
          "has_report_url": false,
          "image_url": "",
          "is_hidden": false,
          "model_library_url": null,
          "name": "No Image Interactive",
          "native_height": 435,
          "native_width": 576,
          "url": "https://concord.org/ngss/",
          "type": "MwInteractive",
          "ref_id": "207301-MwInteractive",
          "linked_interactive": null
        }
      ],
      "embeddables": [
        {
          "content": "<b>Text box 1</b>. Some text in a box. On non full width layouts " +
            "this should be beside the interactive.",
          "is_hidden": false,
          "name": "",
          "type": "Embeddable::Xhtml"
        },
        {
          "content": "<b>Text box 2</b>. More text, in a full width layout this should be " +
            "in the second column below the interative. In print view the layout is not " +
            "respected. So in print view this should be to the left of the interactive." +
            "Later boxes will start wrapping around the interactive in print view.",
          "is_hidden": false,
          "name": "",
          "type": "Embeddable::Xhtml"
        },
        {
          "default_text": "",
          "give_prediction_feedback": false,
          "hint": "",
          "is_hidden": false,
          "is_prediction": false,
          "name": "",
          "prediction_feedback": "",
          "prompt": "Open response question. How well does this print out?",
          "type": "Embeddable::OpenResponse"
        },
        {
          "content": "<b>Text box 3</b>. More Text that is below the open response. " +
            "In print view this should wrap below the interactive.",
          "is_hidden": false,
          "name": "",
          "type": "Embeddable::Xhtml"
        },
        {
          "content": "<b>Text box 4</b>. Another text box. surely this one will wrap.",
          "is_hidden": false,
          "name": "",
          "type": "Embeddable::Xhtml"
        }
      ],
      "sections": []
    };



var interactiveConfigs = [
  {description: "no image",
   click_to_play: false,
   image_size: null,
  },
  {description: "image",
   click_to_play: false,
   // this is the default size of interactives in LARA
   image_size: [576, 435],
  },
  {description: "image and click to play",
   click_to_play: true,
   image_size: [576, 435],
  },
  {description: "taller image than interactive",
   click_to_play: true,
   image_size: [576, 600],
  },
  {description: "shorter image than interactive",
   click_to_play: true,
   image_size: [576, 300],
  },
];

var layouts = [ "l-6040", "l-7030", "r-4060", "r-3070", "l-full-width"];

// size is a array of [width, height]
function generateImage(size) {
  if(size === null || size === ""){
    return "";
  }
  return "http://www.generateit.net/rounded-corner/rounded.php?" +
         "sh=r&r=0&bw=20&bc=7A70FF&bg=FF0000&fg=999999&" +
         "w=" + size[0] + "&h=" + size[1] + "&f=png&aa=1&bgt=0&bt=0&fgt=0&tc=FFFFFF";
}

layouts.forEach(function(layout) {
  interactiveConfigs.forEach(function (config){
    var page = JSON.parse(JSON.stringify(pageTemplate));
    page.name = layout + " " + config.description;
    page.text = "Intro: Layout: " + layout + ". Interactive with " + config.description;
    page.layout = layout;
    page.position = activity.pages.length + 1;
    var interactive = page.interactives[0];
    interactive.click_to_play = config.click_to_play;
    interactive.image_url = generateImage(config.image_size);
    interactive.ref_id = "Interactive-" + activity.pages.length;
    activity.pages.push(page);
  });
});

console.log(JSON.stringify(activity, null, 2));
