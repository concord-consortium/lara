/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $ */

var MenuControl = function (object) {
    this.trigger = object.find('a#menu-trigger');
    this.menu = object.find('ul.nav-menu-top');
    var menu = this.menu;
    this.trigger.click(function () {
        menu.toggle();
    });
};

MenuControl.prototype.open = function () {
    this.menu.toggle();
};

MenuControl.prototype.close = function () {
    this.menu.toggle();
};

$(document).ready(function () {
    var navMenu = new MenuControl($('div.nav-menu'));
});