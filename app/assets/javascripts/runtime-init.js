/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $ */

$(document).ready(function () {
    var headerTop = null;

	// Calculate header size
    if ($('.content-hdr').length > 0) {
        headerTop = $('.content-hdr').offset().top;
    }

    $(window).scroll( function () {
		var windowTop = $(window).scrollTop();

		// Activity nav fixing, if there is one
        if (headerTop) {
            if ( windowTop >= headerTop/2 ) {
                $('.activity-nav-mod').addClass('fixed');
                $('.content-hdr').addClass('extra-pad');
                // $('.activity-nav-mod.fixed').fadeIn();
                $('.activity-nav-mod.fixed .activity-nav-logo .h2').addClass('visible');
            } else {
                $('.activity-nav-mod').removeClass('fixed');
                $('.content-hdr').removeClass('extra-pad');
                $('.activity-nav-mod .activity-nav-logo .h2').removeClass('visible');
            }
        }

		// reveal sidebar-mod once the page is scrolled at least halfway to the content.
        // This means the sidebar never shows up if the page can't be scrolled that far!
        // if( window_top >= content_top/2 ) {
        //     $('.sidebar-mod').fadeIn(2000);
        // }
	});

    // Just fade the sidebar in over three seconds
    $('.sidebar-mod').fadeIn(3000);

	// adding expanded class to .sidebar-mod on click
	$('.sidebar-hdr').add('.sidebar-bd-close').click(function() {
		$('.sidebar-mod').toggleClass('expanded');
	});

    // Set up colorbox for ImageInteractives - see jquery.colorbox.js
    $('.interactive-mod .colorbox').colorbox({ maxWidth: "100%", maxHeight: "100%", minWidth: "960px" });

});  // end document.ready