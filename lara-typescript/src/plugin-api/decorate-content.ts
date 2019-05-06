import * as TextDecorator from "@concord-consortium/text-decorator";

export interface IEventListener {
  type: string;
  listener: (evt: Event) => void;
}

export type IEventListeners = IEventListener | IEventListener[];

/****************************************************************************
 Ask LARA to decorate authored content (text / html).

 @param words A list of case-insensitive words to be decorated. Can use limited regex.
 @param replace The replacement string. Can include '$1' representing the matched word.
 @param wordClass CSS class used in replacement string. Necessary only if `listeners` are provided too.
 @param listeners One or more { type, listener } tuples. Note that events are added to `wordClass`
 described above. It's client code responsibility to use this class in the `replace` string.
 ****************************************************************************/
export const decorateContent = (words: string[], replace: string, wordClass: string, listeners: IEventListeners) => {
  const domClasses = ["question-txt", "help-content", "intro-txt"];
  const options = {
    words,
    replace
  };
  TextDecorator.decorateDOMClasses(domClasses, options, wordClass, listeners);
};
