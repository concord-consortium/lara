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
    $('.jcarousel').on('jcarousel:scrollend', function(event, carousel) {
        self.updateControls(carousel);
        return event;
    });
    // Get our controls
    this.controlNext = $('.jcarousel-next');
    this.controlPrev = $('.jcarousel-prev');
    // Assume we start at the first item
    this.turnOnNext();
    // Two cases here:
    // One, we have an image which may take a bit to load and thus define
    // the height of the .interactive-mod which is what we're using to get the height.
    // Two, we have an iframe or video tag which has already been height-adjusted (or the
    // image is already loaded and we don't need to wait.)
    // The first solution was pretty wonky, so I set a minimum height of 300 for those cases.
	this.setCarouselSize();
};

EmbeddableCarousel.prototype.setCarouselSize = function () {
  // Set 'bestHeight' and 'bestWidth' values
  this.calculateWidth()
  this.setWidth(this.bestWidth)
  // Make sure that interactives have correct height.
  $('[data-aspect-ratio]').trigger('sizeUpdate')
  // Set the carousel to those values and reload it
  this.calculateHeight()
  this.setHeight(this.bestHeight)
  // recalculate scroll values for new dimensions
  this.container.jcarousel('reload')
};

// Set the height of the container
EmbeddableCarousel.prototype.setHeight = function (newHeight) {
    this.container.css('height', newHeight + 'px');
    // Adjust embeddable containers to allow for buttons
    var embeddableHeight = newHeight - this.buttonHeight - 2;
    $('.jcarousel .question').css('max-height', embeddableHeight + 'px');
};

// Set the width of the embeddables
EmbeddableCarousel.prototype.setWidth = function (newWidth) {
    $('.jcarousel .question').css('width', newWidth + 'px');
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

/** Return the height of the tallest question element in our list */
EmbeddableCarousel.prototype.tallestQuestion = function() {
    var tallest = 0;
    var current = 0;
    var self = this;
    $('.jcarousel .question').each( function () {
        // force text-box content into our current computed width
        // this helps to get an accurate measurement.
        $(this).width(self.bestWidth);
        current = $(this).height() + self.buttonHeight;
        tallest = Math.max(tallest, current);
    });
    return tallest;
};

/** Return true if we are in full-width layout */
EmbeddableCarousel.prototype.isHalfWidth = function() {
    return $('.content-mod').hasClass('l-full-width');
};

EmbeddableCarousel.prototype.isResponsive = function() {
  return $('.content-mod').hasClass('l-responsive');
};

/** Calculates the proper height for the carousel container. */
EmbeddableCarousel.prototype.calculateHeight = function() {
    var interactiveHeight = $('.interactive-mod').height();
    var offset = $('.content-mod').offset();

    var available = Math.max($(window).height() - offset.top, 330); // make sure height is at least 330 pixels
    if (this.isResponsive()) {
        this.bestHeight = this.tallestQuestion() + 30;
    } else if (this.isHalfWidth()) {
        this.bestHeight = Math.max(this.tallestQuestion(), available) + 30;
    } else {
        this.bestHeight = Math.max(interactiveHeight, this.tallestQuestion());
        // limit to the window?
        this.bestHeight = Math.min(this.bestHeight, available);
    }
};

/** Calculates the proper width for the carousel container. */
EmbeddableCarousel.prototype.calculateWidth = function() {
    if (this.isHalfWidth()) {
        this.bestWidth = 936;
        return;
    }
    if (this.isResponsive()) {
        this.bestWidth = 278;
        return;
    }
    if ($('.content-mod').hasClass('l-6040')) {
        this.bestWidth = 365;
        return;
    }
    if ($('.content-mod').hasClass('r-4060')) {
        this.bestWidth =  365;
        return;
    }
    this.bestWidth = 271;
};

// unlike document.ready window.load() is called
// after all layout has completed.
// Handy for when you need to get $(foo).height()
$(window).load(function () {
    // Set up the jQuery Carousel if it's active
    if ($('.jcarousel').length > 0) {
        carousel = new EmbeddableCarousel($('.jcarousel'));
    }
});

$(window).resize(function () {
    if (typeof carousel !== 'undefined') {
        carousel.setCarouselSize();
    }
});
