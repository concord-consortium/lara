/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $ */

// Object to handle fixing of the interactive module
var InteractiveModule = function (object) {
    this.module = object;
    this.i_width = object.width();
    this.i_height = object.height();
    this.b_margin = parseInt(object.css('margin-bottom'), 10);
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

InteractiveModule.prototype.getBottomMargin = function () {
    return this.b_margin;
};

InteractiveModule.prototype.getHeightWithMargin = function () {
    return this.i_height + this.b_margin;
};

$(document).ready(function () {
    var scrollingInteractive = new InteractiveModule($('.pinned'));

    // Does the interactive actually have enough room to scroll? It does if its height is
    // less than the difference between its starting position ($('.content-mod').offset().top)
    // and the bottom of the scroll track ($('#end-scroll-track').offset().top). (I've added 
    // a few pixels to that Just In Case - we don't need to wiggle back and forth 10 pixels just
    // because there's room to do so.)
    if (scrollingInteractive.getHeightWithMargin() < ($('#end-scroll-track').offset().top - $('.content-mod').offset().top) - 10) {
        // These blocks use jquery.waypoints
        // Set the top waypoint and call relevant functions from it
        $('.content-mod').waypoint( function (direction) {
            if (direction==='down') {
                scrollingInteractive.fixTop();
                $('.questions-full').css({
                    'margin-top': scrollingInteractive.getHeightWithMargin() // The 52 is a magic number for the bottom margin
                });
            }
            if (direction==='up') {
                scrollingInteractive.unFixTop();
                $('.questions-full').css({
                    'margin-top': 0
                });
            }
        }, {
            context: '#container',
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
            context: '#container',
            offset: scrollingInteractive.getHeight() + 180
        });
    }
});