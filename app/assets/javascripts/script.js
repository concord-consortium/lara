/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $ */

var saveTimer;

function saveFailed () {
    $("#save").html("Save failed!");
}

function showSaved () {
    // Wait a few seconds before actually running
    saveTimer = setTimeout( function () {
        $("#save").html("Saved.");
        // Fade out.
        $("#save").animate({'opacity': '0'}, 'slow');
    }, 2000);
}

function showSaving () {
	$("#save").html("Saving...");
	$("#save").animate({'opacity': '1.0'}, 'slow');
}

function saveForm ($form) {
    // Show "Saving..."
    showSaving();
    // Submit form
    $form.submit();
    // We should be evaluating the response to that and calling either showSaved() or saveFailed().
    showSaved();
}

$(document).ready(function(){

	var header_top = $('.content-hdr').offset().top,
        // content_top = $('.content-mod').offset().top, // We don't use this anymore
	    i_width =$('.pinned').width(),
	    i_height = $('.pinned').height();
    // var interactive_top = $('.interactive-mod').offset().top;
    // var q_height = $('.content-mod').height();



	$(window).scroll(function(){
		var window_top = $(window).scrollTop();

		// Activity nav fixing
		if( window_top >= header_top/2 ) {
			$('.activity-nav-mod').addClass('fixed');
			$('.content-hdr').addClass('extra-pad');
			// $('.activity-nav-mod.fixed').fadeIn();
			$('.activity-nav-mod.fixed .activity-nav-logo .h2').addClass('visible');
		} else {
			$('.activity-nav-mod').removeClass('fixed');
			$('.content-hdr').removeClass('extra-pad');
			$('.activity-nav-mod .activity-nav-logo .h2').removeClass('visible');
		}

		// reveal sidebar-mod once the page is scrolled at least halfway to the content.
        // This means the sidebar never shows up if the page can't be scrolled that far!
        // if( window_top >= content_top/2 ) {
        //     $('.sidebar-mod').fadeIn(2000);
        // }
	});

    // Just fade the sidebar in over three seconds
    $('.sidebar-mod').fadeIn(3000);

	// adding expanded class to .sidebar-mod
	$('.sidebar-hdr').add('.sidebar-bd-close').click(function() {
		$('.sidebar-mod').toggleClass('expanded');
	});

	//This fixes the interactive mod when the window hits the questions
	$('.pinned').waypoint(function(direction){
		if(direction==='down'){
			$('.pinned').addClass('stuck');
			$('.pinned').css({
				'width':i_width
			});
			$('.questions-full').css({
				'margin-top':i_height+52
			});
		}
		if(direction==='up'){
			$('.pinned').removeClass('stuck');
			$('.questions-full').css({
				'margin-top': 0
			});
		}
	}, { offset: 120 }
	);

	//this un-fixes it when we scroll past its track
	$('.related-mod').waypoint(function(direction){
		if(direction==='down'){
			$('.pinned').removeClass('stuck');
			$('.pinned').addClass('bottomed');
		}
		if(direction==='up'){
			$('.pinned').addClass('stuck');
			$('.pinned').removeClass('bottomed');
		}
	}, { offset: i_height + 180 }
	);


    // enable check answer when there is an answer
    $('input[type=radio]').one('click', function () {
        $('#check').removeAttr('disabled');
    });

    // submit multiple choice on change event
    $('.live_submit').on('change',function() {
      saveForm($(this).parents('form:first'));
    });

    // submit textarea on blur event
    $('textarea.live-submit').on('blur',function() {
      saveForm($(this).parents('form:first'));
    });
});  // end document.ready