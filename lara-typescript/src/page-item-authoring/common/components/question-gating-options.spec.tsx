import * as React from "react";
import { fireEvent, render, screen } from "@testing-library/react";
import { QuestionGatingOptions } from "./question-gating-options";

const renderInForm = (props: React.ComponentProps<typeof QuestionGatingOptions>) => {
  render(<form data-testid="form"><QuestionGatingOptions {...props} /></form>);
  return screen.getByTestId("form") as HTMLFormElement;
};

const submitted = (form: HTMLFormElement) => {
  const entries: Record<string, string> = {};
  new FormData(form).forEach((value, key) => { entries[key] = value as string; });
  return entries;
};

const getSelect = () => screen.getByLabelText("Locked until this interactive unlocks them") as HTMLSelectElement;

describe("QuestionGatingOptions", () => {
  it("shows None for a null setting and submits only question_gating", () => {
    const form = renderInForm({ questionGating: null, lockedText: "Locked", unlockedText: "Unlocked" });
    expect(getSelect().value).toBe("none");
    expect(screen.queryByLabelText("Locked banner text")).toBeNull();
    expect(screen.queryByLabelText("Unlocked banner text")).toBeNull();
    expect(submitted(form)).toEqual({ question_gating: "none" });
  });

  it("lists the options in order", () => {
    renderInForm({});
    const options = Array.from(getSelect().options).map(o => [o.value, o.textContent]);
    expect(options).toEqual([
      ["none", "None"],
      ["disable_following_on_page", "All questions after this on the page"],
      ["disable_following_in_section", "Only questions after this in this section"]
    ]);
  });

  ["disable_following_on_page", "disable_following_in_section"].forEach(value => {
    it(`shows the prefilled banner texts and submits them for ${value}`, () => {
      const form = renderInForm({ questionGating: "none", lockedText: "Locked", unlockedText: "Unlocked" });
      fireEvent.change(getSelect(), { target: { value } });
      expect((screen.getByLabelText("Locked banner text") as HTMLInputElement).value).toBe("Locked");
      expect((screen.getByLabelText("Unlocked banner text") as HTMLInputElement).value).toBe("Unlocked");
      expect(submitted(form)).toEqual({
        question_gating: value,
        question_gating_locked_text: "Locked",
        question_gating_unlocked_text: "Unlocked"
      });

      fireEvent.change(getSelect(), { target: { value: "none" } });
      expect(submitted(form)).toEqual({ question_gating: "none" });
    });
  });

  it("ties the notes to their controls", () => {
    renderInForm({ questionGating: "disable_following_on_page" });
    expect(getSelect().getAttribute("aria-describedby")).toBe("question_gating_note");
    expect(document.getElementById("question_gating_note")?.textContent).toContain("other column");
    ["Locked banner text", "Unlocked banner text"].forEach(label => {
      expect(screen.getByLabelText(label).getAttribute("aria-describedby")).toBe("question_gating_text_note");
    });
    expect(document.getElementById("question_gating_text_note")?.textContent).toContain("default");
  });
});
