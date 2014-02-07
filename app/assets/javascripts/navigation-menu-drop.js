/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $ */

var navMenu;

var MenuControl = function (object) {
    this.trigger = object.find('a#menu-trigger');
    this.menu = object.find('div.nav-menu-top');
    // Which menu element is active?
    this.active = this.menu.find('.active');
    // Which element is open?
    this.openActivity = this.menu.find('.on');
    var menu = this.menu,
        self = this;
    // Add click handler to the trigger object, to open and close the menu
    this.trigger.click(function () {
        menu.toggle();
    });
    // Add click handlers to links to change active activity
    this.menu.find('li.activity a.open-close').each( function () {
        $(this).on('click', function () {
            self.changeActive($(this).parent().parent());
        });
    });
};

MenuControl.prototype.changeActive = function (element) {
    // Show the new menu
    element.addClass('on');
    // Fix its caret
    element.find('fa fa-angle-up').addClass('fa-angle-down').removeClass('fa-angle-up');
    // Fix the old activity's caret
    this.active.find('fa fa-angle-down').addClass('fa-angle-up').removeClass('fa-angle-down');
    // Close the old activity
    this.active.removeClass('on');
    // Re-set current-active
    this.active = element;
};

$(document).ready(function () {
    navMenu = new MenuControl($('div.nav-menu'));
});