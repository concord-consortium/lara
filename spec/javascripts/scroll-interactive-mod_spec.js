/*jslint browser: true, sloppy: true, todo: true, devel: true */
/*global $, it, describe, xit, xdescribe, expect, beforeEach, loadFixtures, spyOn, InteractiveModule, ScrollTrack */

//= require waypoints
//= require waypoints-sticky
//= require scroll-interactive-mod

describe('ScrollTrack', function () {
    var scrollTrack;

    beforeEach(function () {
        loadFixtures('interactive-scrolling.html');
        scrollTrack = new ScrollTrack($('.content-mod'), $('#end-scroll-track'));
    });

    it('has attributes', function () {
        expect(scrollTrack.contentModule).toBeDefined();
        expect(scrollTrack.trackEnd).toBeDefined();
        expect(scrollTrack.contentModule).toBe('div.content-mod');
        expect(scrollTrack.trackEnd).toBe('div#end-scroll-track');
    });

    describe('getTop', function () {
        it('returns the offset of the content module', function () {
            expect(scrollTrack.getTop()).toBe($('.content-mod').offset().top);
        });
    });

    describe('getBottom', function () {
        it('returns the offset of the end-scroll-track div', function () {
            expect(scrollTrack.getBottom()).toBe($('#end-scroll-track').offset().top);
        });
    });

    describe('getHeight', function () {
        it('returns the difference between its top and its bottom', function () {
            expect(scrollTrack.getHeight()).toBe($('#end-scroll-track').offset().top - $('.content-mod').offset().top);
        });
    });

    describe('isScrollable', function () {
        describe('when the track is taller than the interactive', function () {
            it('returns true', function () {
                expect(scrollTrack.isScrollable(200)).toBe(true);
            });
        });

        describe('when the track is shorter than the interactive', function () {
            it('returns false', function () {
                expect(scrollTrack.isScrollable(800)).toBe(false);
            });
        });

        describe('when the track is undefined', function () {
            it('returns false', function () {
                scrollTrack.trackEnd = $('#noSuchDiv');
                expect(scrollTrack.isScrollable(200)).toBe(false);
            });
        });
    });
});

describe('InteractiveModule', function () {
    var interactive, scrollTrack;

    beforeEach(function () {
        loadFixtures('interactive-scrolling.html');
        scrollTrack = new ScrollTrack($('.content-mod'), $('#end-scroll-track'));
        interactive = new InteractiveModule($('.pinned'), scrollTrack);
    });

    it('has attributes', function () {
        expect(interactive.bMargin).toBeDefined();
        expect(interactive.topBuffer).toBeDefined();
        expect(interactive.fudgeFactor).toBeDefined();
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

            xit('adds a CSS width', function () {
                expect(interactive.module.css('width')).toBe(interactive.iWidth + 'px');
            });
        });
    });

    describe('unFixTop()', function () {
        beforeEach(function () {
            interactive.module.addClass('stuck');
            interactive.unFixTop();
        });

        it('removes the "stuck" class', function () {
            expect(interactive.module).not.toHaveClass('stuck');
        });
    });

    describe('fixBottom()', function () {
        beforeEach(function () {
            interactive.module.addClass('bottomed');
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
            interactive.module.addClass('stuck');
            interactive.unFixBottom();
        });

        it('removes the "stuck" class', function () {
            expect(interactive.module).not.toHaveClass('stuck');
        });

        it('adds the "bottomed" class', function () {
            expect(interactive.module).toHaveClass('bottomed');
        });
    });

    describe('waypoints control', function () {
        beforeEach(function () {
            interactive.setWaypoints();
        });

        describe('setWaypoints', function () {
            it('sets two waypoints', function () {
                // Actually, it's setting four waypoints, but at two places.
                expect($.waypoints().vertical.length).toBe(2);
            });
        });

        describe('clearWaypoints', function () {
            it('removes established waypoints', function () {
                expect($.waypoints().vertical.length).toBe(4);
                interactive.clearWaypoints();
                expect($.waypoints().vertical.length).toBe(0);
            });
        });

        describe('disableWaypoints', function () {
            // Not clear how to test this
            xit('disables existing waypoints', function () {
                expect($.waypoints().vertical.length).toBe(2);
                interactive.disableWaypoints();
                expect($.waypoints().vertical[0].enabled).toBe(false);
            });
        });

        describe('enableWaypoints', function () {
            // Not clear how to test this
            xit('enables disabled waypoints', function () {
                expect($.waypoints().vertical.length).toBe(4);
                interactive.enableWaypoints();
                expect($.waypoints().vertical[0].enabled).toBe(true);
            });
        });
    });

    describe('getHeight()', function () {
        it('returns the height of the box', function () {
            expect(interactive.getHeight()).toBe(interactive.module.height());
        });
    });
});
