// On a sequence page we want to be able to click on the whole
// activity box to follow a link. see app/views/sequences/show.html.haml

$(document).ready( function(e) {
  $(".sequence-page .activities .activity").click(function(e) {
    window.location=$(this).find(".title a").attr("href");
    return false;
   });
});
