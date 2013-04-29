$(document).ready(function(){

	var header_top = $('.content-hdr').offset().top;
	var interactive_top = $('.interactive-mod').offset().top;
	var content_top = $('.content-mod').offset().top;
	
	var q_height = $('.content-mod').height();
	var i_width =$('.pinned').width();
	var i_height = $('.pinned').height();



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

		// reveal sidebar-mod
		if( window_top >= content_top/2 ) {
			$('.sidebar-mod').fadeIn(2000);
		}
	});


	// adding expanded class to .sidebar-mod
	$('.sidebar-hdr').add('.sidebar-bd-close').click(function() {
		$('.sidebar-mod').toggleClass('expanded');
	});

	//This fixes the interactive mod when the window hits the questions
	$('.pinned').waypoint(function(direction){
		if(direction=='down'){
			$('.pinned').addClass('stuck');
			$('.pinned').css({
				'width':i_width
			});
			$('.questions-full').css({
				'margin-top':i_height+52
			});
		}
		if(direction=='up'){
			$('.pinned').removeClass('stuck');
			$('.questions-full').css({
				'margin-top': 0
			});
		}
	}, { offset: 120 }
	);

	//this un-fixes it when we scroll past its track
	$('.related-mod').waypoint(function(direction){
		if(direction=='down'){
			$('.pinned').removeClass('stuck');
			$('.pinned').addClass('bottomed');
		}
		if(direction=='up'){
			$('.pinned').addClass('stuck');
			$('.pinned').removeClass('bottomed');
		}
	}, { offset: i_height + 180 }
	);


	// prototyping save interaction
	var i = 0;
	setInterval(function(){
		$("#save").toggleClass('saved');
		if(i==0){
			$("#save").html("Saved.");
			$("#save").animate({'opacity': '0'}, 'slow');
		} else {
			$("#save").animate({'opacity': '1.0'}, 'slow');
			$("#save").html("Saving...");
		}
		i = 1-i;
	}, 5000);

});  // end document.ready