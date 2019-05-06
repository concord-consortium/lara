import { decorateContent } from "./decorate-content";
import * as TextDecorator from "@concord-consortium/text-decorator";

jest.mock("@concord-consortium/text-decorator", () => ({
  decorateDOMClasses: jest.fn()
}));

describe("decorateContent", () => {
  it("should delegate to text-decorator library", () => {
    // jest.spyOn(TextDecorator, "decorateDOMClasses");
    const words = ["test"];
    const replace = "replace";
    const wordClass = "class";
    const listeners = [
      {
        type: "click",
        listener: jest.fn()
      }
    ];
    const domClasses = ["question-txt", "help-content", "intro-txt"];
    const options = {
      words,
      replace
    };
    decorateContent(words, replace, wordClass, listeners);
    expect(TextDecorator.decorateDOMClasses).toHaveBeenCalledWith(domClasses, options, wordClass, listeners);
  });
});
