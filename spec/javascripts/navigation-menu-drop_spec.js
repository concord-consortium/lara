/*jslint browser: true, sloppy: true, todo: true, devel: true */
/*global $, it, describe, xit, xdescribe, expect, beforeEach, loadFixtures, spyOn, MenuControl */

//= require navigation-menu-drop

describe('MenuControl', function () {
    var menu;

    describe('basic menu function', function () {
        beforeEach(function () {
            loadFixtures('navigation-menu.html');
            menu = new MenuControl($('div.nav-menu'));
        });

        it('has a jQuery object attribute "trigger"', function () {
            expect(menu.trigger).toBeDefined();
            expect(menu.trigger).toBe('a#menu-trigger');
        });

        it('has a jQuery object attribute "menu"', function () {
            expect(menu.menu).toBeDefined();
            expect(menu.menu).toBe('div.nav-menu-top');
        });

        it('has a jQuery object attribute "active"', function () {
            expect(menu.active).toBeDefined();
            expect(menu.openActivity).toBeDefined();
        });

        it('calls `toggle()` on the menu when trigger is clicked', function () {
            spyOn(menu.menu, 'toggle');
            menu.trigger.click();
            expect(menu.menu.toggle).toHaveBeenCalled();
        });

        it('is not showing the menu at page load', function () {
            expect(menu.menu.css('display')).toBe('none');
        });

        it('is showing the menu after one click', function () {
            menu.trigger.click();
            expect(menu.menu.css('display')).toBe('block');
        });

        it('hides the menu on the second click', function () {
            menu.trigger.click();
            menu.trigger.click();
            expect(menu.menu.css('display')).toBe('none');
        });
    });

    describe('when the menu has a sequence', function () {
        beforeEach(function () {
            loadFixtures('navigation-menu-sequence.html');
            menu = new MenuControl($('div.nav-menu'));
        });

        it('has an element in the "active" attribute', function () {
            expect(menu.active).toBe('li.activity.active');
            expect(menu.openActivity).toBe('li.activity.on');
        });

        it('calls changeActive when activities are clicked', function () {
            spyOn(menu, 'changeActive');
            $('li.activity').first().find('a.open-close').trigger('click');
            expect(menu.changeActive).toHaveBeenCalled();
        });

        describe('changeActive', function () {
            it('changes the currently active activity', function () {
                var currActive = menu.active;
                menu.changeActive($('.activity a.open-close').parent().parent());
                expect(menu.active).not.toEqual(currActive);
                expect(currActive).not.toBe('li.activity.on');
                expect(menu.active).toBe('li.activity.on');
                expect(menu.active.find('ol li.page')[0]).toBeVisible();
            });
        });
    });

});
