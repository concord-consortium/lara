/*jslint browser: true, sloppy: true, todo: true, devel: true */
/*global $, it, describe, xit, xdescribe, expect, beforeEach, spyOn, loadFixtures, InteractiveObject */

//= require interactive-sizing

describe('InteractiveObject', function () {
    var interactive;

    describe('when the interactive is a video', function () {
        beforeEach(function () {
            loadFixtures('interactive-sizing-video.html');
            interactive = new InteractiveObject($('video[data-aspect-ratio]'));
        });

        // Attributes
        it('has defined attributes', function () {
            expect(interactive.element).toBe('video');
            expect(interactive.aspectRatio).toBeDefined();
            expect(interactive.currWidth).toBeDefined();
            expect(interactive.targetHeight).toBeDefined();
        });

        describe('fixSize()', function () {
            beforeEach(function () {
                interactive.fixSize();
            });

            it('has height matching targetHeight', function () {
                expect(interactive.element).toHaveAttr('height', interactive.targetHeight);
            });

            it('has width matching currWidth', function () {
                expect(interactive.element).toHaveAttr('width', interactive.currWidth);
            });
        });
    });

    describe('when the interactive is an iframe', function () {
        // NOTE: PhantomJS 1.8.1 didn't like this fixture. PhantomJS 1.9.0 worked. If this 
        // set of specs breaks, try upgrading PhantomJS.
        beforeEach(function () {
            loadFixtures('interactive-sizing-iframe.html');
            interactive = new InteractiveObject($('iframe[data-aspect-ratio]'));
        });

        // Attributes
        it('has defined attributes', function () {
            expect(interactive.element).toBe('iframe');
            expect(interactive.aspectRatio).toBeDefined();
            expect(interactive.currWidth).toBeDefined();
            expect(interactive.targetHeight).toBeDefined();
        });

        describe('fixSize()', function () {
            beforeEach(function () {
                interactive.fixSize();
            });

            it('has height matching targetHeight', function () {
                expect(interactive.element).toHaveAttr('height', interactive.targetHeight);
            });

            it('has width matching currWidth', function () {
                expect(interactive.element).toHaveAttr('width', interactive.currWidth);
            });
        });
    });
});