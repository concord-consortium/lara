/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $ */

var carousel;

// Object to handle presentation of the carousel
var EmbeddableCarousel = function (element) {
    var self = this;
    this.container = element;
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
};

// Set the height of the container
EmbeddableCarousel.prototype.setHeight = function (newHeight) {
    this.container.css('height', newHeight);
};

// Set the width of the container
EmbeddableCarousel.prototype.setWidth = function (newWidth) {
    this.container.css('width', newWidth);
};

// Update state of carousel controls
EmbeddableCarousel.prototype.updateControls = function (carousel) {
    var list = carousel.items();
    if (list.index(carousel.target()) === 0) {
        // If at start of list, turn off "prev" and on "next"
        console.log("We're at start");
        this.turnOffPrev();
        this.turnOnNext();
    } else if (list.index(carousel.target()) === (list.length - 1)) {
        // If at end of list, turn off "next" and on "prev"
        console.log("We're at end");
        this.turnOffNext();
        this.turnOnPrev();
    } else {
        // Otherwise turn on both
        console.log("We're in the middle");
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

// Setup
$(document).ready(function () {
    // Set up the jQuery Carousel if it's active
    carousel = new EmbeddableCarousel($('.jcarousel'));
});
