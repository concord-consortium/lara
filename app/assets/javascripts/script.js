/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $ */

$(document).ready(function () {

	// Calculate some sizes
    var header_top = $('.content-hdr').offset().top,
        // content_top = $('.content-mod').offset().top, // We don't use this anymore
	    i_width =$('.pinned').width(),
	    i_height = $('.pinned').height();
    // var interactive_top = $('.interactive-mod').offset().top;
    // var q_height = $('.content-mod').height();

    $(window).scroll( function () {
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

	// This fixes the interactive mod when the window hits the questions
    // It depends on the interactive having the "pinned" class and works
    // by adding and removing the "stuck" class, and tweaking CSS.
    // Also, it depends on the 'i_width' and 'i_height' variables being set.
	$('.content-mod').waypoint( function (direction) {
		if (direction==='down') {
            $('.pinned').addClass('stuck');
			$('.pinned').css({
				'width':i_width
			});
			$('.questions-full').css({
				'margin-top':i_height+52
			});
		}
		if (direction==='up') {
			$('.pinned').removeClass('stuck');
			$('.questions-full').css({
				'margin-top': 0
			});
		}
	}, { offset: 120 }
	);

	//this un-fixes it when we scroll past its track
	$('#end-scroll-track').waypoint(function(direction){
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

    // Set up the jQuery Carousel if it's active
    $(function() {
        $('.jcarousel').jcarousel({
            'list': '.embeddables',
            'items': '.question'
        });

        $('.jcarousel-prev').jcarouselControl({
            target: '-=1'
        });

        $('.jcarousel-next').jcarouselControl({
            target: '+=1'
        });
    });

    // Set up colorbox for ImageInteractives
    $('.interactive-mod .colorbox').colorbox({});

});  // end document.ready