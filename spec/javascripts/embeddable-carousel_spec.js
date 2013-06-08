/*jslint browser: true, sloppy: true, todo: true, devel: true */
/*global $, it, describe, xit, xdescribe, expect, beforeEach, spyOn, EmbeddableCarousel */

//= require embeddable-carousel

describe('EmbeddableCarousel', function () {
    var carousel,
        codeblock = $('<div class="jcarousel"><div class="embeddables"><div class="question"></div><div class="question"></div><div class="question"></div></div></div>');

    // TODO: This may call for fixtures for defining the carousel and controls.
    beforeEach(function () {
        carousel = new EmbeddableCarousel(codeblock);
    });

    // Attributes
    it('has a container', function () {
        expect(carousel.container).toBe('div.jcarousel');
    });

    it('has controls', function () {
        expect(carousel.controlNext).toBe('a.jcarousel-next');
        expect(carousel.controlPrev).toBe('a.jcarousel-prev');
    });

    // Event handlers?
    describe('event handlers', function () {
        spyOn(carousel, 'updateControls');
        var e = $.Event('animateend.jcarousel');
        carousel.container.trigger(e);
        expect(carousel.updateControls).toHaveBeenCalled();
    });

    // Methods
    describe('setHeight()', function () {
   
    });

    describe('setWidth()', function () {
        
    });

    describe('updateControls()', function () {
        
    });

    describe('turnOnNext()', function () {
        
    });

    describe('turnOffNext()', function () {
        
    });

    describe('turnOnPrev()', function () {
        
    });

    describe('turnOffPrev()', function () {
        
    });
});