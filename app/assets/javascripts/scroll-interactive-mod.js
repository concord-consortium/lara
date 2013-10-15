/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $ */

// Object to handle fixing of the interactive module
var InteractiveModule = function (object) {
    this.module = object;
    this.i_width = object.width();
    this.i_height = object.height();
};

// Fixes the interactive mod when the window hits the questions scrolling down
InteractiveModule.prototype.fixTop = function () {
    this.module.addClass('stuck');
	this.module.css({
		'width': this.i_width
	});
};

// Un-fixes the interactive mod when the window hits the questions scrolling up
InteractiveModule.prototype.unFixTop = function () {
	this.module.removeClass('stuck');
};

// Fixes the interactive mod when the window hits the bottom marker scrolling up
InteractiveModule.prototype.fixBottom = function () {
	this.module.addClass('stuck');
	this.module.removeClass('bottomed');
};

InteractiveModule.prototype.unFixBottom = function () {
	this.module.removeClass('stuck');
	this.module.addClass('bottomed');
};

InteractiveModule.prototype.getHeight = function () {
    return this.i_height;
};

$(document).ready(function () {
    var scrollingInteractive = new InteractiveModule($('.pinned'));

	// These blocks use jquery.waypoints
    // Set the top waypoint and call relevant functions from it
    $('.content-mod').waypoint( function (direction) {
		if (direction==='down') {
            scrollingInteractive.fixTop();
            $('.questions-full').css({
                'margin-top': this.i_height+52
            });
		}
		if (direction==='up') {
            scrollingInteractive.unFixTop();
            $('.questions-full').css({
                'margin-top': 0
            });
		}
	}, {
        offset: 120 // Is this right for all layouts?
    });

    // Set the bottom waypoint and call the relevant function there too
	$('#end-scroll-track').waypoint(function (direction) {
		if (direction === 'down') {
            scrollingInteractive.unFixBottom();
		}
		if (direction === 'up') {
            scrollingInteractive.fixBottom();
		}
	}, { 
        offset: scrollingInteractive.getHeight() + 180
    });
});