import * as React from "react";
import { render, screen } from "@testing-library/react";
import { CustomizeManagedInteractive } from "./customize";
import { IManagedInteractive } from "./index";
import { ILibraryInteractive } from "../common/hooks/use-library-interactives";

const renderCustomize = (libraryInteractive: Partial<ILibraryInteractive>) => render(
  <CustomizeManagedInteractive
    defaultClickToPlayPrompt="Click to play"
    managedInteractive={{
      linked_interactives: [],
      question_gating: "disable_following_on_page"
    } as Partial<IManagedInteractive> as IManagedInteractive}
    libraryInteractive={
      { name: "Library", aspect_ratio_method: "DEFAULT", ...libraryInteractive } as ILibraryInteractive
    }
  />
);

const gatingSelect = () => screen.queryByLabelText("Locked until this interactive unlocks them");

describe("CustomizeManagedInteractive question gating", () => {
  [true, false].forEach(customizable => {
    describe(`for a ${customizable ? "customizable" : "non-customizable"} library interactive`, () => {
      it("shows the setting with its saved value when the library interactive enables learner state", () => {
        renderCustomize({ customizable, enable_learner_state: true });
        expect((gatingSelect() as HTMLSelectElement).value).toBe("disable_following_on_page");
      });

      it("hides the setting when the library interactive does not enable learner state", () => {
        renderCustomize({ customizable, enable_learner_state: false });
        expect(gatingSelect()).toBeNull();
      });
    });
  });
});
