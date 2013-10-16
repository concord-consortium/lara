/*jslint browser: true, sloppy: true, todo: true, devel: true */
/*global $, it, describe, xit, xdescribe, expect, beforeEach, loadFixtures, spyOn, InteractiveModule */

//= require scroll-interactive-mod

describe('InteractiveModule', function () {
    var interactive;

    beforeEach(function () {
        loadFixtures('interactive-scrolling.html');
        interactive = new InteractiveModule($('.pinned'));
    });

    it('has attributes', function () {
        expect(interactive.iHeight).toBeDefined();
        expect(interactive.iWidth).toBeDefined();
        expect(interactive.bMargin).toBeDefined();
        expect(interactive.fudgeFactor).toBeDefined();
        expect(interactive.trackHeight).toBeDefined();
        expect(interactive.module).toBe('div.pinned');
    });

    describe('fixTop()', function () {
        describe('when the interactive is taller than its column', function () {
            beforeEach(function () {
                interactive.trackHeight = 300;
                interactive.iHeight = 600;
                interactive.fixTop();
            });

            it('does nothing', function () {
                expect(interactive.module).not.toHaveClass('stuck');
            });
        });

        describe('when the interactive is shorter than its column', function () {
            beforeEach(function () {
                interactive.fixTop();
            });

            it('adds the "stuck" class', function () {
                expect(interactive.module).toHaveClass('stuck');
            });

            it('adds a CSS width', function () {
                expect(interactive.module.css('width')).toBe(interactive.iWidth + 'px');
            });
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
            expect(interactive.getHeight()).toBe(interactive.iHeight);
        });
    });
});
