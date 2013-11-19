/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $ */

var scrollingInteractive, scrollTrack;

// FIXME: This doesn't do well with interactives that change their size on load, i.e. iframes.
// FIXME: How do we ensure waypoints are set when an image is completely loaded? 

// Object responsible for managing information about the space in which
// the interactive travels.
var ScrollTrack = function (contentModule, trackEnd) {
    this.contentModule  = contentModule;
    this.trackEnd       = trackEnd;
};

ScrollTrack.prototype.getTop = function ()  {
    return this.contentModule.offset().top;
};

ScrollTrack.prototype.getBottom = function () {
    return this.trackEnd.offset().top;
};

ScrollTrack.prototype.getHeight = function () {
    return this.getBottom() - this.getTop();
};

// This is the main method: given an interactive height, could that interactive scroll in
// the track described here?
ScrollTrack.prototype.isScrollable = function (interactiveHeight) {
    var canIScroll;
    if ((this.contentModule.length === 0) || (this.trackEnd.length === 0) || (interactiveHeight === null)) {
        canIScroll = false;
    } else if (interactiveHeight < this.getHeight()) {
        canIScroll = true;
    } else {
        canIScroll = false;
    }
    return canIScroll;
};

// Object to handle fixing of the interactive module
var InteractiveModule = function (object, scrollTrack) {
    this.module          = object;
    this.bMargin         = parseInt(object.css('margin-bottom'), 10);
    this.topBuffer       = 120; // Magic number: how far is the interactive from the page top when we pin it?
    this.fudgeFactor     = 20; // Magic number: how much scroll track do we want before we let the interactive scroll?
    this.scrollTrack     = scrollTrack;
};

// Wrap the ScrollTrack's isScrollable method
InteractiveModule.prototype.canScroll = function () {
    return this.scrollTrack.isScrollable(this.getHeightWithMargin() + this.fudgeFactor);
};

// Fixes the interactive mod when the window hits the questions scrolling down
InteractiveModule.prototype.fixTop = function () {
    // console.log('^^^ fixTop: pin interactive, scrolling down');
	if (this.canScroll()) {
        this.module.css({
            'width': this.module.width(),
            'height': this.module.height()
        });
        this.module.addClass('stuck');
    }
};

// Un-fixes the interactive mod when the window hits the questions scrolling up
InteractiveModule.prototype.unFixTop = function () {
    // console.log('^^^ unFixTop: un-pin interactive, scrolling up');
	if (this.canScroll() && this.module.hasClass('stuck')) {
        this.module.removeClass('stuck');
    }
};

// Fixes the interactive mod when the window hits the bottom marker scrolling up
InteractiveModule.prototype.fixBottom = function () {
    // console.log('^^^ fixBottom: pin interactive, scrolling up');
	if (this.canScroll() && this.module.hasClass('bottomed')) {
        this.module.addClass('stuck');
        this.module.removeClass('bottomed');
	}
};

InteractiveModule.prototype.unFixBottom = function () {
    // console.log('^^^ unFixBottom: un-pin interactive, scrolling down');
	if (this.canScroll() && this.module.hasClass('stuck')) {
        this.module.removeClass('stuck');
        this.module.addClass('bottomed');
    }
};

InteractiveModule.prototype.setWaypoints = function () {
    // These blocks use jquery.waypoints
    var self = this;
    self.scrollTrack.contentModule.waypoint( function (direction) {
        // Pin interactive scrolling down
        if (direction === 'down') {
            self.fixTop();
            $('.questions-full').css({
                'margin-top': self.getHeightWithMargin()
            });
        }
        // Un-pin interactive scrolling up
        if (direction === 'up') {
            self.unFixTop();
            $('.questions-full').css({
                'margin-top': 0
            });
        }
    }, {
        // context: '#container',
        offset: self.topBuffer // when $('.content-mod') is 120px from the top of the viewport
    });
    self.scrollTrack.trackEnd.waypoint(function (direction) {
        // Un-pin interactive scrolling down
        if (direction === 'down') {
            self.unFixBottom();
        }
        // Pin interactive scrolling up
        if (direction === 'up') {
            self.fixBottom();
        }
    }, {
        // context: '#container',
        offset: self.getHeightWithMargin() + self.topBuffer
    });
};

// These just wrap the $.waypoints() functions, but it seems useful to have this
// object know about them.
InteractiveModule.prototype.clearWaypoints = function () {
    $.waypoints('destroy');
};

InteractiveModule.prototype.disableWaypoints = function () {
    $.waypoints('disable');
};

InteractiveModule.prototype.enableWaypoints = function () {
    $.waypoints('enable');
};

InteractiveModule.prototype.getHeight = function () {
    return this.module.height();
};

InteractiveModule.prototype.getBottomMargin = function () {
    return this.bMargin;
};

InteractiveModule.prototype.getHeightWithMargin = function () {
    return this.module.height() + this.bMargin;
};

$(document).ready(function () {
    var $trackEnd = $('#end-scroll-track'),
        $contentMod = $('.content-mod');

    scrollTrack = new ScrollTrack($contentMod, $trackEnd);
    scrollingInteractive = new InteractiveModule($('.pinned'), scrollTrack);

    // If the interactive is an image, wait for it to load before setting waypoints
    if ($('.pinned>img').length > 0) {
        console.log('^^^ Setting event handlers on image.');
        $('.pinned>img').load( function () {
            console.log('^^^ Image loaded, setting waypoints.');
            scrollingInteractive.setWaypoints();
        }).error( function () {
            console.log('^^^ Image load failed.');
        });
    } else {
        console.log('^^^ No image, setting waypoints.');
        scrollingInteractive.setWaypoints();
    }
});

