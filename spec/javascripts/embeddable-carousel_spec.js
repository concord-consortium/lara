/*jslint browser: true, sloppy: true, todo: true, devel: true */
/*global $, it, describe, xit, xdescribe, expect, beforeEach, spyOn, loadFixtures, EmbeddableCarousel */

//= require embeddable-carousel

describe('EmbeddableCarousel', function () {
    var carousel;

    // TODO: This may call for fixtures for defining the carousel and controls.
    beforeEach(function () {
        loadFixtures('embeddable-carousel.html');
        carousel = new EmbeddableCarousel($('.jcarousel'));
    });

    // Attributes
    it('has a container', function () {
        expect(carousel.container).toBeDefined();
        expect(carousel.container).toHaveClass('jcarousel');
    });

    it('has controls', function () {
        expect(carousel.controlNext).toHaveClass('jcarousel-next');
        expect(carousel.controlPrev).toHaveClass('jcarousel-prev');
    });

    it('sets "next" active to begin with', function () {
        expect(carousel.controlNext).not.toHaveAttr('disabled');
    });

    it('leaves "previous" disabled', function () {
        expect(carousel.controlPrev).toHaveAttr('disabled');
    });

    // Event handlers?
    describe('event handlers', function () {
        it('updates controls on animateend.jcarousel', function () {
            spyOn(carousel, 'updateControls');
            var e = $.Event('animateend.jcarousel');
            carousel.container.trigger(e);
            expect(carousel.updateControls).toHaveBeenCalled();
        });
    });

    // Methods
    describe('setHeight()', function () {
        it('adjusts the height of the container', function () {
            carousel.setHeight('550px');
            expect(carousel.container).toHaveCss({height: '550px'});
        });
    });

    describe('setWidth()', function () {
        it('adjusts the width of the container', function () {
            carousel.setWidth('338px');
            expect(carousel.container).toHaveCss({width: '338px'});
        });
    });

    describe('updateControls()', function () {
        describe('when target is first in the list', function () {
            beforeEach(function () {
                carousel.jcarousel('scroll', 0);
                carousel.updateControls();
            });

            it('turns on "next" and leaves "previous" disabled', function () {
                expect(carousel.controlNext).not.toHaveAttr('disabled');
                expect(carousel.controlPrev).toHaveAttr('disabled');
            });
        });

        describe('when target is in the middle of the list', function () {
            beforeEach(function () {
                carousel.jcarousel('scroll', 1);
                carousel.updateControls();
            });

            it('turns on both controls', function () {
                expect(carousel.controlNext).not.toHaveAttr('disabled');
                expect(carousel.controlPrev).not.toHaveAttr('disabled');
            });
        });

        describe('when target is at the end of the list', function () {
            beforeEach(function () {
                carousel.jcarousel('scroll', -1);
                carousel.updateControls();
            });

            it('turns on "previous" and leaves "next" disabled', function () {
                expect(carousel.controlNext).toHaveAttr('disabled');
                expect(carousel.controlPrev).not.toHaveAttr('disabled');
            });
        });
    });

    describe('turnOnNext()', function () {
        carousel.turnOnNext();
        expect(carousel.controlNext).not.toHaveAttr('disabled');
    });

    describe('turnOffNext()', function () {
        carousel.turnOffNext();
        expect(carousel.controlNext).toHaveAttr('disabled');
    });

    describe('turnOnPrev()', function () {
        carousel.turnOnPrev();
        expect(carousel.controlPrev).not.toHaveAttr('disabled');
    });

    describe('turnOffPrev()', function () {
        carousel.turnOffPrev();
        expect(carousel.controlPrev).toHaveAttr('disabled');
    });
});
