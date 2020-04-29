import { App } from "./app";
import { renderApp } from "./render-app";

export {
  App
};

(window as any).LARA.InteractiveLibraryAdmin = {
  render: renderApp
};
