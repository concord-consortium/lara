/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $ */

var carousel;

// Object to handle presentation of the carousel
var EmbeddableCarousel = function (element) {
    var self = this;
    this.container = element;
    this.buttonHeight = this.container.find('.buttons').height();
    // Set up the carousel
    this.container.jcarousel({
        'list': '.embeddables',
        'items': '.question'
    });
    // Update the control state when we're done changing
    this.container.on('animateend.jcarousel', function (event, carousel) {
        self.updateControls(carousel);
        return event;
    });
    // Get our controls
    this.controlNext = $('.jcarousel-next');
    this.controlPrev = $('.jcarousel-prev');
    // Assume we start at the first item
    this.turnOnNext();
    // Two cases here: one, we have an image which may take a bit to load and thus define
    // the height of the .interactive-mod which is what we're using to get the height.
    // Two, we have an iframe or video tag which has already been height-adjusted (or the
    // image is already loaded and we don't need to wait.)
	if (($('.interactive-mod img').length > 1) && !$('.interactive-mod img')[0].complete) {
		// console.log('Deferring setCarouselSize()');
		$('.interactive-mod img')[0].once('load', function () {
			// console.log('Running deferred setCarouselSize()');
			this.setCarouselSize();
		});
	} else {
		// console.log('Size is ready, running setCarouselSize right away');
		this.setCarouselSize();
	}
};

EmbeddableCarousel.prototype.setCarouselSize = function () {
    // Set 'bestHeight' and 'bestWidth' values
    this.adjustSize();
    // Set the carousel to those values and reload it
    this.setHeight(this.bestHeight);
    this.setWidth(this.bestWidth);
	// recalculate scroll values for new dimensions
    this.container.jcarousel('reload');
};

// Set the height of the container
EmbeddableCarousel.prototype.setHeight = function (newHeight) {
    this.container.css('height', newHeight + 'px');
    // Adjust embeddable containers to allow for buttons
    var embeddableHeight = newHeight - this.buttonHeight;
    $('.question').css('max-height', embeddableHeight + 'px');
};

// Set the width of the embeddables
EmbeddableCarousel.prototype.setWidth = function (newWidth) {
    $('.question').css('width', newWidth + 'px');
};

// Update state of carousel controls
EmbeddableCarousel.prototype.updateControls = function (carousel) {
    // "carousel" here is a carousel object from jcarousel
    var list = carousel.items();
    if (list.index(carousel.target()) === 0) {
        // If at start of list, turn off "prev" and on "next"
        this.turnOffPrev();
        this.turnOnNext();
    } else if (list.index(carousel.target()) === (list.length - 1)) {
        // If at end of list, turn off "next" and on "prev"
        this.turnOffNext();
        this.turnOnPrev();
    } else {
        // Otherwise turn on both
        this.turnOnPrev();
        this.turnOnNext();
    }
};

// Activate the "next" control
EmbeddableCarousel.prototype.turnOnNext = function () {
    this.controlNext.jcarouselControl({
        target: '+=1'
    });
    this.controlNext.find('.button').prop('disabled', false);
};

// Deactivate the "next" control
EmbeddableCarousel.prototype.turnOffNext = function () {
    this.controlNext.jcarouselControl('destroy');
    this.controlNext.find('.button').prop('disabled', true);
};

// Activate the "previous" control
EmbeddableCarousel.prototype.turnOnPrev = function () {
    this.controlPrev.jcarouselControl({
        target: '-=1'
    });
    this.controlPrev.find('.button').prop('disabled', false);
};

// Deactivate the "previous" control
EmbeddableCarousel.prototype.turnOffPrev = function () {
    this.controlPrev.jcarouselControl('destroy');
    this.controlPrev.find('.button').prop('disabled', true);
};

EmbeddableCarousel.prototype.adjustSize = function () {
    // This calculates the proper height and width for the carousel container.
    var newHeight, newWidth, tallest, available;
    // Adjust height and width
    if ($('.content-mod').hasClass('l-full-width')) {
        // If full-width, set height of carousel to height of tallest embeddable or available screen, whichever is less
        tallest = 0;
        available = $(window).height() - $('.activity-nav-mod').height();
        $('.question').each( function () {
            tallest = Math.max(tallest, $(this).height() + this.buttonHeight);
        });
        newHeight = Math.min(tallest, available);
        // If full-width, set width of carousel to X
        newWidth = 960;
    } else {
        // If not full-width, set height of carousel to height of interactive box
        newHeight = $('.interactive-mod').height();
        if ($('.content-mod').hasClass('l-6040') || $('.content-mod').hasClass('r-4060')) {
            // If 60-40, set width of carousel to Y
            newWidth = 374;
        } else {
            // If 70-30, set width of carousel to Z
            newWidth = 278;
        }
    }
    this.bestHeight = newHeight;
    this.bestWidth = newWidth;
};

// Setup
$(document).ready(function () {
    // Set up the jQuery Carousel if it's active
    if ($('.jcarousel').length > 0) {
        carousel = new EmbeddableCarousel($('.jcarousel'));
    }
});
