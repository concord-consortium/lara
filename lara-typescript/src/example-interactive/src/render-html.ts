import * as DOMPurify from "dompurify";
import parse from "html-react-parser";

export function renderHTML(html: string) {
  return parse(DOMPurify.sanitize(html || ""));
}
