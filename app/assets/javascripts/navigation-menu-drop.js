/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $ */

var navMenu;

var MenuControl = function (object) {
    this.trigger = object.find('a#menu-trigger');
    this.menu = object.find('div.nav-menu-top');
    var menu = this.menu,
        self = this;
    // Add click handler to the trigger object, to open and close the menu
    this.trigger.click(function () {
        menu.toggle();
    });
    // Which menu element is active?
    this.active = this.menu.find('.active');
    // Add click handlers to links to change active activity
    this.menu.find('li.activity>a').each( function () {
        $(this).on('click', function () {
            self.changeActive($(this).parent());
        });
    });
};

MenuControl.prototype.changeActive = function (element) {
    // Show the new menu
    element.addClass('active');
    // Fix its caret
    element.find('i.icon-angle-up').addClass('icon-angle-down').removeClass('icon-angle-up');
    // Fix the old activity's caret
    this.active.find('i.icon-angle-down').addClass('icon-angle-up').removeClass('icon-angle-down');
    // Close the old activity
    this.active.removeClass('active');
    // Re-set current-active
    this.active = element;
};

$(document).ready(function () {
    navMenu = new MenuControl($('div.nav-menu'));
});