/*jslint browser: true, sloppy: true, todo: true, devel: true */
/*global $, it, describe, xit, xdescribe, expect, beforeEach, spyOn, InteractiveModule */

//= require scroll-interactive-mod

describe('InteractiveModule', function () {
    var interactive,
        interactive_mod = $('<div class="pinned"></div>');

    beforeEach(function () {
        interactive = new InteractiveModule(interactive_mod);
    });

    it('has attributes i_height, i_width, and module', function () {
        expect(interactive.i_height).toBeDefined();
        expect(interactive.i_width).toBeDefined();
        expect(interactive.module).toBe('div.pinned');
    });

    describe('fixTop()', function () {
        beforeEach(function () {
            interactive.fixTop();
        });

        it('adds the "stuck" class', function () {
            expect(interactive.module).toHaveClass('stuck');
        });

        it('adds a CSS width', function () {
            expect(interactive.module.css('width')).toBe(interactive.i_width + 'px');
        });
    });

    describe('unFixTop()', function () {
        beforeEach(function () {
            interactive.unFixTop();
        });

        it('removes the "stuck" class', function () {
            expect(interactive.module).not.toHaveClass('stuck');
        });
    });

    describe('fixBottom()', function () {
        beforeEach(function () {
            interactive.fixBottom();
        });
        
        it('adds the "stuck" class', function () {
            expect(interactive.module).toHaveClass('stuck');
        });

        it('removes the "bottomed" class', function () {
            expect(interactive.module).not.toHaveClass('bottomed');
        });
    });

    describe('unFixBottom()', function () {
        beforeEach(function () {
            interactive.unFixBottom();
        });

        it('removes the "stuck" class', function () {
            expect(interactive.module).not.toHaveClass('stuck');
        });

        it('adds the "bottomed" class', function () {
            expect(interactive.module).toHaveClass('bottomed');
        });
    });

    describe('getHeight()', function () {
        it('returns the value of the i_height attribute', function () {
            expect(interactive.getHeight()).toBe(interactive.i_height);
        });
    });
});
