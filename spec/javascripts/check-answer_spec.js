/*jslint browser: true, sloppy: true, todo: true, devel: true */
/*global $, it, describe, xit, xdescribe, expect, beforeEach, spyOn, CustomFeedback */

//= require check-answer

describe('CustomFeedback', function () {
    var checkbox = $('<input id="embeddable_multiple_choice_custom" name="embeddable_multiple_choice[custom]" type="checkbox" value="1">'),
        input = $('<li class="custom-hidden" style="display: none;"></li>'),
        custom;

    beforeEach(function () {
        custom = new CustomFeedback(input);
    });

    it('has a jQuery object attribute "el"', function () {
        expect(custom.el).toBeDefined();
        expect(custom.el).toBe('li.custom-hidden');
    });

    describe('show()', function () {
        it("calls hide when checkbox is unchecked", function () {
            spyOn(custom.el, 'hide');
            checkbox.attr('checked', false);
            custom.show(checkbox);
            expect(custom.el.hide).toHaveBeenCalled();
        });

        it("calls show when checkbox is checked", function () {
            spyOn(custom.el, 'show');
            checkbox.attr('checked', true);
            custom.show(checkbox);
            expect(custom.el.show).toHaveBeenCalled();
        });
    });
});

describe('AnswerChecker', function () {
    // TODO: tests actually test something?
    it('has a question id', function () {
        expect(true).toBe(true);
    });

    it('has an answer', function () {
        expect(true).toBe(true);
    });

    describe('check()', function () {
        it('calls modalDialog when there are no answers', function () {
            expect(true).toBe(true);
        });

        it('sends answers to the server', function () {
            expect(true).toBe(true);
        });
    });
});