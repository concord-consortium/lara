import * as React from "react";
import { fireEvent, render, screen } from "@testing-library/react";
import { CustomizeMWInteractive } from "./customize";
import { IMWInteractive } from "./index";

const renderCustomize = (interactive: Partial<IMWInteractive>) => render(
  <CustomizeMWInteractive
    defaultClickToPlayPrompt="Click to play"
    enableLearnerStateRef={React.createRef()}
    interactive={{ linked_interactives: [], ...interactive } as IMWInteractive}
  />
);

const gatingSelect = () => screen.queryByLabelText("Locked until this interactive unlocks them");

describe("CustomizeMWInteractive question gating", () => {
  it("shows the setting with its saved value while save state is enabled", () => {
    renderCustomize({ enable_learner_state: true, question_gating: "disable_following_in_section" });
    expect((gatingSelect() as HTMLSelectElement).value).toBe("disable_following_in_section");
  });

  it("shows and hides the setting with the Enable save state checkbox", () => {
    renderCustomize({ enable_learner_state: false });
    expect(gatingSelect()).toBeNull();

    fireEvent.click(screen.getByLabelText("Enable save state"));
    expect(gatingSelect()).not.toBeNull();

    fireEvent.click(screen.getByLabelText("Enable save state"));
    expect(gatingSelect()).toBeNull();
  });
});
