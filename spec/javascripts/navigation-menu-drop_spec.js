/*jslint browser: true, sloppy: true, todo: true, devel: true */
/*global $, it, describe, xit, xdescribe, expect, beforeEach, loadFixtures, spyOn, MenuControl */

//= require navigation-menu-drop

describe('MenuControl', function () {
    var menu;

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
        expect(menu.menu).toBe('ul.nav-menu-top');
    });

    it('calls `toggle()` on the menu when trigger is clicked', function () {
        // spyon
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
