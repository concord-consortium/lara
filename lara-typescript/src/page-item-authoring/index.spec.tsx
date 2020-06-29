import * as PageItemAuthoring from "./index";
import * as React from "react";
import * as ReactDOMServer from "react-dom/server";

describe("Page Item Authoring", () => {
  it("should export all the needed functions", () => {
    expect(PageItemAuthoring.ManagedInteractiveAuthoring).toBeDefined();
    expect(PageItemAuthoring.renderManagedInteractiveAuthoring).toBeDefined();

    expect(PageItemAuthoring.MWInteractiveAuthoring).toBeDefined();
    expect(PageItemAuthoring.renderMWInteractiveAuthoring).toBeDefined();

    expect(PageItemAuthoring.InteractiveAuthoringPreview).toBeDefined();
    expect(PageItemAuthoring.renderInteractiveAuthoringPreview).toBeDefined();
  });
});

describe("ReactDOMServer", () => {
  it("should be available", () => {
    expect(ReactDOMServer.renderToStaticMarkup(<p>Some Text</p>)).toBe("<p>Some Text</p>");
  });
});
