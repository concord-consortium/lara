/*jslint browser: true, sloppy: true, todo: true, devel: true */
/*global $, it, describe, xit, xdescribe, expect, beforeEach, spyOn, loadFixtures, EmbeddableCarousel */

//= require jquery.jcarousel
//= require jquery.jcarousel-control
//= require embeddable-carousel

describe('EmbeddableCarousel', function () {
    var carousel;

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
        expect(carousel.controlNext.find('.button')).not.toHaveAttr('disabled');
    });

    it('leaves "previous" disabled', function () {
        expect(carousel.controlPrev.find('.button')).toHaveAttr('disabled');
    });

    // Event handlers?
    describe('event handlers', function () {
        var e;
        beforeEach(function () {
            e = $.Event('animateend.jcarousel');
        });

        it('updates controls on animateend.jcarousel', function () {
            spyOn(carousel, 'updateControls');
            carousel.container.trigger(e);
            expect(carousel.updateControls).toHaveBeenCalled();
        });

        xit('sets buttons properly', function () {
            carousel.container.jcarousel('scroll', 0);
            carousel.container.trigger(e);
            expect(carousel.controlNext.find('.button')).not.toHaveAttr('disabled');
            expect(carousel.controlPrev.find('.button')).toHaveAttr('disabled');

            carousel.container.jcarousel('scroll', 1);
            carousel.container.trigger(e);
            expect(carousel.controlNext.find('.button')).not.toHaveAttr('disabled');
            expect(carousel.controlPrev.find('.button')).not.toHaveAttr('disabled');

            carousel.container.jcarousel('scroll', -1);
            carousel.container.trigger(e);
            expect(carousel.controlNext.find('.button')).toHaveAttr('disabled');
            expect(carousel.controlPrev.find('.button')).not.toHaveAttr('disabled');
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

    describe('turnOnNext()', function () {
        it('removes the disabled attribute', function () {
            carousel.turnOnNext();
            expect(carousel.controlNext.find('.button')).not.toHaveAttr('disabled');
        });
    });

    describe('turnOffNext()', function () {
        it('adds the disabled attribute', function () {
            carousel.turnOffNext();
            expect(carousel.controlNext.find('.button')).toHaveAttr('disabled');
        });
    });

    describe('turnOnPrev()', function () {
        it('removes the disabled attribute', function () {
            carousel.turnOnPrev();
            expect(carousel.controlPrev.find('.button')).not.toHaveAttr('disabled');
        });
    });

    describe('turnOffPrev()', function () {
        it('adds the disabled attribute', function () {
            carousel.turnOnPrev();
            carousel.turnOffPrev();
            expect(carousel.controlPrev.find('.button')).toHaveAttr('disabled');
        });
    });
});
