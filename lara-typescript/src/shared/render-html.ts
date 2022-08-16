import * as DOMPurify from "dompurify";
import parse from "html-react-parser";

export function renderHTML(html: string) {
  return parse(DOMPurify.sanitize(html || "", {ADD_TAGS: ["iframe"], ADD_ATTR: ["allowfullscreen", "frameborder", "scrolling", "target"]}));
}
