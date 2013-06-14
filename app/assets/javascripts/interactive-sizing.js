/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $ */

var interactive;

// Object to handle sizing of interactive object
var InteractiveObject = function (element) {
    this.element = element;
    this.aspectRatio = this.element.data('aspect_ratio');
    this.currWidth = $('.interactive-mod').width();
    this.targetHeight = this.currWidth/this.aspectRatio;
};

InteractiveObject.prototype.fixSize = function () {
    // Hitting the width and height attrs should work for both video and iframe
    this.element.attr('width', this.currWidth);
    this.element.attr('height', this.targetHeight);
};

// Setup
$(document).ready(function () {
    interactive = new InteractiveObject($('[data-aspect_ratio]'));
    interactive.fixSize();
});
