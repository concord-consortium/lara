/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $ */

var resizingInteractive;

// Object to handle sizing of interactive object
var ResizableInteractive = function (element) {
    this.element = element;
    this.aspectRatio = this.element.data('aspect-ratio');
    this.currWidth = $('.interactive-mod').width();
    this.targetHeight = this.currWidth/this.aspectRatio;
};

ResizableInteractive.prototype.fixSize = function () {
    // Hitting the width and height attrs should work for both video and iframe
    this.element.attr('width', this.currWidth);
    this.element.attr('height', this.targetHeight);
};

// Setup
$(document).ready(function () {
    resizingInteractive = new ResizableInteractive($('[data-aspect-ratio]'));
    resizingInteractive.fixSize();
});
